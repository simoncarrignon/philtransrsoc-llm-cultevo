import pickle
import argparse
import os
import numpy as np

# Setup argument parser
parser = argparse.ArgumentParser(description='Extract and print all unique statements.')
parser.add_argument('--outdir', action="store", dest='outdir', default='.')
args = parser.parse_args()

# Directory to store the output file
outdir = args.outdir

# Load data from pickle files
all_steps = pickle.load(open(os.path.join(outdir, "alltstepbeta.pkl"), 'rb'))
all_statements = pickle.load(open(os.path.join(outdir, "variantsbeta.pkl"), "rb"))
all_prompt = pickle.load(open(os.path.join(outdir, "inpromptbeta.pkl"), "rb"))

output_file_path = os.path.join(outdir, "processed_statements.csv")

# Open the output file in write mode
with open(output_file_path, "w") as output_file:
    output_file.write('Step,ID,Count,InPromptCount,Statement\n')

    # Iterate through the list of steps
    for step_index, steps in enumerate(all_steps):
        # Iterate through each value in the step
        counts=None
        if step_index<len(all_prompt) :
            counts=np.unique(all_prompt[step_index],return_counts=True)
            counts= dict(zip(counts[0],counts[1]))
        for stat_index, stat_value in enumerate(steps):
            # Check if the value is greater than 0
            if stat_value > 0:
                # Extract the corresponding statement and sanitize it
                statement = all_statements[stat_index]["statement"]
                if counts is not None:
                    inprompt_count = counts.get(stat_index,0)
                else:
                    inprompt_count = 'NA'
                sanitized_statement = statement.replace('"', "'")  # Remove any existing quotes
                # Write step index, value, and sanitized statement to the file
                output_file.write(f'{step_index},{stat_index},{stat_value},{inprompt_count},"{sanitized_statement}"\n')

print(f"All results have been written to {output_file_path}.")
