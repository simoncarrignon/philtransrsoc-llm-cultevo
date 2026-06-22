smooth_k <- function(y, k = 5) {
  # centered moving average, partial windows at ends
  stats::filter(y, rep(1/k, k), sides = 2, method = "convolution")
}

##more exhaustive exploreation of changes in embeddings"
summary <- c("Mean","S","Median","Q75")
metrics <- c("DistInit","DistWithin")
metrics <-  c(metrics,paste0(metrics,"Weighted"))
dtist <- as.vector(outer(summary, metrics, paste0))
listmetrics <- as.list(metrics) 
names(listmetrics) <- metrics 
dtlist <- paste0(summary,listmetrics[[ndt]])


models<-c("Mistral 7B"= "Mistral-7B-Instruct-v0.3_gennew_concatenated_files_1","Qwen2.5 7B"= "Qwen2.5-7B-Instruct_gennew_concatenated_files_1","Qwen2.5 7B"="qwen2.5-7b-var1_","OpenAI ChatGPT3.5"= "GPT3.5_gennew_concatenated_files","Qwen3 8B"= "qwen3-8b-")

alldischanges <- lapply(models[-c(5,3)][c(1,3,2)],function(m)read.csv(paste0("embeddings/",m,"_embeddings_distances.csv")))
sel_names <- mut_names <- c("original","efficient","attractive","random")
cols_op <- palette.colors(n=length(mut_names),palette="Set 1")
cols_op <- scales::hue_pal()(length(mut_names))  
names(cols_op)=sort(mut_names)
pchs=20+1:length(sel_names) 
names(pchs)=sel_names

lty_map <- setNames(rep(1:6, length.out = length(sel_names)), sel_names)


for( ndt in names(listmetrics) ){
    dtlist=paste0(summary,listmetrics[[ndt]])
    png(paste0("Figure_time_",ndt,".png"),width=2600,height=2000,pointsize=17)
    par(mfrow=c(4,3),mar=c(4,4,2,1),cex=1.1,oma=c(0,3,0,7))
    for(dtcol in dtlist){
        for(mi in names(models)[-c(5,3)][c(1,3,2)]){
            dischange <- alldischanges[[mi]]
            ylim <- range(dischange[[dtcol]], na.rm = TRUE)
            plot(NA, xlim = c(0,100), ylim = ylim, xlab = "Step", ylab = dtcol,main=mi)
            for (mut in mut_names) {
                for (sel in sel_names) {
                    exp <- dischange[dischange$Mutation == mut & dischange$Selection == sel, ]
                    lines(smooth_k(exp[[dtcol]],k=1), col = cols_op[[as.character(sel)]], lty = lty_map[[as.character(mut)]], lwd = 2)
                }
            }
        }
    }
    dev.off()
}
for( ndt in names(listmetrics) ){
    dtlist=paste0(summary,listmetrics[[ndt]])
    png(paste0("Figure_embedding_final_",ndt,".png"),width=2600,height=2000,pointsize=17)
    par(mfrow=c(4,3),mar=c(4,4,2,1),cex=1.1,oma=c(0,3,0,7))
    for(dtcol in dtlist){
        for(mi in names(models)[-c(5,3)][c(1,3,2)]){
            dischange <- alldischanges[[mi]]
            dischange <- dischange[dischange$Step > 90,]
            res <- tapply(dischange[[dtcol]],dischange[,c("Mutation","Selection"),],mean)
            ylim <- range(res)
            plot(NA, xlim=c(.7,4.3), ylim = ylim, xlab = "Step", ylab = dtcol,xaxt="n",main=mi)
            for(m in sel_names){
                lines(res[m,mut_names],col=cols_op[m],type="o",pch=20,lwd=4)
            }
            axis(1,at=1:4,label=sel_names)
        }
        legend("topright", inset = c(-0.25, 0), pch = 20, lwd = 4, col = cols_op, legend = names(cols_op), title = "Mutation", bty = "n", xpd = NA)
    }
    dev.off()
}





alls=do.call("rbind",alldischanges)
alls <- alls[alls$Step >90,]
for(x in c("Mutation","Selection")){
    png(paste0("Figure_embedding_distance_wrt_",x,".png"),width=2400,height=2600,pointsize=17)
    par(mfrow=c(4,4))
    for(s  in summary){
        for(dt in metrics){
            y <- paste0(s,dt)
            boxplot(alls[[y]] ~ alls[[x]],col=cols_op,ylab=y)
    }}
    mtext(x,3,-2,outer=T)
    dev.off()
}

## J beta vs dist

