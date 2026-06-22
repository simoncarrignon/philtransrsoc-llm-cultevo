smooth_k <- function(y, k = 5) {
  # centered moving average, partial windows at ends
  stats::filter(y, rep(1/k, k), sides = 2, method = "convolution")
}

summary <- c("Mean","S","Median","Q75")
metrics <- c("DistInit","DistWithin")
metrics <-  c(metrics,paste0(metrics,"Weighted"))
dtist <- as.vector(outer(summary, metrics, paste0))
listmetrics <- as.list(metrics) 
names(listmetrics) <- metrics 


models<-c("Mistral 7B"= "Mistral-7B-Instruct-v0.3_gennew_concatenated_files_1","Qwen2.5 7B"= "Qwen2.5-7B-Instruct_gennew_concatenated_files_1","Qwen2.5 7B"="qwen2.5-7b-var1_","OpenAI ChatGPT3.5"= "GPT3.5_gennew_concatenated_files","Qwen3 8B"= "qwen3-8b-")

alldischanges <- lapply(models[-c(5,3)][c(1,3,2)],function(m)read.csv(paste0("../text_analysis/embeddings/",m,"_embeddings_distances.csv")))
sel_names <- mut_names <- c("original","efficient","attractive","random")
cols_op <- palette.colors(n=length(mut_names),palette="Set 1")
cols_op <- scales::hue_pal()(length(mut_names))  
names(cols_op)=sort(mut_names)
pchs=20+1:length(sel_names) 
names(pchs)=sel_names

lty_map <- setNames(rep(1:6, length.out = length(sel_names)), sel_names)


allrep=list(rep01=readRDS(here::here("abc/output/list_allposteriors_rep00.RDS")),
rep02=readRDS(here::here("abc/output/list_allposteriors_rep01.RDS")))
modmodels=unique(unname(unlist(sapply(allrep,names,USE.NAMES = F))))

names(modmodels)=c(
  "Mistral 7B",
  "Qwen2.5 7B",
  "Qwen2.5 7B",
  "OpenAI ChatGPT3.5",
  "Qwen3 8B")

png(paste0("Figure_time_select.png"),width=2600,height=1500,pointsize=17)
par(mfrow=c(2,3),mar=c(4,4,2,1),cex=1.1,oma=c(0,3,0,7))
yparam = c("Mean of the cosine distance between unique statements"="MeanDistWithin","Mean of the cosine distance between all statements"="MeanDistWithinWeighted")
for(ndt in names(yparam)){#,"SDistWithin","MeanDistInit","SDistInit")){
	dtcol = yparam[ndt]
    for(mi in names(models)[-c(5,3)][c(1,3,2)]){
        dischange <- alldischanges[[mi]]
        ylim <- range(dischange[[dtcol]], na.rm = TRUE)
        plot(NA, xlim = c(-1,100), ylim = c(0,.6), xlab = "Step", ylab = ndt,main=mi)
        for (mut in mut_names) {
            for (sel in sel_names) {
                exp <- dischange[dischange$Mutation == mut & dischange$Selection == sel, ]
                lines(smooth_k(exp[[dtcol]],k=1), col = cols_op[[as.character(sel)]], lty = lty_map[[as.character(mut)]], lwd = 4)
        abline(h=exp[exp$Step == 0,dtcol],lty=2,col="red",lwd=2)
            }
        }
    }
}
        u=legend("topright", inset = c(-0.25, -.3), pch = NA, lwd = 4, col = cols_op, legend = names(cols_op), title = "Selection", bty = "n", xpd = NA)
        v=legend("topright", inset = c(-0.25, -u$rect$h),  lwd = 2, col = "red", legend = "initial mean distance", title = "", bty = "n", xpd = NA,lty=2)
        legend("topright", inset = c(-0.25, -u$rect$h+v$rect$h+.05),  lwd = 2, col = 1, legend = mut_names , title = "Mutation", bty = "n", xpd = NA,lty=lty_map,)

dev.off()


