# Code and Data for paper 

This is a fork of: https://github.com/simoncarrignon/llm-cult-evol

# Project Overview

project contains several scripts, prompts, and results related to language model exploration using Cultural Evolution model. Below is a structured overview of the directory contents, designed to help you navigate the repository efficiently.

### Directory Structure

- 📁 **Root Directory:**
  - 📄 `lastautoExplor.sh`: A shell script likely used for automation or exploration tasks.
  - 📄 `lis`: A list file, potentially containing itemized data or configurations.
  - 📄 `README.md`: The file you are currently reading.
  - 📜 `read.R`: An R script for data processing or analysis.
  - 🗃️ `results.csv`: A CSV file containing consolidated results or data outputs.

- 📁 **chain-llms/**:
  - 📄 `Dockerfile`: Configuration for setting up the Docker environment.
  - 📄 `get_top_ten.py`: A Python script to extract top ten statement from an experiment
  - 📄 `get_top_two_time.py`: cf above
  - 📄 `gptCultEv.py`: core script to generate a chain experiment, described below
  - 📓 `GPTEVOL.ipynb`: Jupyter Notebook to interactively play with LLMs and reproduce the expeirment
  - 📃 `requirements.txt`: A listing of Python dependencies necessary for the project.

  - 📁 **prompts/**:
    - Contains prompt files used to drive the experiment
      - 📜 `generatenew_attractive_health.prompt`
      - 📜 `generate_new_convincing.prompt`
      - 📜 `generatenew_efficient_health.prompt`
      - 📜 `generatenew_original_health.prompt`
      - 📜 `generatenew_random_health.prompt`
      - 📜 `modify_previous_for_more_attractive.prompt`
      - 📜 `modify_previous_for_more_efficient.prompt`
      - 📜 `modify_previous_for_more_original.prompt`
      - 📜 `modify_previous_for_more_random.prompt`
      - 📜 `modify_previous_random.prompt`
      - 📜 `select_attractive.prompt`
      - 📜 `select_efficient.prompt`
      - 📜 `select_original.prompt`
      - 📜 `select_random.prompt`


## Chain transmission with Chat GPT

A dockerfile is provided to run the expeiremnt, which allow to easily re-run it regardless of the hardware or software you have.

First of all you will need to install docker : https://docs.docker.com/engine/install/

On linux, don't forget to add yourself to the docker group if you don'twant to have to use sudo to run it

```bash
   sudo groupadd docker
   sudo usermod -aG docker $USER
```

### Build and run the docker

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

## Model of Cultural Transmission

Model inspired by: https://royalsocietypublishing.org/doi/full/10.1098/rsif.2022.0570 and others

### Theoretical

## Approximate Bayesian Computation

Model inspired by: https://royalsocietypublishing.org/doi/full/10.1098/rsif.2022.0570 and others

### how too
