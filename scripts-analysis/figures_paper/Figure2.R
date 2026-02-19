mut <- "random"
sel <- "original"
model= "Qwen2.5-7B-Instruct"
pref <- "gennew"
# Read the CSV file output of the all chains fr this model
data <- read.csv(here::here("chain-output","merged-csvs",paste0(model,"_",pref,"_concatenated_files_0.csv")))
data  <- data[data$Mutation == mut & data$Selection == sel,]

liststat <- data[data$Step < 15 ,]  #statement before 15 steps
keeps=tapply(liststat$Count,liststat$ID,max)>1 #statements with more than 1 selection
liststat  <- unique(liststat[,c("ID","Statement")])[keeps,]
liststat <- liststat[-c(2:4,6:10),] #remove the initial bet and the one who disapear

ids=liststat$ID
colsid=adjustcolor(rainbow(length(ids)))

#Rcolorbrewer Dark2
colsid=c("#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E","#E6AB02","#A6761D","#666666")

names(colsid)=as.character(ids)


png("Figure1a.png",height=700,width=900,pointsize=17)
par(mar=c(4,4,1,1),cex=1.2)
plot(1,1,ylim=range(data[["Count"]])*1.02,xlim=c(0,15),type="n",ylab="Number of Time Selected",xlab="Step")
for(u in ids){
    a=data[["Count"]][data$ID==u]
    b=data$Step[data$ID==u]
    col=colsid[as.character(u)]
    lines(b,a,col=col,lwd=4)
    if(max(a)>1){
        par(xpd=NA)
        if(b[which.max(a)]!=0)text(b[which.max(a)],max(a),paste0("Stat. ",u),col=col,adj=1,pos=3,font=2)
        par(xpd=F)
    }
}
abline(h=c(1,100),col=adjustcolor("grey",.3))
abline(v=seq(1,15,1),col=adjustcolor("grey",.4),lty=5)
box(which="outer")
dev.off()

### TABLE with background matching lines
library(knitr)
library(kableExtra)

kable(liststat, format = "html", row.names = FALSE) |>
  kable_styling(full_width = FALSE) |>
  column_spec(1:2, background = colsid[as.character(liststat$ID)], color="#f0f0f0", bold = TRUE)



### not used in paper

### Temporal change: whole simulation
ids=unique(data$ID)
colsid=sample(adjustcolor(rainbow(length(ids))))
names(colsid)=as.character(ids)
plot(1,1,ylim=range(data[["Count"]]),xlim=c(0,102),type="n",ylab="Number of time selected",xlab="")
for(u in ids){
    a=data[["Count"]][data$ID==u]
    b=data$Step[data$ID==u]
    col=colsid[as.character(u)]
    lines(b,a,col=col,lwd=3)
}

