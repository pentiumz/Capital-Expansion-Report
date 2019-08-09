--    ***************************************************************************************
--    ***-----This generates the data required for for the DC Capital Expansion Report----***
--    ***-----Most of these are broken up into encounters/visits & then unique patients---***
--    ***-----Some code will need to be rewritten in someplaces (Language/Race/insurance)-***
--    ***-----WARNING-- the  staff who came in for flu shots need to be directly ---------***
--    ***-----WARNING-- Insurance section needs to be mannually updated ------------------***
--    ***-----WARNING-- excluded, so any new staff will need to be added------------------***
--    ***-----^Their names are kept in a table somewhere in eCw, but I'm not sure where---***
--    **------(If I have time I'll try and simplify this. Don't need to be doing so)------***
--    **------(many pulls directly FROM the DB...)----------------------------------------***
--    ***************************************************************************************

if object_id ('tempdb..#temptable1')          is not null drop table   #temptable1
--if object_id ('tempdb..#temptable2')          is not null drop table   #temptable2
if object_id ('tempdb..#temptable3')          is not null drop table   #temptable3
--if object_id ('tempdb..#temptable4')          is not null drop table   #temptable4
if object_id ('tempdb..#tempnew')             is not null drop table   #tempnew
if object_id ('tempdb..#tempenc')             is not null drop table   #tempenc
if object_id ('tempdb..#tempnewenc')          is not null drop table   #tempnewenc
if object_id ('tempdb..#tempinsurance')       is not null drop table   #tempinsurance
if object_id ('tempdb..#tempinsurance2')      is not null drop table   #tempinsurance2
if object_id ('tempdb..#tempinsurance3')      is not null drop table   #tempinsurance3
if object_id ('tempdb..#tempinsurance4')      is not null drop table   #tempinsurance4
if object_id ('tempdb..#tempNEWdental')       is not null drop table   #tempNEWdental
if object_id ('tempdb..#tempNEWvision')       is not null drop table   #tempNEWvision
if object_id ('tempdb..#tempNEWbehavioral')   is not null drop table   #tempNEWbehavioral
if object_id ('tempdb..#tempvision')          is not null drop table   #tempvision
if object_id ('tempdb..#tempvision1')         is not null drop table   #tempvision1
if object_id ('tempdb..#tempdental')          is not null drop table   #tempdental
if object_id ('tempdb..#tempNEwBH' )          is not null drop table   #tempNEwBH
if object_id ('tempdb..#tempnewmedical' )     is not null drop table   #tempnewmedical
if object_id ('tempdb..#tempSSA')			  is not null drop table   #tempSSA
if object_id ('tempdb..#tempSSA2' )			  is not null drop table   #tempSSA2
if object_id ('tempdb..#tempSSA3' )			  is not null drop table   #tempSSA3
if object_id ('tempdb..#tempSSAenc')          is not null drop table   #tempSSAenc
if object_id ('tempdb..#tempprenatal')	      is not null drop table   #tempprenatal

-- ************************************ Set Date Range ************************************************

Declare @start_date date
Declare @end_date   date
set  @start_date =  '2018-10-01'
set  @end_date   =  '2019-09-30'


-- ************************************* Temp Tables ***************************************************
/* Temptables:
1: Unique Patients
2: NONE 
3: Unique Encounters
4: NONE
*/

-- THE #TEMPTABLE1 (UNIQUE PATIENTS)
SELECT DISTINCT 
	p.pid,
	u.dob, 
	u.sex,
	p.race,
	u.zipcode,
	p.language,
	p.ethnicity, 
	u.upcity
INTO #temptable1 
FROM enc e, users u, patients p
WHERE p.pid = u.uid
AND e.patientid = p.pid
AND  e.visittype in ('ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
					'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
					'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','nurse','exch-ex','exch-new'
					)
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--THE OTHER TEMP TABLE (UNIQUE ENCOUNTERS)
SELECT 
-- No Distinct^
	p.pid,
	u.dob, 
	u.sex,
	p.race,
	u.zipcode,
	p.language,
	p.ethnicity, 
	u.upcity
INTO #temptable3 
FROM enc e, users u, patients p
WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND  e.visittype in (
					'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
					'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
					'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
					 )
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

-- *********************************** AGE **********************************************************************
--ENC AGE COUNT
-- The below code will assign a 1 to whichever age range a patient falls INTO ELSE 0
SELECT SUM 
    (CASE WHEN DATEDIFF(hour,u.ptdob,'2019-06-30')/8766    <=   9         THEN 1 ELSE 0 END) '0-9',
