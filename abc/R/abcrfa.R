abcrfa <- function(target, param, sumstat, tol,...){
    require(abc)
    require(ranger)
    model = abc(target, param = param, sumstat = sumstat, tol, method = "loclinear")#,transf="log")
    weights=model$weights
    unadj.values=model$unadj.values
    N=dim(sumstat)[1]
    subnumber=c(1:N)[model$region]
    wei=weights/sum(weights)
    #### randomforest regression adjustment
    re=c(which(wei==0))
    againwei=wei[-re]
    subnumber=c(1:N)[model$region][-re]
    npara=dim(param)[2]
    adj.values=matrix(1,length(subnumber),npara)
    for(i in 1:npara){
        data=data.frame(param[,i],sumstat)
        names(data)[1]<-'param'
        tree.model <- ranger(param~.,data=data[subnumber,],case.weights = againwei,...)
        pred=1:length(againwei)
        for(k in 1:length(againwei)){
            if(tree.model$predictions[k]=="NaN"){
                pred[k]=predict(tree.model,data[subnumber,][k,-1])$predictions
            }
            else{
                pred[k]=tree.model$predictions[k]
            }
        } 

        residuals=data[subnumber,1]-pred
        names(target)=names(data)[-1]
        adj.values[,i]=predict(tree.model,data=target)$predictions+residuals
    }
    return(list(adj.values=adj.values,unadj.values=unadj.values))
}
