sel_names <- mut_names <- c("original","efficient","attractive","random")
cols=palette.colors(n=length(mut_names),palette="Set 1")
cols <- scales::hue_pal()(length(mut_names))  
names(cols)=sort(mut_names)
pchs=20+1:length(sel_names) 
names(pchs)=sel_names
models<-c("Mistral 7B"= "mistral-7b-instruct-v0.3_generate_new_statements","Qwen2.5 7B"= "qwen2.5-7b-instruct_generate_new_statements","Qwen2.5 7B"="qwen2.5-7b-var1_generate_new_statements","OpenAI ChatGPT3.5"= "gpt3.5_generate_new_statements","Qwen3 8B"= "qwen3-8b-gguf_generate_new_statements")

metrics <- c("anx","negemo","posemo")
png("Figure5.png",width=2400,height=1000,pointsize=17)
par(mfrow=c(2,3),mar=c(4,4,2,1),cex=1.2,oma=c(0,0,0,7))
for(mi in names(models)[c(1,2)]){
for(me in metrics){
		m <- models[mi]
		dt <- read.csv(here::here("scripts-analysis/text_analysis/output/summary_tables/",gsub("generate_new_statements","gennew_concatenated",paste0(m,"_",me,".csv"))))
		dt$Selection  <-  as.factor(dt$Selection)
		dt$Mutation  <-  as.factor(dt$Mutation)
		plot(1,type="n",xaxt="n",pch=20,col=cols["original"],ylim=range(dt[,3]),ylab=me,xlim=c(.7,4.3),main='',xlab="Selection")
		mtext(mi,side=3,line=.5,adj=0,font=2,cex=1.1)
grid()
		for(sel in unique(dt$Mutation)) lines(dt[dt$Mutation == sel ,3],type="o",pch=20,col=cols[sel],lwd=4)
		axis(1,at=1:4,label=levels(dt$Selection))
	}
legend("topright", inset = c(-0.25, 0), pch = 20, lwd = 4, col = cols, legend = names(cols), title = "Mutation", bty = "n", xpd = NA)
}
dev.off()


