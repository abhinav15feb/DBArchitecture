set pagesize 600;
set linesize 600;

SELECT CATALOG.catalog_id, count(MINERALS.mineralid) "# of Minerals",count(mcomment) "# of Comments"
FROM CATALOG,MINERALS, GUEST_COMMENTS
WHERE CATALOG.catalog_id = MINERALS.mcatalogid and MINERALS.mineralid = GUEST_COMMENTS.mineralid
group by CATALOG.catalog_id
;

SELECT MINERALS.mineralid "Mineral ID",count(mcomment) "# of Comments", msize "Size", mlength || ' x ' || mdepth || ' x ' || mheight || ' ' || m_unit  "Dimensions"
FROM MINERALS, GUEST_COMMENTS
WHERE MINERALS.mineralid = GUEST_COMMENTS.mineralid
group by MINERALS.mineralid, mlength, mdepth, mheight, m_unit, msize
;

SELECT SPECIES.species_id "Species ID", count(MINERALS.mineralid) "# of Minerals",count(mcomment) "# of Comments"
FROM SPECIES,MINERALS, GUEST_COMMENTS
WHERE SPECIES.species_id = MINERALS.mspeciesid and MINERALS.mineralid = GUEST_COMMENTS.mineralid
group by SPECIES.species_id
;

-- Minerals analysed by analyst
SELECT analyst_id, count(analysis_details.mineral_id) "# of Minerals Analyzed"
FROM analysis_details
group by analyst_id;

-- various methods used by analyst
SELECT analyst_id, amethod "Method Used"
FROM analysis_details;

-- All methods used for analysis
SELECT UNIQUE amethod "Methods"
FROM analysis_details;

-- Proficiency of analysts
SELECT analyst_id, count(amethod) "# of Methods used", mCount "Total # of Methods"
FROM analysis_details, (SELECT count(DISTINCT amethod) mCount
FROM analysis_details) countTable
group by analyst_id, mCount;

-- Number of times, a particular mineral has been analysed by a analyst
SELECT analyst_id, mineral_id, count(acode) "# of Times mineral analyzed"
FROM analysis_details
group by analyst_id, mineral_id;

-- Minerals whose analyse has to be done.
select mineralid
from minerals
where mineralid not in (SELECT mineral_id FROM analysis_details );

-- Minerals collected by collector
SELECT collection_details.collector_id "Collector ID", collector_fname || ' ' || collector_lname NAME, count(mineral_id) "# of Minerals collected"
FROM collection_details, collector
where collection_details.collector_id = collector.collector_id
group by collection_details.collector_id, collector_fname, collector_lname;

-- Minerals owned by owners
SELECT own_details.owner_id "Owner ID", owner_fname || ' ' || owner_lname NAME, count(mineral_id) "# of Minerals owned"
FROM own_details, owner
where own_details.owner_id = owner.owner_id
group by own_details.owner_id, owner_fname, owner_lname;

-- Minerals bought price from owners along with date
SELECT own_details.owner_id "Owner ID", owner_fname || ' ' || owner_lname NAME, mineral_id, price, own_details.ACQUISITION_DATE
FROM own_details, owner
where own_details.owner_id = owner.owner_id;


-- Minerals appraised by appraiser
SELECT mappraiserid, count(mmineralid) "# of Minerals appraised"
FROM appraisal_details
group by mappraiserid;

-- number of times appraisal done by appraiser
SELECT mappraiserid, count(distinct appraisal_date) "# of times appraisal process done"
FROM appraisal_details
group by mappraiserid;

-- number of times a particular mineral appraisal done by appraiser
SELECT mappraiserid, mmineralid, count(distinct appraisal_date) "# fo times Mineral appraised"
FROM appraisal_details
group by mappraiserid, mmineralid;

-- Average appraisal done by appraiser
SELECT mappraiserid, avg(estimated_value) "Average Estimate of Minerals appraised"
FROM appraisal_details
group by mappraiserid;



--VIEWS
--Guests who have commented the most on minerals (top 3).

create view popular_guest as 
select ID, "Guest Name" from (
select GUESTS.guestid ID, guestfname || ' ' || guestlname "Guest Name", RANK() OVER (ORDER BY count(commentid) desc) as rank
from GUESTS, Guest_comments
where guests.guestid = guest_comments.guestid
group by GUESTS.guestid, guestfname, guestlname
order by count(commentid) desc
)
where rank <4

with check option;

create view mineral_Collector as 
select mineral_name "Mineral Name", city || ', ' || county "Location Name", collector_fname || ' ' || collector_lname "Collector Name" 
from minerals, location, collector, collection_details
where minerals.mlocalid = location.location_id
and collector.collector_id = collection_details.collector_id
and minerals.mineralid = collection_details.mineral_id

with check option;

create view current_mineral_value as 
select mineral_name, "Current Value" from(
select mineral_name, estimated_value "Current Value", RANK() OVER (PARTITION by mineralid ORDER BY appraisal_date desc) as rank
from minerals, appraisal_details
where minerals.mineralid = appraisal_details.mmineralid)
where rank <2
;





--INDEXES
CREATE INDEX mineral_name ON MINERALS
  (mineral_name
  );
CREATE INDEX appraiser_name ON APPRAISER
  (a_fname
  );
CREATE INDEX species_name ON SPECIES
  (species_name
  );
CREATE INDEX history_mineral_id ON HISTORY
  (mineral_id
  );
CREATE INDEX guest_name ON GUESTS
  (guestfname
  );