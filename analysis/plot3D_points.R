experiment <- commandArgs(trailingOnly = TRUE)[1]
        library(rgl)
list_allposteriors <- readRDS(file=file.path(here::here(),experiment,"list_allposteriors.RDS"))
par(mfrow=c(ceiling(length(list_allposteriors)/2),2),cex=1) 
if(length(list_allposteriors)==1) par(mfrow=c(1,1),cex=1)
sel_names <- mut_names <- c("original","efficient","attractive","random")
cols=palette.colors(n=length(mut_names),palette="Set 2")
names(cols)=mut_names
pchs=20+1:length(sel_names) 
names(pchs)=sel_names
models  <-  c("GPT3.5","GPT4","O3MINI")
file_results  <- list("Mutate statements"="mut","Generate new statements"="gennew")
for(mv in models){
    for( ge in names(file_results)){
        strat <- paste(mv,ge)
        if(length(list_allposteriors[[gsub(" ","_",tolower(strat))]])==0)break;
        tmp <- list_allposteriors[[gsub(" ","_",tolower(strat))]]
        alladjustment <- tmp$alladjustment
        allmodes <- tmp$allmodes
        expnames  <- do.call("rbind.data.frame",strsplit(names(alladjustment),"_"))
        #expnames <- names(tmp$alladjustment)
        colnames(expnames) <- c("Mutation","Selection")

        # Open a new 3D plot
        open3d()

        # Plot settings
        xlim <- c(0, 3)
        ylim <- c(-1, 5)
        zlim <- c(0, 3)
        title3d(main='', xlab='J', ylab=expression(beta), zlab='e')

        # First plot data
        for(e in 1:nrow(expnames)) {
            en <- paste0(expnames[e,], collapse="_")
            try({
                points3d(alladjustment[[en]][[1]] ,
                         pch=pchs[[expnames$Selection[[e]]]],
                         col=cols[[expnames$Mutation[[e]]]],size=10)
            })
        }
        # Add legend
        legend3d("topright", legend=unique(expnames$Mutation), pch=21, col=cols, 
                 title="Mutation operator", cex=0.8, bty="n")
        axes3d()
        play3d(spin3d(axis = c(0, 0, 1)), duration = 10)
    }
}


