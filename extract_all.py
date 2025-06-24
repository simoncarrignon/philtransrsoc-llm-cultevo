import pickle
import argparse
import os

# Setup argument parser
parser = argparse.ArgumentParser(description='Extract and print all unique statements.')
parser.add_argument('--outdir', action="store", dest='outdir', default='.')
args = parser.parse_args()

# Directory to store the output file
outdir = args.outdir

# Load data from pickle files
all_steps = pickle.load(open(os.path.join(outdir, "alltstepbeta.pkl"), 'rb'))
all_statements = pickle.load(open(os.path.join(outdir, "variantsbeta.pkl"), "rb"))

output_file_path = os.path.join(outdir, "processed_statements.csv")

# Open the output file in write mode
with open(output_file_path, "w") as output_file:
    # Iterate through the list of steps
    for step_index, steps in enumerate(all_steps):
        # Iterate through each value in the step
        for stat_index, stat_value in enumerate(steps):
            # Check if the value is greater than 0
            if stat_value > 0:
                # Extract the corresponding statement and sanitize it
                statement = all_statements[stat_index]["statement"]
                sanitized_statement = statement.replace('"', "'")  # Remove any existing quotes
                # Write step index, value, and sanitized statement to the file
                output_file.write(f'{step_index},{stat_index},{stat_value},"{sanitized_statement}"\n')

print(f"All results have been written to {output_file_path}.")
