
/*

DATA CLEANING PROJECT USING SQL 

The dataset I used in this project comes from the following link and is called 'Uncleaned_DS_jobs.csv' : 
https://www.kaggle.com/datasets/rashikrahmanpritom/data-science-job-posting-on-glassdoor

My final cleaned dataset as a result of the queries in this file could be found in the CleanedDSJobs.csv file. 

The following is an overview of the steps I use to clean the data:

1.) Creating the columns 'SalaryMin' and 'SalaryMax'.
2.) Creating the column 'JobType'.
3.) Creating the columns 'City' and 'State'.
4.) Creating the columns 'HQCity' and 'HQState'.
5.) Creating the column 'CompanySize'.
6.) Turning '-1' into either null or ''.
7.) Removing excess text from the 'Revenue' column.
8.) Removing duplicate records.
9.) Creating the 'SalaryAvg' column.
10.) Re-organizing columns and records and storing data into a new table. 

*/

-- 1.) In this step I create two new columns called 'SalaryMin' and 'SalaryMax' using the 'SalaryEstimate' column. Once I am done, I delete
-- the SalaryEstimate column. 

ALTER TABLE DSJobs
ADD SalaryMin varchar(50); 

SET SQL_SAFE_UPDATES = 0;

UPDATE DSJobs
SET SalaryMin =  SUBSTRING(salaryestimate, 2, LOCATE('K', salaryestimate)-2) ; 

ALTER TABLE DSJobs
ADD SalaryMax varchar(50); 

UPDATE DSJobs
SET SalaryMax =  SUBSTRING(salaryestimate, LOCATE('$', salaryestimate,2) +1, LOCATE('K',salaryestimate,6)  - LOCATE ('$', salaryestimate,2)  - 1) ; 

ALTER TABLE DSJobs
DROP COLUMN SalaryEstimate;

SET SQL_SAFE_UPDATES = 1;


-- 2.)  In this step I create a new column called 'JobType' where I categorize jobs in the 'JobTitle' column as either being DE (Data Engineer),
-- DS (Data Scientist), DA (Data Analyst), or 'Other' for everything else. 

ALTER TABLE DSJobs
ADD JobType varchar(50);

SET SQL_SAFE_UPDATES = 0;

UPDATE DSJobs
SET JobType = CASE

	WHEN JobTitle LIKE '%engin%' THEN 'DE'
	WHEN JobTitle LIKE '%scien%' THEN 'DS'
    WHEN JobTitle LIKE '%analy%' THEN 'DA'
    ELSE 'Other'

END  ; 

SET SQL_SAFE_UPDATES = 1;


-- 3.) In this step, I break the 'location' column into two different columns, the 'City' column and the 'State' column. Once I am done, I delete
-- the location column. 

ALTER TABLE DSJobs
ADD City varchar(50);

SET SQL_SAFE_UPDATES = 0;

UPDATE DSJobs
SET City = CASE
WHEN location = 'Remote' THEN location
WHEN location = 'United States' THEN ''
ELSE SUBSTRING(location,1, LOCATE(',', location)-1)
END
 ; 

ALTER TABLE DSJobs
ADD State varchar(50);


UPDATE DSJobs
SET State = CASE
WHEN location='Remote' THEN location
WHEN location = 'United States' THEN ''
WHEN location = 'California' THEN 'CA'
WHEN location = 'New Jersey' THEN 'NJ'
WHEN location = 'Utah' THEN 'UT'
WHEN location = 'Texas' THEN 'TX'
WHEN city = 'Patuxent' THEN 'MD'
ELSE SUBSTRING(location,LOCATE(',', location)+2, 2)
END  ; 
 
ALTER TABLE DSJobs
DROP COLUMN Location; 

SET SQL_SAFE_UPDATES = 1;

-- 4.) In this step, I break the 'headquarters' column into two different columns, the 'HQCity' column and the 'HQState' column. Once I am done, 
-- I delete the 'headquarters' column. 


ALTER TABLE DSJobs
ADD HQCity varchar(200); 

SET SQL_SAFE_UPDATES = 0;

UPDATE DSJobs
SET HQCity = CASE 
WHEN headquarters=-1 THEN ''
ELSE SUBSTRING(headquarters, 1,LOCATE(',', headquarters)-1 ) 
END ; 

