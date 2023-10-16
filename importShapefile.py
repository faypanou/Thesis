#from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine
import geopandas as gpd
 
user = "postgres"
password = "****"
host = "localhost"
port = 5432
database = "ais"
 
conn = f"postgresql://{user}:{password}@{host}:{port}/{database}"
engine = create_engine(conn)

print("connected")

#Read shapefile using GeoPandas
gdf = gpd.read_file("D:\Courses\Διπλωματική\AIS\Zenodo\[C2] European Coastline\Europe Coastline (Polygone).shp")
 
#Import shapefile to databse
gdf.to_postgis(name="boundary", con=engine, schema="public")
 
print("success")
