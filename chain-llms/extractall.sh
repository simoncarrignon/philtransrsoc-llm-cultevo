N=100
t=100
K=50
model=$1
#

for mut in original efficient random attractive;
do
    for sel in efficient attractive original random; 
    do

        echo "doing ${mut} vs ${sel} ===="
        python3 extract_all.py --outdir  expK${K}N${N}T${t}_mut${mut}_sel${sel}_${model} 
        #selection no mutation
        python3 extract_all.py --outdir  expK${K}N${N}T${t}_gennew${mut}_sel${sel}_${model} 

    done
done
