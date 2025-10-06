N=100
t=100
K=50
#
model="Mistral-7B-Instruct-v0.3"

for mut in original efficient random attractive;
do
    for sel in efficient attractive original random; 
    do

        echo "doing ${mut} vs ${sel} ===="
        #mutation
        outdir=expK${K}N${N}T${t}_mut${mut}_sel${sel}_${model}
        if [ ! -d "$outdir" ]; then
            mkdir $outdir
            time ./bin/python3 ./gptCultEv.py -N $N -t $t -k $K --statements statements.txt --modprompt new_mutation_prompts/modify_previous_for_more_${mut}.prompt --selprompt prompts/select_${sel}.prompt --mutate 'yes' --outdir ${outdir}    > $outdir/${outdir}.log 
            #generation from scratch
        else
            echo "Skipping ${outdir} as it already exists."
        fi
        outdir=expK${K}N${N}T${t}_gennew${mut}_sel${sel}_${model}
        if [ ! -d "$outdir" ]; then
            mkdir $outdir
            time ./bin/python3 ./gptCultEv.py -N $N -t $t -k $K --statements statements.txt --modprompt prompts/generatenew_${mut}_health.prompt --selprompt prompts/select_${sel}.prompt --outdir ${outdir} > $outdir/${outdir}.log    
        else
            echo "Skipping ${outdir} as it already exists."
        fi

    done
done
