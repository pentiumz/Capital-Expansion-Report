--    ***************************************************************************************
--    ***-----This generates the data required for for the DC Capital Expansion Report----***
--    ***-----Most of these are broken up into encounters/visits & then unique patients---***
--    ***-----Some code will need to be rewritten in someplaces (Language/Race/insurance)-***
--    ***-----WARNING-- the  staff who came in for flu shots need to be directly ---------***
--    ***-----WARNING-- excluded, so any new staff will need to be added------------------***
--    ***-----^Their names are kept in a table somewhere in eCw, but I'm not sure where---***
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
 if object_id ('tempdb..#tempSSA' )			   is not null drop table   #tempSSA
 if object_id ('tempdb..#tempSSA2' )		   is not null drop table   #tempSSA2
 if object_id ('tempdb..#tempSSA3' )		   is not null drop table   #tempSSA3
 if object_id ('tempdb..#tempSSAenc')          is not null drop table   #tempSSAenc
 if object_id ('tempdb..#tempprenatal')		   is not null drop table   #tempprenatal

Declare   @start_date date
Declare   @end_date   date
set		  @start_date =  '2017-10-01'
set		  @end_date   =  '2018-09-30'

-- ************************************* Temp Tables ***************************************************
-- THE #TEMPTABLE1 (UNIQUE PTS)
Select distinct 
p.pid,u.dob, u.sex,p.race,u.zipcode,p.language,p.ethnicity, u.upcity
into #temptable1 
from enc e, users u, patients p
WHERE p.pid = u.uid
AND e.patientid = p.pid 
and  e.visittype in (
					'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
					'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
					'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','nurse','exch-ex','exch-new'
					)
and e.date between @start_date and @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--THE OTHER TEMP TABLE (ENCOUNTERS)
Select 
p.pid,u.dob, u.sex,p.race,u.zipcode,p.language,p.ethnicity, u.upcity--,i.insurancename --,id.SeqNo,id.insOrder
into #temptable3 
from enc e, users u, patients p
WHERE p.pid = u.uid
AND e.patientid = p.pid 
and  e.visittype in (
					'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
					'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
					'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
					)
and e.date between @start_date and @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

-- *********************************** AGE **********************************************************************
--ENC AGE COUNT
Select SUM 
    (case when DATEDIFF(hour,u.ptdob,'2017-06-30')/8766    <=   9         then 1 else 0 end) '0-09',
SUM (case when DATEDIFF(hour,u.ptdob,'2017-06-30')/8766 between 10 and 19 then 1 else 0 end) '10-19',
SUM (case when DATEDIFF(hour,u.ptdob,'2017-06-30')/8766 between 20 and 29 then 1 else 0 end) '20-29',
SUM (case when DATEDIFF(hour,u.ptdob,'2017-06-30')/8766 between 30 and 39 then 1 else 0 end) '30-39',
SUM (case when DATEDIFF(hour,u.ptdob,'2017-06-30')/8766 between 40 and 49 then 1 else 0 end) '40-49',
SUM (case when DATEDIFF(hour,u.ptdob,'2017-06-30')/8766 between 50 and 59 then 1 else 0 end) '50-59',
SUM (case when DATEDIFF(hour,u.ptdob,'2017-06-30')/8766 between 60 and 69 then 1 else 0 end) '60-69',
SUM (case when DATEDIFF(hour,u.ptdob,'2017-06-30')/8766 between 70 and 79 then 1 else 0 end) '70-79',
SUM (case when DATEDIFF(hour,u.ptdob,'2017-06-30')/8766 between 80 and 89 then 1 else 0 end) '80-89',
sUM (case when DATEDIFF(hour,u.ptdob,'2017-06-30')/8766    >=   90        then 1 else 0 end) '90+'
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
and  e.visittype in (
					'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
					'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
					'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
					)
