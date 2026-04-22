

source(here::here("scripts-analysis/abc/R/model-slots.R"))
source(here::here("scripts-analysis/var/heatmap.R"))

m=10
tstep=100
N=100
p0=rep(N/m,m)
u0="rnorm"
mu=.1

model.slot(p0=p0,J=1,u0=u0,beta=1,sde=1,tstep=tstep,e=10,mu=mu,N=N,m=m,mutate=T,log=F,K=50,useslots=T)

allparam=list(c(0,1.2),c(1.2,1.2),c(0,0),c(1.2,0))
par(mfrow=c(2,2),mar=c(.5,.5,.5,.5),oma=c(4,2,2,.5))
for( jb in allparam){
    plot(1,1,ann=F,axes=F,type="n")
    rect( par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4], col = "black")
    par(new=T)
    heatmap_utility(model.slot(p0=p0,J=jb[1],u0=u0,beta=jb[2],sde=1,tstep=tstep,e=1,mu=mu/2,N=N,m=m,mutate=T,log=F,K=50,useslots=T),ann=F,axes=F,pal=viridis::magma(256))
    if(jb[2]==0)(axis(1,label=pretty(seq(1,100,length.out=5)),at=pretty(seq(0,1,length.out=5))))
    box()
}
mtext("J=0",3,.5,0.25,outer=T)
mtext("J=1.2",3,.5,0.75,outer=T)
mtext(expression(beta==0),2,.5,0.25,outer=T)
mtext(expression(beta==1.2),2,.5,0.75,outer=T)
mtext("time",1,2,0.25,outer=T)
mtext("time",1,2,0.75,outer=T)


pref="gennew"
# Read the CSV file output of the all chains fr this model
data <- read.csv(here::here("chain-output","merged-csvs",paste0(model,"_",pref,"_concatenated_files_1.csv")))
data  <- data[data$Mutation == mut & data$Selection == sel,]


ids=unique(data$ID[data$Step < 15])
colsid=adjustcolor(rainbow(length(ids)))
names(colsid)=as.character(ids)

    heatmap_utility(model.slot(p0=p0,J=jb[1],u0=u0,beta=jb[2],sde=1,tstep=tstep,e=1,mu=mu/2,N=N,m=m,mutate=T,log=F,K=50,useslots=T),ann=F,axes=F,pal=viridis::magma(256))

mutations="original"#c("random","efficient")
par(mfrow=c(3,2),mar=c(.5,.5,.5,.5),oma=c(4,2,2,.5))
m="Mistral-7B-Instruct-v0.3"
pref="mut"
for(mut in mutations){
	for(sel in mutations){


			data <- read.csv(here::here("chain-output","merged-csvs",paste0(m,"_",pref,"_concatenated_files.csv")))
		data  <- data[data$Mutation == mut & data$Selection == sel,]
		data  <- data[data$Step < 50,]
aa=list()
aa$freq=xtabs(Count ~ ID + Step, data[,c("ID","Count","Step")])
aa$ut = 1:nrow(aa$freq)


				plot(1,1,ann=F,axes=F,type="n")
				rect( par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4], col = "black")
				par(new=T)
				heatmap_utility(aa,ann=F,axes=F,pal=viridis::magma(256))
				if(mut=="efficient")(axis(1,label=pretty(seq(1,50,length.out=5)),at=pretty(seq(0,1,length.out=5))))
				box()
	}
}
mtext("Selection Random",3,.5,0.25,outer=T)
mtext("Selection Efficient",3,.5,0.75,outer=T)
mtext("Mutation Efficient",2,.5,0.25,outer=T)
mtext("Mutation Random",2,.5,0.75,outer=T)
mtext("time",1,2,0.25,outer=T)
mtext("time",1,2,0.75,outer=T)

mutations="original"#c("random","efficient")
selection=c("random","efficient")
par(mfrow=c(3,2),mar=c(.5,.5,.5,.5),oma=c(4,2,2,.5))
models=c("Mistral-7B-Instruct-v0.3","GPT3.5","Qwen2.5-7B-Instruct")
pref="mut"
for(m in models){
	for(sel in selection){


			data <- read.csv(here::here("chain-output","merged-csvs",paste0(m,"_",pref,"_concatenated_files.csv")))
		data  <- data[data$Mutation == mut & data$Selection == sel,]
		data  <- data[data$Step < 50,]
aa=list()
aa$freq=xtabs(Count ~ ID + Step, data[,c("ID","Count","Step")])
aa$ut = 1:nrow(aa$freq)


				plot(1,1,ann=F,axes=F,type="n")
				rect( par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4], col = "black")
				par(new=T)
				heatmap_utility(aa,ann=F,axes=F,pal=viridis::magma(256))
				if(mut=="efficient")(axis(1,label=pretty(seq(1,50,length.out=5)),at=pretty(seq(0,1,length.out=5))))
				box()
	}
}
mtext("Selection Random",3,.5,0.25,outer=T)
mtext("Selection Efficient",3,.5,0.75,outer=T)
mtext("Qwen",2,.5,0.15,outer=T)
mtext("GPT3.5",2,.5,0.5,outer=T)
mtext("Mistral 7B",2,.5,0.85,outer=T)
mtext("time",1,2,0.25,outer=T)
mtext("time",1,2,0.75,outer=T)
