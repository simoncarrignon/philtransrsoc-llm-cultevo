experiment <- 'data'
list_allposteriors <- readRDS(file=file.path(experiment,"list_allposteriors.RDS"))
par(mfrow=c(3,2),cex=1)
cols=palette.colors(n=length(unique(expnames$Mutation)),palette="Set 2")
names(cols)=unique(expnames$Mutation)
pchs=20+1:length(unique(expnames$Selection)) 
names(pchs)=unique(expnames$Selection)
models  <-  c("GPT3.5","GPT4","O3MINI")
for(mv in models){
for( ge in names(file_results)){
   strat <- paste(mv,ge)
   tmp <- list_alladjustments[[gsub(" ","_",tolower(strat))]]
   alladjustment <- tmp$alladjustment
   allmodes <- tmp$allmodes
   expnames  <- do.call("rbind.data.frame",strsplit(names(alladjustment),"_"))
   #expnames <- names(tmp$alladjustment)
colnames(expnames) <- c("Mutation","Selection")
   plot(1,1,ylim=c(0,2),xlim=c(0,2),main=paste(mv,ge),type="n",ylab=expression(beta),xlab="J")
   for(e in 1:nrow(expnames)){
       en <- paste0(expnames[e,],collapse="_")
       try({
           points(alladjustment[[en]][[1]],pch=pchs[[expnames$Selection[[e]]]],bg=cols[[expnames$Mutation[[e]]]])
       })
   }
   uu=legend("topright",legend=unique(expnames$Mutation),pt.bg=cols,pch=21,title="Mutation operator",bty="n",cex=.8)
   legend(x=(uu$rect$left),y=uu$rect$top-(uu$rect$h*1.4),legend=unique(expnames$Selection),pt.bg=0,pch=pchs,title="Selection operator",bty="n",cex=.8)
   points(do.call("rbind",allmodes),cex=2,pch=pchs[expnames$Selection[1:length(allmodes)]],bg=cols[expnames$Mutation[1:length(allmodes)]],lwd=2)
}
}

