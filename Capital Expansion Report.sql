--    ***************************************************************************************
--    ***-----This generates the data required for for the DC Capital Expansion Report----***
--    ***-----Most of these are broken up into encounters/visits & then unique patients---***
--    ***-----Some code will need to be rewritten in someplaces (Language/Race/insurance)-***
--    ***-----WARNING-- the  staff who came in for flu shots need to be directly ---------***
--    ***-----WARNING-- excluded, so any new staff will need to be added------------------***
--    ***-----^Their names are kept in a table somewhere in eCw, but I'm not sure where---***
--    **------(If I have time I'll try and simplify this. Don't need to be doing so)------***
--    **------(many pulls directly FROM the DB...)----------------------------------------***
--    ***************************************************************************************

 if object_id ('tempdb..#temptable1')          is not null drop table   #temptable1
 if object_id ('tempdb..#temptable2')          is not null drop table   #temptable2
 if object_id ('tempdb..#temptable3')          is not null drop table   #temptable3
 if object_id ('tempdb..#temptable4')          is not null drop table   #temptable4
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
 if object_id ('tempdb..#tempSSA')			   is not null drop table   #tempSSA
 if object_id ('tempdb..#tempSSA2' )	       is not null drop table   #tempSSA2
 if object_id ('tempdb..#tempSSA3' )	       is not null drop table   #tempSSA3
 if object_id ('tempdb..#tempSSAenc')          is not null drop table   #tempSSAenc
 if object_id ('tempdb..#tempprenatal')	       is not null drop table   #tempprenatal

-- ************************************ Set Date Range ************************************************

Declare   @start_date date
Declare   @end_date   date
set  @start_date =  '2018-10-01'
set  @end_date   =  '2019-09-30'

-- ************************************* Temp Tables ***************************************************
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
AND  e.visittype in (
					'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
					'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
					'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','nurse','exch-ex','exch-new'
					)
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--THE OTHER TEMP TABLE (UNIQUE ENCOUNTERS)
SELECT 
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
    (CASE WHEN DATEDIFF(hour,u.ptdob,'2018-06-30')/8766    <=   9         THEN 1 ELSE 0 END) '0-09',
