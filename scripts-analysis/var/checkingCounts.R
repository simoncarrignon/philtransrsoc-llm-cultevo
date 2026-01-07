sing_ex <- read.csv("../data/chains/expK50N100T100_mutoriginal_seloriginal_GPT3.5/processed_statements.csv",header=F)
allex <- read.csv("../data/chains/GPT3.5_mut_concatenated_files.csv")
test_ex  <- allex[allex$Mutation == "original" & allex$Selection == "original",]

#checking total number of addoptions
plot(tapply(sing_ex$V3,sing_ex[,c("V1")],sum),type="l",lwd=3)
points(tapply(test_ex$Count,test_ex[,c("Step")],sum),col="red",type="l",lwd=3)

for(t in 1:max(sing_ex$V1)){
    tmp=sing_ex[sing_ex$V1 == t,]
    all <- sum(tmp$V3)
    ids=unique(tmp$V2)
    kp = ids %in% sing_ex[sing_ex$V1 == t-1,'V2']
    kpb = ids %in% unique(sing_ex[sing_ex$V1 %in% 1:(t-1),'V2'])
    which(kp %in% kpb)
    old <- sum(tmp$V3[kp])
    old_res <- sum(tmp$V3[kpb])
    print(paste0("step:",t," count of all traits: ", all,", number of pre-existing one: ",old," including resurections: ",old_res))
}

#check for all
expid <- unique(allex[,c("Mutation","Selection")])
for(e in 1:nrow(expid)){
    u <- expid[e,]
    sing_ex=allex[allex$Mutation == u[,1] & allex$Selection == u[,2],]
    for(t in 1:max(sing_ex$Step)){
        tmp <- sing_ex[sing_ex$Step == t,]
        all <- sum(tmp$Count)
        ids <- unique(tmp$ID)
        kp  <-  ids %in% sing_ex[sing_ex$Step == t-1,'ID']
        kpb  <-  ids %in% unique(sing_ex[sing_ex$Step %in% 1:(t-1),'ID'])
        which(kp %in% kpb)
        old <- sum(tmp$Count[kp])
        old_res <- sum(tmp$Count[kpb])
        print(paste0("step:",t," count of all traits: ", all,", number of pre-existing one: ",old," including resurections: ",old_res))
    }
}


#check for all
expid <- unique(allex[,c("Mutation","Selection")])
pres <- c()
res <- c()
pbst <- c()
for(e in 1:nrow(expid)){
    u <- expid[e,]
    sing_ex=allex[allex$Mutation == u[,1] & allex$Selection == u[,2],]
    for(t in 2:max(sing_ex$Step)){
        tmp <- sing_ex[sing_ex$Step == t,]
        all <- sum(tmp$Count)
        ids <- unique(tmp$ID)
        kp  <-  ids %in% sing_ex[sing_ex$Step == t-1,'ID']
        kpb  <-  ids %in% unique(sing_ex[sing_ex$Step %in% 1:(t-1),'ID'])
        which(kp %in% kpb)
        old <- sum(tmp$Count[kp])
        old_res <- sum(tmp$Count[kpb])
        res=rbind(res,c(old_res,old,t,e))
        pres=c(pres,old)
        if(old_res != 100) pbst = c(pbst,t,e)

    }
}
_
plot(res[,2])
lines(res[,1],col="red")


#Most of the low number are due to old statement re-appearing. good example is 
weird <- which.min(res[,2])
u <- expid[res[weird,4],]
sing_ex <- allex[allex$Mutation == u[,1] & allex$Selection == u[,2],]
sing_ex[ sing_ex$Step == res[weird,3] ,]

sing_ex <- read.csv("../chain-llms/test3/processed_statements.csv",header=F,skip=1)
plot(tapply(sing_ex$V3,sing_ex[,c("V1")],sum),type="l",lwd=3)
points(tapply(test_ex$Count,test_ex[,c("Step")],sum),col="red",type="l",lwd=3)

for(t in 1:max(sing_ex$V1)){
    tmp=sing_ex[sing_ex$V1 == t,]
    all <- sum(tmp$V3)
    ids=unique(tmp$V2)
    kp = ids %in% sing_ex[sing_ex$V1 == t-1,'V2']
    kpb = ids %in% unique(sing_ex[sing_ex$V1 %in% 1:(t-1),'V2'])
    which(kp %in% kpb)
    old <- sum(tmp$V3[kp])
    old_res <- sum(tmp$V3[kpb])
    print(paste0("step:",t," count of all traits: ", all,", number of pre-existing one: ",old," including resurections: ",old_res))
}
