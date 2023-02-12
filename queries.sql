-----------------------------------------------------------
-- MAKELINE OF ROUTE
select ship_id, ST_Makeline( point order by timestamp) as line
from public.brest2015
group by ship_id


select ship_id, ST_Makeline( point order by timestamp) as line
from public.eu2015
group by ship_id


--select * from public.eu2015 where ship_id=923166
-----------------------------------------------------------
-- ships that at the same time are within 100m of each other
select *
from public.eu2015 as e
inner join public.brest2015 as b
on b.timestamp=e.timestamp
and ST_dWithin(e.point,b.point, 100)
--664791

	
-----------------------------------------------------------
--select count(*) from public."Brittany_Ports" --222

-- Brest ships and Brittany Ports
drop table if exists Brest_Brit

select bre.ship_id,bre.sog,bre.timestamp,bre.point,bri.libelle_po,bri.geometry
into temp table Brest_Brit
from public.brest2015 as bre
inner join public."Brittany_Ports" as bri
on ST_dWithin(bri.geometry,bre.point,0.005)

select * from Brest_Brit --26429

-----------------------------------------------------------
-- Brittany Ports and stoped/resting ships for one date(2015-10-03)

--drop table if exists Stopped_ships

select distinct a.brest_shipid,a.libelle_po,a.eu_shipid
from
(select distinct bre.ship_id as brest_shipid,bre.sog,bre.point as brest_pnts --min(bre.timestamp) as min_brest_tmstmp,max(bre.timestamp) as max_brest_tmstmp
,bri.libelle_po,bri.geometry,eu.ship_id as eu_shipid,eu.sog,eu.point as eu_pnts--, min(eu.timestamp) as min_eu_tmstmp,max(eu.timestamp) as max_eu_tmstmp,eu.timestamp as eu_tmstmp
--into temp table Stopped_ships
from public.brest2015 as bre
inner join public."Brittany_Ports" as bri
on ST_dWithin(bri.geometry,bre.point,0.005)
inner join public.eu2015 as eu
on ST_dWithin(bri.geometry,eu.point,0.005)
where bre.sog=0 and eu.sog=0 
and bre.timestamp >= '2015-10-03 00:00:00' and  bre.timestamp < '2015-10-04 00:00:00'
and eu.timestamp >= '2015-10-03 00:00:00' and  eu.timestamp < '2015-10-04 00:00:00'
group by bre.ship_id,bre.sog,bre.point,eu.ship_id,bri.libelle_po,bri.geometry,eu.ship_id,eu.sog,eu.point )a
--1

--select * from Stopped_ships
-----------------------------------------------------------
-- most frequent port

select b.libelle_po,b.geometry
from
	(
	select count(a.libelle_po),a.libelle_po,a.geometry
	from
		(select bri.libelle_po,bri.geometry
		from public.brest2015 as bre
		inner join public."Brittany_Ports" as bri
		on ST_dWithin(bri.geometry,bre.point,0.01)
		inner join public.eu2015 as eu
		on ST_dWithin(bri.geometry,eu.point,0.01)
 		)a
 	group by a.libelle_po,a.geometry
	order by count(a.libelle_po) desc
 	limit 1
	)b
	
-----------------------------------------------------------
--duration of ship transmission per day
select b.ship_id,b.min,b.max,(b.max-b.min) as duration
from (
select a.ship_id,min(a.timestamp)as min,max(a.timestamp) as max
from (
select ship_id,timestamp, cast(timestamp as date) as date
from public.brest2015
where 1=1
)a
group by a.date,a.ship_id
)b
order by ship_id asc,
min asc,
max asc
--2101

--duration of ship routing per day (speed>0)
select b.ship_id,b.min,b.max,(b.max-b.min) as duration
from (
select a.ship_id,min(a.timestamp)as min,max(a.timestamp) as max
from (
select ship_id,timestamp, cast(timestamp as date) as date,sog
from public.brest2015
where 1=1
and sog>0
order by ship_id asc
)a
group by a.date,a.ship_id
)b
order by ship_id asc,
min asc,
max asc
--1778 rows

-----------------------------------------------------------
-- resting ships in open waters -- duration >1 h 

