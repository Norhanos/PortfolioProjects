ALTER TABLE DSJobs
ADD SalaryMin varchar(50); 

SET SQL_SAFE_UPDATES = 0;

UPDATE DSJobs
SET SalaryMin =  SUBSTRING(salaryestimate, 2, LOCATE('K', salaryestimate)-2) ; 

SET SQL_SAFE_UPDATES = 1;

ALTER TABLE DSJobs
ADD SalaryMax varchar(50); 

SET SQL_SAFE_UPDATES = 0;

UPDATE DSJobs
SET SalaryMax =  SUBSTRING(salaryestimate, LOCATE('$', salaryestimate,2) +1, LOCATE('K',salaryestimate,6)  - LOCATE ('$', salaryestimate,2)  - 1) ; 

SET SQL_SAFE_UPDATES = 1;

ALTER TABLE DSJobs
ADD SalaryAvg varchar(50); 


SET SQL_SAFE_UPDATES = 0;

UPDATE DSJobs
SET SalaryAvg = (salarymin+salarymax)/2 ; 

SET SQL_SAFE_UPDATES = 1;

ALTER TABLE DSJobs
ADD SalaryRange varchar(50); 

SET SQL_SAFE_UPDATES = 0;

UPDATE DSJobs
SET SalaryRange = CONCAT(salarymin,'-',salarymax)  ; 

SET SQL_SAFE_UPDATES = 1;

ALTER TABLE DSJobs
DROP COLUMN SalaryEstimate;
