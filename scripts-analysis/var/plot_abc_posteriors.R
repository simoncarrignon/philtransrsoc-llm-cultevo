experiment <- '../testin_abc'
list_allposteriors <- readRDS(file=file.path(experiment,"list_allposteriors.RDS"))

model
## in the case that we have multiple 
names(list_allposteriors[[1]]$alladjustment) <- sub("_newm","newm",names(list_allposteriors[[1]]$alladjustment))
expnames  <- do.call("rbind.data.frame",strsplit(names(list_allposteriors$gpt3.5_mutate_statements$alladjustment),"_"))
colnames(expnames) <- c("Mutation","Selection")


cols=palette.colors(n=length(unique(expnames$Mutation)),palette="Set 2")
names(cols)=unique(expnames$Mutation)
pchs=20+1:length(unique(expnames$Selection)) 
names(pchs)=unique(expnames$Selection)

models  <-  c("GPT3.5","GPT4","O3MINI")[1]
models <- ""
for(mv in models){
for( ge in names(list_allposteriors)){
   strat <- paste0(ge)
   tmp <- list_allposteriors[[gsub(" ","_",tolower(strat))]]
   allmodes <- tmp$allmodes
   alladjustment <- tmp$alladjustment
   png(filename = paste0("ABC_",strat,".png"), width = 2400, height = 2200, res = 300)
   par(cex=1.1)
   plot(1,1,ylim=c(0,2),xlim=c(0,2),main=paste(mv,ge),type="n",ylab=expression(beta),xlab="J")
   for(e in 1:nrow(expnames)){
       en <- paste0(expnames[e,],collapse="_")
       try({
           points(alladjustment[[en]][[1]],pch=pchs[[expnames$Selection[[e]]]],bg=adjustcolor(cols[[expnames$Mutation[[e]]]],.6),lwd=.5)
       })
   }
   points(do.call("rbind",allmodes),cex=2,pch=pchs[expnames$Selection[1:length(allmodes)]],bg=cols[expnames$Mutation[1:length(allmodes)]],lwd=2)
   uu=legend("topright",legend=unique(expnames$Mutation),pt.bg=cols,pch=21,title="Mutation operator" ,cex=.8,bg="white")
   legend(x=(uu$rect$left),y=uu$rect$top-(uu$rect$h*1.4),legend=unique(expnames$Selection),pt.bg=0,pch=pchs,title="Selection operator",cex=.8,bg="white")
   dev.off()
}
}