drop table if exists Rstng_ships
select c.ship_id,c.min,c.max,c.duration
into temp table Rstng_ships
from
(
	select b.ship_id,b.min,b.max,(b.max-b.min) as duration
	from (
		select a.ship_id,min(a.timestamp)as min,max(a.timestamp) as max
		from (
			select ship_id,timestamp, cast(timestamp as date) as date,sog
			from public.brest2015
			where 1=1
			and sog=0
			order by ship_id asc
			)a
		group by a.date,a.ship_id
		)b
		)c
where c.duration>'00:00:00'
order by ship_id asc,
min asc,
max asc
--select * from Rstng_ships

--threshold distance 95935.9 from Brest port (for this instance)
select r.ship_id,r.min,r.max, br.point,ST_Distance('SRID=4326;POINT(95931.3 42.2397840)'::geometry,br.point)
from Rstng_ships r
inner join public.brest2015 br
on br.ship_id=r.ship_id 
and br.timestamp=r.min
inner join public."Brittany_Ports" bri
on ST_Disjoint(bri.geometry,br.point)
--where ST_Distance(bri.geometry,br.point) >1
where ST_Distance('SRID=4326;POINT(95931.3 42.2397840)'::geometry,br.point) >95935.9
union
select r.ship_id,r.min,r.max, br.point,ST_Distance('SRID=4326;POINT(95931.3 42.2397840)'::geometry,br.point)
from Rstng_ships r
inner join public.brest2015 br
on br.ship_id=r.ship_id 
and br.timestamp=r.max
inner join public."Brittany_Ports" bri
on ST_Disjoint(bri.geometry,br.point)
--where ST_Distance(bri.geometry,br.point) >1
where ST_Distance('SRID=4326;POINT(95931.3 42.2397840)'::geometry,br.point) >95935.9

--select * from public."Brittany_Ports" where libelle_po='Brest' --95931.3/2397840

-----------------------------------------------------------
--Resting Areas-Polygons
drop table if exists Rsting_Areas

select *
into temp table Rsting_Areas
from (
select r.ship_id,r.min,r.max, br.point,ST_Distance('SRID=4326;POINT(95931.3 42.2397840)'::geometry,br.point)
from Rstng_ships r
inner join public.brest2015 br
on br.ship_id=r.ship_id 
and br.timestamp=r.min
inner join public."Brittany_Ports" bri
on ST_Disjoint(bri.geometry,br.point)
--where ST_Distance(bri.geometry,br.point) >1
where ST_Distance('SRID=4326;POINT(95931.3 42.2397840)'::geometry,br.point) >95935.9
union
select r.ship_id,r.min,r.max, br.point,ST_Distance('SRID=4326;POINT(95931.3 42.2397840)'::geometry,br.point)
from Rstng_ships r
inner join public.brest2015 br
on br.ship_id=r.ship_id 
and br.timestamp=r.max
inner join public."Brittany_Ports" bri
on ST_Disjoint(bri.geometry,br.point)
--where ST_Distance(bri.geometry,br.point) >1
where ST_Distance('SRID=4326;POINT(95931.3 42.2397840)'::geometry,br.point) >95935.9
)a
--select * from Rsting_Areas

--delete from  Rsting_Areas where ship_id=37100300 //out of limits

-- Make Polygon of rested Area
select ST_ConcaveHull(ST_Collect(point order by ship_id), 0.99, false) as Resting_Area
from Rsting_Areas 
-----------------------------------------------------------
-- ships in open waters with distance <200m between them (from 2 datasets)

select a.EU_ship,a.eu_position,a.Brest_ship,a.dt_brest,a.brest_position,
from 
	(
	select eu.ship_id as EU_ship,cast(eu.timestamp as date) as dt_eu,eu.point as eu_position,
	bre.ship_id as Brest_ship,cast(bre.timestamp as date) as dt_brest,bre.point as brest_position
	from public.eu2015 eu
	inner join public.brest2015 bre
	on ST_dWithin(bre.point,eu.point,0.002)
	inner join public."Brittany_Ports" bri
	on ST_Disjoint(bri.geometry,bre.point)
	where 1=1
	and eu.sog>0 
	and bre.sog>0
	)a
	where a.dt_eu=a.dt_brest
