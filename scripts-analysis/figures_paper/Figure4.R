sel_names <- mut_names <- c("original","efficient","attractive","random")
cols=palette.colors(n=length(mut_names),palette="Set 1")
cols <- scales::hue_pal()(length(mut_names))  
names(cols)=sort(mut_names)
pchs=20+1:length(sel_names) 
names(pchs)=sel_names

allrep=list(rep01=readRDS(here::here("scripts-analysis/abc/output/list_allposteriors_rep00.RDS")),
rep02=readRDS(here::here("scripts-analysis/abc/output/list_allposteriors_rep01.RDS")))
models=unique(unname(unlist(sapply(allrep,names,USE.NAMES = F))))

names(models)=c(
  "Mistral 7B",
  "Qwen2.5 7B",
  "Qwen2.5 7B",
  "OpenAI ChatGPT3.5",
  "Qwen3 8B")

selections=c("efficient","random")

png("Figure4.png",width=2400,height=500,pointsize=17)
par(mfrow=c(1,3),mar=c(4,4,2,1),cex=1.1,oma=c(0,3,0,7))
for(mi in names(models)[-c(5,3)][c(1,3,2)]){
    m=models[mi]
    x=allrep[[1]][[1]]$alladjustment[[1]]$adj.values[,1]
    y=allrep[[1]][[1]]$alladjustment[[1]]$adj.values[,2]
    hdrcde::hdr.boxplot.2d(x,y,prob=c(50,75,95),ylim=c(0,2.5),xlim=c(0,2.1),shadecols=NA,outside.points=F,main='',pointcol="white",xlab=expression("frequency-dependent bias (J)"),ylab=expression("content-dependent bias"~(beta)))
    abline(h = 1, v = 1, col = adjustcolor("grey",.6), lwd = 1)
    abline(a = 0, b = 1, col = adjustcolor("black",.6), lwd = 1,lty=2)
    mutation="original"
    print(m)
    for(selection in selections){
        x=allrep[[2]][[m]]$alladjustment[[paste(mutation,selection,sep="_")]]$adj.values[,1]
        y=allrep[[2]][[m]]$alladjustment[[paste(mutation,selection,sep="_")]]$adj.values[,2]
        par(new=T)
        hdrcde::hdr.boxplot.2d(x,y,prob=c(10,50,75),ylim=c(0,2.5),xlim=c(0,2.1),shadecols=cols[selection],outside.points=F)
    }
    mtext(mi,side=3,line=.5,adj=0,font=2,cex=1.1)
}
legend("topright", inset = c(-0.25, 0),title="Selection",legend=selections,pt.bg=cols[selections],pch=21,cex=1.2,pt.cex=2,bty="n" , xpd = NA)
dev.off()