allrep=list(rep01=readRDS(here::here("scripts-analysis/abc/output/list_allposteriors_rep00.RDS")),
rep02=readRDS(here::here("scripts-analysis/abc/output/list_allposteriors_rep01.RDS")))
modmodels=unique(unname(unlist(sapply(allrep,names,USE.NAMES = F))))

names(modmodels)=c(
  "Mistral 7B",
  "Qwen2.5 7B",
  "Qwen2.5 7B",
  "OpenAI ChatGPT3.5",
  "Qwen3 8B")
summary_mean_table <- data.frame()
for(dtcol in dtlist){
    for(mi in names(models)[-c(5,3)][c(1,3,2)]){
        dischange <- alldischanges[[mi]]
        dischange <- dischange[dischange$Step > 70,]
        for (mut in mut_names) {
            for (sel in sel_names) {
                exp <- dischange[dischange$Mutation == mut & dischange$Selection == sel, ]
                exn <- paste(mut,sel,sep="_")
                jbeta <- allrep[[2]][[modmodels[mi]]]$allmodes[[exn]]
                mean_metrics <- sapply(dtist,function(d)mean(exp[[d]]))
                newrow <- cbind.data.frame(Model=mi,Mutation=mut,Selection=sel,J=jbeta[1],beta=jbeta[2],t(mean_metrics))

                summary_mean_table <- rbind.data.frame(summary_mean_table,newrow)
            }
        }
    }
}


plot(as.data.frame(summary_mean_table))

par(mfrow=c(1,length(dtist)))
for(i in 6:13) plot(summary_mean_table[,c("J","beta")],cex=exp(summary_mean_table[,i]),main=colnames(summary_mean_table)[i])
for(i in 6:13) plot(summary_mean_table[,("J")],summary_mean_table[,i])
for(i in 6:13) plot(summary_mean_table[,"beta"],summary_mean_table[,i],ylab=colnames(summary_mean_table)[i])

pal <- colorRampPalette(c("blue","yellow","red"))

for(i in dtist) plot(summary_mean_table[,c("J","beta")], cex = exp(summary_mean_table[,i]), main = colnames(summary_mean_table)[i])

for(i in dtist) plot(summary_mean_table[,"beta"], summary_mean_table[,i],ylab=i)

cols <- pal(100)[as.integer(cut(summary_mean_table[,"beta"], breaks = 100, include.lowest = TRUE))]
for(i in dtist) plot(summary_mean_table[,"J"], summary_mean_table[,i], ylab = i, col  = cols, pch  = 20,cex=3)

cols <- pal(100)[as.integer(cut(summary_mean_table[,"J"], breaks = 100, include.lowest = TRUE))]
for(i in dtist) plot(summary_mean_table[,"beta"], summary_mean_table[,i], ylab = i, col  = cols, pch  = 20,cex=3)

for(txt in c("Model","Mutation","Selection")){
    for(s in summary){
    png(paste0("Figure_JBeta_vs_",s,"_plus_",txt,".png"),width=2000,height=2600,pointsize=17)
        par(mfrow=c(4,2))
        for(m in metrics){
            me <- paste0(s,m)
            params <- c("J","beta")
            for(post in params){
                secondpost <- summary_mean_table[,params[params != post]]
            cols <- pal(100)[as.integer(cut(secondpost, breaks = 100, include.lowest = TRUE))]
            plot(summary_mean_table[,post], summary_mean_table[,me], ylab = me, col  = cols, pch  = 20,cex=3,xlab=post)
            text(summary_mean_table[,post], summary_mean_table[,me],summary_mean_table[,txt],pos=1)
            legend("top",col=pal(4),pch=20,legend=round(seq(min(secondpost),max(secondpost),length.out=4),2),horiz=T,title=params[params != post],pt.cex=2)
            }
        }
        dev.off()
    }
}

for(s in "Mean"){
    png(paste0("Mean_JBeta.png"),width=2000,height=2800,pointsize=17)
    par(mfrow=c(8,3))
        for(m in metrics){
            params <- c("J","beta")
            for(post in params){
    for(txt in c("Model","Mutation","Selection")){
            me <- paste0(s,m)
                secondpost <- summary_mean_table[,params[params != post]]
            cols <- pal(100)[as.integer(cut(secondpost, breaks = 100, include.lowest = TRUE))]
            plot(summary_mean_table[,post], summary_mean_table[,me], ylab = me, col  = cols, pch  = 20,cex=3,xlab=post)
            text(summary_mean_table[,post], summary_mean_table[,me],summary_mean_table[,txt],pos=1)
            legend("top",col=pal(4),pch=20,legend=round(seq(min(secondpost),max(secondpost),length.out=4),2),horiz=T,title=params[params != post],pt.cex=2)
            }
        }
    }
        dev.off()
}

