select * from public.ship_data 
--5756438 rows

select count(distinct "MMSI_Number") 
from public.ship_data 
-- 824

--COUNTING THE TRANSMITTED SIGNALS FOR ITS SHIP
select count("MMSI_Number"),"MMSI_Number"
from public.ship_data
group by "MMSI_Number"
ORDER BY count("MMSI_Number") asc

-- GET MAXIMUM SIGNALS 
select max(a.cnt) AS TOTAL_SIGNALS
from
(
select count("MMSI_Number") as cnt,"MMSI_Number"
from public.ship_data
group by "MMSI_Number" 
)a

select a."MMSI_Number",a.cnt as TOTAL_SIGNALS
from (
select "MMSI_Number", count("MMSI_Number") as cnt,
row_number() over (order by count("MMSI_Number") desc) as rn
from public.ship_data
group by "MMSI_Number"
)a
where rn=1




--Haversine formula
CREATE FUNCTION haversine(Lat1, Lng1, Lat2, Lng2) AS 
    2 * 6335 
        * sqrt(
            pow(sin((radians(Lat2) - radians(Lat1)) / 2), 2)
            + cos(radians(Lat1))
            * cos(radians(Lat2))
            * pow(sin((radians(Lng2) - radians(Lng1)) / 2), 2)

declare Lat1 numeric [{default :=} ]

select * from public.ship_data where "MMSI_Number"= 1193046
			order by "Longitude" desc
			

			
			
------------------- Total Time duration of signaling----------
--drop table if exists B		
select a."MMSI_Number",a."Time" as Beginning
into temp table B
from (
	select "MMSI_Number","Time",
	row_number() over (partition by "MMSI_Number" order by ("Time") asc) as rn
	from public.ship_data 
	group by "MMSI_Number","Time"
	  )a
	where a.rn=1 		
--select * from B
			
--drop table if exists E			
select b."MMSI_Number",b."Time" as Ending
into temp table E
from (
	select "MMSI_Number","Time",
	row_number() over (partition by "MMSI_Number" order by ("Time") desc) as rn
	from public.ship_data 
	group by "MMSI_Number","Time"
	  )b
	where b.rn=1 		
--select * from E			
			
			
select e."MMSI_Number",(Ending-Beginning) as Duration
from B b 
left join E e
on e."MMSI_Number"=b."MMSI_Number"
--erxontai duration pollon imeron, pos to kovoume?

			
			
----------Estimate stationary points--------
--order by most signals
select	"Longitude"
		--,count("Longitude") as cnt_long
		,"Latitude"
		--,count("Latitude") as cnt_lat
		--,"Speed"
from public.ship_data
group by "Longitude","Latitude","Speed"
having count("Longitude")>1 and "Speed"=0.00
order by count("Longitude") desc

			
-- Estimate HDG-normal velocity
	
--vn=SOG sin(COG−HDG)
			
select "MMSI_Number","Time",("Speed")*sin("COG"-"Heading") as Normal_velocity
from public.ship_data	
			
	 				
 
-- Estimate HDG-parallel velocity	
--vp=SOG cos(COG−HDG)
			
select "MMSI_Number","Time",("Speed")*cos("COG"-"Heading") as Normal_velocity
from public.ship_data	
			
			
select "MMSI_Number","Heading","COG",("COG"-"Heading")
			from public.ship_data