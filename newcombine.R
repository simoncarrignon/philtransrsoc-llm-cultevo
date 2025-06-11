gennew <- read.csv("GPT3.5_gennew_concatenated_files.csv")
mut <- read.csv("GPT3.5_mut_concatenated_files.csv")


par(mfrow=c(2,4),cex=1.2)
exps  <- list(innov=gennew,mutation=mut)
ex.col  <- palette.colors(n=4,palette="Set 2")
for(nex in names(exps)){
    simudat   <- exps[[nex]]
    allunique <- lapply( unique(simudat$Selection),function(s){
        allsimudat <- lapply(unique(simudat$Mutation),function(m){
            numdat <- simudat[simudat$Selection == s & simudat$Mutation == m,3:5]
            tapply(numdat$ID,numdat$Step,length)
        })
        names(allsimudat)=unique(simudat$Mutation)
        allsimudat
    }) 
    names(allunique)=unique(simudat$Selection)
    
    range(unlist(allunique))
    for(i in seq_along(allunique)){
        plot(0,1,ylim=c(0,45),xlim=c(0,101),type="n",main=names(allunique)[i],xlab="time",ylab="unique statement")
        for(j in seq_along(allunique[[i]])){
            lines(allunique[[i]][[j]],lwd=2,col=ex.col[j])
        }
        legend("topright",title=nex,col=ex.col,legend=names(allunique[[i]]),lwd=2)
    }
}

for(nex in names(exps)){
    simudat   <- exps[[nex]]
    allunique <- lapply( unique(simudat$Selection),function(s){
        allsimudat <- lapply(unique(simudat$Mutation),function(m){
            numdat <- simudat[simudat$Selection == s & simudat$Mutation == m,3:5]
            tapply(numdat$Count,numdat$Step,function(sdt)
                       sum(sdt*(sdt-1))/(sum(sdt)*(sum(sdt)-1))
            )
        })
        names(allsimudat)=unique(simudat$Mutation)
        allsimudat
    }) 
    names(allunique)=unique(simudat$Selection)
    
    range(unlist(allunique))
    for(i in seq_along(allunique)){
        plot(0,1,ylim=c(0,1),xlim=c(0,101),type="n",main=names(allunique)[i],xlab="time",ylab="simpson diversity index")
        for(j in seq_along(allunique[[i]])){
            lines(allunique[[i]][[j]],lwd=2,col=ex.col[j])
        }
        legend("topright",title=nex,col=ex.col,legend=names(allunique[[i]]),lwd=2)
    }
}

par(mfrow=c(8,4),cex=1,mar=c(1,2,3,1))
for(nex in names(exps)){
    simudat   <- exps[[nex]]
    for( s in  unique(simudat$Selection)){
        for( m in unique(simudat$Mutation)){
            numdat <- simudat[simudat$Selection == s & simudat$Mutation == m,3:5]
            plot(0,1,ylim=c(0,log(101)),xlim=c(0,101),type="n",main=paste0("selection: ",s,",",nex,": ",m),xlab="time",ylab="log count")
            for(i in numdat$ID){
                nd = numdat[numdat$ID == i,]
                lines(nd$Step,log(nd$Count),lwd=1,col=1)
            }
    }
}
}

par(mfrow=c(2,4),cex=1.2)
exps  <- list(innov=gennew,mutation=mut)
ex.col  <- palette.colors(n=4,palette="Set 2")
for(nex in names(exps)){
    simudat   <- exps[[nex]]

    # Step 2: Calculate sentiment valence for each statement
    # This adds a new column to the data frame for the valence scores
    simudat$Valence <- get_sentiment(simudat$Statement, method = "syuzhet")
    allunique <- lapply( unique(simudat$Selection),function(s){
        allsimudat <- lapply(unique(simudat$Mutation),function(m){
            numdat <- simudat[simudat$Selection == s & simudat$Mutation == m,]
            tapply(numdat$Valence,numdat$Step,mean)
        })
        names(allsimudat)=unique(simudat$Mutation)
        allsimudat
    }) 
    names(allunique)=unique(simudat$Selection)
    range(unlist(allunique))
    for(i in seq_along(allunique)){
        plot(0,1,ylim=c(0,9),xlim=c(0,101),type="n",main=names(allunique)[i],xlab="time",ylab="mean valence")
        for(j in seq_along(allunique[[i]])){
            lines(allunique[[i]][[j]],lwd=2,col=ex.col[j])
        }
        legend("topright",title=nex,col=ex.col,legend=names(allunique[[i]]),lwd=2)
    }
}
