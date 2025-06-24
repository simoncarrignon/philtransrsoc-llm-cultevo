mdl=$1
N=100
t=100
K=50
output_file="concatenated_files.csv"

# Write headers to the output file
echo "Mutation,Selection,Step,ID,Count,Statement" > "${mdl}_mut_$output_file"
echo "Mutation,Selection,Step,ID,Count,Statement" > "${mdl}_gennew_$output_file"

for mut in original efficient random attractive; do
    for sel in efficient attractive original random; do
        echo "doing ${mut} vs ${sel} ===="
        
        # Check and concatenate files if they exist, adding mutation and selection columns
        if [[ -f expK${K}N${N}T${t}_mut${mut}_sel${sel}_${mdl}/processed_statements.csv ]]; then
            awk -v mut="$mut" -v sel="$sel" 'BEGIN{FS=OFS=","}{if(NR>1) print mut,sel,$0}' expK${K}N${N}T${t}_mut${mut}_sel${sel}_${mdl}/processed_statements.csv >> "${mdl}_mut_$output_file"
        fi

        if [[ -f expK${K}N${N}T${t}_gennew${mut}_sel${sel}_${mdl}/processed_statements.csv ]]; then
            awk -v mut="$mut" -v sel="$sel" 'BEGIN{FS=OFS=","}{if(NR>1) print mut,sel,$0}' expK${K}N${N}T${t}_gennew${mut}_sel${sel}_${mdl}/processed_statements.csv >> "${mdl}_gennew_$output_file"
        fi
    done
done

