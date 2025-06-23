# Code and Data for paper 

This is a fork of: https://github.com/simoncarrignon/llm-cult-evol

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




For the python version:

```bash
export OPENAI_API_KEY="key"
```

This use the python virtual env:

```bash
./bin/python3 gptCultEv.py
```


So far nothing as been parametrized and thing (mutation rate, length of simulation, statements,...) needs to be hardcoded in the main python file gptCultEv

Once the experiment is done two files are create: `alltstepbeta.pkl` & `variantsbeta.pkl`
They store informaiton about the variants seleted through time and the satetment generated. They can be exctracted using:

```bash
python3 get_top_ten.py 
python3 toCSV.py 
```

- `get_top_ten.py` printsthe 10 most used statements at the end of the simulation
- `toCSV.py` creates a csv with the number of instance who choose each traits ; one row per time step and one column per statement 

## Model of Cultural Transmission

Model inspired by: https://royalsocietypublishing.org/doi/full/10.1098/rsif.2022.0570 and others

### Theoretical

## Approximate Bayesian Computation

Model inspired by: https://royalsocietypublishing.org/doi/full/10.1098/rsif.2022.0570 and others

### Theoretical
