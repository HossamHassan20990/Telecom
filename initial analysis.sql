/*
	General questions about leaving customers:
				
		1-What percentage of customers abandoned the service during the time period covered by the data?
		2-What are the main reasons reported by customers for leaving the service?
		3-Is there a difference in the rate of abandonment between different categories of customers (by age, gender, location, type of service)?
		4-Is there a relationship between the level of customer satisfaction and the likelihood of leaving the service?
*/

-- 1-What percentage of customers abandoned the service during the time period covered by the data?
SELECT 
	count (*) as total_customers ,
	count (case when customer_status = 'churned' then 1 end) as customer_churned,
	(count (case when customer_status = 'churned' then 1 end) *100 /  count (*)) as percentage_customer_chutned
FROM telecom..status_analysis

-- 2-What are the main reasons reported by customers for leaving the service?
-- category reason
CREATE VIEW categoty_reason as 
SELECT churn_category , count (*) as reason_frequency
FROM telecom..status_analysis
WHERE customer_status = 'churned'
GROUP BY churn_category

WITH TotalChurns AS (
    SELECT SUM(reason_frequency) AS total_churns
    FROM categoty_reason
)
SELECT
    churn_category,
    reason_frequency,
    (reason_frequency  * 100.0 / (SELECT total_churns FROM TotalChurns))  AS percentage
FROM
    categoty_reason;

-- main reasin
SELECT  churn_reason , count (*) as reason_frequency
FROM telecom..status_analysis
WHERE customer_status = 'churned'
GROUP BY churn_reason
ORDER BY reason_frequency DESC

-- 3-1-Is there a difference in the rate of abandonment between different categories of customers by gender
-- Create view to easy handling two table
CREATE VIEW churned_by_gender as 
SELECT 
	telecom..customer_info.gender , telecom..status_analysis.customer_status
FROM 
	telecom..customer_info
JOIN 
	telecom..status_analysis
ON 
	telecom..customer_info.customer_id = telecom..status_analysis.customer_id

SELECT
	telecom..churned_by_gender.gender ,
	count (*) as total,
	count (case when customer_status = 'churned' then 1 end ) as customer_churned,
	(floor(count (case when customer_status = 'churned' then 1 end) * 100 / count (*))) as percentage_of_churned
FROM 
	telecom..churned_by_gender
GROUP BY
	telecom..churned_by_gender.gender

-- 3-2-Is there a difference in the rate of abandonment between different categories of customers by age?

-- Create view to easy handling two table
CREATE VIEW churned_by_age as 
SELECT 
	telecom..customer_info.age , telecom..status_analysis.customer_status
FROM 
	telecom..customer_info
JOIN 
	telecom..status_analysis
ON 
	telecom..customer_info.customer_id = telecom..status_analysis.customer_id

SELECT * FROM  telecom..churned_by_age

SELECT 
	telecom..churned_by_age.customer_status , 
	min(telecom..churned_by_age.age) as 'MIN',
	avg(telecom..churned_by_age.age) as 'AVG',
	max(telecom..churned_by_age.age) as 'MAX'
FROM 
	telecom..churned_by_age
GROUP BY 
	telecom..churned_by_age.customer_status

-- 3-3-Is there a difference in the rate of abandonment between different categories of customers by location?

-- Create view to easy handling two table
CREATE VIEW  churned_by_location as
SELECT  
	telecom..location_info.city, telecom..status_analysis.customer_status
FROM 
	telecom..location_info
JOIN 
	telecom..status_analysis
ON telecom..status_analysis.customer_id = telecom..location_info.customer_id

SELECT 
	churned_by_location.city, 
	count(case when churned_by_location.customer_status = 'churned' then 1 end ) as total_churned
FROM 
	churned_by_location
GROUP BY 
	churned_by_location.city
ORDER BY total_churned DESC

-- 3-4-Is there a difference in the rate of abandonment between different categories of customers by type of services?
-- Create view to easy handling two table
CREATE VIEW churned_by_type_of_services as
SELECT 
	telecom..service_options.* , 
	telecom..status_analysis.customer_status,
	telecom..status_analysis.cltv
FROM 
	telecom..service_options 
JOIN 
	telecom..status_analysis
ON 
	telecom..service_options.customer_id = telecom..status_analysis.customer_id

	SELECT 
		customer_status, 
		min(cltv) 'min_cltv', 
		max(cltv) 'max_cltv' 
	FROM 
		churned_by_type_of_services
	GROUP BY 
		customer_status

-- 4-Is there a relationship between the level of customer satisfaction and the likelihood of leaving the service?

SELECT 
	customer_status,
	min(satisfaction_score) 'min customer satisfaction score',
	max(satisfaction_score) 'max customer satisfaction score',
	avg(satisfaction_score) 'avg customer satisfaction score',
	min(churn_score) 'min churn score',
	max(churn_score) 'max churn score',
	avg(churn_score) 'avg churn score'
FROM 
	telecom..status_analysis
GROUP BY 
	customer_status


/* 
	Create view that collects all the questions and re-analyzes them 
	contains all tables 
	retreve the columns that were analyzed
*/

SELECT * FROM telecom..customer_info
SELECT * FROM telecom..location_info
SELECT * FROM telecom..online_services
SELECT * FROM telecom..payment_info
SELECT * FROM telecom..service_options
SELECT * FROM telecom..status_analysis

CREATE VIEW churned_customers as

SELECT 
	telecom..customer_info.customer_id, telecom..customer_info.gender, telecom..customer_info.age,
	telecom..location_info.city, telecom..location_info.total_population,
	telecom..payment_info.contract, telecom..payment_info.payment_method, telecom..payment_info.monthly_charges, telecom..payment_info.total_charges, telecom..payment_info.total_revenue,
	telecom..service_options.avg_monthly_gb_download, telecom..service_options.unlimited_data, telecom..service_options.offer,
	telecom..status_analysis.satisfaction_score, telecom..status_analysis.cltv, telecom..status_analysis.customer_status, telecom..status_analysis.churn_score, telecom..status_analysis.churn_category,telecom..status_analysis.churn_reason
FROM 
	telecom..customer_info 
JOIN 
	telecom..location_info  ON  telecom..customer_info.customer_id = telecom..location_info.customer_id
JOIN 
	telecom..payment_info  ON  telecom..customer_info.customer_id = telecom..payment_info.customer_id
JOIN 
	telecom..service_options  ON  telecom..customer_info.customer_id = telecom..service_options.customer_id
JOIN 
	telecom..status_analysis  ON  telecom..customer_info.customer_id = telecom..status_analysis.customer_id

SELECT * FROM churned_customers







