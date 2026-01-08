sel_names <- mut_names <- c("original","efficient","attractive","random")
cols=palette.colors(n=length(mut_names),palette="Set 2")
names(cols)=mut_names
pchs=20+1:length(sel_names) 
names(pchs)=sel_names

library(syuzhet)
for( model in c("GPT3.5","Mistral-7B-Instruct-v0.3","Qwen2.5-7B-Instruct","Qwen2.5-7B-var1")){
for(pref in c("gennew","mut")){

    tryCatch({
    # Read the CSV file
    data <- read.csv(here::here("data",paste0(model,"_",pref,"_concatenated_files.csv")))

    # Calculate each metrics and 
    data$Valence <- get_sentiment(data$Statement, method = "syuzhet")
    data$nchar <- nchar(data$Statement)
    data$logcount <- log(data$Count)
    data$logpercent <- log(data$Count/100)
    data$experience <- paste0(data$Mutation,"-",data$Selection)

    # Find which combination of mut/sel  have been done
    colmut=seq_along(unique(data$Mutation))
    names(colmut)=unique(data$Mutation)
    #colsel=seq_along(unique(data$Selection))
    #names(colsel)=unique(data$Selection)
    colsel=cols
    # Plot metrics over time 
    # Plot setup


    for(var in c("Valence","nchar","Count","logcount")){
        png(paste0(model,"_all_",var,"_",pref,".png"),width=2000,height=2000,pointsize=20)
        par(mfrow=c(4,4),mar=c(0,0,0,0),oma=c(1,8,6,1))
        for( test in unique(data$experience)){
            print(paste(model,test))
            exp=data[data$experience==test,]
            quants=tapply(exp[[var]],exp$Step,quantile)
            mmin=sapply(quants,"[",1)
            mmax=sapply(quants,"[",5)
            mmean=sapply(quants,"[",3)
            x=seq_along(mmax)
            plot(1,1,ylim=range(data[[var]]),xlim=c(0,101),type="n",ylab="Valence")
            if(unique(exp$Mutation)=="original")mtext(unique(exp$Selection),3,3,cex=1.5)
            if(unique(exp$Selection)=="efficient")mtext(unique(exp$Mutation),2,3,cex=1.5)

            #boxplot(exp$Valence ~ exp$step,ylim=range(data$Valence),ylab=test,col=colsel[unique(exp$Selection)])
            polygon(c(x, rev(x)), c(mmax, rev(mmin)), col=adjustcolor(colsel[unique(exp$Selection)],.3), border=colsel[unique(exp$Selection)])
            mmin=sapply(quants,"[",2)
            mmax=sapply(quants,"[",4)
            polygon(c(x, rev(x)), c(mmax, rev(mmin)), col=adjustcolor(colsel[unique(exp$Selection)],.5), border=colsel[unique(exp$Selection)])
            lines(mmean,col=1,lwd=3)
        }
        mtext("Selection:",3,3,at=0,outer=T,cex=1.5)
        if(pref=="mut")mtext("Mutation",2,6,outer=T,cex=1.5)
        else mtext("Generate new from",2,6,outer=T,cex=1.5)

        dev.off()
    }
    for(var in c("logpercent","Count","logcount")){
        png(paste0(model,"_timeline_",var,"_",pref,".png"),width=2000,height=2000,pointsize=20)
        par(mfrow=c(4,4),mar=c(0,0,0,0),oma=c(1,8,6,1))
        for( test in unique(data$experience)){
            print(paste0(model,test))
            try({
            exp=data[data$experience==test,]
            plot(1,1,ylim=range(data[[var]]),xlim=c(0,101),type="n",ylab="Valence",xlab="")
            for(u in unique(exp$ID)){
                a=exp[[var]][exp$ID==u]
                b=exp$Step[exp$ID==u]
                col=colsel[unique(exp$Selection)]
                lines(b,a,col=col)
            }
            if(unique(exp$Mutation)=="original")mtext(unique(exp$Selection),3,3,cex=1.5)
            if(unique(exp$Selection)=="efficient")mtext(unique(exp$Mutation),2,3,cex=1.5)
            })
        }
        mtext("Selection:",3,3,at=0,outer=T,cex=1.5)
        if(pref=="mut")mtext("Mutation",2,6,outer=T,cex=1.5)
        else mtext("Generate new from",2,6,outer=T,cex=1.5)

        dev.off()
    }
    print("done")
    },error=function(e){
        print(paste("combination",model,pref,"not found"))
    })
}
}
