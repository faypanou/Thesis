import pandas as pd

#df = pd.read_csv(r'D:/Courses/Διπλωματική/AIS/Zenodo/[P1] AIS Data/nari_dynamic.csv', header=1)
#shuffled_df = df.sample(frac=1)
#shuffled_df.to_csv('nari_dynamic_shuffled.csv', index=False)

chunksize = 10 ** 6

data = pd.DataFrame()

for chunk in pd.read_csv(r'D:/Courses/Διπλωματική/AIS/Zenodo/[P1] AIS Data/nari_dynamic.csv', chunksize=chunksize):
    sampled = chunk.sample(frac=0.4)
    data  = pd.concat([data,sampled])


data=data.fillna( -100)

#df= pd.read_csv("nari_dynamic_shuffled_nonull.csv")
#print('success')
#df.head(10)
print(data.shape[0])
#data.drop_duplicates(keep='last', inplace=True)
data.drop_duplicates(subset=['sourcemmsi','speedoverground','lon','lat','t'], keep='last', inplace=True)
#sourcemmsi,navigationalstatus,rateofturn,speedoverground,courseoverground,trueheading,lon,lat,t
print(data.shape[0])
f=5000000/data.shape[0]
data=data.sample(frac=f)
print(data)
data.to_csv('nari_dynamic_shuffled_clean.csv', index=False)