png(paste0("Mean_JBeta_DistWithin_Model.png"),width=2400,height=3000,pointsize=17)
par(mfrow=c(3,2),oma=c(0,5,2,1),xpd=T,mar=c(3,4,0,0))
column <- "MeanDistWithinWeighted"
params <- c("J","beta")
    for(txt in c("Model","Mutation","Selection")){
for(post in params){
    secondpost <- summary_mean_table[,params[params != post]]
    cols <- pal(100)[as.integer(cut(secondpost, breaks = 100, include.lowest = TRUE))]
    plot(summary_mean_table[,post], summary_mean_table[,column], ylab = column, col  = cols, pch  = 20,cex=3,xlab=post)
    text(summary_mean_table[,post], summary_mean_table[,column],summary_mean_table[,txt],pos=1,col=ifelse(is.na(cols_op[summary_mean_table[,txt]]),"black",cols_op[summary_mean_table[,txt]]))
    legend("topright",col=pal(4),pch=20,legend=round(seq(min(secondpost),max(secondpost),length.out=4),2),horiz=T,title=params[params != post],pt.cex=2)
}
 mtext(txt,2,2,outer=T,1)
}
dev.off()

png(paste0("Mean_JBeta_DistWithin.png"),width=3000,height=3500,pointsize=28)
par(mfrow=c(3,2),xpd=T,cex=1.1)
column <- "MeanDistWithinWeighted"
params <- c("J","beta")
    txt <- "Model"
for(post in params){
    secondpost <- summary_mean_table[,params[params != post]]
    cols <- pal(100)[as.integer(cut(secondpost, breaks = 100, include.lowest = TRUE))]
    plot(summary_mean_table[,post], summary_mean_table[,column], ylab = column, col  = cols, pch  = 20,cex=3,xlab=post,main=txt)
  grid(col = "#E8E8E8", lty = 1, lwd = 0.8)
  box(col = "#555555", lwd = 0.9)
    text(summary_mean_table[,post], summary_mean_table[,column],summary_mean_table[,txt],pos=1,col=ifelse(is.na(cols_op[summary_mean_table[,txt]]),"black",cols_op[summary_mean_table[,txt]]))
    legend("topright",col=pal(4),pch=20,legend=round(seq(min(secondpost),max(secondpost),length.out=4),2),horiz=T,title=params[params != post],pt.cex=2,bty="n")
}
    for(txt in c("Mutation","Selection")){
for(post in params){
    secondpost <- summary_mean_table[,params[params != post]]
    plot(summary_mean_table[,post], summary_mean_table[,column], ylab = column, col  = cols, pch  = 20,cex=3,xlab=post,type="n",main=txt)
  grid(col = "#E8E8E8", lty = 1, lwd = 0.8)
  box(col = "#555555", lwd = 0.9)
    text(summary_mean_table[,post], summary_mean_table[,column],summary_mean_table[,txt],col=ifelse(is.na(cols_op[summary_mean_table[,txt]]),"black",cols_op[summary_mean_table[,txt]]))
}
}
dev.off()

alls=do.call("rbind",alldischanges)
alls <- alls[alls$Step >90,]
png(paste0("Figure_overall_embedding_distance_wrt_operators.png"),width=2400,height=1600,pointsize=32)
par(mfrow=c(2,2))
    for(column in c("MeanDistInitWeighted", "MeanDistWithinWeighted")){
for(x in c("Mutation","Selection")){ 
    boxplot(alls[[column]] ~ alls[[x]],col=cols_op,ylab=column,xlab=x) 
}
    }
dev.off()

png(paste0("Figure_embedding_final_",ndt,".png"),width=2600,height=2000,pointsize=17)
par(mfrow=c(2,3),mar=c(4,4,2,1),cex=1.1,oma=c(0,3,0,7))
for(dtcol in c("MeanDistWithin","MeanDistInit")){
    for(mi in names(models)[-c(5,3)][c(1,3,2)]){
        dischange <- alldischanges[[mi]]
        dischange <- dischange[dischange$Step > 90,]
        res <- tapply(dischange[[dtcol]],dischange[,c("Mutation","Selection"),],mean)
        ylim <- range(res)
        plot(NA, xlim=c(.7,4.3), ylim = ylim, xlab = "Step", ylab = dtcol,xaxt="n",main=mi)
        for(m in sel_names){
            lines(res[m,mut_names],col=cols_op[m],type="o",pch=20,lwd=4)
        }
        axis(1,at=1:4,label=sel_names)
    }
    legend("topright", inset = c(-0.25, 0), pch = 20, lwd = 4, col = cols_op, legend = names(cols_op), title = "Mutation", bty = "n", xpd = NA)
}
dev.off()

