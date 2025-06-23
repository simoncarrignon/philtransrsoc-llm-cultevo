# Code and Data for paper 

This is a fork of: https://github.com/simoncarrignon/llm-cult-evol

## Chain transmission with Chat GPT

To run the chain experiment, needs of python 

### Install on Debian with venv

```bash
sudo apt install python3.10-venv
python3 -m venv . #activate environment in the local repo
./bin/pip3 install openai  #install openai
./bin/pip3 install requests
```





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
