expdir <- "test"

source("R/model-core.R")
source("R/abcrfa.R")
source("R/metrics.R")
tmpdir <- expdir
n=0
while(dir.exists(tmpdir)){
    n <- n+1
    tmpdir <- paste0(expdir,"_",n)
}
expdir <- tmpdir
dir.create(expdir)

set.seed(1234)
m=10
tstep=100
N=100
p0=rep(N/m,m)
u0="rnorm"
mu=.1

ns=5000
Js=runif(ns,0,1.5) 
betas=runif(ns,0,1.5) 
prior <- list(J=Js,beta=betas)

metrics <- c(d.sim, d.gap , d.turn, d.min,d.max,d.mean,d.median, d.unique)
names(metrics) <- c("d.sim"," d.gap "," d.turn"," d.min","d.max","d.mean","d.median","d.unique")
metrics  <-  metrics[-c(4:7)]
#for all metrics we mesure the distance to all original scenario
mtr=names(metrics);names(mtr)=mtr
library(parallel)

models  <-  c("GPT3.5")
file_results  <- list("Mutate statements"="mut","Generate new statements"="gennew")
list_alladjustments <- list()
for(mv in models){
    for( ge in names(file_results)){
       expfilenames <- file.path(here::here(),"data",paste(mv,file_results[[ge]],"concatenated_files.csv",sep = "_"))
       allexp <- read.csv(expfilenames)
       expnames <- unique(allexp[,c("Mutation","Selection")])
       exnames <- apply(expnames,1,function(e)paste0(e,collapse="_"))
       allexp <- lapply(1:nrow(expnames),function(e){
          subex <- allexp[allexp$Mutation == expnames[e,"Mutation"] & allexp$Selection == expnames[e,"Selection"],] 
          subex <- unname(reshape(subex[,3:5], idvar = "ID", timevar = "Step", direction = "wide")[,-1])
          subex[is.na(subex)] <- 0
          return(subex)
       })
       names(allexp) <- exnames
       mdl=names(allexp);names(mdl)=mdl

       strat=paste (mv,ge)
       cat(paste0("Running ABCRFA inference for: \n ",strat," strategy, using ",length(metrics)," metrics (",paste0(names(metrics),collapse=","),") ========\n"))
       allmetricsallex <- lapply(allexp,function(exp)lapply(metrics,function(f)f(exp)))
    
       cl <- makeCluster(20,"FORK",outfile=file.path("test",paste0(gsub(" ","_",tolower(strat)), "_log_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".log")))
       alldismulti <- parLapply(cl,1:ns,function(i) {
           tryCatch(
           {
               if(i%%5==0)print(i)
               res=model(p0=p0,J=Js[i],u0=u0,beta=betas[i],sde=1,tstep=tstep,mu=mu,N=N,m=m,mutate=T,log=F)$freq
               #for all 'data'(our fake scenario), were subsample the simulaiton to match the shape of the modl
               simumetrics=lapply(metrics,function(met)tryCatch(met(res),error=function(i)NA))
               ##  up is a trick to automatically names outcome of lapply.
               distances=lapply(mdl,function(m)sapply(mtr,function(d)RMSE(simumetrics[[d]],allmetricsallex[[m]][[d]])))
               rm(simumetrics)
               gc()
               return(distances)
           },error=function(i){
               return(paste0("problem with this",i))
           })
       })
       stopCluster(cl)
       saveRDS(file=file.path(expdir,paste0(gsub(" ","_",tolower(strat)), "_result_abc_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".RDS")),alldismulti)

       success <- sapply(alldismulti,length)==length(mdl)
       allresults <- alldismulti[success] #removing simulation that fail on on model
       allresults  <-  lapply(mdl,function(m)t(sapply(allresults,"[[",m)))
       prior.cl <- lapply(prior,'[',1:ns)  #limit simulation to look at
       prior.cl <- lapply(prior.cl,'[',success) #rimove simu that failed
       params=do.call("cbind",prior.cl)

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
    
       ##run adjustment
       alladjustment=lapply(cleaned,function(modelresult){
           artif=modelresult[,disfunc]
           model.rfa <- abcrfa(obs, param = params, sumstat = artif , tol = .02)
           cor=model.rfa$adj.values[,2]>0 & model.rfa$adj.values[,1]>0
           model.rfa$adj.values=apply(model.rfa$adj.values,2,function(i)i[cor])
           model.rfa
       })
       names(alladjustment)=names(cleaned)
       allmodes=lapply(alladjustment,function(adj){ apply(adj$adj.values,2,function(i)hdrcde::hdr(i)$mode) })

       list_alladjustments[[gsub(" ","_",tolower(strat))]] <- list(alladjustment=alladjustment,allmodes=allmodes,alldismult=alldismulti)
    }
}
    


par(mfrow=c(1,2),cex=2)
mv="GPT3.5"
for( ge in names(file_results)){
   strat <- paste(mv,ge)
   tmp <- list_alladjustments[[gsub(" ","_",tolower(strat))]]
   alladjustment <- tmp$alladjustment
   allmodes <- tmp$allmodes
   expnames  <- do.call("rbind.data.frame",strsplit(names(alladjustment),"_"))
   exnames <- names(tmp$alladjustment)
   colnames(expnames) <- c("Mutation","Selection")
   cols=palette.colors(n=length(unique(expnames$Mutation)),palette="Set 2")
   names(cols)=unique(expnames$Mutation)
   pchs=20+1:length(unique(expnames$Selection)) 
   names(pchs)=unique(expnames$Selection)
   plot(1,1,ylim=c(0,2),xlim=c(0,2),main=ge,type="n",ylab=expression(beta),xlab="J")
   for(e in 1:nrow(expnames)){
       en <- paste0(expnames[e,],collapse="_")
       try({
           points(alladjustment[[en]][[1]],pch=pchs[[expnames$Selection[[e]]]],bg=cols[[expnames$Mutation[[e]]]])
       })
   }
   uu=legend("bottomleft",legend=unique(expnames$Mutation),pt.bg=cols,pch=21,title="Mutation operator",bty="n",cex=.8)
   legend(x=(uu$rect$left+(uu$rect$w*1.4)),y=uu$rect$top,legend=unique(expnames$Selection),pt.bg=0,pch=pchs,title="Selection operator",bty="n",cex=.8)
   points(do.call("rbind",allmodes),cex=2,pch=pchs[expnames$Selection[1:length(allmodes)]],bg=cols[expnames$Mutation[1:length(allmodes)]],lwd=2)
}

