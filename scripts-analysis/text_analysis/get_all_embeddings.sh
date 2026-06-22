#get all embedding from concatenated file 
#for f in ../../chain-output/merged-csvs/*_gennew_concatenated_file*.csv; do echo $f ; python embed_statement.py $f ; done 
for f in ../../chain-output/merged-csvs/*_gennew_concatenated_file*.csv; do echo $f ; Rscript getDistanceSemanticThrouhgtime.R ${f%%.csv*} ; done 

