import pandas as pd

#df = pd.read_csv(r'D:/Courses/Διπλωματική/AIS/Zenodo/[P1] AIS Data/nari_dynamic.csv', header=1)
#shuffled_df = df.sample(frac=1)
#shuffled_df.to_csv('nari_dynamic_shuffled.csv', index=False)

chunksize = 10 ** 6

data = pd.DataFrame()

for chunk in pd.read_csv(r'D:/Courses/Διπλωματική/AIS/Zenodo/[P1] AIS Data/nari_dynamic.csv', chunksize=chunksize):
    sampled = chunk.sample(frac=0.27)
    data  = pd.concat([data,sampled])


data=data.fillna( -100)

print(data)
data.to_csv('nari_dynamic_shuffled_nonull.csv', index=False)
