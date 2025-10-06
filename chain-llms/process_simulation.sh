model=$1
curr=$PWD
bash ./extractall.sh $model
bash ./concatall.sh $model
#cd  ../abc/
#Rscript abc_paper_small.R output_${model}  ${curr}
#cd  ${curr}
