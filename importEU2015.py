import psycopg2
conn = psycopg2.connect("host=localhost dbname=ais user=postgres password=1998")
#create a cursor object 
#cursor object is used to interact with the database
cur = conn.cursor()
# cur.execute("""
#     CREATE TABLE EU2015(
#         ship_id bigint,
#         navstatus numeric,
#         ROT numeric,
#         SOG numeric,
#         COG numeric,
#         Heading numeric,
#         longitude numeric,
#         latitude numeric,
#         timestamp bigint
#     )

# """)
with open('nari_dynamic_shuffled_nonull.csv', 'r') as f:
    # Notice that we don't need the `csv` module.
    next(f) # Skip the header row.
    cur.copy_from(f, 'eu2015', sep=',')
conn.commit()

#$ cat nari_dynamic_shuffled.csv | awk '{sub(/^ +/,""); gsub(/, /,",")}1' | psql db -c "COPY eu2015 FROM STDIN WITH CSV HEADER"