ALTER TABLE DSJobs
ADD HQState varchar(200); 

UPDATE DSJobs
SET HQState = CASE
WHEN headquarters=-1 THEN ''
ELSE SUBSTRING(headquarters, LOCATE(',', headquarters)+2,50 ) 
END ; 

ALTER TABLE DSJobs
DROP COLUMN Headquarters;

SET SQL_SAFE_UPDATES = 1;

-- 5.) In this step, I create a column called 'CompanySize' which is similar to the original 'Size' column but without all of the 
-- unnecessary text. After that, I delete the 'Size' column. 


ALTER TABLE DSJobs
ADD CompanySize varchar(200); 

SET SQL_SAFE_UPDATES = 0;

UPDATE DSJobs
SET CompanySize = CASE
WHEN (CASE
WHEN size = '10000+ employees' THEN ''
ELSE SUBSTRING(size,LOCATE('to', size)+2, LOCATE('e', size)- LOCATE('to', size) - 3 )
END)='' THEN CONCAT((CASE
WHEN size = '10000+ employees' THEN '10000+'
ELSE SUBSTRING(size,1, LOCATE('to', size)-1 )
END),(CASE
WHEN size = '10000+ employees' THEN ''
ELSE SUBSTRING(size,LOCATE('to', size)+2, LOCATE('e', size)- LOCATE('to', size) - 3 )
END))
ELSE CONCAT((CASE
WHEN size = '10000+ employees' THEN '10000+'
ELSE SUBSTRING(size,1, LOCATE('to', size)-1 )
END),'-',CASE
WHEN size = '10000+ employees' THEN ''
ELSE SUBSTRING(size,LOCATE('to', size)+2, LOCATE('e', size)- LOCATE('to', size) - 3 )
END)
END;

SET SQL_SAFE_UPDATES = 1;

ALTER TABLE DSJobs
DROP COLUMN Size; 


-- 6.) Some of the columns in this dataset use a '-1' to indicate that a value is not available. Since this could mess with certain queries,
-- I will replace all '-1' values with either an empty string or a null. I will do this for the following columns: 'Founded' , 'Industry', 
-- 'TypeofOwnership', 'Sector', 'Revenue', and 'Competitors'.

SET SQL_SAFE_UPDATES = 0;

UPDATE DSJOBS
SET founded=
CASE
WHEN founded=-1 THEN null
ELSE founded
END
;

UPDATE DSJOBS
SET industry=
CASE
WHEN industry=-1 THEN ''
ELSE industry
END
;

UPDATE DSJOBS
SET typeofownership=
CASE
WHEN typeofownership=-1 THEN ''
ELSE typeofownership
END
;

UPDATE DSJOBS
SET sector=
CASE
WHEN sector=-1 THEN ''
ELSE sector
END
;



UPDATE DSJOBS
SET revenue=
CASE
WHEN revenue=-1 THEN ''
ELSE revenue
END
;

UPDATE DSJOBS
SET competitors=
CASE
WHEN competitors=-1 THEN ''
ELSE competitors
END
;

SET SQL_SAFE_UPDATES = 1;

-- 7.) In this step I remove the excess text from the data entered into the 'Revenue' column. 

SET SQL_SAFE_UPDATES = 0;

UPDATE DSJOBS
SET revenue=
CASE
WHEN revenue = 'Unknown / Non-Applicable' THEN ''
WHEN revenue = '' THEN ''
WHEN revenue = '$1 to $2 billion (USD)' THEN '1-2 B'
WHEN revenue = '$100 to $500 million (USD)' THEN '100-500 M'
WHEN revenue = '$10+ billion (USD)' THEN '10+ B'
WHEN revenue = '$2 to $5 billion (USD)' THEN '2-5 B'
WHEN revenue = '$500 million to $1 billion (USD)' THEN '0.5 -1 B'
WHEN revenue = '$5 to $10 billion (USD)' THEN '5-10 B'
WHEN revenue = '$10 to $25 million (USD)' THEN '10-25 M'
WHEN revenue = '$25 to $50 million (USD)' THEN '25-50 M'
WHEN revenue = '$50 to $100 million (USD)' THEN '50-100 M'
WHEN revenue = '$1 to $5 million (USD)' THEN '1-5 M'
WHEN revenue = '$5 to $10 million (USD)' THEN '5-10 M'
WHEN revenue = 'Less than $1 million (USD)' THEN '-1 M'
END
;

