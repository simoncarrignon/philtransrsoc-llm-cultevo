experiment <- 'data'
list_allposteriors <- readRDS(file=file.path(here::here(),experiment,"list_allposteriors.RDS"))
par(mfrow=c(2,3),cex=1)
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
   tmp <- list_allposteriors[[gsub(" ","_",tolower(strat))]]
   alladjustment <- tmp$alladjustment
   allmodes <- tmp$allmodes
   expnames  <- do.call("rbind.data.frame",strsplit(names(alladjustment),"_"))
   #expnames <- names(tmp$alladjustment)
colnames(expnames) <- c("Mutation","Selection")
   plot(1,1,ylim=c(0,3),xlim=c(0,2),main=paste(mv,ge),type="n",ylab=expression(beta),xlab="J")
   for(e in 1:nrow(expnames)){
       en <- paste0(expnames[e,],collapse="_")
       try({
           points(alladjustment[[en]][[1]][,1:2],pch=pchs[[expnames$Selection[[e]]]],bg=cols[[expnames$Mutation[[e]]]])
       })
   }
   uu=legend("topright",legend=unique(expnames$Mutation),pt.bg=cols,pch=21,title="Mutation operator",bty="n",cex=.8)
   legend(x=(uu$rect$left),y=uu$rect$top-(uu$rect$h*1.4),legend=unique(expnames$Selection),pt.bg=0,pch=pchs,title="Selection operator",bty="n",cex=.8)
   points(do.call("rbind",allmodes),cex=2,pch=pchs[expnames$Selection[1:length(allmodes)]],bg=cols[expnames$Mutation[1:length(allmodes)]],lwd=2)
}
}

