import csv
import os
import random

from dotenv import load_dotenv
from random_username.generate import generate_username

load_dotenv()
data_dir = "." + os.getenv("CSV_DIR")

filename = data_dir + "/services.csv"
header = ["service_name"]
data = []
svcs = [
    "OWA",
    "MAPI",
    "RPC",
    "Autodiscover",
    "Powershell",
    "EWS",
    "ECP",
    "OAB",
    "Services",
    "Replication",
    "MRS",
    "MAPI-Connectivity",
    "Maintenance",
    "Active DBs",
    "Passive DBs",
    "Disks",
    "BitLocker",
    "Anti-Malware",
    "PendingReboot",
]

with open(filename, "w", encoding="UTF8") as f:
    writer = csv.writer(f)

    # write the header
    writer.writerow(header)

    for s in svcs:
        data = [s]
        writer.writerow(data)

filename = data_dir + "/users.csv"
header = ["username"]
data = []
users = []  # Will contain the generated list of DCs

with open(filename, "w", encoding="UTF8") as f:
    writer = csv.writer(f)

    # write the header
    writer.writerow(header)

    users = generate_username(20)
    for u in users:
        data = [u]
        writer.writerow(data)

filename = data_dir + "/dc.csv"
header = ["dc_name"]
data = []
dcs = []  # Will contain the generated list of DCs

with open(filename, "w", encoding="UTF8") as f:
    writer = csv.writer(f)

    # write the header
    writer.writerow(header)

    # Generate DC names into file and store into list
    for d in range(5):
        for i in range(8):
            data = [f"S-DC-EXC0{d+1}0{i+1}"]
            dcs.append(data[0])
            writer.writerow(data)

# Read Services names
with open(data_dir + "/services.csv") as file:
    svcs = file.read().split("\n")
svcs.pop(0)  # Remove Header
svcs = list(filter(None, svcs))  # remove empty strings

# Generate Status
filename = data_dir + "/dc-svc.csv"
header = ["host", "app", "status"]
data = []

with open(filename, "w", encoding="UTF8") as f:
    writer = csv.writer(f)

    # write the header
    writer.writerow(header)

    for dc in dcs:
        for svc in svcs:
            status = "ok"
            if random.randrange(100) >= 98:
                status = "no"
            data = [dc, svc, status]
            writer.writerow(data)

# Generate mail traffic
filename = data_dir + "/send-receive.csv"
header = ["sender", "receiver", "bytes"]
data = []

with open(filename, "w", encoding="UTF8") as f:
    writer = csv.writer(f)

    # write the header
    writer.writerow(header)
    for i in range(200):
        sender = random.choice(users)
        receiver = random.choice(users)
        bytes = random.randint(100, 1000)
        data = [sender, receiver, bytes]
        writer.writerow(data)

# Generate webmail status
filename = data_dir + "/webmail.csv"
header = ["host", "status"]
data = []

hosts = [
    "server",
    "webmail",
    "ecp",
    "ews",
    "eas",
    "oab",
    "mapi",
    "autodiscover",
    "autodiscover.ext",
    "powershell",
    "oos",
]

with open(filename, "w", encoding="UTF8") as f:
    writer = csv.writer(f)

    # write the header
    writer.writerow(header)

    for host in hosts:
        status = "ok"
        if random.randrange(100) >= 90:
            status = "no"
        data = [host + ".webmail.ec.europa.eu", status]
        writer.writerow(data)