SUM (CASE WHEN DATEDIFF(hour,u.ptdob,'2019-06-30')/8766 BETWEEN 10 AND 19 THEN 1 ELSE 0 END) '10-19',
SUM (CASE WHEN DATEDIFF(hour,u.ptdob,'2019-06-30')/8766 BETWEEN 20 AND 29 THEN 1 ELSE 0 END) '20-29',
SUM (CASE WHEN DATEDIFF(hour,u.ptdob,'2019-06-30')/8766 BETWEEN 30 AND 39 THEN 1 ELSE 0 END) '30-39',
SUM (CASE WHEN DATEDIFF(hour,u.ptdob,'2019-06-30')/8766 BETWEEN 40 AND 49 THEN 1 ELSE 0 END) '40-49',
SUM (CASE WHEN DATEDIFF(hour,u.ptdob,'2019-06-30')/8766 BETWEEN 50 AND 59 THEN 1 ELSE 0 END) '50-59',
SUM (CASE WHEN DATEDIFF(hour,u.ptdob,'2019-06-30')/8766 BETWEEN 60 AND 69 THEN 1 ELSE 0 END) '60-69',
SUM (CASE WHEN DATEDIFF(hour,u.ptdob,'2019-06-30')/8766 BETWEEN 70 AND 79 THEN 1 ELSE 0 END) '70-79',
SUM (CASE WHEN DATEDIFF(hour,u.ptdob,'2019-06-30')/8766 BETWEEN 80 AND 89 THEN 1 ELSE 0 END) '80-89',
sUM (CASE WHEN DATEDIFF(hour,u.ptdob,'2019-06-30')/8766    >=   90        THEN 1 ELSE 0 END) '90+'
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND  e.visittype in (
					'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
					'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
					'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
					 )
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--Unique AGE COUNT
SELECT 
	SUM (CASE WHEN DATEDIFF(hour,#temptable1.dob,'2019-06-30')/8766 <= 9			  THEN 1 ELSE 0 END)  '0-9',
	SUM (CASE WHEN DATEDIFF(hour,#temptable1.dob,'2019-06-30')/8766 BETWEEN 10 AND 19 THEN 1 ELSE 0 END) '10-19',
	SUM (CASE WHEN DATEDIFF(hour,#temptable1.dob,'2019-06-30')/8766 BETWEEN 20 AND 29 THEN 1 ELSE 0 END) '20-29',
	SUM (CASE WHEN DATEDIFF(hour,#temptable1.dob,'2019-06-30')/8766 BETWEEN 30 AND 39 THEN 1 ELSE 0 END) '30-39',
	SUM (CASE WHEN DATEDIFF(hour,#temptable1.dob,'2019-06-30')/8766 BETWEEN 40 AND 49 THEN 1 ELSE 0 END) '40-49',
	SUM (CASE WHEN DATEDIFF(hour,#temptable1.dob,'2019-06-30')/8766 BETWEEN 50 AND 59 THEN 1 ELSE 0 END) '50-59',
	SUM (CASE WHEN DATEDIFF(hour,#temptable1.dob,'2019-06-30')/8766 BETWEEN 60 AND 69 THEN 1 ELSE 0 END) '60-69',
	SUM (CASE WHEN DATEDIFF(hour,#temptable1.dob,'2019-06-30')/8766 BETWEEN 70 AND 79 THEN 1 ELSE 0 END) '70-79',
	SUM (CASE WHEN DATEDIFF(hour,#temptable1.dob,'2019-06-30')/8766 BETWEEN 80 AND 89 THEN 1 ELSE 0 END) '80-89',
	sUM (CASE WHEN DATEDIFF(hour,#temptable1.dob,'2019-06-30')/8766 >= 90			  THEN 1 ELSE 0 END) '90+'
FROM #temptable1

-- ***********************************  GENDER  *********************************************************************** 
--ENC by GENDER 
-- The below code will assign a 1 to whichever gender a client falls INTO. If a client fall INTO neither binary category
-- they're put INTO the 'unknown' category. This is the categorization provided by the report recipients.

SELECT 
sum( CASE WHEN u.sex ='female'THEN 1 ELSE 0 END) 'Female',
sum( CASE WHEN u.sex ='male'  THEN 1 ELSE 0 END) 'Male',
sum( CASE WHEN ((u.sex <> 'male') AND (u.sex <> 'female' ))THEN 1 ELSE 0 END) 'Unknown'
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND  e.visittype in (
					'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
					'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
					'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
					)
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--UNIQUE by GENDER
SELECT 
sum( CASE WHEN   #temptable1.sex ='female'THEN 1 ELSE 0 END) 'Female',
sum( CASE WHEN   #temptable1.sex ='male'  THEN 1 ELSE 0 END) 'Male',
sum( CASE WHEN ((#temptable1.sex <> 'male') AND (#temptable1.sex <> 'female' ))THEN 1 ELSE 0 END) 'unknown'
FROM #temptable1

-- *********************************** RACE ***********************************************************************
--ENC by RACE

-- The below code will attempt to assign a client INTO the race bucket that they best fit INTO.
SELECT 
	SUM( CASE WHEN ((p.race LIKE '%Indian%')  OR (p.race LIKE '%Alaska%'))  THEN 1 ELSE 0 END)  'American Indian/Alaska Native',
	SUM( CASE WHEN p.race LIKE   '%asian%' THEN 1 ELSE 0 END)									'Asian',
	SUM( CASE WHEN p.race LIKE   '%black%' THEN 1 ELSE 0 END)									'Black',
	SUM( CASE WHEN p.race LIKE   '%more%'  THEN 1 ELSE 0 END)									'More than one race',
	SUM( CASE WHEN ((p.race LIKE '%Pacific%')  OR (p.race LIKE '%Hawaii%')) THEN 1 ELSE 0 END)  'Native Hawaiian/ Other Pacific Islander',
	SUM( CASE WHEN (p.race LIKE  '%Other%' AND p.race not LIKE '%Other P%')  THEN 1 ELSE 0 END) 'Other Race',
	SUM( CASE WHEN ((p.race LIKE '%Refuse%') OR (p.race LIKE '%unknown%'))  THEN 1 ELSE 0 END)	'Unknown',
	SUM( CASE WHEN p.race LIKE   '%white%' THEN 1 ELSE 0 END)									'White'

FROM patients p, users u, enc e
WHERE p.pid = u.uid
		AND	e.patientid = p.pid 
		and	e.visittype in (
							'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
							'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
							'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
							)
		AND e.date BETWEEN @start_date AND @end_date
		AND e.status = 'CHK'
		AND u.ulname <> '%TEST%'
		AND e.deleteflag = '0'

--Unique by RACE
SELECT 
	SUM( CASE WHEN ((#temptable1.race LIKE '%Indian%')  OR (#temptable1.race LIKE '%Alaska%'))  THEN 1 ELSE 0 END)  'American Indian/Alaska Native',
	SUM( CASE WHEN #temptable1.race LIKE '%asian%' THEN 1 ELSE 0 END)												'Asian',
	SUM( CASE WHEN #temptable1.race LIKE '%black%' THEN 1 ELSE 0 END)												'Black',
	SUM( CASE WHEN #temptable1.race LIKE '%more%'  THEN 1 ELSE 0 END)												'More than one race',
	SUM( CASE WHEN ((#temptable1.race LIKE '%Pacific%')  OR (#temptable1.race LIKE '%Hawaii%')) THEN 1 ELSE 0 END)  'Native Hawaiian/ Other Pacific Islander',
	SUM( CASE WHEN (#temptable1.race LIKE '%Other%' AND #temptable1.race not LIKE '%Other P%')  THEN 1 ELSE 0 END)  'Other Race',
	SUM( CASE WHEN ((#temptable1.race LIKE '%Refuse%') OR (#temptable1.race LIKE '%unknown%'))  THEN 1 ELSE 0 END)	'Unknown',
	SUM( CASE WHEN #temptable1.race LIKE '%white%' THEN 1 ELSE 0 END)												'White'
FROM #temptable1

-- *********************************** ETHNICITY  ******************************************************************
--enc ethnicity wooh 

-- The below code will assign a client INTO, whichever ethnicity bucket they fall INTO.
SELECT
	SUM(CASE WHEN p.ethnicity= '2135-2' THEN 1 ELSE 0 END) 'Hispanic OR Latino',
	SUM(CASE WHEN p.ethnicity= '2186-5' THEN 1 ELSE 0 END) 'Non Hispanic',
	SUM(CASE WHEN p.ethnicity= '2145-2' THEN 1 ELSE 0 END) 'Unknown'

FROM patients p, users u, enc e

WHERE 
	p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype in (
					'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
					'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
					'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
					)
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--unique ethnicity wooh wooh
SELECT
SUM( CASE WHEN #temptable1.ethnicity= '2135-2' THEN 1 ELSE 0 END) 'Hispanic OR Latino',
SUM( CASE WHEN #temptable1.ethnicity= '2186-5' THEN 1 ELSE 0 END) 'Non Hispanic',
SUM( CASE WHEN #temptable1.ethnicity= '2145-2' THEN 1 ELSE 0 END) 'Unknown'

FROM #temptable1

-- ************************************** DC RESIDENT ********************************************************************
--enc DC resident
-- -- The below code will assign a client's residency status based on what
SELECT 
	SUM(CASE WHEN u.upcity	    LIKE '%wash%' THEN 1 ELSE 0 END)	 'DC Resident',
	SUM(CASE WHEN u.upcity not LIKE '%wash%' THEN 1 ELSE 0 END) 'Non DC Resident'

FROM patients p, users u, enc e

WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype in (
					'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
					'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
					'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
					)
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--unique DC resident
SELECT 
SUM( CASE WHEN #temptable1.upcity LIKE '%wash%' THEN 1 ELSE 0 END)	   'DC Resident',
SUM( CASE WHEN #temptable1.upcity not LIKE '%wash%' THEN 1 ELSE 0 END) 'Non DC Resident'
FROM #temptable1

-- ************************************** Zipcode ********************************************************************
--enc Zipcode
-- The below code will assign a 1 to clients based on which zipcode they fall into. If a client's zip does not fall into one of the
-- the buckets, that client is added to 'unknown'.

SELECT 
	SUM( CASE WHEN u.zipcode ='20001' THEN 1 ELSE 0 END) '20001',
	SUM( CASE WHEN u.zipcode ='20000' THEN 1 ELSE 0 END) '20000',
	SUM( CASE WHEN u.zipcode ='20002' THEN 1 ELSE 0 END) '20002',
	SUM( CASE WHEN u.zipcode ='20003' THEN 1 ELSE 0 END) '20003',
	SUM( CASE WHEN u.zipcode ='20004' THEN 1 ELSE 0 END) '20004',
	SUM( CASE WHEN u.zipcode ='20005' THEN 1 ELSE 0 END) '20005',
	SUM( CASE WHEN u.zipcode ='20007' THEN 1 ELSE 0 END) '20007',
	SUM( CASE WHEN u.zipcode ='20008' THEN 1 ELSE 0 END) '20008',
	SUM( CASE WHEN u.zipcode ='20009' THEN 1 ELSE 0 END) '20009',
	SUM( CASE WHEN u.zipcode ='20010' THEN 1 ELSE 0 END) '20010',
	SUM( CASE WHEN u.zipcode ='20011' THEN 1 ELSE 0 END) '20011',
	SUM( CASE WHEN u.zipcode ='20012' THEN 1 ELSE 0 END) '20012',
	SUM( CASE WHEN u.zipcode ='20013' THEN 1 ELSE 0 END) '20013',
	SUM( CASE WHEN u.zipcode ='20015' THEN 1 ELSE 0 END) '20015',
	SUM( CASE WHEN u.zipcode ='20016' THEN 1 ELSE 0 END) '20016',
	SUM( CASE WHEN u.zipcode ='20017' THEN 1 ELSE 0 END) '20017',
	SUM( CASE WHEN u.zipcode ='20018' THEN 1 ELSE 0 END) '20018',
	SUM( CASE WHEN u.zipcode ='20019' THEN 1 ELSE 0 END) '20019',
	SUM( CASE WHEN u.zipcode ='20020' THEN 1 ELSE 0 END) '20020',
	SUM( CASE WHEN u.zipcode ='20024' THEN 1 ELSE 0 END) '20024',
	SUM( CASE WHEN u.zipcode ='20032' THEN 1 ELSE 0 END) '20032',
	SUM( CASE WHEN u.zipcode ='20036' THEN 1 ELSE 0 END) '20036',
	SUM( CASE WHEN u.zipcode ='20037' THEN 1 ELSE 0 END) '20037',
	SUM( CASE WHEN u.zipcode ='20706' THEN 1 ELSE 0 END) '20706',
	SUM( CASE WHEN u.zipcode ='20740' THEN 1 ELSE 0 END) '20740',
	SUM( CASE WHEN u.zipcode ='20742' THEN 1 ELSE 0 END) '20742',
	SUM( CASE WHEN u.zipcode ='20743' THEN 1 ELSE 0 END) '20743',
	SUM( CASE WHEN u.zipcode ='20746' THEN 1 ELSE 0 END) '20746',
	SUM( CASE WHEN u.zipcode ='20770' THEN 1 ELSE 0 END) '20770',
	SUM( CASE WHEN u.zipcode ='20091' THEN 1 ELSE 0 END) '20091',
	SUM( CASE WHEN u.zipcode ='20910' THEN 1 ELSE 0 END) '20910',
	SUM( CASE WHEN u.zipcode ='22150' THEN 1 ELSE 0 END) '22150',
'' '.',
	sum( CASE WHEN u.zipcode not in ('20001','20000','20002','20003','20004','20005','20007','20008','20009','20010','20011','20012',
								 '20013','20015','20016','20017','20018','20019','20020','20024','20032','20036','20037','20706',
								 '20740','20742','20743','20746','20770','20091','20910','22150') THEN 1 ELSE 0 END) 'unknown'
--^this all made my brain melt slightly...

FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype in (
					'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
					'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
					'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
					)
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--unique Zipcode
SELECT 
	SUM( CASE WHEN #temptable1.zipcode ='20001' THEN 1 ELSE 0 END) '20001',
	SUM( CASE WHEN #temptable1.zipcode ='20000' THEN 1 ELSE 0 END) '20000',
	SUM( CASE WHEN #temptable1.zipcode ='20002' THEN 1 ELSE 0 END) '20002',
	SUM( CASE WHEN #temptable1.zipcode ='20003' THEN 1 ELSE 0 END) '20003',
	SUM( CASE WHEN #temptable1.zipcode ='20004' THEN 1 ELSE 0 END) '20004',
	SUM( CASE WHEN #temptable1.zipcode ='20005' THEN 1 ELSE 0 END) '20005',
	SUM( CASE WHEN #temptable1.zipcode ='20007' THEN 1 ELSE 0 END) '20007',
	SUM( CASE WHEN #temptable1.zipcode ='20008' THEN 1 ELSE 0 END) '20008',
	SUM( CASE WHEN #temptable1.zipcode ='20009' THEN 1 ELSE 0 END) '20009',
	SUM( CASE WHEN #temptable1.zipcode ='20010' THEN 1 ELSE 0 END) '20010',
	SUM( CASE WHEN #temptable1.zipcode ='20011' THEN 1 ELSE 0 END) '20011',
	SUM( CASE WHEN #temptable1.zipcode ='20012' THEN 1 ELSE 0 END) '20012',
	SUM( CASE WHEN #temptable1.zipcode ='20013' THEN 1 ELSE 0 END) '20013',
	SUM( CASE WHEN #temptable1.zipcode ='20015' THEN 1 ELSE 0 END) '20015',
	SUM( CASE WHEN #temptable1.zipcode ='20016' THEN 1 ELSE 0 END) '20016',
	SUM( CASE WHEN #temptable1.zipcode ='20017' THEN 1 ELSE 0 END) '20017',
	SUM( CASE WHEN #temptable1.zipcode ='20018' THEN 1 ELSE 0 END) '20018',
	SUM( CASE WHEN #temptable1.zipcode ='20019' THEN 1 ELSE 0 END) '20019',
	SUM( CASE WHEN #temptable1.zipcode ='20020' THEN 1 ELSE 0 END) '20020',
	SUM( CASE WHEN #temptable1.zipcode ='20024' THEN 1 ELSE 0 END) '20024',
	SUM( CASE WHEN #temptable1.zipcode ='20032' THEN 1 ELSE 0 END) '20032',
	SUM( CASE WHEN #temptable1.zipcode ='20036' THEN 1 ELSE 0 END) '20036',
	SUM( CASE WHEN #temptable1.zipcode ='20037' THEN 1 ELSE 0 END) '20037',
	SUM( CASE WHEN #temptable1.zipcode ='20706' THEN 1 ELSE 0 END) '20706',
	SUM( CASE WHEN #temptable1.zipcode ='20740' THEN 1 ELSE 0 END) '20740',
	SUM( CASE WHEN #temptable1.zipcode ='20742' THEN 1 ELSE 0 END) '20742',
	SUM( CASE WHEN #temptable1.zipcode ='20743' THEN 1 ELSE 0 END) '20743',
	SUM( CASE WHEN #temptable1.zipcode ='20746' THEN 1 ELSE 0 END) '20746',
	SUM( CASE WHEN #temptable1.zipcode ='20770' THEN 1 ELSE 0 END) '20770',
	SUM( CASE WHEN #temptable1.zipcode ='20091' THEN 1 ELSE 0 END) '20091',
	SUM( CASE WHEN #temptable1.zipcode ='20910' THEN 1 ELSE 0 END) '20910',
	SUM( CASE WHEN #temptable1.zipcode ='22150' THEN 1 ELSE 0 END) '22150',
'' '.',
	sum( CASE WHEN #temptable1.zipcode not in ('20001','20000','20002','20003','20004','20005','20007','20008','20009','20010','20011','20012',
										   '20013','20015','20016','20017','20018','20019','20020','20024','20032','20036','20037','20706',
										   '20740','20742','20743','20746','20770','20091','20910','22150') THEN 1 ELSE 0 END) 'unknown'
FROM #temptable1

-- **************************************  LANGUAGE ********************************************************************
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------- Need to update this section every time this report is run! ---------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--ENC LANGUAGE
-- This code will assign a client INTO the language category that best fits them. 
-- Because of spelling errors this particular section may need to be adjusted to ensure that all clients are being captured.
-- Also the 'unknown' section will need to be updated to account for any new languages.
SELECT 
	SUM( CASE WHEN p.language LIKE '%Amharic%' THEN 1 ELSE 0 END)   'Amharic',
	SUM( CASE WHEN (p.language LIKE '%Chinese%' 
				OR p.language LIKE '%Manda%' 
				OR p.language LIKE '%Cantonese%') 
    				THEN 1 ELSE 0 END) 'Chinese%',
	SUM( CASE WHEN (p.language = 'English' 
		OR p.language = 'eng') 
    		THEN 1 ELSE 0 END) 'English',
	SUM(CASE WHEN p.language LIKE '%French%' THEN 1 ELSE 0 END)    'French',
	SUM(CASE WHEN p.language LIKE '%Kore%' THEN 1 ELSE 0 END)	'Korean',
	SUM(CASE WHEN p.language LIKE '%Other%' THEN 1 ELSE 0 END)	'Other',
	SUM(CASE WHEN p.language LIKE '%Spanish%' THEN 1 ELSE 0 END)   'Spanish',
	SUM(CASE WHEN
	    (
		 p.language LIKE '?'           or
		 p.language LIKE 'arabic%'     or
		 p.language LIKE 'deaf'        or
		 p.language LIKE 'Indian%'     or
		 p.language LIKE 'Portuguese%' or
		 p.language LIKE 'Russian%'    or
		 p.language LIKE '%Sign%'      or
		 p.language LIKE 'Tagalog%'    or
		 p.language =    ''            or
		 p.language LIKE 'Tigrigna'		
		)						 THEN 1  ELSE 0 END)    'Unknown' ,
	SUM(CASE WHEN p.language = 'Vietnamese'THEN 1 ELSE 0 END)	    'Vietnamese'

FROM patients p, users u, enc e

WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype in (
					'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
					'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
					'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
					)
AND e.date BETWEEN @start_date AND @end_date
AND e.status     = 'CHK'
AND u.ulname     <> '%TEST%'
AND e.deleteflag = '0'

--unique language
SELECT 
	SUM(CASE WHEN  #temptable1.language LIKE '%Amharic%' THEN 1 ELSE 0 END) 'Amharic',
	SUM(CASE WHEN (#temptable1.language LIKE '%chinese%' OR #temptable1.language LIKE '%Manda%' OR #temptable1.language LIKE 'cantonese%')
																						 THEN 1 ELSE 0 END) 'Chinese',
	SUM(CASE WHEN (#temptable1.language =    'english' OR #temptable1.language = 'eng') THEN 1 ELSE 0 END) 'English',
	SUM(CASE WHEN  #temptable1.language LIKE '%French%' THEN 1 ELSE 0 END)  'French',
	SUM(CASE WHEN  #temptable1.language LIKE '%Kore%' THEN 1 ELSE 0 END)    'Korean',
	SUM(CASE WHEN  #temptable1.language LIKE '%Other%' THEN 1 ELSE 0 END)   'Other',
	SUM(CASE WHEN  #temptable1.language LIKE '%spanish%' THEN 1 ELSE 0 END) 'Spanish',
	SUM(CASE WHEN (#temptable1.language LIKE '?'			or
					#temptable1.language LIKE 'arabic%'		or
					#temptable1.language LIKE 'deaf%'		or
					#temptable1.language LIKE 'Indian%'		or
					#temptable1.language LIKE 'Port%'		or
					#temptable1.language LIKE 'Russian'		or
					#temptable1.language LIKE '%Sign%'		or
					#temptable1.language LIKE '%Tagalog%' 		or
					#temptable1.language LIKE ''			or
					#temptable1.language LIKE 'Tigrigna'		
					)  THEN 1  ELSE 0 END) 'Unknown',
	SUM (CASE WHEN #temptable1.language = 'Vietnamese'THEN 1 ELSE 0 END) 'Vietnamese'
FROM #temptable1

-- ************************************** INSURANCE  ********************************************************************

SELECT #temptable3.pid, id.insorder, id.seqno, i.insurancename
INTO #tempinsurance3
FROM #temptable3
LEFT JOIN insurancedetail id  on #temptable3.pid=id.pid  AND id.deleteflag=0
LEFT JOIN insurance i		  on id.insid=i.insid		 AND  i.deleteFlag = 0
ORDER BY #temptable3.pid, id.seqno, id.insorder desc

	DELETE FROM #tempinsurance3
	WHERE (#tempinsurance3.seqno > 1)

SELECT #tempinsurance3.*
INTO   #tempinsurance4
FROM   #tempinsurance3
WHERE  #tempinsurance3.insOrder is not null
and	   #tempinsurance3.seqno is not null

SELECT 
	SUM( CASE WHEN #tempinsurance4.insurancename  LIKE '%alliance%' THEN 1 ELSE 0 END)   'Alliance',
	SUM( CASE WHEN (#tempinsurance4.insurancename  LIKE '%medicaid%' or #tempinsurance4.insuranceName like ' HEALTH SERVICES FOR CHILDREN') THEN 1 ELSE 0 END)   'Medicaid',
	SUM( CASE WHEN #tempinsurance4.insurancename  LIKE '%medicare%' THEN 1 ELSE 0 END)   'Medicare',
	SUM( CASE WHEN #tempinsurance4.insurancename  LIKE ''			 THEN 1 ELSE 0 END)'Other Public', -- Not the best way to capture this info. It should probably should this be a manual count
	SUM( CASE WHEN 
				(#tempinsurance4.insurancename LIKE '%private%' 
			  OR #tempinsurance4.insurancename LIKE '%Blue Cross%'
			  OR #tempinsurance4.insurancename LIKE '%BlueCross%'
			  OR #tempinsurance4.insurancename LIKE '%Aetna%'
			  OR #tempinsurance4.insurancename LIKE '%Carefirst%'
			  OR #tempinsurance4.insurancename LIKE '%Cigna%'
			  OR #tempinsurance4.insurancename LIKE '%United Health%'
			  OR #tempinsurance4.insurancename LIKE '%UnitedHealthCare%'
			  OR #tempinsurance4.insurancename LIKE '%Bravo%'
			  OR #tempinsurance4.insurancename LIKE '%spec needs%'
			  OR #tempinsurance4.insurancename LIKE '%Takaful Insurance Co%'
			  OR #tempinsurance4.insurancename LIKE '%Central United Life Insurance%'
			  OR #tempinsurance4.insurancename LIKE '%Kaiser%'
			  OR #tempinsurance4.insurancename LIKE '%AMERIGROUP-DC ICP%'
			  OR #tempinsurance4.insuranceName LIKE '%DC AMERIHEALTH ICP%'
			  OR #tempinsurance4.insuranceName LIKE '%UHC EVERCARE%'
			  )
																THEN 1 ELSE 0 END)  'Private',
	SUM( CASE WHEN (#tempinsurance4.insurancename LIKE '%uninsure%' OR #tempinsurance4.insurancename LIKE 'DC Fund')  THEN 1 ELSE 0 END)  'Uninsured',
	SUM( case  when #tempinsurance4.insurancename LIKE '%Sliding%' THEN 1 ELSE 0 END)	'Sliding Fee',
	SUM( case  when #tempinsurance4.insurancename LIKE '%income%'  THEN 1 ELSE 0 END)	'Unknown'
FROM #tempinsurance4

-- Unique pt insurance
SELECT DISTINCT #temptable1.pid, id.insorder, id.seqno, i.insurancename
INTO #tempinsurance
FROM #temptable1
LEFT JOIN insurancedetail id on #temptable1.pid=id.pid  AND id.deleteflag = 0
LEFT JOIN insurance i		 on id.insid=i.insid		AND i.deleteFlag  = 0
ORDER BY #temptable1.pid, id.seqno, id.insorder desc
DELETE FROM #tempinsurance WHERE (#tempinsurance.seqno > 1)

SELECT #tempinsurance.*
INTO #tempinsurance2
FROM #tempinsurance
WHERE #tempinsurance.insOrder is not null
  AND #tempinsurance.seqno is not null

SELECT 
	SUM( CASE WHEN #tempinsurance2.insurancename  LIKE '%alliance%' THEN 1 ELSE 0 END)   'Alliance',
	SUM( CASE WHEN (#tempinsurance2.insurancename  LIKE '%medicaid%' or #tempinsurance2.insuranceName like ' HEALTH SERVICES FOR CHILDREN') THEN 1 ELSE 0 END)   'Medicaid',
	SUM( CASE WHEN #tempinsurance2.insurancename  LIKE '%medicare%' THEN 1 ELSE 0 END)   'Medicare',
	SUM( CASE WHEN #tempinsurance2.insurancename  LIKE ''			THEN 1 ELSE 0 END)'Other Public', -- Not the best way to capture this info. It should probably should this be a manual count
	SUM( CASE WHEN 
				(#tempinsurance2.insurancename LIKE '%private%' 
			  OR #tempinsurance2.insurancename LIKE '%Blue Cross%'
			  OR #tempinsurance2.insurancename LIKE '%BlueCross%'
			  OR #tempinsurance2.insurancename LIKE '%Aetna%'
			  OR #tempinsurance2.insurancename LIKE '%Carefirst%'
			  OR #tempinsurance2.insurancename LIKE '%Cigna%'
			  OR #tempinsurance2.insurancename LIKE '%United Health%'
			  OR #tempinsurance2.insurancename LIKE '%UnitedHealthCare%'
			  OR #tempinsurance2.insurancename LIKE '%Bravo%'
			  OR #tempinsurance2.insurancename LIKE '%spec needs%'
			  OR #tempinsurance2.insurancename LIKE '%Takaful Insurance Co%'
			  OR #tempinsurance2.insurancename LIKE '%Central United Life Insurance%'
			  OR #tempinsurance2.insurancename LIKE '%Kaiser%'
			  OR #tempinsurance2.insurancename LIKE '%AMERIGROUP-DC ICP%'
			  OR #tempinsurance2.insuranceName LIKE '%DC AMERIHEALTH ICP%'
			  OR #tempinsurance2.insuranceName LIKE '%UHC EVERCARE%'
				)		THEN 1 ELSE 0 END)  'Private',
	SUM( CASE WHEN (#tempinsurance2.insurancename LIKE '%uninsure%' OR #tempinsurance2.insurancename LIKE 'DC Fund')  THEN 1 ELSE 0 END)  'Uninsured',
	SUM( case  when #tempinsurance2.insurancename LIKE '%Sliding%' THEN 1 ELSE 0 END)	'Sliding Fee',
	SUM( case  when #tempinsurance2.insurancename LIKE '%income%'  THEN 1 ELSE 0 END)	'Unknown'
FROM #tempinsurance2

-- *********************************** POVERTY LEVELS *************************************************************

-- ********************** #TempSSA Creation *****************************************************************************
SELECT 
	t3.pid, 
	ssa.PovertyLevel, 
	ssa.AssignedDate

INTO #tempSSA
FROM #temptable3 t3
LEFT JOIN slidingscaleassigned ssa on t3.pid=ssa.patientId  AND SSA.deleteflag=0
ORDER BY t3.pid

SELECT tssa.pid, tssa.PovertyLevel, convert(date,tssa.AssignedDate) AssignedDate
INTO #tempSSAenc
FROM #tempssa tssa
	Inner Join (
				SELECT 
					Pid,
					max(assigneddate) maxAssigneddate
				FROM #tempSSA
				group by Pid
				)
		 #tempssa2 on tssa.pid = #tempssa2.pid 
		 AND tSSA.AssignedDate = #tempssa2.maxAssigneddate
ORDER BY tssa.pid

SELECT 
	sum(CASE WHEN ssaenc.povertylevel <101 THEN 1 ELSE 0 END)				 '100% AND Below ENC',
	sum(CASE WHEN ssaenc.povertylevel BETWEEN 101 AND 150 THEN 1 ELSE 0 END) '101% - 150%',
	sum(CASE WHEN ssaenc.povertylevel BETWEEN 151 AND 200 THEN 1 ELSE 0 END) '151% - 200%',
	sum(CASE WHEN ssaenc.povertylevel BETWEEN 201 AND 250 THEN 1 ELSE 0 END) '201% - 250%',
	sum(CASE WHEN ssaenc.povertylevel BETWEEN 251 AND 300 THEN 1 ELSE 0 END) '251% - 300%',
	sum(CASE WHEN ssaenc.povertylevel > 300 THEN 1 ELSE 0 END)			     '301% AND Above'
FROM #tempSSAenc ssaenc

-- Find latest Assign Dates FROM SSA UNIQUE
SELECT DISTINCT tssa.pid, tssa.PovertyLevel, convert(date,tssa.AssignedDate) AssignedDate
INTO #tempSSA3
FROM #tempssa tssa
	Inner Join (
				SELECT 
					pid, max(assigneddate) maxAssigneddate
				FROM #tempSSA
				group by Pid
				)
		 #tempssa2 on			tssa.pid = #tempssa2.pid 
		 and		   tSSA.AssignedDate = #tempssa2.maxAssigneddate
ORDER BY tssa.pid

SELECT 
	SUM(CASE WHEN ssa3.povertylevel <101 THEN 1 ELSE 0 END)				   '100% AND Below UNIQUE',
	SUM(CASE WHEN ssa3.povertylevel BETWEEN 101 AND 150 THEN 1 ELSE 0 END) '101% - 150%',
	SUM(CASE WHEN ssa3.povertylevel BETWEEN 151 AND 200 THEN 1 ELSE 0 END) '151% - 200%',
	SUM(CASE WHEN ssa3.povertylevel BETWEEN 201 AND 250 THEN 1 ELSE 0 END) '201% - 250%',
	SUM(CASE WHEN ssa3.povertylevel BETWEEN 251 AND 300 THEN 1 ELSE 0 END) '251% - 300%',
	SUM(CASE WHEN ssa3.povertylevel > 300 THEN 1 ELSE 0 END)			   '301% AND Above'
FROM #tempSSA3 ssa3

-- ************************************** PRIMARY MEDICAL *************************************************************

-- MEDICAL primary count
SELECT count(p.pid) as TOTAL_PRIMARY_MEDICAL_ENC
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND  e.visittype in (
					'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
					'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU',
					'GYN-NEW','RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
					)
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--MEDICAL primary unique
SELECT count(DISTINCT p.pid ) as All_Primary_Patients_Unique
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND  e.visittype in ('ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
					'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU',
					'GYN-NEW','RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
					)
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

-- ************************************** BEHAVIORAL HEALTH **********************************************************
-- BH ENC
SELECT count( p.pid) as BH_ENC
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype LIKE  'BH%'
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

-- BH DISTINCT
SELECT count(DISTINCT p.pid) as BH_Pats_Uni 
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype like 'BH%'
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

-- ************************************* VISION **********************************************************************
--Vision Patients Temp Table
SELECT 
	p.pid, 
	e.date, 
	e.visittype 
INTO #tempvision
FROM patients p, users u, enc e, #temptable1 
WHERE p.pid = #temptable1.pid
AND p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype LIKE '%eye%'
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--Vision Patient Unique Count
SELECT count( #tempvision.pid)  as Vision_Unique_Pts 
FROM #tempvision

--Vision ENC Temp Table1        
SELECT    count(e.encounterid)  as Vision_ENCs
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype LIKE '%eye%'
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

-- *************************************** DENTAL  *******************************************************************
SELECT p.pid, e.date, e.visittype 
INTO #tempdental
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype LIKE '%Den%' 
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

-- Dental Unique PTS Count
SELECT 
	count( #tempdental.pid) as Dental_ENC
FROM #tempdental

--  Dental Encounter Count
SELECT   
	count(DISTINCT p.pid ) as Dental_Pats_Uni
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype IN ('den-new', 
						'den-rct',
							'den-fu',
								'den-po',
									'den-rec')
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

-- **************************************** NEW Patients ***********************************************************
-- #tempnewenc creation (list of 'new' encounters)
SELECT
	p.pid,
	u.dob, 
	u.sex,
	p.race,
	u.zipcode,
	p.language,
	p.ethnicity, 
	u.upcity,
	e.visittype,
	e.encounterID
INTO #tempnewenc 
FROM users u, patients p,enc e
 LEFT JOIN edi_invoice ei on e.encounterid=ei.encounterid
 LEFT JOIN edi_inv_diagnosis eid on ei.id=eid.invoiceid
 LEFT JOIN items i on eid.itemid=i.itemid

WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND  e.visittype LIKE '%new%'
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--New pts
SELECT 
	p.pid, 
	e.date, 
	e.encounterID
INTO #tempnewmedical
FROM users u, patients p, ENC E
 LEFT JOIN edi_invoice ei on e.encounterid=ei.encounterid
 LEFT JOIN edi_inv_diagnosis eid on ei.id=eid.invoiceid
 LEFT JOIN items i on eid.itemid=i.itemid

WHERE p.pid = u.uid
AND  e.patientid = p.pid 
AND (e.visittype LIKE '%adult-new%' OR e.visittype LIKE 'ped-prenat-new')
AND  e.date BETWEEN @start_date AND @end_date
AND  e.status = 'CHK'
AND  u.ulname <> '%TEST%'
AND  e.deleteflag = '0'

--Count new pts
SELECT 
	count(DISTINCT #tempnewmedical.pid) as  Number_of_New_Patients
FROM #tempnewmedical

--Count encounters with new pts  
select count(distinct e.encounterid) 'Encounters from New Pts'
from enc e, patients p
inner join -- Inner join to make a list of new patients' pid's then find matches against new list of clients
	( SELECT 
		p.pid, 
		e.date, 
		e.encounterID

	  FROM users u, patients p, ENC E


	  WHERE p.pid = u.uid
		AND  e.patientid = p.pid 
		AND (e.visittype LIKE '%adult-new%' OR e.visittype LIKE 'ped-prenat-new')
		AND  e.date BETWEEN @start_date AND @end_date
		AND  e.status = 'CHK'
		AND  u.ulname <> '%TEST%'
		AND  e.deleteflag = '0'
	) npe on p.pid=npe.pid and p.pid=npe.pid

where p.pid = e.patientid
and e.date between @start_date and @end_date
and e.status = 'chk'
and e.deleteflag = 0
AND  e.visittype in (
					'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
					'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
					'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
					 )

-- **************************************** NEW DENTAL PATIENTS************************************************
SELECT count(DISTINCT #tempnewenc.pid) New_Dental_Pts
FROM #tempnewenc, enc e, users u
WHERE e.visittype LIKE '%new%'
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'
AND #tempnewenc.pid = e.patientID
AND #tempnewenc.pid = u.uid

-- Vision Temp Table Creation
SELECT   p.pid,e.date,e.visittype, e.encounterid
INTO #tempNEWdental
FROM patients p, users u, enc e, #tempnewenc
WHERE p.pid = #tempnewenc.pid
AND p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype IN ('DEN-new')
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--NEW Vision PTS DISTINCT
SELECT 
	count(DISTINCT #tempNEWdental.pid) as NEW_PTS_DENTAL_unique
FROM #tempNEWdental

--NEW Vision ENC
SELECT   
	count(DISTINCT #tempNEWdental.encounterID) as NEW_PTS_DENTAL_ENC
FROM #tempNEWdental
WHERE  #tempNEWdental.visittype LIKE '%den%'

-- **************************************** NEW VISION PATIENTS************************************************

-- Vision Temp Table Creation
SELECT   
p.pid,
e.date,
e.visittype, 
e.encounterid
INTO #tempNEWvision
FROM patients p, users u, enc e, #tempnewenc
WHERE p.pid = #tempnewenc.pid
AND p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype IN ('eye-new')
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--NEW Vision PTS DISTINCT
SELECT 
	count(DISTINCT #tempNEWvision.pid) as NEW_PTS_vision_unique
FROM #tempNEWvision

--NEW Vision ENC
SELECT   
	count(DISTINCT #tempNEWvision.encounterID) as NEW_PTS_vision_ENC
FROM #tempNEWvision
WHERE  #tempNEWvision.visittype LIKE '%eye%'

-- **************************************** NEW BH PATIENTS************************************************
-- Dental Temp Table Creation
SELECT   
p.pid,
e.date,
e.visittype, 
e.encounterid
INTO #tempNEwBH
FROM patients p, users u, enc e, #tempnewenc
WHERE p.pid = #tempnewenc.pid
AND p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype IN ('BHC-new')
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--NEW BH PTS DISTINCT
SELECT 
	count(DISTINCT #tempNEwBH.pid) as NEW_PTS_BH_unique
FROM #tempNEwBH

--NEW BH ENC
SELECT 
	count(DISTINCT #tempNEwBH.encounterID) as NEW_PTS_BH_ENC
FROM #tempNEwBH
WHERE  #tempNEwBH.visittype LIKE '%BHC%'

--*************************************** PRENATAL EXISTING AND NEW PATIENTS*********************************

-- After this is run, export to Excel AND unduplicate by p.controlno AND examine chart for trimester of entry at first prenatal visit

-- #tempnewmedical <--- JOIN THIS to decipher who's a new patient

SELECT DISTINCT 
p.controlno,
p.pid, 
u.ufname, 
u.ulname, 
u.dob, 
convert(date,e.date) as date, 
DATEDIFF(hour,u.ptdob,'2018-06-30')/8766 AS Age,
eid.code, i.itemname
INTO #tempprenatal
 FROM patients p, users u, enc e
 LEFT JOIN edi_invoice ei on e.encounterid=ei.encounterid
 LEFT JOIN edi_inv_diagnosis eid on ei.id=eid.invoiceid
 LEFT JOIN items i on eid.itemid=i.itemid
WHERE p.pid=u.uid
AND p.pid=e.patientid
AND e.date BETWEEN @start_date AND @end_date
AND e.status='CHK'
AND e.visittype in (
		    'adult-fu','adult-new','adult-pe','adult-urg', 
		    'deaf-fu', 'deaf-new','gyn-fu','gyn-new','gyn-urg',
		    'ped-prenat', 'peds-fu', 'peds-pe', 'peds-urg', 'rcm-off'
		    )
AND eid.code LIKE 'Z34%'

--New Pts TOP ROW LEFT THEN RIGHT
SELECT 
	count(DISTINCT tp.pid) Count_New_Prenatal_patients_NewFirstTrimester
FROM #tempnewmedical
inner join #tempprenatal tp on #tempnewmedical.pid = tp.pid
WHERE tp.itemname LIKE '%First%'

SELECT 
	count(DISTINCT tp.pid) Count_New_Prenatal_patients_NewPrenatal
FROM #tempnewmedical
inner join #tempprenatal tp on #tempnewmedical.pid = tp.pid

--Existing Pts BOTTOM ROW LEFT THEN RIGHT		
SELECT 
	count(DISTINCT tp.pid) Count_New_Prenatal_patients_ExistingFirstTrimester
FROM #tempnewmedical
right outer join #tempprenatal tp on #tempnewmedical.pid = tp.pid
WHERE tp.itemname LIKE '%First%'

SELECT 
	count(DISTINCT tp.pid) Count_New_Prenatal_patients_ExistingPrenatal
FROM #tempnewmedical
right outer join #tempprenatal tp on #tempnewmedical.pid = tp.pid

-- **************************************** UNDUPLICATED NUMBER OF PTS SINCE SITE OPENING 10/01/2009 to @end_date***********
SELECT 
	count(DISTINCT p.pid) All_Pts_Since_2009
FROM enc e, users u, patients p
WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND  e.visittype in (
		    'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
		    'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
		    'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','nurse','exch-ex','exch-new'
		    )
AND e.date BETWEEN '10/01/2009' AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

-- ************************************ Set Visit Types (pipe dream)************************************************

/*
Declare @visittypes table (Id varchar(200))
Insert  into @visittypes(Id) values ('adult-fu')/*,('adult-new'),('adult-pe'),('adult-urg'),('confidentl'),('ped-prenata'),('ped-prenat'),
								('ped-prenat-new'),('peds-fu'),('peds-pe'),('peds-urg'),('asylum'),('gyn-fu'),('gyn-new'),
								('RCM-OFF'),('Deaf-FU'),('Deaf-New'),('nurse'),('exch-ex'),('exch-new')   
	*/
select * from @visittypes
*/
