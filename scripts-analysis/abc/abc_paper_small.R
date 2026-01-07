outdir <- commandArgs(trailingOnly = TRUE)[1]#folder where  output of ABC will be written
experiment <- commandArgs(trailingOnly = TRUE)[2]#folder where the concatenated_files.csv are stored 


source("R/model-core.R")
source("R/model-slots.R")
source("R/abcrfa.R")
source("R/metrics.R")
set.seed(1234)

ns=50000 #number of simulatoin to be run for the ABC
tol=.01 # percentage of selected simulation infirst stage of ABC
m=10
tstep=100
N=100
p0=rep(N/m,m)
u0="rnorm"
mu=.1

loadsimu=TRUE
prior_file <- file.path(here::here(), outdir, "prior.RDS")

if(!loadsimu){
    tmpdir <- outdir
    n=0
    while(dir.exists(file.path(here::here(),tmpdir))){
        n <- n+1
        tmpdir <- paste0(outdir,"_",n)
    }
    outdir <- tmpdir
   dir.create(file.path(here::here(),outdir))
   e=rep(1,ns)
   Js=runif(ns,0,2) 
   betas=runif(ns,0,2) 
   prior <- list(J=Js,beta=betas,e=e)
   prior_file <- file.path(here::here(), outdir, "prior.RDS")
   saveRDS(prior, prior_file)
}


# Load prior from file if loadsimu is TRUE
if (loadsimu) {
    if (file.exists(prior_file)) {
        loaded_prior <- readRDS(prior_file)
        message("Loaded prior from file.")
        
        # Check if the loaded prior needs more entries to match 'NS'
        if (length(loaded_prior$J) < ns) {
            missing_count <- ns - length(loaded_prior$J)
            message(sprintf("Loaded prior has %d fewer entries. Generating additional %d values.", missing_count, missing_count))
            
            # Generate additional missing values
            additional_Js <- runif(missing_count, 0, 2)
            additional_betas <- runif(missing_count, 0, 2)
            additional_e <- runif(missing_count, 1, 2)

            # Append to the loaded prior
            loaded_prior$J <- c(loaded_prior$J, additional_Js)
            loaded_prior$beta <- c(loaded_prior$beta, additional_betas)
            
            # Save the augmented prior back to file
            saveRDS(loaded_prior, prior_file)
            message("Augmented prior saved.")
        }
        e <- loaded_prior$e
        Js <- loaded_prior$J
        betas <- loaded_prior$beta
        
        # Set prior to loaded prior
        prior <- loaded_prior
    } else {
        stop("Prior file not found and 'loadsimu' is TRUE.")
    }
}


metrics <- c(d.sim, d.gap , d.turn, d.min,d.max,d.mean,d.median, d.unique)
names(metrics) <- c("d.sim"," d.gap "," d.turn"," d.min","d.max","d.mean","d.median","d.unique")
metrics  <-  metrics[-c(4:7)]
#for all metrics we mesure the distance to all original scenario
mtr=names(metrics);names(mtr)=mtr
library(parallel)

burnin=1:2 #discard two first steps which are artificially prepared
models  <-  c("GPT3.5","GPT4","O3MINI","Mistral-7B-Instruct-v0.3")[c(1,4)]

