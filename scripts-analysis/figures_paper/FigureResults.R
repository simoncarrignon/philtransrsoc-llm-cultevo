sel_names <- mut_names <- c("original","efficient","attractive","random")
cols=palette.colors(n=length(mut_names),palette="Set 1")
cols <- scales::hue_pal()(length(mut_names))  
names(cols)=sort(mut_names)
pchs=20+1:length(sel_names) 
names(pchs)=sel_names

allrep=list(rep01=readRDS("../testin_abc/list_allposteriors.RDS"),
rep02=readRDS("../scripts-analysis/abc/list_allposteriors_rep01.RDS"))
allrep=readRDS("allabc_output_simu.RDS")
allmodes=do.call("rbind",lapply(allrep[[1]],function(i)do.call("rbind",i$allmodes)))
allmodes2=do.call("rbind",lapply(allrep[[2]][-5],function(i)do.call("rbind",i$allmodes)))
allmodes=rbind(allmodes2,allmodes)
expnames=do.call("rbind",strsplit(rownames(allmodes),"_"))


points(allmodes,bg=adjustcolor(cols[expnames[,2]],.6),pch=21,cex=2,xlab=expression(beta),ylab="J")

models=unique(unname(unlist(sapply(allrep,names,USE.NAMES = F))))

names(models)=c(
  "Mistral 7B",
  "Qwen2.5 7B",
  "Qwen2.5 7B",
  "OpenAI ChatGPT3.5",
  "Qwen3 8B")

par(mfrow=c(1,3),mar=c(4,4,2,1),cex=1.1,oma=c(0,0,0,7))
for(mi in names(models)[-c(5,3)][c(1,3,2)]){
    m=models[mi]
    m_allmodes <- do.call("rbind",allrep[[2]][[m]]$allmodes)
    colnames(m_allmodes) <- c("J","beta")
    expnames <- do.call("rbind",strsplit(rownames(m_allmodes),"_"))
    colnames(expnames) <- c("Mutation","Selection")
    m_allmodes <- cbind.data.frame(m_allmodes,apply(expnames,2,as.factor))
    m_allmodes$Selection  <-  as.factor(m_allmodes$Selection)
    m_allmodes$Mutation  <-  as.factor(m_allmodes$Mutation)
    plot(1,type="n",xaxt="n",pch=20,col=cols["original"],ylim=c(0,6),ylab=expression(J~"/"~beta),xlim=c(.7,4.3),main='',xlab="Selection")
    mtext(mi,side=3,line=.5,adj=0,font=2,cex=1.1)
    grid(lty=1,nx=0)
    abline(v=1:4,col=adjustcolor("grey",.6))
    abline(h=0:7,col=adjustcolor("grey",.6))
    for(mut in unique(m_allmodes$Mutation)) lines(m_allmodes[m_allmodes$Mutation == mut ,1]/m_allmodes[m_allmodes$Mutation == mut ,2],type="o",pch=20,col=cols[sel])
    axis(1,at=1:4,label=levels(m_allmodes$Selection))
}
legend("topright", inset = c(-0.25, 0), pch = 20, lwd = 1, col = cols, legend = names(cols), title = "Mutation", bty = "n", xpd = NA)

png("beta_j_posterior.png",width=2400,height=1000,pointsize=17)
par(mfrow=c(2,3),mar=c(4,4,2,1),cex=1.1,oma=c(0,3,0,7))
for(mi in names(models)[-c(5,3)][c(1,3,2)]){
    m=models[mi]
    m_allmodes <- do.call("rbind",allrep[[2]][[m]]$allmodes)
    colnames(m_allmodes) <- c("J","beta")
    expnames <- do.call("rbind",strsplit(rownames(m_allmodes),"_"))
    colnames(expnames) <- c("Mutation","Selection")
    m_allmodes <- cbind.data.frame(m_allmodes,apply(expnames,2,as.factor))
    m_allmodes$Selection  <-  as.factor(m_allmodes$Selection)
    m_allmodes$Mutation  <-  as.factor(m_allmodes$Mutation)
    plot(1,type="n",xaxt="n",pch=20,ylim=c(0,2.5),ylab=expression(J),xlim=c(.7,4.3),main='',xlab="Selection")
    mtext(mi,side=3,line=.5,adj=0,font=2,cex=1.1)
    grid(lty=1,nx=0)
    abline(v=1:4,col=adjustcolor("grey",.6))
    abline(h=0:7,col=adjustcolor("grey",.6))
    for(sel in unique(m_allmodes$Mutation)) lines(m_allmodes[m_allmodes$Mutation == sel ,1],type="o",pch=20,col=cols[sel],lwd=4)
    axis(1,at=1:4,label=levels(m_allmodes$Selection))
}
legend("topright", inset = c(-0.25, 0), pch = 20, lwd = 4, col = cols, legend = names(cols), title = "Mutation", bty = "n", xpd = NA)

for(mi in names(models)[-c(5,3)][c(1,3,2)]){
    m=models[mi]
    m_allmodes <- do.call("rbind",allrep[[2]][[m]]$allmodes)
    colnames(m_allmodes) <- c("J","beta")
    expnames <- do.call("rbind",strsplit(rownames(m_allmodes),"_"))
    colnames(expnames) <- c("Mutation","Selection")
    m_allmodes <- cbind.data.frame(m_allmodes,apply(expnames,2,as.factor))
    m_allmodes$Selection  <-  as.factor(m_allmodes$Selection)
    m_allmodes$Mutation  <-  as.factor(m_allmodes$Mutation)
    plot(1,type="n",xaxt="n",pch=20,col=cols["original"],ylim=c(0,2.5),ylab=expression(beta),xlim=c(.7,4.3),main='',xlab="Selection")
    mtext(mi,side=3,line=.5,adj=0,font=2,cex=1.1)
    grid(lty=1,nx=0)
    abline(v=1:4,col=adjustcolor("grey",.6))
    abline(h=0:7,col=adjustcolor("grey",.6))
    for(sel in unique(m_allmodes$Mutation)) lines(m_allmodes[m_allmodes$Mutation == sel ,2],type="o",pch=20,col=cols[sel],lwd=4)
    axis(1,at=1:4,label=levels(m_allmodes$Selection))
}
legend("topright", inset = c(-0.25, 0), pch = 20, lwd = 4, col = cols, legend = names(cols), title = "Mutation", bty = "n", xpd = NA)
dev.off()
