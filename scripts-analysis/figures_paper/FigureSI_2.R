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

selections=c("efficient","random","original","attractive")

## To plo
png("FigureSI_2.png",width=2200,height=3000,pointsize=17)
par(mfrow=c(4,3),mar=c(4,4,2,1),cex=1.1,oma=c(1,4,1,1))
for(mutation  in selections){
    for(m in models[-c(3,5)]){
        x=allrep[[1]][[1]]$alladjustment[[1]]$adj.values[,1]
        y=allrep[[1]][[1]]$alladjustment[[1]]$adj.values[,2]
        hdrcde::hdr.boxplot.2d(x,y,prob=c(50,75),ylim=c(0,2.5),xlim=c(0,2.1),shadecols=NA,outside.points=F,main=m)
        #mutation="original"
        print(m)
        for(selection in selections){
            try({
                par(new=T)
                x=allrep[[1]][[m]]$alladjustment[[paste(mutation,selection,sep="_")]]$adj.values[,1]
                y=allrep[[1]][[m]]$alladjustment[[paste(mutation,selection,sep="_")]]$adj.values[,2]
                hdrcde::hdr.boxplot.2d(x,y,prob=c(10,50,65),ylim=c(0,2.5),xlim=c(0,2.1),shadecols=cols[selection],outside.points=F)
            })
            x=allrep[[2]][[m]]$alladjustment[[paste(mutation,selection,sep="_")]]$adj.values[,1]
            y=allrep[[2]][[m]]$alladjustment[[paste(mutation,selection,sep="_")]]$adj.values[,2]
            par(new=T)
            hdrcde::hdr.boxplot.2d(x,y,prob=c(10,50,95),ylim=c(0,2.5),xlim=c(0,2.1),shadecols=cols[selection],outside.points=F)
            if(m == "mistral-7b-instruct-v0.3_generate_new_statements")mtext(text=mutation,2,4,cex=1.2,srt=2)

legend("topleft",  ,title="Selection",legend=selections,pt.bg=cols[selections],pch=21,cex=1.2,pt.cex=2,bty="n" , xpd = NA)
        }
    }

}

dev.off()
