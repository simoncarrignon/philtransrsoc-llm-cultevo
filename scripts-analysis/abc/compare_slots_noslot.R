source("R/model-slots.R")


### When having "Slot" it slow donw the utility incrase and increaset the drift. Logicial as we artificially reduce N. If K =N then results are very similaru, regardles of the other parameter



par(mar=c(1,3,1,0),mfrow=c(8,2));mu=0.01;m=10;J=1.1;beta=.1;N=30*m;
replicate(8,
{
   heatmap_utility(model.slot(u0="runif",m=m,sde=1,p0=rep(N/m,m),N=N,mu=mu,tstep=200,p=p,J=J,beta=beta,useslots=T,log=T,K=50));
   heatmap_utility(model.slot(u0="runif",m=m,sde=1,p0=rep(N/m,m),N=N,mu=mu,tstep=200,p=p,J=J,beta=beta,useslots=F,log=T))
})


par(mar=c(1,3,1,0),mfrow=c(8,2));mu=0.01;m=10;J=1.1;beta=.1;N=30*m;
replicate(8,
{
   heatmap_utility(model.slot(u0="runif",m=m,sde=1,p0=rep(N/m,m),N=N,mu=mu,tstep=200,p=p,J=J,beta=beta,useslots=T,log=T,K=N));
   heatmap_utility(model.slot(u0="runif",m=m,sde=1,p0=rep(N/m,m),N=N,mu=mu,tstep=200,p=p,J=J,beta=beta,useslots=F,log=T))
})


par(mar=c(1,3,1,0),mfrow=c(8,2));mu=0.01;m=10;J=0.1;beta=1;N=30*m;
replicate(8,
{
   heatmap_utility(model.slot(u0="runif",m=m,sde=1,p0=rep(N/m,m),N=N,mu=mu,tstep=200,p=p,J=J,beta=beta,useslots=T,log=T,K=50));
   heatmap_utility(model.slot(u0="runif",m=m,sde=1,p0=rep(N/m,m),N=N,mu=mu,tstep=200,p=p,J=J,beta=beta,useslots=F,log=T))
})


par(mar=c(1,3,1,0),mfrow=c(8,2));mu=0.01;m=10;J=0.1;beta=1;N=30*m;
replicate(8,
{
   heatmap_utility(model.slot(u0="runif",m=m,sde=1,p0=rep(N/m,m),N=N,mu=mu,tstep=200,p=p,J=J,beta=beta,useslots=T,log=T,K=N));
   heatmap_utility(model.slot(u0="runif",m=m,sde=1,p0=rep(N/m,m),N=N,mu=mu,tstep=200,p=p,J=J,beta=beta,useslots=F,log=T))
})

