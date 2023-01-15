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
-- Brittany Ports and stoped/resting ships for 2015-10-03

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
-- resting ships in open waters -- duration >1 h


-----------------------------------------------------------
-- ships in open waters with distance <200m between them (from 2 datasets)

select a.EU_ship,a.eu_position,a.Brest_ship,a.dt_brest,a.brest_position
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

--select ship_id, cast(timestamp as date) as dt_brest
--from public."Brest2015"
--limit 100