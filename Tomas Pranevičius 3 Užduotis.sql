/*SQL Home Task
The output of the task should be provided queries. If you can, you could also provide the output
of the query result or test scenarios.
Duration of the task working remotely is 1.5 h. First 0.5 h should be spent for data upload to the
DB. 1 hour should be spent for writing the queries. It is completely OK not to finish all tasks
– quality is more important than quantity!
You should use default.sandbox_activations table/ file
(https://drive.google.com/file/d/1Wuh6ZbBbeh1Jkk_jlOY76-kDVcipsU6T/view?usp=sharing),
where you can get information about the base of the prepaid clients.
Before starting the task, you should download PostgreSQL https://www.postgresql.org/download/
Upload sandbox_activations.csv file into the DB.
Main info about the columns of a prepaid customer base:
-- account_id - unique SIM / Client ID
-- msisdn - phone number of the client
-- activation_date - service activation date
-- deletion_date - service deactivation date
-- status - the newest/current status of the service/client
-- imei_a - unique phone/device ID (IMEI).
-- device_brand - Phone brand
-- device_model - Phone model
-- device_type - Phone type
TASKS:*/
/*1) Query by which you could extract active clients at the 2013-06-19.*/

select * from sandbox_activations_csv
where activation_date <= '2013-06-19%' and status = 'ACTIVE';



/*2) How many clients were activated and deactivated during June of 2013. Please provide
both numbers as a result of one query.*/

select count(*) as total,
SUM(CASE when activation_date like '2013-06%'  then 1 end) as 'ACTIVATED CLIENTS',
SUM(CASE when deletion_date like '2013-06%'  then 1 end) as 'DEACTIVATED CLIENTS'
from sandbox_activations_csv;



/*3) How many active clients had more than one SIM card on 2013-06-19. Unique client
could be identified by using unique device information (prepaid customers are usually not
identified in the systems).*/

select count(count) from (select count(*) as count, imei_a from sandbox_activations_csv
where activation_date <= '2013-06-19%' and status like 'active'
group by imei_a
having imei_a not in (0,'') and count > 1) as kt;

/*4) Select currently active clients and pick up TOP5 device brands by each phone type.
Please provide the result in one single query.*/

select device_brand, count(*) as total
from sandbox_activations_csv
where status = 'ACTIVE' and device_brand not like ''
group by device_brand
order by total desc
limit 5;

/*5) Request is to provide a new column for currently active clients. New column should have
the value of IMEI if the client is the first who used this IMEI (you can check by the client
activation date). If the client is not the first one, then column value should be 'Multi SIM'.*/

select *,
CASE 
	WHEN account_id in (select account_id from sandbox_activations_csv
	where imei_a != "" 
	group by imei_a
	HAVING min(activation_date)) then imei_a 
	ELSE'MULTI-SIM'
END AS IMEY
from sandbox_activations_csv;


/*6) Rebuild the table into an IMEI history query where you could track the history of the
reuse of the device. This table/query should have the columns:
-- imei
-- msisdn
-- device_brand
-- device_model
-- imei_eff_dt - the date when msisdn is used with the IMEI
-- imei_end_dt - the date when new other msisdn reused the phone.*/