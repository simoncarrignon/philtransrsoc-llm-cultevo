alltraits=read.csv("allcsv.csv")
dim(alltraits)
plot(alltraits[,2])
alltraits[is.na(alltraits)]=0
write.csv(file="corrected.csv",alltraits,row.names=F)
