import csv  

filename = './data/dc.csv'
header = ['dc_name']
data = []

with open(filename, 'w', encoding='UTF8') as f:
    writer = csv.writer(f)

    # write the header
    writer.writerow(header)

    # Geerate DC names
    for d in range(5):
        for i in range(8):

            data = [f'S-DC-EXC0{d+1}0{i+1}']
            writer.writerow(data)
