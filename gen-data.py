import csv  
import random

# Read DCs names
with open("./data/dc.csv") as file:
    dcs = file.read().split('\n')
dcs.pop(0) # Remove Header
dcs = list(filter(None, dcs)) # remove empty strings

# Read Services names
with open("./data/services.csv") as file:
    svcs = file.read().split('\n')
svcs.pop(0) # Remove Header
svcs = list(filter(None, svcs)) # remove empty strings

# Genberate Data for DC services failure
for i in range (100):
    if random.randrange(100) >= 95: 
        dc = random.choice(dcs)
        svc = random.choice(svcs)
        print(dc, svc)
