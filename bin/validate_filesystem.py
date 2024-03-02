import os

# Write
fps = []
for i in range(2):
    fp = f'/data/nitelite_pipeline_output/test{i}.txt'
    with open(fp, 'w') as f:
        f.write('Hello, world!\n')
    fps.append(fp)

# Read
os.listdir('/data/nitelite_pipeline_output/')
for fp in fps:
    with open(fp, 'r') as f:
        print(f.read())

# Delete
for fp in fps:
    os.remove(fp)