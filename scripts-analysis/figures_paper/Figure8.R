models<-c("Mistral 7B"= "Mistral-7B-Instruct-v0.3_gennew_concatenated_files_1","Qwen2.5 7B"= "Qwen2.5-7B-Instruct_gennew_concatenated_files_1","Qwen2.5 7B"="qwen2.5-7b-var1_","OpenAI ChatGPT3.5"= "GPT3.5_gennew_concatenated_files","Qwen3 8B"= "qwen3-8b-")

## getting the embeddings
alldischanges <- lapply(models[-c(5,3)][c(1,3,2)],function(m)read.csv(paste0("../text_analysis/embeddings/",m,"_embeddings_distances.csv")))
sel_names <- mut_names <- c("original","efficient","attractive","random")
pal <- colorRampPalette(c("blue","yellow","red"))
cols_op <- palette.colors(n=length(mut_names),palette="Set 1")
cols_op <- scales::hue_pal()(length(mut_names))  
names(cols_op)=sort(mut_names)

png(paste0("Figure8.png"),width=2600,height=800,pointsize=17)
par(mfrow=c(1,3),mar=c(4,4,2,1),cex=1.1,oma=c(0,3,0,7))
dtcol="MeanDistWithin"
for(mi in names(models)[-c(5,3)][c(1,3,2)]){
    dischange <- alldischanges[[mi]]
    dischange <- dischange[dischange$Step > 90,]
    res <- tapply(dischange[[dtcol]],dischange[,c("Mutation","Selection"),],mean)
    ylim <- range(res)
    plot(NA, xlim=c(.7,4.3), ylim = c(.1,.5), xlab = "Step", ylab = "Mean cosine distance between all unique statements",xaxt="n",main=mi)
    for(m in sel_names){
        lines(res[m,mut_names],col=cols_op[m],type="o",pch=20,lwd=4)
    }
    axis(1,at=1:4,label=sel_names)
}
legend("topright", inset = c(-0.25, 0), pch = 20, lwd = 4, col = cols_op, legend = names(cols_op), title = "Mutation", bty = "n", xpd = NA)
dev.off()

