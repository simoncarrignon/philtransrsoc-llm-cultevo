
exp="exp.csv"
alltraits=read.csv(exp)
dim(alltraits)
plot(alltraits[,2])
alltraits[is.na(alltraits)]=0
plot(1,1,xlim=c(0,nrow(alltraits)),ylim=range(alltraits),type="n",xlab="time",ylab="count")

for(l in 1:ncol(alltraits))lines(alltraits[,l],col=rainbow(ncol(alltraits))[l],lwd=2)

cnt=table(total)
dis=cnt
counts=as.numeric(names(dis))
val=as.numeric(dis)
points(counts,val,col="red")


#traits frequencies
total=apply(alltraits,2,sum)
cnt=table(total)
dis=cnt
counts=as.numeric(names(dis))
val=as.numeric(dis)
plot(counts,val,log="xy")
total=apply(alltraits,2,sum)


#Fitting power laws
mln1=displ(total[total>0])
mln1$setXmin(estimate_xmin(mln1))
lines(mln,col="red")
mln2=displ(total2[total2>0])
mln2$setXmin(estimate_xmin(mln2))
pts2=plot(mln2)
pts1=plot(mln)
plot(mln2,pch=21,bg="red",xlim=range(pts1$x,pts2$x),ylim=range(pts1$y,pts2$y),xlab="number of time a variant is adopted",ylab="%", )
lines(mln2,col="red")
points(pts1$x,pts1$y,pch=21,bg="green")
lines(mln1,col="green")
