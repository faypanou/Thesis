import pandas as pd
df = pd.read_csv(r'D:/Courses/Διπλωματική/AIS/AIS Breast 2015/ais_brest_locations.csv', header=1)
shuffled_df = df.sample(frac=1)
shuffled_df.to_csv('ais_brest_locations_shuffled.csv', index=False)