
#' a function to plot the distribution of utility as a heatmpa
#' @param datafreq the result of function model, a list with one datframe in $freq and a vctor of utility in $ut
#' @export
heatmap_utility <- function(datafreq,pal=hcl.colors(256,"Zissou 1",rev=F),axis=F,...){
    us=sort(unique(round(datafreq$ut,1)))
    frq=datafreq$freq
    hm=sapply(us,function(u)apply(frq[ round(datafreq$ut,1)==u,,drop=F],2,sum))
    image(log(hm),col=pal,xlab="time",ylab="utility",xaxt="n",yaxt="n",...)
    if(axis)axis(2,at=seq(0,1,length.out=5),label=round(seq(min(us),max(us),length.out=5)))
    if(axis)axis(1,at=seq(0,1,length.out=5),label=round(seq(1,ncol(frq)-1,length.out=5)))
    return(hm)
}

