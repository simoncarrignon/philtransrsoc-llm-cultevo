models<-c("Mistral 7B"= "Mistral-7B-Instruct-v0.3_gennew_concatenated_files_1","Qwen2.5 7B"= "Qwen2.5-7B-Instruct_gennew_concatenated_files_1","Qwen2.5 7B"="qwen2.5-7b-var1_","OpenAI ChatGPT3.5"= "GPT3.5_gennew_concatenated_files","Qwen3 8B"= "qwen3-8b-")

## getting the embeddings
alldischanges <- lapply(models[-c(5,3)][c(1,3,2)],function(m)read.csv(paste0("../text_analysis/embeddings/",m,"_embeddings_distances.csv")))
sel_names <- mut_names <- c("original","efficient","attractive","random")

## getting the posterios for J and beta
allrep=list(rep01=readRDS(here::here("../scripts-analysis/abc/output/list_allposteriors_rep00.RDS")),
rep02=readRDS(here::here("../scripts-analysis/abc/output/list_allposteriors_rep01.RDS")))
modmodels=unique(unname(unlist(sapply(allrep,names,USE.NAMES = F))))
names(modmodels)=c(
  "Mistral 7B",
  "Qwen2.5 7B",
  "Qwen2.5 7B",
  "OpenAI ChatGPT3.5",
  "Qwen3 8B")

summary <- c("Mean","S","Median","Q75")
metrics <- c("DistInit","DistWithin")
metrics <-  c(metrics,paste0(metrics,"Weighted"))
dtist <- as.vector(outer(summary, metrics, paste0))

## generating overall table with all correpsondance 
summary_mean_table <- data.frame()
for(mi in names(models)[-c(5,3)][c(1,3,2)]){
	dischange <- alldischanges[[mi]]
	dischange <- dischange[dischange$Step > 80,]
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

pal <- colorRampPalette(c("blue","yellow","red"))
cols_op <- palette.colors(n=length(mut_names),palette="Set 1")
cols_op <- scales::hue_pal()(length(mut_names))  
names(cols_op)=sort(mut_names)

png(paste0("Figure9.png"),width=1300,height=1000,pointsize=14)
par(mfrow=c(1,1),xpd=F,cex=1.1)
column <- "MeanDistWithinWeighted"
params <- c("beta","J")
    txt <- "Model"
for(post in params[2]){
    secondpost <- summary_mean_table[,params[params != post]]
    cols <- pal(100)[as.integer(cut(secondpost, breaks = 100, include.lowest = TRUE))]
    plot(summary_mean_table[,post], summary_mean_table[,column], ylab = "Mean of Cosine Distance", col  = cols, pch  = 20,cex=3,xlab="frequency-dependent bias (J)",main=txt)
  grid(col = "#E8E8E8", lty = 1, lwd = 0.8)
  box(col = "#555555", lwd = 0.9)
  par(xpd=T)
    text(summary_mean_table[,post], summary_mean_table[,column],summary_mean_table[,txt],pos=1,col=ifelse(is.na(cols_op[summary_mean_table[,txt]]),"black",cols_op[summary_mean_table[,txt]]),cex=.8)
    legend("topright",col=pal(5),pch=20,legend=round(seq(min(secondpost),max(secondpost),length.out=5),2),horiz=T,title=expression(beta),pt.cex=2,bty="n")
}
dev.off()



