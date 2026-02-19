#' general function
#' @param p0: vector initial frequencies
#' @param J: social
#' @param u: list of utility or function do comput utility of cultural traits
#' @param beta:  transparancy
#' @param sde: stander deviation of copy error
#' @param tstep: number of timestep
#' @param mu: rate of inovation
#' @param N: number of social individual
#' @param m: number of different cultural traits
#' @return: matrice with frequency for each time steps
#' @export
model.slot <- function(p0,J,u0,unit=NULL,beta,sde,tstep,mu,N,m,prob=p,mutate=TRUE,cumul=FALSE,e=1,log=FALSE,K=50,useslots=T){
    if(is.character(u0)){
        if(u0=="runif")
            u=runif(m,-e,e)
        else{
            u=get(u0)(m,0,e)
        }
    }
    else if(length(u0)!=m)
        u=sample(u0,m)
    else
        u=u0
    if(!is.null(unit))u=unit

    approxMaxLength <- length(p0)+N*mu*tstep
    final <- matrix(0,approxMaxLength,tstep+1) 
    final[1:length(p0),1] <- p0
    pt <- p0
    stopifnot(length(pt)==length(u))
    newTraits <- 0
    slots <- 1:m#sample(x=seq_along(p0),size=K,replace=T)
    for(t in 2:(tstep+1)){

        if(log)print(paste0(t,"/",tstep))
        remainings=which(pt>0) 
        if(length(remainings)==1) pt[remainings]=N #if only one trait availalbe no need for any selection, agents get all the same traits
        else{
            if(useslots){
                counts  <<- table(slots)
                available <<- as.numeric(names(counts))
                if(t>2)stopifnot(sum(counts)==K)
                if(length(available)==1) selection <- table(rep(available,N))
                else{
                    rawpt <- prob(p_t=counts/K,J=J,u=u[available],beta=beta,sde=sde)
                    selection <- table(sample(available,size=N,replace=T,prob=rawpt))
                }
            }
            else{
                rawpt <- prob(p_t=pt[remainings]/N,J=J,u=u[remainings],beta=beta,sde=sde)
                selection <- table(sample(remainings,size=N,replace=T,prob=rawpt))
            }

            pt[remainings] <- 0
            pt[as.numeric(names(selection))] <- as.numeric(selection)
            pt[pt<0] <- 0
            if(NA %in% pt)pt[is.na(pt)] <- N/sum(is.na(pt)) #if we have infinite proba it meas that selection will be split among those traits with infinite proba but this is dealt with -- not in the best way -- at the level of prob()
        }

        remainings=which(pt>0) 
        pb=N-sum(pt)
        stopifnot(!is.na(pb))
        stopifnot(pb==0)

        if(useslots) newTraits <- rbinom(1,K,mu)
        else newTraits <- rbinom(1,N,mu)

        if(length(remainings)==1) slots <- rep(remainings,K-newTraits)
        else slots <- sample(x=remainings,size=K-newTraits,prob=pt[remainings],replace=T)

        if(newTraits>0){ #we choose among the cultural traits the one that will loose users (user who will innovate)
            remainings=which(pt>0) 
			if(length(remainings)==1){ #handling case with 1
				inovators=rep(remainings,newTraits)
			}
			else{
                indrem=rep(remainings,pt[remainings]) # here we convert counts in a vector where traits id are repeated as many time as they are in use in population
				inovators=sample(indrem,size=newTraits) #choose which agent will switch to a new trait
			}
            count_inovators = table(inovators) #count inovators and group them if the where using the same cultural traits
			while(any(pt[as.numeric(names(count_inovators))]<count_inovators)){
				inovators=sample(remainings,newTraits,replace=TRUE,prob=pt[remainings]) #choose which agent will switch to a new trait
				count_inovators = table(inovators) 
                print(newTraits)
			}
            if(is.character(u0)){
                if(mutate){ 
                    epsilons=c()
                    if(e==0) epsilons=rep(0,newTraits)
                    else{
                        if(u0=="runif")
                            epsilons=runif(newTraits,-e,e)
                        else{
                            epsilons=get(u0)(newTraits,0,e)
                        }
                        stopifnot(all(!is.na(epsilons)))
                    }
                    lnewtraits=u[inovators]+epsilons
                }
                else if(cumul){ 
                    newm=mean(u[pt>0])
                    lnewtraits=get(u0)(newTraits,newm)
                }
                else
                    lnewtraits=get(u0)(newTraits)

            }
            else
                lnewtraits=sample(u0,newTraits,replace=TRUE) #sample new utility from the original distribution
            u=c(u,lnewtraits) #add the new utilities to utility pool

            #recompute frequencies after inventors switched to new variants
            pt[as.numeric(names(count_inovators))]=pt[as.numeric(names(count_inovators))]-as.vector(count_inovators)
            slots <- c(slots,(length(pt)+1):(length(pt)+newTraits))
            pt=c(pt,rep(1,newTraits)) #new cultural traits have  1 represent thus frequency  of 1/N 
        }
        while(length(pt)>nrow(final))
        {
            newchunk=t(replicate(length(pt)-nrow(final),rep(0,ncol(final))))
            final=rbind(final,newchunk) #extend result matrix
        }
        final[1:length(pt),t]=pt
        stopifnot(sum(pt)==N,length(pt)==length(u))
    }
    final=final[seq_along(u),] #remove empty row that weren't used (save space)
    return(list(freq=final,ut=u))
}


#' probability model (from Vidiella et all 2023)
#' 
#' @param p_t: a vector of frequencies at time t
#' @param J: an integer quantifying the weight of those freqnecies (if <-1 : anticonformist bias, if 0 neutral, if >1 conformist) 
#' @param u: a list of utility or function to comput utility of cultural traits (same size that p_t)
#' @param beta:  transparancy
#' @param sde: standard deviation of error in estimating the utilitoes
#' @return: a vector of same size that p_t and u with the frequencies at time t+1

p <- function(p_t, J, u, beta, sde){
  eps <- `if`(sde > 0, rnorm(length(p_t), mean = 0, sd = sde), 0)
  p <- p_t^J * exp(beta*u + eps)
  p_t <- p / sum(p)
  return(replace(p_t, is.na(p_t), 1/sum(is.na(p_t)))) #this is problematic for very high J and beta 
}

