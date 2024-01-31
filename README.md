# Chani transmission with Chat GPT


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
python3 get_top_ten.py #this willprint the 10 most used statement at the end of the simulation
python3 toCSV.py #this create a csv with the number of instance who choose each traits ; one row per time step and one column per statement 
```


