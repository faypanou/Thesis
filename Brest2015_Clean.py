import pandas as pd

data=pd.read_csv(r'D:/Courses/Διπλωματική/AIS/AIS Breast 2015/ais_brest_locations.csv')
print(data.shape[0])
data.drop_duplicates(subset=['id','speed','longitude','latitude','timestamp'], keep='last', inplace=True)
print(data.shape[0])
#data.to_sql('BREST2015', conn, if_exists='replace', index = False)
#data.to_sql(con=conn, name='BREST2015', if_exists='replace')
data.to_csv('ais_brest_locations_clean.csv', index=False)