file_results  <- list("Mutate statements"="mut","Generate new statements"="gennew")
list_alladjustments <- list()
for(mv in models){
    for( ge in names(file_results)){
       expfilenames <- file.path(here::here(),experiment,paste(mv,file_results[[ge]],"concatenated_files.csv",sep = "_"))
       print(expfilenames)
       allexp <- read.csv(expfilenames)
       expnames <- unique(allexp[,c("Mutation","Selection")])
       exnames <- apply(expnames,1,function(e)paste0(e,collapse="_"))
       allexp <- lapply(1:nrow(expnames),function(e){
          subex <- allexp[allexp$Mutation == expnames[e,"Mutation"] & allexp$Selection == expnames[e,"Selection"],] 
          subex <- unname(reshape(subex[,3:5], idvar = "ID", timevar = "Step", direction = "wide")[,-1])
          subex[is.na(subex)] <- 0
          return(subex[,-burnin])
       })
       names(allexp) <- exnames
       mdl=names(allexp);names(mdl)=mdl

       strat=paste (mv,ge)
       cat(paste0("Running ABCRFA inference for: \n ",strat," strategy, using ",length(metrics)," metrics (",paste0(names(metrics),collapse=","),") ========\n"))
       allmetricsallex <- lapply(allexp,function(exp)lapply(metrics,function(f)f(exp)))
    
       cl <- makeCluster(10,"FORK",outfile=file.path(here::here(),outdir,paste0(gsub(" ","_",tolower(strat)), "_log_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".log")))
       alldismulti <- parLapply(cl,1:ns,function(i) {
           tryCatch(
           {
               #if(i%%5==0)print(i)
               if(loadsimu && file.exists(here::here(outdir,paste0(i,"_full.RDS")))){
                   simumetrics=readRDS(file=file.path(here::here(),outdir,paste0(i,"_simumetrics.RDS")))
                   #print("read backup")
               }
               else{

                   res=model.slot(p0=p0,J=Js[i],u0=u0,beta=betas[i],sde=1,tstep=tstep,mu=mu,N=N,m=m,mutate=T,log=F,K=50,useslots=T)$freq[,-burnin]
               #for all 'data'(our fake scenario), were subsample the simulaiton to match the shape of the modl
                   simumetrics=lapply(metrics,function(met)tryCatch(met(res),error=function(i)NA))
                   saveRDS(file=file.path(here::here(),outdir,paste0(i,"_full.RDS")),res)
                   saveRDS(file=file.path(here::here(),outdir,paste0(i,"_simumetrics.RDS")),simumetrics)
               }
               distances=lapply(mdl,function(m)sapply(mtr,function(d)RMSE(simumetrics[[d]],allmetricsallex[[m]][[d]])))
               rm(simumetrics)
               gc(reset=T,verbose=F)
               return(distances)
           },error=function(i){
               return(paste0("problem with this",i))
           })
       })
       stopCluster(cl)
       outsim_file <- file.path(here::here(),outdir,paste0(gsub(" ","_",tolower(strat)), "_result_abc_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".RDS"))
       cat(paste0("saving All simulations distance  in: ",outsim_file),"\n")
       saveRDS(file=outsim_file,alldismulti)

       success <- sapply(alldismulti,length)==length(mdl)
       allresults <- alldismulti[success] #removing simulation that fail on on model
       allresults  <-  lapply(mdl,function(m)t(sapply(allresults,"[[",m)))
       prior.cl <- lapply(prior,'[',1:ns)  #limit simulation to look at
       prior.cl <- lapply(prior.cl,'[',success) #rimove simu that failed
       params=do.call("cbind",prior.cl)
       rm(alldismulti)

       #we read how many column we colect, column should be the name of the metric used
       exclfunc=c()#c("d.lognormsd"",""d.lognormmean")#,"d.gini")
       disfunc=colnames(allresults[[1]])
       names(disfunc)=disfunc
       disfunc=disfunc[!(names(disfunc) %in% exclfunc)]
       #create perfect distance metrics table
       obs=as.data.frame(t(sapply(disfunc,function(i)0)))

       ##we also need to remove any simulation with NAs
       excluded=unique(unlist(lapply(allresults,function(data)apply(data,2,function(simumetrics)which(any(is.na(simumetrics)))))))
       cleaned=allresults
       if(length(excluded)>0){
           params=params[-excluded,]
           cleaned=lapply(cleaned,function(data)data[-excluded,])
       }
       rm(allresults)
    
       ##run adjustment
       alladjustment=lapply(cleaned,function(modelresult){
           artif=modelresult[,disfunc]
           model.rfa <- abcrfa(obs, param = params[,-3], sumstat = artif , tol = tol)
           cor=model.rfa$adj.values[,2]>0 & model.rfa$adj.values[,1]>0
           model.rfa$adj.values=apply(model.rfa$adj.values,2,function(i)i[cor])
           model.rfa
       })
       names(alladjustment)=names(cleaned)
       allmodes=lapply(alladjustment,function(adj){ apply(adj$adj.values,2,function(i)hdrcde::hdr(i)$mode) })

       list_alladjustments[[gsub(" ","_",tolower(strat))]] <- list(alladjustment=alladjustment,allmodes=allmodes)#,alldismult=alldismulti)
    }
}
outfile <- file.path(here::here(),outdir,"list_allposteriors.RDS")
cat(paste0("saving all output in: ",outfile),"\n")
saveRDS(file=outfile,list_alladjustments)
    