SET SQL_SAFE_UPDATES = 1;

-- 8.) In this step, I move the data to a new table called Duplicates. I then remove any duplicate records. I define duplicate records as having
-- the same companyname, jobtitle, city, and state. This dataset includes a number of records which have all the same data except for the 
-- salary range. To fix this issue, I set the salary minimum of every record to the lowest minimum belonging to that group of duplicates, and 
-- the salary maximum to the highest maximum belonging to that group of duplicates. For example, if one record has a SalaryMin = 100 and 
-- SalaryMax = 130 and its duplicate record has a SalaryMin=105 and SalaryMax = 150, then both would get SalaryMin= 100 and SalaryMax=150. 
-- After doing this, the two records would then be truly identical, and one would get deleted. 

SET SQL_SAFE_UPDATES = 0;

CREATE TABLE Duplicates (
    idx int,
    JobTitle varchar(255),
    JobDescription text,
    Rating int,
    CompanyName varchar(255),
    Founded int,
    Ownership varchar(255),
    Industry varchar(255),
    Sector varchar(255),
    Revenue varchar(255),
    Competitors varchar(255),
    SalaryMin int,
    SalaryMax int,
    SalaryAvg int,
    SalaryRange varchar(255),
    JobType varchar(255),
    City varchar(255),
    State varchar(255),
    HQCity varchar(255),
    HQState varchar(255),
    CompanySize varchar(255),
    UQ int,
    MINIM int,
    MAXIM int
    
);

INSERT INTO Duplicates

WITH 

DuplicateCTE  AS
(SELECT *, ROW_NUMBER() OVER (PARTITION BY jobtitle,companyname,city,state) AS UQ
FROM cleanedv1
) 

SELECT * ,
MIN(CONVERT(SalaryMin,unsigned)) OVER (PARTITION BY companyname,jobtitle,city,state) AS MINIM,
MAX(CONVERT(SalaryMax,unsigned)) OVER (PARTITION BY companyname,jobtitle,city,state) AS MAXIM

FROM DuplicateCTE
ORDER BY companyname,jobtitle,city,state,uq
;

DELETE FROM Duplicates
WHERE UQ>1;

UPDATE Duplicates
SET Salarymin = minim;

UPDATE Duplicates
SET Salarymax = maxim;

ALTER TABLE Duplicates
DROP COLUMN minim;

ALTER TABLE Duplicates
DROP COLUMN maxim;

ALTER TABLE Duplicates
DROP COLUMN uq;

SET SQL_SAFE_UPDATES = 1;


-- 9.) In this step, I create a column called 'SalaryAvg' which is the average of the SalaryMin and SalaryMax. 

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE Duplicates
ADD SalaryAvg int; 

UPDATE Duplicates
SET SalaryAvg = round((salarymin+salarymax)/2 ,1); 

SET SQL_SAFE_UPDATES = 1;


-- 10.) This is the final step. Here I create a table called 'CleanedDSJobs' where I store my cleaned dataset. Before storing, I re-order
-- the records according to the index number, delete the 'Industry' column, and re-order the columns according to what I personally think
-- is the most interesting.

SET SQL_SAFE_UPDATES = 0;

CREATE TABLE CleanedDSJobs (
    idx int,
    CompanyName varchar(255),
    JobTitle varchar(255),
    JobType varchar(225),
    SalaryMin int,
    SalaryMax int,
    SalaryAvg int,
    City varchar(255),
    State varchar(255),
	Sector varchar(255),
    CompanySize varchar(255),
    Rating int,
    Revenue varchar(255),
    Ownership varchar(255),
    Founded  int,
    HQCity varchar(255),
    HQState varchar(255),
    Competitors varchar(255),
    JobDescription text
    
);


INSERT INTO CleanedDSJobs

SELECT idx, companyname, jobtitle, jobtype, salarymin, salarymax, salaryavg, city, state, sector, companysize, rating, revenue, ownership, founded,
hqcity,hqstate,competitors, jobdescription
FROM duplicates
order by idx;

SET SQL_SAFE_UPDATES = 1;



