import psycopg2
import pandas as pd
conn = psycopg2.connect("host=localhost dbname=ais user=postgres password=****")
#create a cursor object 
#cursor object is used to interact with the database
cur = conn.cursor()
#id,timestamp,longitude,latitude,annotation,speed,heading,turn,course,number_of_points
cur.execute("""
     CREATE TABLE BREST2015(
         ship_id bigint,
         timestamp bigint,
         longitude numeric,
         latitude numeric,
         annotation numeric,
         SOG numeric,
         Heading numeric,
         turn numeric,
         COG numeric,
        number_of_points numeric
     )

 """)
# data=pd.read_csv(r'D:\Courses\Διπλωματική\AIS\AIS Breast 2015\ais_brest_locations.csv')
# data.drop_duplicates(subset=['id','speed','longitude','latitude','timestamp'], keep='last', inplace=True)
# #data.to_sql('BREST2015', conn, if_exists='replace', index = False)
# data.to_sql(con=conn, name='BREST2015', if_exists='replace')

with open('D:/Courses/Διπλωματική/AIS/python_scripts/ais_brest_locations_clean.csv', 'r') as f:
     # Notice that we don't need the `csv` module.
     next(f) # Skip the header row.
     cur.copy_from(f, 'brest2015', sep=',')
conn.commit()

#$ cat nari_dynamic_shuffled.csv | awk '{sub(/^ +/,""); gsub(/, /,",")}1' | psql db -c "COPY eu2015 FROM STDIN WITH CSV HEADER"