and e.date between @start_date and @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--Unique AGE COUNT
select 
SUM (case when DATEDIFF(hour,#temptable1.dob,'2017-06-30')/8766 <= 9			  then 1 else 0 end)  '0-09',
SUM (case when DATEDIFF(hour,#temptable1.dob,'2017-06-30')/8766 between 10 and 19 then 1 else 0 end) '10-19',
SUM (case when DATEDIFF(hour,#temptable1.dob,'2017-06-30')/8766 between 20 and 29 then 1 else 0 end) '20-29',
SUM (case when DATEDIFF(hour,#temptable1.dob,'2017-06-30')/8766 between 30 and 39 then 1 else 0 end) '30-39',
SUM (case when DATEDIFF(hour,#temptable1.dob,'2017-06-30')/8766 between 40 and 49 then 1 else 0 end) '40-49',
SUM (case when DATEDIFF(hour,#temptable1.dob,'2017-06-30')/8766 between 50 and 59 then 1 else 0 end) '50-59',
SUM (case when DATEDIFF(hour,#temptable1.dob,'2017-06-30')/8766 between 60 and 69 then 1 else 0 end) '60-69',
SUM (case when DATEDIFF(hour,#temptable1.dob,'2017-06-30')/8766 between 70 and 79 then 1 else 0 end) '70-79',
SUM (case when DATEDIFF(hour,#temptable1.dob,'2017-06-30')/8766 between 80 and 89 then 1 else 0 end) '80-89',
sUM (case when DATEDIFF(hour,#temptable1.dob,'2017-06-30')/8766 >= 90			  then 1 else 0 end) '90+'
from #temptable1

-- ***********************************  GENDER  *********************************************************************** 
--ENC by GENDER 
SELECT 
sum( CASE when u.sex ='female'then 1 else 0 end) 'female',
sum( CASE when u.sex ='male'  then 1 else 0 end) 'Male',
sum( CASE when ((u.sex <> 'male') and (u.sex <> 'female' ))then 1 else 0 end) 'unknown'
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
and  e.visittype in (
					'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
					'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
					'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
					)
and e.date between @start_date and @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--UNIQUE by GENDER
SELECT 
sum( CASE when   #temptable1.sex ='female'then 1 else 0 end) 'Female',
sum( CASE when   #temptable1.sex ='male'  then 1 else 0 end) 'Male',
sum( CASE when ((#temptable1.sex <> 'male') and (#temptable1.sex <> 'female' ))then 1 else 0 end) 'unknown'
FROM #temptable1

-- *********************************** RACE ***********************************************************************
--ENC by RACE
SELECT 
SUM( case when ((p.race like '%Indian%')  or (p.race like '%Alaska%'))  then 1 else 0 end)  'American Indian/Alaska Native',
SUM( case when p.race like   '%asian%' then 1 else 0 end)									'Asian',
SUM( case when p.race like   '%black%' then 1 else 0 end)									'Black',
SUM( case when p.race like   '%more%'  then 1 else 0 end)									'More than one race',
SUM( case when ((p.race like '%Pacific%')  or (p.race like '%Hawaii%')) then 1 else 0 end)  'Native Hawaiian/ Other Pacific Islander',
SUM( case when (p.race like  '%Other%' and p.race not like '%Other P%')  then 1 else 0 end) 'Other Race',
SUM( case when ((p.race like '%Refuse%') or (p.race like '%unknown%'))  then 1 else 0 end)	'Unknown',
SUM( case when p.race like   '%white%' then 1 else 0 end)									'White'

FROM patients p, users u, enc e
WHERE		p.pid = u.uid
		AND	e.patientid = p.pid 
		and	e.visittype in (
							'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
							'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
							'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
							)
		and e.date between @start_date and @end_date
		AND e.status = 'CHK'
		AND u.ulname <> '%TEST%'
		AND e.deleteflag = '0'

--Unique by RACE
SELECT 
SUM( case when ((#temptable1.race like '%Indian%')  or (#temptable1.race like '%Alaska%'))  then 1 else 0 end)  'American Indian/Alaska Native',
SUM( case when #temptable1.race like '%asian%' then 1 else 0 end)												'Asian',
SUM( case when #temptable1.race like '%black%' then 1 else 0 end)												'Black',
SUM( case when #temptable1.race like '%more%'  then 1 else 0 end)												'More than one race',
SUM( case when ((#temptable1.race like '%Pacific%')  or (#temptable1.race like '%Hawaii%')) then 1 else 0 end)  'Native Hawaiian/ Other Pacific Islander',
SUM( case when (#temptable1.race like '%Other%' and #temptable1.race not like '%Other P%')  then 1 else 0 end)  'Other Race',
SUM( case when ((#temptable1.race like '%Refuse%') or (#temptable1.race like '%unknown%'))  then 1 else 0 end)	'Unknown',
SUM( case when #temptable1.race like '%white%' then 1 else 0 end)												'White'
FROM #temptable1

-- **************************************** ETHNICITY  ******************************************************************
--enc ethnicity wooh 
SELECT
SUM( case when p.ethnicity= '2135-2' then 1 else 0 end) 'Hispanic or Latino',
SUM( case when p.ethnicity= '2186-5' then 1 else 0 end) 'Non Hispanic',
SUM( case when p.ethnicity= '2145-2' then 1 else 0 end) 'Unknown'
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
and  e.visittype in (
					'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
					'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
					'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
					)
and e.date between @start_date and @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--unique ethnicity wooh wooh
SELECT
SUM( case when #temptable1.ethnicity= '2135-2' then 1 else 0 end) 'Hispanic or Latino',
SUM( case when #temptable1.ethnicity= '2186-5' then 1 else 0 end) 'Non Hispanic',
SUM( case when #temptable1.ethnicity= '2145-2' then 1 else 0 end) 'Unknown'
from #temptable1

-- ************************************** DC RESIDENT ********************************************************************
--enc DC resident
SELECT 
SUM( case when u.upcity like '%wash%' then 1 else 0 end)	 'DC Resident',
SUM( case when u.upcity not like '%wash%' then 1 else 0 end) 'Non DC Resident'
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
and  e.visittype in (
					'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
					'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
					'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
					)
and e.date between @start_date and @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--unique DC resident
SELECT 
SUM( case when #temptable1.upcity like '%wash%' then 1 else 0 end)	   'DC Resident',
SUM( case when #temptable1.upcity not like '%wash%' then 1 else 0 end) 'Non DC Resident'
from #temptable1

-- ************************************** Zipcode ********************************************************************

--enc Zipcode
SELECT 
SUM( case when u.zipcode ='20001' then 1 else 0 end) '20001',
SUM( case when u.zipcode ='20000' then 1 else 0 end) '20000',
SUM( case when u.zipcode ='20002' then 1 else 0 end) '20002',
SUM( case when u.zipcode ='20003' then 1 else 0 end) '20003',
SUM( case when u.zipcode ='20004' then 1 else 0 end) '20004',
SUM( case when u.zipcode ='20005' then 1 else 0 end) '20005',
SUM( case when u.zipcode ='20007' then 1 else 0 end) '20007',
SUM( case when u.zipcode ='20008' then 1 else 0 end) '20008',
SUM( case when u.zipcode ='20009' then 1 else 0 end) '20009',
SUM( case when u.zipcode ='20010' then 1 else 0 end) '20010',
SUM( case when u.zipcode ='20011' then 1 else 0 end) '20011',
SUM( case when u.zipcode ='20012' then 1 else 0 end) '20012',
SUM( case when u.zipcode ='20013' then 1 else 0 end) '20013',
SUM( case when u.zipcode ='20015' then 1 else 0 end) '20015',
SUM( case when u.zipcode ='20016' then 1 else 0 end) '20016',
SUM( case when u.zipcode ='20017' then 1 else 0 end) '20017',
SUM( case when u.zipcode ='20018' then 1 else 0 end) '20018',
SUM( case when u.zipcode ='20019' then 1 else 0 end) '20019',
SUM( case when u.zipcode ='20020' then 1 else 0 end) '20020',
SUM( case when u.zipcode ='20024' then 1 else 0 end) '20024',
SUM( case when u.zipcode ='20032' then 1 else 0 end) '20032',
SUM( case when u.zipcode ='20036' then 1 else 0 end) '20036',
SUM( case when u.zipcode ='20037' then 1 else 0 end) '20037',
SUM( case when u.zipcode ='20706' then 1 else 0 end) '20706',
SUM( case when u.zipcode ='20740' then 1 else 0 end) '20740',
SUM( case when u.zipcode ='20742' then 1 else 0 end) '20742',
SUM( case when u.zipcode ='20743' then 1 else 0 end) '20743',
SUM( case when u.zipcode ='20746' then 1 else 0 end) '20746',
SUM( case when u.zipcode ='20770' then 1 else 0 end) '20770',
SUM( case when u.zipcode ='20091' then 1 else 0 end) '20091',
SUM( case when u.zipcode ='20910' then 1 else 0 end) '20910',
SUM( case when u.zipcode ='22150' then 1 else 0 end) '22150',
'',
sum( case when u.zipcode not in ('20001','20000','20002','20003','20004','20005','20007','20008','20009','20010','20011','20012',
								 '20013','20015','20016','20017','20018','20019','20020','20024','20032','20036','20037','20706',
								 '20740','20742','20743','20746','20770','20091','20910','22150') then 1 else 0 end) 'unknown'
--^this all made my brain melt slightly...
FROM patients p, users u, enc e
WHERE p.pid = u.uid
and e.patientid = p.pid 
and  e.visittype in (
	'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
	'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
	'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
	)
and e.date between @start_date and @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--unique Zipcode
SELECT 
SUM( case when #temptable1.zipcode ='20001' then 1 else 0 end) '20001',
SUM( case when #temptable1.zipcode ='20000' then 1 else 0 end) '20000',
SUM( case when #temptable1.zipcode ='20002' then 1 else 0 end) '20002',
SUM( case when #temptable1.zipcode ='20003' then 1 else 0 end) '20003',
SUM( case when #temptable1.zipcode ='20004' then 1 else 0 end) '20004',
SUM( case when #temptable1.zipcode ='20005' then 1 else 0 end) '20005',
SUM( case when #temptable1.zipcode ='20007' then 1 else 0 end) '20007',
SUM( case when #temptable1.zipcode ='20008' then 1 else 0 end) '20008',
SUM( case when #temptable1.zipcode ='20009' then 1 else 0 end) '20009',
SUM( case when #temptable1.zipcode ='20010' then 1 else 0 end) '20010',
SUM( case when #temptable1.zipcode ='20011' then 1 else 0 end) '20011',
SUM( case when #temptable1.zipcode ='20012' then 1 else 0 end) '20012',
SUM( case when #temptable1.zipcode ='20013' then 1 else 0 end) '20013',
SUM( case when #temptable1.zipcode ='20015' then 1 else 0 end) '20015',
SUM( case when #temptable1.zipcode ='20016' then 1 else 0 end) '20016',
SUM( case when #temptable1.zipcode ='20017' then 1 else 0 end) '20017',
SUM( case when #temptable1.zipcode ='20018' then 1 else 0 end) '20018',
SUM( case when #temptable1.zipcode ='20019' then 1 else 0 end) '20019',
SUM( case when #temptable1.zipcode ='20020' then 1 else 0 end) '20020',
SUM( case when #temptable1.zipcode ='20024' then 1 else 0 end) '20024',
SUM( case when #temptable1.zipcode ='20032' then 1 else 0 end) '20032',
SUM( case when #temptable1.zipcode ='20036' then 1 else 0 end) '20036',
SUM( case when #temptable1.zipcode ='20037' then 1 else 0 end) '20037',
SUM( case when #temptable1.zipcode ='20706' then 1 else 0 end) '20706',
SUM( case when #temptable1.zipcode ='20740' then 1 else 0 end) '20740',
SUM( case when #temptable1.zipcode ='20742' then 1 else 0 end) '20742',
SUM( case when #temptable1.zipcode ='20743' then 1 else 0 end) '20743',
SUM( case when #temptable1.zipcode ='20746' then 1 else 0 end) '20746',
SUM( case when #temptable1.zipcode ='20770' then 1 else 0 end) '20770',
SUM( case when #temptable1.zipcode ='20091' then 1 else 0 end) '20091',
SUM( case when #temptable1.zipcode ='20910' then 1 else 0 end) '20910',
SUM( case when #temptable1.zipcode ='22150' then 1 else 0 end) '22150',
'',
sum( case when #temptable1.zipcode not in ('20001','20000','20002','20003','20004','20005','20007','20008','20009','20010','20011','20012',
										   '20013','20015','20016','20017','20018','20019','20020','20024','20032','20036','20037','20706',
										   '20740','20742','20743','20746','20770','20091','20910','22150') then 1 else 0 end) 'unknown'
from #temptable1

-- **************************************  LANGUAGE ********************************************************************
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------- Need to update this section every time this report is run! ---------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--ENC LANGUAGE
SELECT 
SUM( case when p.language like '%Amharic%' then 1 else 0 end)   'Amharic',
SUM( case when (p.language like '%chinese%' or p.language like '%Manda%' or p.language like '%cantonese%') then 1 else 0 end) 'Chinese%',
SUM( case when (p.language = 'english' or p.language = 'eng') then 1 else 0 end) 'English',
SUM( case when p.language like '%French%' then 1 else 0 end)    'French',
SUM( case when p.language like '%Kore%' then 1 else 0 end)		'Korean',
SUM( case when p.language like '%Other%' then 1 else 0 end)		'Other',
SUM( case when p.language like '%Spanish%' then 1 else 0 end)   'Spanish',
SUM( case when
			    (
				 p.language like '?'		   or
				 p.language like 'arabic%'     or
				 p.language like 'deaf'        or
				 p.language like 'Indian%'     or
				 p.language like 'Portuguese%' or
				 p.language like 'Russian%'    or
				 p.language like '%Sign%'      or
				 p.language like 'Tagalog%'    or
				 p.language =    ''            or
				 p.language like 'Tigrigna'		
				)						 then 1  else 0 end)    'Unknown' 
,sum (case when p.language = 'Vietnamese'then 1 else 0 end)	    'Vietnamese'
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
and  e.visittype in (
					'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
					'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
					'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
					)
and e.date between @start_date and @end_date
AND e.status     = 'CHK'
AND u.ulname     <> '%TEST%'
AND e.deleteflag = '0'

--unique language
SELECT 
SUM( case when  #temptable1.language like '%Amharic%' then 1 else 0 end) 'Amharic',
SUM( case when (#temptable1.language like '%chinese%' or #temptable1.language like '%Manda%' or #temptable1.language like 'cantonese%')
 then 1 else 0 end) 'Chinese',
SUM( case when (#temptable1.language =    'english' or #temptable1.language = 'eng') then 1 else 0 end) 'English',
SUM( case when  #temptable1.language like '%French%' then 1 else 0 end)    'French' ,
SUM( case when  #temptable1.language like '%Kore%' then 1 else 0 end)    'Korean' ,
SUM( case when  #temptable1.language like '%Other%' then 1 else 0 end)   'Other'  ,
SUM( case when  #temptable1.language like '%spanish%' then 1 else 0 end) 'Spanish',
SUM( case when (#temptable1.language like '?'			or
				#temptable1.language like 'arabic%'		or
				#temptable1.language like 'deaf%'		or
				#temptable1.language like 'Indian%'		or
				#temptable1.language like 'Port%'		or
				#temptable1.language like 'Russian'		or
				#temptable1.language like '%Sign%'		or
				#temptable1.language like '%Tagalog%'   or
				#temptable1.language like ''			or
				#temptable1.language like 'Tigrigna'		
												)  then 1  else 0 end) 'Unknown' 
,sum (case when #temptable1.language = 'Vietnamese'then 1 else 0 end) 'Vietnamese'
from #temptable1

-- ************************************** INSURANCE  ********************************************************************

select #temptable3.pid, id.insorder, id.seqno, i.insurancename
into #tempinsurance3
from #temptable3
left join insurancedetail id  on #temptable3.pid=id.pid  and id.deleteflag=0
left join insurance i		  on id.insid=i.insid		 and  i.deleteFlag = 0
order by #temptable3.pid, id.seqno, id.insorder desc

delete from #tempinsurance3
where (#tempinsurance3.seqno > 1)

Select #tempinsurance3.*
into   #tempinsurance4
from   #tempinsurance3
where  #tempinsurance3.insOrder is not null
and	   #tempinsurance3.seqno is not null

select 
 sum( case when #tempinsurance4.insurancename  like '%alliance%' then 1 else 0 end)   'Alliance'
,sum( case when #tempinsurance4.insurancename  like '%medicaid%' then 1 else 0 end)   'Medicaid'
,sum( case when #tempinsurance4.insurancename  like '%medicare%' then 1 else 0 end)   'Medicare'
,sum( case when #tempinsurance4.insurancename  like ''			 then 1 else 0 end)'Other Public' -- Not really correct/accurate way to do this. probably should this be a manual count
,sum( case when 
				(
				 #tempinsurance4.insurancename like '%private%' 
			  or #tempinsurance4.insurancename like '%Blue Cross%'
			  or #tempinsurance4.insurancename like '%BlueCross%'
			  or #tempinsurance4.insurancename like '%Aetna%'
			  or #tempinsurance4.insurancename like '%Carefirst%'
			  or #tempinsurance4.insurancename like '%Cigna%'
			  or #tempinsurance4.insurancename like '%United%'
			  or #tempinsurance4.insurancename like '%Bravo%'
			  or #tempinsurance4.insurancename like '%spec needs%'
				)
																then 1 else 0 end)  'Private'
,sum( case when (#tempinsurance4.insurancename like '%uninsure%' 
			  or #tempinsurance4.insurancename like 'DC Fund')  then 1 else 0 end)  'Uninsured'
,sum( case  when #tempinsurance4.insurancename like '%Sliding%' then 1 else 0 end)	'Sliding Fee'
,sum( case  when #tempinsurance4.insurancename like '%income%'  then 1 else 0 end)	'Unknown'
from #tempinsurance4

-- Unique insurance
select distinct #temptable1.pid, id.insorder, id.seqno, i.insurancename
into #tempinsurance
from #temptable1
left join insurancedetail id on #temptable1.pid=id.pid  and id.deleteflag = 0
left join insurance i		 on id.insid=i.insid		and i.deleteFlag  = 0
order by #temptable1.pid, id.seqno, id.insorder desc
delete from #tempinsurance where (#tempinsurance.seqno > 1)

Select #tempinsurance.*
into #tempinsurance2
from #tempinsurance
where #tempinsurance.insOrder is not null
and #tempinsurance.seqno is not null

select 
 sum( case when  #tempinsurance2.insurancename like '%alliance%' then 1 else 0 end) 'Alliance'
,sum( case when  #tempinsurance2.insurancename like '%medicaid%' then 1 else 0 end) 'Medicaid'
,sum( case when  #tempinsurance2.insurancename like '%medicare%' then 1 else 0 end) 'Medicare'
,sum( case when  #tempinsurance2.insurancename like ''			 then 1 else 0 end) 'Other Public' --FLAGGING THIS. See above^
,sum( case when (#tempinsurance2.insurancename like '%private%'
			  or #tempinsurance2.insurancename like '%Blue Cross%'
			  or #tempinsurance2.insurancename like '%BlueCross%'
			  or #tempinsurance2.insurancename like '%Aetna%'
			  or #tempinsurance2.insurancename like '%Carefirst%'
			  or #tempinsurance2.insurancename like '%Cigna%'
			  or #tempinsurance2.insurancename like '%United%'
			  or #tempinsurance2.insurancename like '%Bravo%'
			  or #tempinsurance2.insurancename like '%spec needs%'
			    ) 												then 1 else 0 end)  'Private'
,sum( case when (#tempinsurance2.insurancename like '%uninsure%' 
			  or #tempinsurance2.insurancename like ''
			  or #tempinsurance2.insurancename like 'DC Fund'
			  )													then 1 else 0 end)   'Uninsured'
,sum( case  when #tempinsurance2.insurancename like '%Slid%'    then 1 else 0 end)	 'Sliding Fee'
,sum( case  when #tempinsurance2.insurancename like '%income%'  then 1 else 0 end)	 'Unknown'

from #tempinsurance2

-- ************************************** POVERTY LEVELS ****************************************************************

-- ********************** #TempSSA Creation

select t3.pid, ssa.PovertyLevel, ssa.AssignedDate
into #tempSSA
from #temptable3 t3
left join slidingscaleassigned ssa on t3.pid=ssa.patientId  and SSA.deleteflag=0
order by t3.pid

Select tssa.pid, tssa.PovertyLevel, convert(date,tssa.AssignedDate) AssignedDate
into #tempSSAenc
from #tempssa tssa
	Inner Join (
				Select Pid,max(assigneddate) maxAssigneddate
				from #tempSSA
				group by Pid
				)
		 #tempssa2 on tssa.pid = #tempssa2.pid 
		 and tSSA.AssignedDate = #tempssa2.maxAssigneddate
order by tssa.pid

SELECT 
sum(case when ssaenc.povertylevel <101 then 1 else 0 end)      '100% and Below ENC',
sum(case when ssaenc.povertylevel between 101 and 150 then 1 else 0 end) '101% - 150%',
sum(case when ssaenc.povertylevel between 151 and 200 then 1 else 0 end) '151% - 200%',
sum(case when ssaenc.povertylevel between 201 and 250 then 1 else 0 end) '201% - 250%',
sum(case when ssaenc.povertylevel between 251 and 300 then 1 else 0 end) '251% - 300%',
sum(case when ssaenc.povertylevel > 300 then 1 else 0 end)		    '301% and Above'
from #tempSSAenc ssaenc

-- Find latest Assign Dates from SSA UNIQUE
Select distinct tssa.pid, tssa.PovertyLevel, convert(date,tssa.AssignedDate) AssignedDate
into #tempSSA3
from #tempssa tssa
	Inner Join (
				Select Pid,max(assigneddate) maxAssigneddate
				from #tempSSA
				group by Pid
				)
		 #tempssa2 on			tssa.pid = #tempssa2.pid 
		 and		   tSSA.AssignedDate = #tempssa2.maxAssigneddate
order by tssa.pid

SELECT 
sum(case when ssa3.povertylevel <101 then 1 else 0 end)      '100% and Below UNIQUE',
sum(case when ssa3.povertylevel between 101 and 150 then 1 else 0 end) '101% - 150%',
sum(case when ssa3.povertylevel between 151 and 200 then 1 else 0 end) '151% - 200%',
sum(case when ssa3.povertylevel between 201 and 250 then 1 else 0 end) '201% - 250%',
sum(case when ssa3.povertylevel between 251 and 300 then 1 else 0 end) '251% - 300%',
sum(case when ssa3.povertylevel > 300 then 1 else 0 end)		    '301% and Above'
from #tempSSA3 ssa3

-- ************************************** PRIMARY MEDICAL *************************************************************

-- MEDICAL primary count
SELECT   count(p.pid) as TOTAL_PRIMARY_MEDICAL_ENC
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
and  e.visittype in 
				(
				'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
				'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU',
				'GYN-NEW','RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
				)
and e.date between @start_date and @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--MEDICAL primary unique
SELECT   count(distinct p.pid ) as All_Primary_Patients_Unique
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
and  e.visittype in (
					'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
					'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU',
					'GYN-NEW','RCM-OFF', 'Deaf-fu','Deaf-new','nurse','exch-ex','exch-new'
					)
and e.date between @start_date and @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

-- ************************************** BEHAVIORAL HEALTH **********************************************************
-- BH ENC
SELECT   count( p.pid) as BH_ENC
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype like  '%BHC%'
and e.date between @start_date and @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

-- BH Distinct
SELECT   count(distinct p.pid) as BH_Pats_Uni 
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype in ('BHC-FU','BHC-NEW','BH-THERAPY')
and e.date between @start_date and @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

-- ************************************* VISION **********************************************************************
--Vision Patients Temp Table
SELECT   p.pid, e.date, e.visittype 
into #tempvision
FROM patients p, users u, enc e, #temptable1 
WHERE p.pid = #temptable1.pid
and p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype like '%eye%'
and e.date between @start_date and @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--Vision Patient Unique Count
select count( #tempvision.pid)  as Vision_Unique_Pts 
from #tempvision

--Vision ENC Temp Table1        
SELECT    count(e.encounterid)  as Vision_ENCs
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype like '%eye%'
and e.date between @start_date and @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

-- *************************************** DENTAL  *******************************************************************
SELECT p.pid, e.date, e.visittype 
into #tempdental
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype like '%Den%' 
and e.date between @start_date and @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

-- Dental Unique PTS Count
select count( #tempdental.pid)  as Dental_ENC
from #tempdental

--  Dental Encounter Count
SELECT   count(distinct p.pid ) as Dental_Pats_Uni
FROM patients p, users u, enc e
WHERE p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype IN ('den-new', 
						'den-rct',
							'den-fu',
								'den-po',
									'den-rec')
and e.date between @start_date and @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

-- **************************************** NEW Patients ***********************************************************
-- #tempnewenc creation (list of 'new' encounters)
Select
p.pid,u.dob, u.sex,p.race,u.zipcode,p.language,p.ethnicity, u.upcity,e.visittype,e.encounterID
into #tempnewenc 
from users u, patients p,enc e
 left join edi_invoice ei on e.encounterid=ei.encounterid
 left join edi_inv_diagnosis eid on ei.id=eid.invoiceid
 left join items i on eid.itemid=i.itemid

WHERE		p.pid = u.uid
		AND e.patientid = p.pid 
		and  e.visittype like '%new%'
		and e.date between @start_date and @end_date
		AND e.status = 'CHK'
		AND u.ulname <> '%TEST%'
		AND e.deleteflag = '0'

--New pts
select p.pid, e.date, e.encounterID
into #tempnewmedical
from users u, patients p, ENC E
 left join edi_invoice ei on e.encounterid=ei.encounterid
 left join edi_inv_diagnosis eid on ei.id=eid.invoiceid
 left join items i on eid.itemid=i.itemid

WHERE	     p.pid = u.uid
		AND  e.patientid = p.pid 
		and (e.visittype like '%adult-new%' or e.visittype like 'ped-prenat-new')
		and  e.date between @start_date and @end_date
		AND  e.status = 'CHK'
		AND  u.ulname <> '%TEST%'
		AND  e.deleteflag = '0'

--Count new pts
select count(distinct #tempnewmedical.pid) as  Number_of_New_Patients
from #tempnewmedical

--Count new pts encs
select count(distinct e.encounterID) as Visits_by_New_Pats
from enc e,patients p,users u
where e.patientID in (	'12229',	'12439',	'12466',	'12486',	'12549',	'12678',	'12823',	'12932',	'13004',	'13084',	'13092',	'13106',	'13381',	'13527',	'13583',	'13585',	'13792',	'13946',	'14266',	'14358',	'14416',	'14418',	'14468',	'14532',	'14779',	'15121',	'16283',	'16490',	'18565',	'19971',	'21236',	'23170',	'24056',	'24315',	'25410',	'26347',	'30535',	'32708',	'33415',	'33443',	'34423',	'40066',	'41059',	'43483',	'43899',	'44133',	'44170',	'45391',	'46133',	'46351',	'47878',	'48213',	'49895',	'50424',	'52079',	'52498',	'53122',	'53287',	'54828',	'55647',	'56460',	'56856',	'60135',	'60696',	'61742',	'63649',	'65366',	'66123',	'67382',	'68834',	'68965',	'69100',	'69499',	'69864',	'70157',	'70729',	'71643',	'72544',	'72846',	'76230',	'76717',	'78429',	'78590',	'80230',	'80557',	'1400070609',	'1400071094',	'1400071128',	'1400071233',	'1400071493',	'1400072118',	'1400072214',	'1400072574',	'1400072813',	'1400072966',	'1400073012',	'1400074371',	'1400074585',	'1400074835',	'1400074915',	'1400075983',	'1400076221',	'1400076770',	'1400076989',	'1400077908',	'1400077969',	'1400078156',	'1400078216',	'1400080305',	'1400080840',	'1400081146',	'1400081356',	'1400082102',	'1400083007',	'1400083042',	'1400083488',	'1400083498',	'1400083663',	'1400083868',	'1400083873',	'1400084016',	'1400084672',	'1400084725',	'1400085988',	'1400086209',	'1400086448',	'1400086724',	'1400087122',	'1400087919',	'1400088123',	'1400088296',	'1400089026',	'1400089110',	'1400089236',	'1400089295',	'1400089655',	'1400089690',	'1400090486',	'1400090673',	'1400090680',	'1400090986',	'1400091174',	'1400091826',	'1400092173',	'1400092203',	'1400092244',	'1400092570',	'1400093139',	'1400093212',	'1400093600',	'1400094023',	'1400094315',	'1400095082',	'1400095840',	'1400095921',	'1400096026',	'1400096063',	'1400096152',	'1400096376',	'1400096626',	'1400097219',	'1400097740',	'1400098732',	'1400098939',	'1400098974',	'1400099191',	'1400099827',	'1400100009',	'1400100069',	'1400100596',	'1400101004',	'1400101998',	'1400102162',	'1400102178',	'1400103438',	'1400103680',	'1400103786',	'1400103798',	'1400103850',	'1400104369',	'1400104414',	'1400104417',	'1400104418',	'1400104423',	'1400104424',	'1400104438',	'1400104449',	'1400104450',	'1400104461',	'1400104471',	'1400104479',	'1400104482',	'1400104485',	'1400104498',	'1400104501',	'1400104503',	'1400104504',	'1400104508',	'1400104524',	'1400104526',	'1400104527',	'1400104529',	'1400104530',	'1400104531',	'1400104538',	'1400104539',	'1400104541',	'1400104542',	'1400104552',	'1400104553',	'1400104554',	'1400104562',	'1400104563',	'1400104568',	'1400104570',	'1400104582',	'1400104583',	'1400104584',	'1400104585',	'1400104589',	'1400104590',	'1400104591',	'1400104600',	'1400104601',	'1400104602',	'1400104614',	'1400104616',	'1400104618',	'1400104627',	'1400104629',	'1400104630',	'1400104635',	'1400104636',	'1400104638',	'1400104639',	'1400104641',	'1400104642',	'1400104643',	'1400104651',	'1400104652',	'1400104653',	'1400104654',	'1400104669',	'1400104677',	'1400104679',	'1400104681',	'1400104700',	'1400104701',	'1400104702',	'1400104705',	'1400104708',	'1400104709',	'1400104718',	'1400104721',	'1400104722',	'1400104727',	'1400104729',	'1400104730',	'1400104732',	'1400104734',	'1400104735',	'1400104745',	'1400104746',	'1400104748',	'1400104755',	'1400104760',	'1400104761',	'1400104769',	'1400104772',	'1400104778',	'1400104781',	'1400104789',	'1400104791',	'1400104792',	'1400104795',	'1400104797',	'1400104802',	'1400104803',	'1400104811',	'1400104812',	'1400104813',	'1400104816',	'1400104819',	'1400104822',	'1400104839',	'1400104840',	'1400104841',	'1400104855',	'1400104856',	'1400104878',	'1400104880',	'1400104890',	'1400104895',	'1400104903',	'1400104904',	'1400104905',	'1400104910',	'1400104911',	'1400104918',	'1400104922',	'1400104924',	'1400104925',	'1400104937',	'1400104940',	'1400104944',	'1400104945',	'1400104960',	'1400104962',	'1400104964',	'1400104978',	'1400104979',	'1400104980',	'1400104987',	'1400104988',	'1400104990',	'1400104997',	'1400104998',	'1400104999',	'1400105000',	'1400105001',	'1400105006',	'1400105007',	'1400105010',	'1400105013',	'1400105022',	'1400105023',	'1400105032',	'1400105033',	'1400105035',	'1400105036',	'1400105047',	'1400105049',	'1400105057',	'1400105058',	'1400105059',	'1400105060',	'1400105065',	'1400105067',	'1400105069',	'1400105070',	'1400105074',	'1400105077',	'1400105079',	'1400105080',	'1400105084',	'1400105089',	'1400105094',	'1400105095',	'1400105100',	'1400105107',	'1400105111',	'1400105113',	'1400105114',	'1400105120',	'1400105121',	'1400105123',	'1400105134',	'1400105140',	'1400105141',	'1400105152',	'1400105153',	'1400105155',	'1400105169',	'1400105170',	'1400105178',	'1400105183',	'1400105186',	'1400105187',	'1400105194',	'1400105195',	'1400105196',	'1400105220',	'1400105229',	'1400105230',	'1400105231',	'1400105232',	'1400105235',	'1400105236',	'1400105243',	'1400105251',	'1400105256',	'1400105258',	'1400105260',	'1400105268',	'1400105269',	'1400105270',	'1400105292',	'1400105293',	'1400105297',	'1400105299',	'1400105305',	'1400105311',	'1400105324',	'1400105327',	'1400105328',	'1400105329',	'1400105332',	'1400105333',	'1400105334',	'1400105343',	'1400105344',	'1400105353',	'1400105354',	'1400105355',	'1400105360',	'1400105369',	'1400105376',	'1400105377',	'1400105385',	'1400105392',	'1400105402',	'1400105408',	'1400105409',	'1400105410',	'1400105413',	'1400105415',	'1400105418',	'1400105427',	'1400105428',	'1400105437',	'1400105438',	'1400105440',	'1400105445',	'1400105448',	'1400105453',	'1400105465',	'1400105466',	'1400105467',	'1400105468',	'1400105473',	'1400105474',	'1400105475',	'1400105478',	'1400105491',	'1400105492',	'1400105502',	'1400105503',	'1400105504',	'1400105505',	'1400105509',	'1400105514',	'1400105515',	'1400105516',	'1400105518',	'1400105526',	'1400105527',	'1400105528',	'1400105533',	'1400105534',	'1400105536',	'1400105537',	'1400105538',	'1400105539',	'1400105552',	'1400105553',	'1400105555',	'1400105556',	'1400105557',	'1400105561',	'1400105563',	'1400105579',	'1400105580',	'1400105583',	'1400105584',	'1400105585',	'1400105586',	'1400105618',	'1400105625',	'1400105627',	'1400105628',	'1400105633',	'1400105638',	'1400105641',	'1400105642',	'1400105643',	'1400105654',	'1400105657',	'1400105659',	'1400105660',	'1400105662',	'1400105663',	'1400105667',	'1400105668',	'1400105675',	'1400105676',	'1400105677',	'1400105678',	'1400105689',	'1400105692',	'1400105694',	'1400105695',	'1400105724',	'1400105725',	'1400105727',	'1400105735',	'1400105736',	'1400105737',	'1400105738',	'1400105750',	'1400105752',	'1400105755',	'1400105756',	'1400105763',	'1400105764',	'1400105765',	'1400105783',	'1400105784',	'1400105786',	'1400105794',	'1400105797',	'1400105799',	'1400105800',	'1400105804',	'1400105805',	'1400105806',	'1400105811',	'1400105818',	'1400105822',	'1400105823',	'1400105840',	'1400105841',	'1400105845',	'1400105846',	'1400105847',	'1400105866',	'1400105875',	'1400105876',	'1400105878',	'1400105881',	'1400105882',	'1400105885',	'1400105895',	'1400105896',	'1400105897',	'1400105898',	'1400105899',	'1400105900',	'1400105901',	'1400105931',	'1400105932',	'1400105935',	'1400105937',	'1400105938',	'1400105939',	'1400105946',	'1400105952',	'1400105957',	'1400105958',	'1400105983',	'1400105986',	'1400105999',	'1400106000',	'1400106005',	'1400106013',	'1400106017',	'1400106019',	'1400106028',	'1400106029',	'1400106030',	'1400106038',	'1400106039',	'1400106040',	'1400106053',	'1400106061',	'1400106062',	'1400106069',	'1400106085',	'1400106086',	'1400106087',	'1400106092',	'1400106093',	'1400106103'	)
-- Those PID's ^ were all manually pulled from the #tempnewmedical table
-- They'll need to be repulled unless someone wants to be not a dummy and just pull and insert them with SQ
and          p.pid = u.uid
		AND  e.patientid = p.pid 
		and (e.visittype like 'adult%' or e.visittype like 'ped%')
		and  e.date between @start_date and @end_date
		AND  e.status = 'CHK'
		AND  u.ulname <> '%TEST%'
		AND  e.deleteflag = '0'

-- **************************************** NEW DENTAL PATIENTS************************************************
Select count(distinct #tempnewenc.pid) New_
from #tempnewenc, enc e, users u
where e.visittype like '%new%'
and e.date between @start_date and @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'
and #tempnewenc.pid = e.patientID
and #tempnewenc.pid = u.uid

-- Vision Temp Table Creation
SELECT   p.pid,e.date,e.visittype, e.encounterid
into #tempNEWdental
FROM patients p, users u, enc e, #tempnewenc
WHERE p.pid = #tempnewenc.pid
and p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype IN ('DEN-new')
and e.date between @start_date and @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--NEW Vision PTS Distinct
select count(distinct #tempNEWdental.pid) as NEW_PTS_DENTAL_unique
from #tempNEWdental

--NEW Vision ENC
SELECT   count(distinct #tempNEWdental.encounterID) as NEW_PTS_DENTAL_ENC
FROM #tempNEWdental
WHERE  #tempNEWdental.visittype like '%den%'

-- **************************************** NEW VISION PATIENTS************************************************
-- Vision Temp Table Creation
SELECT   p.pid,e.date,e.visittype, e.encounterid
into #tempNEWvision
FROM patients p, users u, enc e, #tempnewenc
WHERE p.pid = #tempnewenc.pid
and p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype IN ('eye-new')
and e.date between @start_date and @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--NEW Vision PTS Distinct
select count(distinct #tempNEWvision.pid) as NEW_PTS_vision_unique
from #tempNEWvision

--NEW Vision ENC
SELECT   count(distinct #tempNEWvision.encounterID) as NEW_PTS_vision_ENC
FROM #tempNEWvision
WHERE  #tempNEWvision.visittype like '%eye%'

-- **************************************** NEW BH PATIENTS************************************************
-- Dental Temp Table Creation
SELECT   p.pid,e.date,e.visittype, e.encounterid
into #tempNEwBH
FROM patients p, users u, enc e, #tempnewenc
WHERE p.pid = #tempnewenc.pid
and p.pid = u.uid
AND e.patientid = p.pid 
AND e.visittype IN ('BHC-new')
and e.date between @start_date and @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

--NEW BH PTS Distinct
select count(distinct #tempNEwBH.pid) as NEW_PTS_BH_unique
from #tempNEwBH

--NEW BH ENC
SELECT count(distinct #tempNEwBH.encounterID) as NEW_PTS_BH_ENC
FROM #tempNEwBH
WHERE  #tempNEwBH.visittype like '%BHC%'

--*************************************** PRENATAL EXISTING AND NEW PATIENTS*********************************

-- then export to Excel and unduplicate by p.controlno and examine chart for trimester of entry at first prenatal visit

-- #tempnewmedical <--- JOIN THIS to decipher who's a new patient

select distinct p.controlno,p.pid, u.ufname, u.ulname, u.dob, convert(date,e.date) as date, DATEDIFF(hour,u.ptdob,'2018-06-30')/8766 AS Age,
eid.code, i.itemname
INTO #tempprenatal
 from patients p, users u, enc e
 left join edi_invoice ei on e.encounterid=ei.encounterid
 left join edi_inv_diagnosis eid on ei.id=eid.invoiceid
 left join items i on eid.itemid=i.itemid
where p.pid=u.uid
and p.pid=e.patientid
and e.date between @start_date and @end_date
and e.status='CHK'
and e.visittype in ('adult-fu','adult-new','adult-pe','adult-urg', 
'deaf-fu', 'deaf-new','gyn-fu','gyn-new','gyn-urg','ped-prenat', 'peds-fu', 'peds-pe', 'peds-urg', 'rcm-off')
and eid.code like 'Z34%'

--New Pts TOP ROW LEFT THEN RIGHT
select count(distinct tp.pid) Count_New_Prenatal_patients_NewFirstTrimester
 from #tempnewmedical
 inner join #tempprenatal tp on #tempnewmedical.pid = tp.pid
 where tp.itemname like '%First%'

 select count(distinct tp.pid) Count_New_Prenatal_patients_NewPrenatal
 from #tempnewmedical
 inner join #tempprenatal tp on #tempnewmedical.pid = tp.pid

--Existing Pts BOTTOM ROW LEFT THEN RIGHT		
select count(distinct tp.pid) Count_New_Prenatal_patients_ExistingFirstTrimester
 from #tempnewmedical
 right outer join #tempprenatal tp on #tempnewmedical.pid = tp.pid
 where tp.itemname like '%First%'

 select count(distinct tp.pid) Count_New_Prenatal_patients_ExistingPrenatal
 from #tempnewmedical
 right outer join #tempprenatal tp on #tempnewmedical.pid = tp.pid

-- **************************************** UNDUPLICATED NUMBER OF PTS SINCE SITE OPENING 10/01/2009 to @end_date***********
SELECT count(distinct p.pid) All_Pts_Since_2009
from enc e, users u, patients p
WHERE p.pid = u.uid
AND e.patientid = p.pid 
and  e.visittype in (
					'ADULT-FU', 'ADULT-NEW','ADULT-PE','ADULT-URG','CONFDNTL','PED-PRENAT',
					'PED-PRENAT-NEW','PEDS-FU','PEDS-PE','PEDS-URG','Asylum','GYN-FU','GYN-NEW',
					'RCM-OFF', 'Deaf-fu','Deaf-new','nurse','nurse','exch-ex','exch-new'
					)
and e.date between '10/01/2009' and @end_date
AND e.status = 'CHK'
AND u.ulname <> '%TEST%'
AND e.deleteflag = '0'

