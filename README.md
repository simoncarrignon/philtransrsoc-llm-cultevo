Code and Data for paper 
======================

This is a fork of: https://github.com/simoncarrignon/llm-cult-evol

# Project Overview

project contains several scripts, prompts, and results related to language model exploration using Cultural Evolution model. Below is a structured overview of the directory contents, designed to help you navigate the repository efficiently.

## Directory Structure

- 📁 **Root Directory:**
  - 📄 **`README.md`**: The main documentation file you're reading now, outlining important aspects of the project and how to engage with the repository.

- 📁 **`/data/`:**
  - 📜 **High-Level Datasets**:
    - 📄 **`GPT3.5_gennew_concatenated_files.csv`**: Data generated through new statement creation using GPT-3.5.
    - 📄 **`GPT4_mut_concatenated_files.csv`**: Results from mutation experiments using GPT-4.
    - 📄 **`O3MINI_gennew_concatenated_files.csv`** and **`O3MINI_mut_concatenated_files.csv`**: Results from the O3MINI model, for generating new statements and mutations.
  - 📂 **Chains Data**:
    - Each subdirectory (e.g., `expK50N100T100_mutoriginal_selattractive_O3MINI`) contains:
      - 📄 **`processed_statements.csv`**: Represents experiments with specific configurations related to mutation, selection, and model type integration.

- 📁 **`/abc/`:**
  - 📜 **R Scripts:**
    - 📄 **`model-core.R`**, **`abcrfa.R`**, **`metrics.R`**: R scripts facilitating model implementation, metric computation, and ABC application.
  - 📜 **Project Execution Script**:
    - 📄 **`abc_paper_small.R`**: R script for executing small-scale tests of the ABC model and generating results.

- 📁 **`/analysis/`:**
  - 📜 **R Scripts:**
    - 📄 **`newcombine.R`**: Combines datasets for further analysis.
    - 📄 **`plot_abc_posteriors.R`**: Script to visualize ABC posteriors.

- 📁 **`/chain-llms/`:**
  - 📜 **Core Python Scripts:**
    - 📄 **`gptCultEv.py`**: Main Python script to orchestrate and simulate chain experiments.
    - 📄 **`get_top_ten.py`**, **`get_top_two_time.py`**: Scripts to extract full statement from `.pkl` of most frequent statements.
    - 📄 **`toCSV.py`**: Converts `.pkl` file CSV format for accessibility and further analysis.
  - 📓 **Notebook**:
    - 📓 **`GPTEVOL.ipynb`**: Interactive Jupyter Notebook for experimenting with language models.
  - 📜 **Configuration:**
    - 📄 **`Dockerfile`**: Defines the Docker environment setup.
    - 📃 **`requirements.txt`**: Lists Python dependencies for the experiments.

  - 📁 */chain-llms/prompts/** 
    - 📜 Contains various `.prompt` files for model interactions to guide AI behavior (selection and mutation operator)

  - 📜 **Automation and Utilities:**
    - 📄 **`lastautoExplor.sh`**: Shell script for automation of exploratory tasks.
    - 📜 **Scripts for Data Management**:
      - 📄 **`extract_all.py`**, **`extractall.sh`**, **`concatall.sh`**: Scripts and shell commands for managing and processing experiment data files.

# Chain transmission with Chat GPT

A dockerfile is provided to run the expeiremnt, which allow to easily re-run it regardless of the hardware or software you have.

First of all you will need to install docker : https://docs.docker.com/engine/install/

On linux, don't forget to add yourself to the docker group if you don'twant to have to use sudo to run it

```bash
   sudo groupadd docker
   sudo usermod -aG docker $USER
```

## Build and run the docker

To build the docker

```bash
cd chain-llms/
docker build -t llmchain .
```

And to run it you will need your OPENAIA KEY 

I pass it using --env option from dockers, but many other option are possible. thus ou cna try:

```bash
docker run --rm  --env OPENAI_API_KEY=$OPENAI_API_KEY llmchain --help
```

A full command will look like that:

```bash
docker run --rm  -v ./results:/usr/src/app/results --env OPENAI_API_KEY=$OPENAI_API_KEY llmchain -N 20 -t 10 -k 5 --statements statements.txt --modprompt prompts/generatenew_random_health.prompt --selprompt prompts/select_random.prompt --outdir "results/"
```

Where is -v is used to link the output folder within the docker with a local folder

For the python version:

```bash
export OPENAI_API_KEY="key"
```

This use the python virtual env:

```bash
./bin/python3 gptCultEv.py
```

Once the experiment is done two files are create: `alltstepbeta.pkl` & `variantsbeta.pkl`
They store informaiton about the variants seleted through time and the satetment generated. They can be exctracted using:

```bash
python3 get_top_ten.py  --outdir results
python3 toCSV.py --outdir results > results.csv
```
- `get_top_ten.py` prints the 10 most used statements at the end of the simulation
- `toCSV.py` creates a csv with how many  agents have choose each traits ; one row per time step and one column per statement 

# Model of Cultural Transmission

Model inspired by: https://royalsocietypublishing.org/doi/full/10.1098/rsif.2022.0570 and others

## Theoretical

# Approximate Bayesian Computation

This implementatio of ABC rely on random forest to adjust the posterior distribution based on multiple summary statistique.

## how too
