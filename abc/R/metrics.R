#below are wrappers for our different metrics: they usually transform a table representing each traits frequency for each phase into a single vector with the value of the metric for each phase.
d.sim <- function(freqarray)1-apply(freqarray,2,simpson)
relfreq  <-  function(freqarray)apply(freqarray,2,function(f)f/sum(f))
d.gap <- function(freqarray)apply(apply(relfreq(freqarray),2,range),2,function(i)i[2]-i[1])
d.turn <- function(freqarray)getTurnover(freqarray,10)
d.spec <- function(freqarray)GeneCycle::periodogram(d.sim(freqarray))$spec[,1]
d.unique <- function(freqarray)apply(freqarray,2,function(i)sum(i>0))
d.gini <- function(freqarray)apply(freqarray,2,gini)
d.lognormmean <- function(freqarray)apply(freqarray,2,lognormmean)
d.lognormsd <- function(freqarray)apply(freqarray,2,lognormsd)


#' Compute turnover
#' @param datfreq a table
#' @param the number of element in the top list
getTurnover <- function(datfreq,Y){
    rankmin=(nrow(datfreq)-Y) #need to be ranked above that to be in topY
    sapply(1:(ncol(datfreq)-1),function(t)
           {
               rk1=rank(datfreq[,t],ties.method="min")
               rk2=rank(datfreq[,t+1],ties.method="min")
               r1=which(rk1>rankmin)
               r2=which(rk2>rankmin)
               return(sum(!(r2 %in% r1)))
           })
}


lognormmean <- function(vecval){
    require(poweRlaw)
    vecval=vecval[vecval>0]
    vecval=vecval[!is.na(vecval)]
    mln = poweRlaw::dislnorm$new(vecval)
    estln = poweRlaw::estimate_xmin(mln)
    if(is.na(estln$pars[1]))10
    else estln$pars[1]
}

lognormsd <- function(vecval){
    require(poweRlaw)
    vecval=vecval[vecval>0]
    vecval=vecval[!is.na(vecval)]
    mln = poweRlaw::dislnorm$new(vecval)
    estln = poweRlaw::estimate_xmin(mln)
    if(is.na(estln$pars[2]))10
    else estln$pars[2]
}


simpson <- function(vecval,normalize=T){
	sum(vecval*(vecval-1))/(sum(vecval)*(sum(vecval)-1))
}

gini <- function(datfreq){
    datfreq=datfreq[datfreq>0]
    st=0
    for(i in datfreq){
        si=0
        for( j in datfreq) si=si+abs(i-j)
        st=st+si
    }
    st/(2*length(datfreq)^2*mean(datfreq))
}

getMaxFreq <- function(datfreq,normalize=T){
    sm=getsimpson(datfreq)
    f.data=GeneCycle::periodogram(sm)
    f.data$freq[which.max(f.data$spec/sum(f.data$spec))]*length(sm)
}

GetNumTraits <- function(datfreq) apply(datfreq,2,function(i)sum(i>0))
GetMaxNumTraits <- function(datfreq) max(apply(datfreq,2,function(i)sum(i>0)))

getMaxFreqTraits <- function(datfreq,normalize=T){
    sm=GetNumTraits(datfreq)
    f.data=GeneCycle::periodogram(sm)
    f.data$freq[which.max(f.data$spec/sum(f.data$spec))]*length(sm)
}


getModeFreq <- function(datfreq,normalize=T){
    f.d=GeneCycle::periodogram(getsimpson(datafreq))
    #hdrcde::den(f.d$)$mode
}

getModeSimpson <- function(datfreq){
    hdrcde::hdr(getsimpson(datfreq))$mode
}

getMeanLastU <- function(datsim,tstep){sum(datsim$ut*datsim$freq[,tstep+1])/sum(datsim$freq[,tstep+1])}


RMSE <- function(m,s)sqrt(sum(m-s)^2)

