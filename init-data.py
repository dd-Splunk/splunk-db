import csv
import random

filename = "./data/dc.csv"
header = ["dc_name"]
data = []

with open(filename, "w", encoding="UTF8") as f:
    writer = csv.writer(f)

    # write the header
    writer.writerow(header)

    # Geerate DC names
    for d in range(5):
        for i in range(8):

            data = [f"S-DC-EXC0{d+1}0{i+1}"]
            writer.writerow(data)

# Read DCs names
with open("./data/dc.csv") as file:
    dcs = file.read().split("\n")
dcs.pop(0)  # Remove Header
dcs = list(filter(None, dcs))  # remove empty strings

# Read Services names
with open("./data/services.csv") as file:
    svcs = file.read().split("\n")
svcs.pop(0)  # Remove Header
svcs = list(filter(None, svcs))  # remove empty strings

filename = "./data/dc-svc.csv"
header = ["host", "app", "status"]
data = []

with open(filename, "w", encoding="UTF8") as f:
    writer = csv.writer(f)

    # write the header
    writer.writerow(header)

    for dc in dcs:
        for svc in svcs:
            status = "ok"
            if random.randrange(100) >= 95:
                status = "no"
            data = [dc, svc, status]
            writer.writerow(data)