SUM (CASE WHEN DATEDIFF(hour,u.ptdob,'2018-06-30')/8766 BETWEEN 10 AND 19 THEN 1 ELSE 0 END) '10-19',
SUM (CASE WHEN DATEDIFF(hour,u.ptdob,'2018-06-30')/8766 BETWEEN 20 AND 29 THEN 1 ELSE 0 END) '20-29',
SUM (CASE WHEN DATEDIFF(hour,u.ptdob,'2018-06-30')/8766 BETWEEN 30 AND 39 THEN 1 ELSE 0 END) '30-39',
SUM (CASE WHEN DATEDIFF(hour,u.ptdob,'2018-06-30')/8766 BETWEEN 40 AND 49 THEN 1 ELSE 0 END) '40-49',
SUM (CASE WHEN DATEDIFF(hour,u.ptdob,'2018-06-30')/8766 BETWEEN 50 AND 59 THEN 1 ELSE 0 END) '50-59',
SUM (CASE WHEN DATEDIFF(hour,u.ptdob,'2018-06-30')/8766 BETWEEN 60 AND 69 THEN 1 ELSE 0 END) '60-69',
SUM (CASE WHEN DATEDIFF(hour,u.ptdob,'2018-06-30')/8766 BETWEEN 70 AND 79 THEN 1 ELSE 0 END) '70-79',
SUM (CASE WHEN DATEDIFF(hour,u.ptdob,'2018-06-30')/8766 BETWEEN 80 AND 89 THEN 1 ELSE 0 END) '80-89',
sUM (CASE WHEN DATEDIFF(hour,u.ptdob,'2018-06-30')/8766    >=   90        THEN 1 ELSE 0 END) '90+'
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
SUM (CASE WHEN DATEDIFF(hour,#temptable1.dob,'2018-06-30')/8766 <= 9			  THEN 1 ELSE 0 END)  '0-09',
SUM (CASE WHEN DATEDIFF(hour,#temptable1.dob,'2018-06-30')/8766 BETWEEN 10 AND 19 THEN 1 ELSE 0 END) '10-19',
SUM (CASE WHEN DATEDIFF(hour,#temptable1.dob,'2018-06-30')/8766 BETWEEN 20 AND 29 THEN 1 ELSE 0 END) '20-29',
SUM (CASE WHEN DATEDIFF(hour,#temptable1.dob,'2018-06-30')/8766 BETWEEN 30 AND 39 THEN 1 ELSE 0 END) '30-39',
SUM (CASE WHEN DATEDIFF(hour,#temptable1.dob,'2018-06-30')/8766 BETWEEN 40 AND 49 THEN 1 ELSE 0 END) '40-49',
SUM (CASE WHEN DATEDIFF(hour,#temptable1.dob,'2018-06-30')/8766 BETWEEN 50 AND 59 THEN 1 ELSE 0 END) '50-59',
SUM (CASE WHEN DATEDIFF(hour,#temptable1.dob,'2018-06-30')/8766 BETWEEN 60 AND 69 THEN 1 ELSE 0 END) '60-69',
SUM (CASE WHEN DATEDIFF(hour,#temptable1.dob,'2018-06-30')/8766 BETWEEN 70 AND 79 THEN 1 ELSE 0 END) '70-79',
SUM (CASE WHEN DATEDIFF(hour,#temptable1.dob,'2018-06-30')/8766 BETWEEN 80 AND 89 THEN 1 ELSE 0 END) '80-89',
sUM (CASE WHEN DATEDIFF(hour,#temptable1.dob,'2018-06-30')/8766 >= 90			  THEN 1 ELSE 0 END) '90+'
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
WHERE		p.pid = u.uid
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

-- **************************************** ETHNICITY  ******************************************************************
--enc ethnicity wooh 

-- The below code will assign a client INTO, whichever ethnicity bucket they fall INTO.
SELECT
SUM( CASE WHEN p.ethnicity= '2135-2' THEN 1 ELSE 0 END) 'Hispanic OR Latino',
SUM( CASE WHEN p.ethnicity= '2186-5' THEN 1 ELSE 0 END) 'Non Hispanic',
SUM( CASE WHEN p.ethnicity= '2145-2' THEN 1 ELSE 0 END) 'Unknown'
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
SUM( CASE WHEN u.upcity	    LIKE '%wash%' THEN 1 ELSE 0 END)	 'DC Resident',
SUM( CASE WHEN u.upcity not LIKE '%wash%' THEN 1 ELSE 0 END) 'Non DC Resident'
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
'',
sum( CASE WHEN u.zipcode not in ('20001','20000','20002','20003','20004','20005','20007','20008','20009','20010','20011','20012',
								 '20013','20015','20016','20017','20018','20019','20020','20024','20032','20036','20037','20706',
								 '20740','20742','20743','20746','20770','20091','20910','22150') THEN 1 ELSE 0 END) 'unknown'
--^this all made my brain melt slightly...
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
'',
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
SUM( CASE WHEN p.language LIKE '%French%' THEN 1 ELSE 0 END)    'French',
SUM( CASE WHEN p.language LIKE '%Kore%' THEN 1 ELSE 0 END)	'Korean',
SUM( CASE WHEN p.language LIKE '%Other%' THEN 1 ELSE 0 END)	'Other',
SUM( CASE WHEN p.language LIKE '%Spanish%' THEN 1 ELSE 0 END)   'Spanish',
SUM( CASE WHEN
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
		)						 THEN 1  ELSE 0 END)    'Unknown' 
,sum (CASE WHEN p.language = 'Vietnamese'THEN 1 ELSE 0 END)	    'Vietnamese'
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND  e.visittype in (
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
SUM( CASE WHEN  #temptable1.language LIKE '%Amharic%' THEN 1 ELSE 0 END) 'Amharic',
SUM( CASE WHEN (#temptable1.language LIKE '%chinese%' OR #temptable1.language LIKE '%Manda%' OR #temptable1.language LIKE 'cantonese%')
																					 THEN 1 ELSE 0 END) 'Chinese',
SUM( CASE WHEN (#temptable1.language =    'english' OR #temptable1.language = 'eng') THEN 1 ELSE 0 END) 'English',
SUM( CASE WHEN  #temptable1.language LIKE '%French%' THEN 1 ELSE 0 END)  'French',
SUM( CASE WHEN  #temptable1.language LIKE '%Kore%' THEN 1 ELSE 0 END)    'Korean',
SUM( CASE WHEN  #temptable1.language LIKE '%Other%' THEN 1 ELSE 0 END)   'Other',
SUM( CASE WHEN  #temptable1.language LIKE '%spanish%' THEN 1 ELSE 0 END) 'Spanish',
SUM( CASE WHEN (#temptable1.language LIKE '?'			or
				#temptable1.language LIKE 'arabic%'		or
				#temptable1.language LIKE 'deaf%'		or
				#temptable1.language LIKE 'Indian%'		or
				#temptable1.language LIKE 'Port%'		or
				#temptable1.language LIKE 'Russian'		or
				#temptable1.language LIKE '%Sign%'		or
				#temptable1.language LIKE '%Tagalog%' 		or
				#temptable1.language LIKE ''			or
				#temptable1.language LIKE 'Tigrigna'		
				)  THEN 1  ELSE 0 END) 'Unknown' 
,sum (CASE WHEN #temptable1.language = 'Vietnamese'THEN 1 ELSE 0 END) 'Vietnamese'
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
 sum( CASE WHEN #tempinsurance4.insurancename  LIKE '%alliance%' THEN 1 ELSE 0 END)   'Alliance'
,sum( CASE WHEN #tempinsurance4.insurancename  LIKE '%medicaid%' THEN 1 ELSE 0 END)   'Medicaid'
,sum( CASE WHEN #tempinsurance4.insurancename  LIKE '%medicare%' THEN 1 ELSE 0 END)   'Medicare'
,sum( CASE WHEN #tempinsurance4.insurancename  LIKE ''			 THEN 1 ELSE 0 END)'Other Public' -- Not the best way to capture this info. It should probably should this be a manual count
,sum( CASE WHEN 
				(
				 #tempinsurance4.insurancename LIKE '%private%' 
			  OR #tempinsurance4.insurancename LIKE '%Blue Cross%'
			  OR #tempinsurance4.insurancename LIKE '%BlueCross%'
			  OR #tempinsurance4.insurancename LIKE '%Aetna%'
			  OR #tempinsurance4.insurancename LIKE '%Carefirst%'
			  OR #tempinsurance4.insurancename LIKE '%Cigna%'
			  OR #tempinsurance4.insurancename LIKE '%United%'
			  OR #tempinsurance4.insurancename LIKE '%Bravo%'
			  OR #tempinsurance4.insurancename LIKE '%spec needs%'
				)
																THEN 1 ELSE 0 END)  'Private'
,sum( CASE WHEN (#tempinsurance4.insurancename LIKE '%uninsure%' 
  	OR #tempinsurance4.insurancename LIKE 'DC Fund')  THEN 1 ELSE 0 END)  'Uninsured'
,sum( case  when #tempinsurance4.insurancename LIKE '%Sliding%' THEN 1 ELSE 0 END)	'Sliding Fee'
,sum( case  when #tempinsurance4.insurancename LIKE '%income%'  THEN 1 ELSE 0 END)	'Unknown'
FROM #tempinsurance4

-- Unique insurance
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
 sum( CASE WHEN  #tempinsurance2.insurancename LIKE '%alliance%' THEN 1 ELSE 0 END) 'Alliance'
,sum( CASE WHEN  #tempinsurance2.insurancename LIKE '%medicaid%' THEN 1 ELSE 0 END) 'Medicaid'
,sum( CASE WHEN  #tempinsurance2.insurancename LIKE '%medicare%' THEN 1 ELSE 0 END) 'Medicare'
,sum( CASE WHEN  #tempinsurance2.insurancename LIKE ''			 THEN 1 ELSE 0 END) 'Other Public' --FLAGGING THIS. See above^
,sum( CASE WHEN (#tempinsurance2.insurancename LIKE '%private%'
			  OR #tempinsurance2.insurancename LIKE '%Blue Cross%'
			  OR #tempinsurance2.insurancename LIKE '%BlueCross%'
			  OR #tempinsurance2.insurancename LIKE '%Aetna%'
			  OR #tempinsurance2.insurancename LIKE '%Carefirst%'
			  OR #tempinsurance2.insurancename LIKE '%Cigna%'
			  OR #tempinsurance2.insurancename LIKE '%United%'
			  OR #tempinsurance2.insurancename LIKE '%Bravo%'
			  OR #tempinsurance2.insurancename LIKE '%spec needs%'
			    ) 												THEN 1 ELSE 0 END)  'Private'
,sum( CASE WHEN (#tempinsurance2.insurancename LIKE '%uninsure%' 
			  OR #tempinsurance2.insurancename LIKE ''
			  OR #tempinsurance2.insurancename LIKE 'DC Fund'
			  )													THEN 1 ELSE 0 END)   'Uninsured'
,sum( case  when #tempinsurance2.insurancename LIKE '%Slid%'    THEN 1 ELSE 0 END)	 'Sliding Fee'
,sum( case  when #tempinsurance2.insurancename LIKE '%income%'  THEN 1 ELSE 0 END)	 'Unknown'

FROM #tempinsurance2

-- ************************************** POVERTY LEVELS ****************************************************************

-- ********************** #TempSSA Creation
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
sum(CASE WHEN ssaenc.povertylevel <101 THEN 1 ELSE 0 END)      '100% AND Below ENC',
sum(CASE WHEN ssaenc.povertylevel BETWEEN 101 AND 150 THEN 1 ELSE 0 END) '101% - 150%',
sum(CASE WHEN ssaenc.povertylevel BETWEEN 151 AND 200 THEN 1 ELSE 0 END) '151% - 200%',
sum(CASE WHEN ssaenc.povertylevel BETWEEN 201 AND 250 THEN 1 ELSE 0 END) '201% - 250%',
sum(CASE WHEN ssaenc.povertylevel BETWEEN 251 AND 300 THEN 1 ELSE 0 END) '251% - 300%',
sum(CASE WHEN ssaenc.povertylevel > 300 THEN 1 ELSE 0 END)		    '301% AND Above'
FROM #tempSSAenc ssaenc

-- Find latest Assign Dates FROM SSA UNIQUE
SELECT DISTINCT tssa.pid, tssa.PovertyLevel, convert(date,tssa.AssignedDate) AssignedDate
INTO #tempSSA3
FROM #tempssa tssa
	Inner Join (
				SELECT 
					Pid,
					max(assigneddate) maxAssigneddate
				FROM #tempSSA
				group by Pid
				)
		 #tempssa2 on			tssa.pid = #tempssa2.pid 
		 and		   tSSA.AssignedDate = #tempssa2.maxAssigneddate
ORDER BY tssa.pid

SELECT 
sum(CASE WHEN ssa3.povertylevel <101 THEN 1 ELSE 0 END)      '100% AND Below UNIQUE',
sum(CASE WHEN ssa3.povertylevel BETWEEN 101 AND 150 THEN 1 ELSE 0 END) '101% - 150%',
sum(CASE WHEN ssa3.povertylevel BETWEEN 151 AND 200 THEN 1 ELSE 0 END) '151% - 200%',
sum(CASE WHEN ssa3.povertylevel BETWEEN 201 AND 250 THEN 1 ELSE 0 END) '201% - 250%',
sum(CASE WHEN ssa3.povertylevel BETWEEN 251 AND 300 THEN 1 ELSE 0 END) '251% - 300%',
sum(CASE WHEN ssa3.povertylevel > 300 THEN 1 ELSE 0 END)		    '301% AND Above'
FROM #tempSSA3 ssa3

-- ************************************** PRIMARY MEDICAL *************************************************************

-- MEDICAL primary count
SELECT 
	count(p.pid) as TOTAL_PRIMARY_MEDICAL_ENC
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND  e.visittype in 
		(
		'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
		'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU',
		'GYN-NEW','RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
		)
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--MEDICAL primary unique
SELECT
	count(DISTINCT p.pid ) as All_Primary_Patients_Unique
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

-- ************************************** BEHAVIORAL HEALTH **********************************************************
-- BH ENC
SELECT   count( p.pid) as BH_ENC
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype LIKE  '%BHC%'
AND e.date BETWEEN @start_date AND @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

-- BH DISTINCT
SELECT   count(DISTINCT p.pid) as BH_Pats_Uni 
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype in ('BHC-FU','BHC-NEW','BH-THERAPY')
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

WHERE	     p.pid = u.uid
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

--Count new pts encs
SELECT 
	count(DISTINCT e.encounterID) as Visits_by_New_Pats
FROM enc e,patients p,users u
WHERE e.patientID in (	'12229',	'12439',	'12466',	'12486',	'12549',	'12678',	'12823',	'12932',	'13004',	'13084',	'13092',	'13106',	'13381',	'13527',	'13583',	'13585',	'13792',	'13946',	'14266',	'14358',	'14416',	'14418',	'14468',	'14532',	'14779',	'15121',	'16283',	'16490',	'18565',	'19971',	'21236',	'23170',	'24056',	'24315',	'25410',	'26347',	'30535',	'32708',	'33415',	'33443',	'34423',	'40066',	'41059',	'43483',	'43899',	'44133',	'44170',	'45391',	'46133',	'46351',	'47878',	'48213',	'49895',	'50424',	'52079',	'52498',	'53122',	'53287',	'54828',	'55647',	'56460',	'56856',	'60135',	'60696',	'61742',	'63649',	'65366',	'66123',	'67382',	'68834',	'68965',	'69100',	'69499',	'69864',	'70157',	'70729',	'71643',	'72544',	'72846',	'76230',	'76717',	'78429',	'78590',	'80230',	'80557',	'1400070609',	'1400071094',	'1400071128',	'1400071233',	'1400071493',	'1400072118',	'1400072214',	'1400072574',	'1400072813',	'1400072966',	'1400073012',	'1400074371',	'1400074585',	'1400074835',	'1400074915',	'1400075983',	'1400076221',	'1400076770',	'1400076989',	'1400077908',	'1400077969',	'1400078156',	'1400078216',	'1400080305',	'1400080840',	'1400081146',	'1400081356',	'1400082102',	'1400083007',	'1400083042',	'1400083488',	'1400083498',	'1400083663',	'1400083868',	'1400083873',	'1400084016',	'1400084672',	'1400084725',	'1400085988',	'1400086209',	'1400086448',	'1400086724',	'1400087122',	'1400087919',	'1400088123',	'1400088296',	'1400089026',	'1400089110',	'1400089236',	'1400089295',	'1400089655',	'1400089690',	'1400090486',	'1400090673',	'1400090680',	'1400090986',	'1400091174',	'1400091826',	'1400092173',	'1400092203',	'1400092244',	'1400092570',	'1400093139',	'1400093212',	'1400093600',	'1400094023',	'1400094315',	'1400095082',	'1400095840',	'1400095921',	'1400096026',	'1400096063',	'1400096152',	'1400096376',	'1400096626',	'1400097219',	'1400097740',	'1400098732',	'1400098939',	'1400098974',	'1400099191',	'1400099827',	'1400100009',	'1400100069',	'1400100596',	'1400101004',	'1400101998',	'1400102162',	'1400102178',	'1400103438',	'1400103680',	'1400103786',	'1400103798',	'1400103850',	'1400104369',	'1400104414',	'1400104417',	'1400104418',	'1400104423',	'1400104424',	'1400104438',	'1400104449',	'1400104450',	'1400104461',	'1400104471',	'1400104479',	'1400104482',	'1400104485',	'1400104498',	'1400104501',	'1400104503',	'1400104504',	'1400104508',	'1400104524',	'1400104526',	'1400104527',	'1400104529',	'1400104530',	'1400104531',	'1400104538',	'1400104539',	'1400104541',	'1400104542',	'1400104552',	'1400104553',	'1400104554',	'1400104562',	'1400104563',	'1400104568',	'1400104570',	'1400104582',	'1400104583',	'1400104584',	'1400104585',	'1400104589',	'1400104590',	'1400104591',	'1400104600',	'1400104601',	'1400104602',	'1400104614',	'1400104616',	'1400104618',	'1400104627',	'1400104629',	'1400104630',	'1400104635',	'1400104636',	'1400104638',	'1400104639',	'1400104641',	'1400104642',	'1400104643',	'1400104651',	'1400104652',	'1400104653',	'1400104654',	'1400104669',	'1400104677',	'1400104679',	'1400104681',	'1400104700',	'1400104701',	'1400104702',	'1400104705',	'1400104708',	'1400104709',	'1400104718',	'1400104721',	'1400104722',	'1400104727',	'1400104729',	'1400104730',	'1400104732',	'1400104734',	'1400104735',	'1400104745',	'1400104746',	'1400104748',	'1400104755',	'1400104760',	'1400104761',	'1400104769',	'1400104772',	'1400104778',	'1400104781',	'1400104789',	'1400104791',	'1400104792',	'1400104795',	'1400104797',	'1400104802',	'1400104803',	'1400104811',	'1400104812',	'1400104813',	'1400104816',	'1400104819',	'1400104822',	'1400104839',	'1400104840',	'1400104841',	'1400104855',	'1400104856',	'1400104878',	'1400104880',	'1400104890',	'1400104895',	'1400104903',	'1400104904',	'1400104905',	'1400104910',	'1400104911',	'1400104918',	'1400104922',	'1400104924',	'1400104925',	'1400104937',	'1400104940',	'1400104944',	'1400104945',	'1400104960',	'1400104962',	'1400104964',	'1400104978',	'1400104979',	'1400104980',	'1400104987',	'1400104988',	'1400104990',	'1400104997',	'1400104998',	'1400104999',	'1400105000',	'1400105001',	'1400105006',	'1400105007',	'1400105010',	'1400105013',	'1400105022',	'1400105023',	'1400105032',	'1400105033',	'1400105035',	'1400105036',	'1400105047',	'1400105049',	'1400105057',	'1400105058',	'1400105059',	'1400105060',	'1400105065',	'1400105067',	'1400105069',	'1400105070',	'1400105074',	'1400105077',	'1400105079',	'1400105080',	'1400105084',	'1400105089',	'1400105094',	'1400105095',	'1400105100',	'1400105107',	'1400105111',	'1400105113',	'1400105114',	'1400105120',	'1400105121',	'1400105123',	'1400105134',	'1400105140',	'1400105141',	'1400105152',	'1400105153',	'1400105155',	'1400105169',	'1400105170',	'1400105178',	'1400105183',	'1400105186',	'1400105187',	'1400105194',	'1400105195',	'1400105196',	'1400105220',	'1400105229',	'1400105230',	'1400105231',	'1400105232',	'1400105235',	'1400105236',	'1400105243',	'1400105251',	'1400105256',	'1400105258',	'1400105260',	'1400105268',	'1400105269',	'1400105270',	'1400105292',	'1400105293',	'1400105297',	'1400105299',	'1400105305',	'1400105311',	'1400105324',	'1400105327',	'1400105328',	'1400105329',	'1400105332',	'1400105333',	'1400105334',	'1400105343',	'1400105344',	'1400105353',	'1400105354',	'1400105355',	'1400105360',	'1400105369',	'1400105376',	'1400105377',	'1400105385',	'1400105392',	'1400105402',	'1400105408',	'1400105409',	'1400105410',	'1400105413',	'1400105415',	'1400105418',	'1400105427',	'1400105428',	'1400105437',	'1400105438',	'1400105440',	'1400105445',	'1400105448',	'1400105453',	'1400105465',	'1400105466',	'1400105467',	'1400105468',	'1400105473',	'1400105474',	'1400105475',	'1400105478',	'1400105491',	'1400105492',	'1400105502',	'1400105503',	'1400105504',	'1400105505',	'1400105509',	'1400105514',	'1400105515',	'1400105516',	'1400105518',	'1400105526',	'1400105527',	'1400105528',	'1400105533',	'1400105534',	'1400105536',	'1400105537',	'1400105538',	'1400105539',	'1400105552',	'1400105553',	'1400105555',	'1400105556',	'1400105557',	'1400105561',	'1400105563',	'1400105579',	'1400105580',	'1400105583',	'1400105584',	'1400105585',	'1400105586',	'1400105618',	'1400105625',	'1400105627',	'1400105628',	'1400105633',	'1400105638',	'1400105641',	'1400105642',	'1400105643',	'1400105654',	'1400105657',	'1400105659',	'1400105660',	'1400105662',	'1400105663',	'1400105667',	'1400105668',	'1400105675',	'1400105676',	'1400105677',	'1400105678',	'1400105689',	'1400105692',	'1400105694',	'1400105695',	'1400105724',	'1400105725',	'1400105727',	'1400105735',	'1400105736',	'1400105737',	'1400105738',	'1400105750',	'1400105752',	'1400105755',	'1400105756',	'1400105763',	'1400105764',	'1400105765',	'1400105783',	'1400105784',	'1400105786',	'1400105794',	'1400105797',	'1400105799',	'1400105800',	'1400105804',	'1400105805',	'1400105806',	'1400105811',	'1400105818',	'1400105822',	'1400105823',	'1400105840',	'1400105841',	'1400105845',	'1400105846',	'1400105847',	'1400105866',	'1400105875',	'1400105876',	'1400105878',	'1400105881',	'1400105882',	'1400105885',	'1400105895',	'1400105896',	'1400105897',	'1400105898',	'1400105899',	'1400105900',	'1400105901',	'1400105931',	'1400105932',	'1400105935',	'1400105937',	'1400105938',	'1400105939',	'1400105946',	'1400105952',	'1400105957',	'1400105958',	'1400105983',	'1400105986',	'1400105999',	'1400106000',	'1400106005',	'1400106013',	'1400106017',	'1400106019',	'1400106028',	'1400106029',	'1400106030',	'1400106038',	'1400106039',	'1400106040',	'1400106053',	'1400106061',	'1400106062',	'1400106069',	'1400106085',	'1400106086',	'1400106087',	'1400106092',	'1400106093',	'1400106103'	)
-- Those PID's ^ were all manually pulled FROM the #tempnewmedical table
-- They'll need to be repulled unless someone wants to be not a dummy AND just pull AND insert them with SQL
AND          p.pid = u.uid
		AND  e.patientid = p.pid 
		AND (e.visittype LIKE 'adult%' OR e.visittype LIKE 'ped%')
		AND  e.date BETWEEN @start_date AND @end_date
		AND  e.status = 'CHK'
		AND  u.ulname <> '%TEST%'
		AND  e.deleteflag = '0'

-- **************************************** NEW DENTAL PATIENTS************************************************
SELECT count(DISTINCT #tempnewenc.pid) New_
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

-- THEN export to Excel AND unduplicate by p.controlno AND examine chart for trimester of entry at first prenatal visit

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
