N=100
t=100
K=50
#

for mut in original efficient random attractive;
do
    for sel in efficient attractive original random; 
    do

        echo "doing ${mut} vs ${sel} ===="
        time ./bin/python3 ./gptCultEv.py -N $N -t $t -k $K --statements statements.txt --modprompt modify_previous_for_more_${mut}.prompt --selprompt select_${sel}.prompt --mutate 'yes' --outdir expK${K}N${N}T${t}_mut${sel}_sel${sel}_GPT3.5 --image "e"  &
        # 
        #selection no mutation
        time ./bin/python3 ./gptCultEv.py -N $N -t $t -k $K --statements statements.txt --modprompt generatenew_${mut}_health.prompt --selprompt select_${sel}.prompt --outdir expK${K}N${N}T${t}_gennew${sel}_sel${sel}_GPT3.5 --image "e"  

    done
done
