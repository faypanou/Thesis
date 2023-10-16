--Data evaluation

----------Breast2015----------			
alter table public.brest2015 add column Point geometry(Point)
			
update public.brest2015
set Point=ST_SetSRID(ST_MakePoint("longitude","latitude"),4326)
			
			
-- indexes
CREATE INDEX idx_breast15_id
ON public.brest2015
USING btree("ship_id")

--select * from public.brest2015 limit 100
--select * from public.eu2015 limit 100

----------Europe2015----------
alter table public."Europe2015" add column Points geometry(Point)
			
update public."Europe2015"
set Points=ST_SetSRID(ST_MakePoint("lon","lat"),4326)
			
select * from public."Europe2015"
limit 10000
			
-- indexes
CREATE INDEX idx_eu2015_id
ON public.eu2015
USING btree("ship_id")


--timestamp alteration

alter table public.brest2015 add column timestamp timestamp without time zone
update public.brest2015 set timestamp=to_timestamp(time/1000);

alter table public.eu2015 add column timestamp timestamp without time zone
update public.eu2015 set timestamp=to_timestamp(time);

--select to_timestamp(1444259347000/1000) + 1444259347000 MOD 1000 * INTERVAL '0.001' SECOND

-----------------------------------------------------------
--WGS84 into the projection ETRS89/LAEA Europe CRS
--alter table public."Brest2015" add column points3035 geometry(Point, 3035)

--update public."Brest2015"
--set points3035=ST_Transform(points, 3035)

--alter table public."Europe2015" add column points3035 geometry(Point, 3035)

--update public."Europe2015"
--set points3035=ST_Transform(points, 3035)

-----------------------------------------------------------
--EU2015
alter table public.eu2015 add column point geometry(Point)
			
update public.eu2015
set point=ST_SetSRID(ST_MakePoint(longitude,latitude),4326)

-- indexes
CREATE INDEX idx_eu2015_id
ON public.eu2015
USING btree(ship_id)

-----------------------------------------------------------
-- Spatial Indexes
--Spatial index on Brest2015
create index idx_brest2015_points
on public.brest2015
using GiST(point)

--Spatial index on Brittany_Ports
create index idx_Brittany_geometry
on public."Brittany_Ports"
using GiST(geometry)

create index idx_eur2015_points
on public.eu2015
using GiST(point)
-----------------------------------------------------------
--ST Buffer
--select st_buffer(points,0.001,8.0) from public."Brest2015"
    

-----------------------------------------------------------
--pk
ALTER TABLE public.brest2015 ADD CONSTRAINT brest2015_pk PRIMARY KEY ("ship_id","sog","timestamp","longitude","latitude");
ALTER TABLE public."Brittany_Ports" ADD CONSTRAINT Brittany_Ports_pkey PRIMARY KEY ("gml_id","geometry");
alter table public.eu2015 ADD CONSTRAINT eu2015_pkey PRIMARY KEY ("ship_id","sog","longitude","latitude","timestamp");



-----------------------------------------------------------
--find duplicates
SELECT ship_id,longitude,latitude,annotation,speed,heading,turn,course,points,timestamp, COUNT(*)
FROM public."Brest2015"
GROUP BY ship_id,longitude,latitude,annotation,speed,heading,turn,course,points,timestamp
HAVING COUNT(*) > 1
order by ship_id asc


SELECT ship_id,navstatus,rot,sog,cog,heading,longitude,latitude,timestamp,points,COUNT(*)
FROM public.eu2015
GROUP BY ship_id,navstatus,rot,sog,cog,heading,longitude,latitude,timestamp,points
HAVING COUNT(*) > 1
order by ship_id asc --40051

DELETE FROM public.eu2015
WHERE ship_id IN
    (SELECT ship_id
    FROM 
        (SELECT ship_id,
         ROW_NUMBER() OVER( PARTITION BY ship_id,navstatus,rot,sog,cog,heading,longitude,latitude,timestamp,points
        ORDER BY ship_id,navstatus,rot,sog,cog,heading,longitude,latitude,timestamp,points ) AS row_num
        FROM public.eu2015) t
        WHERE t.row_num > 1 ); --40472

--delete duplicates
DELETE FROM public."Brest2015"
WHERE ship_id IN
    (SELECT ship_id
    FROM 
        (SELECT ship_id,
         ROW_NUMBER() OVER( PARTITION BY ship_id,longitude,latitude,annotation,speed,heading,turn,course,points,timestamp
        ORDER BY ship_id,longitude,latitude,annotation,speed,heading,turn,course,points,timestamp ) AS row_num
        FROM  public."Brest2015") t
        WHERE t.row_num > 1 ); --171
		--664878
-----------------------------------------------------------
--checks for coordinates
select * from public.brest2015 where latitude>90
select * from public.brest2015 where longitude<-180

delete from public.brest2015 where latitude>90
delete from public.brest2015 where longitude<-180
select * from public.brest2015 limit 1000


select * from public.eu2015 limit 1000
select * from public.eu2015 where latitude>90
select * from public.eu2015 where longitude<-180
-----------------------------------------------------------	
