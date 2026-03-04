create table patients(
patient_id	int,
age	int,
sex	varchar(50),
blood_type	text,
chronic_disease	varchar(50),
bmi	numeric(10,1),
smoker	varchar(50),
insurance_type	varchar(50),
admission_count	int);


create table admissions(
admission_id	int,
patient_id	int,
admission_date	date,
discharge_date	date ,
department	varchar(50),
admission_reason	varchar(50),
severity	varchar(50),
icu_required	varchar(50),
length_of_stay_days	int);

create table treatment(
treatment_id	int,
admission_id	int,
treatment_type	varchar(50),
treatment_date	date,
outcome	varchar(50),
cost_usd	numeric(10,2));

create table billing(
billing_id	int,
admission_id	int,
total_cost_usd	numeric(10,2),
insurance_coverage_percent	int,
patient_responsibility_usd	numeric(10,2),
payment_status	varchar(50),
payment_method	varchar(50),
insurance_coverage_usd	numeric(10,2));



select * from patients;
select * from treatment;
select * from admissions;
select * from billing;



---- COST & FINANCIAL CONTROL

--- Which departments contribute the highest total healthcare cost?

select a.department,sum(total_cost_usd) as total_cost
from admissions a
join billing b
on a.admission_id = b.admission_id 
group by a.department
order by total_cost desc;

--- Which treatments consume the most money overall?

select treatment_type,sum(cost_usd) as total_usd
from treatment
group by treatment_type
order by total_usd desc;


--- Patient Flow & Operations

---  How many patients are admitted per day/month and how does this trend over time?

select extract(month from admission_date) as month, count(admission_id) no_of_patients
from admissions
group by month
order by no_of_patients desc;

---  What is the average length of stay (LOS) per department?

select department,round(avg(length_of_stay_days),2) as Average_stay
from admissions
group by department;

--- Which departments have the highest patient load ?

select department,count(*) as highest_patient
from admissions
group by department
order by highest_patient desc;


--- Q4: What percentage of patients are repeat patients vs new?

with patient_counts as(
select patient_id,
count(*) as admission_count
from admissions
group by patient_id),

total as (
select 
sum (case when admission_count =1 then 1 else 0 end) as new_count,
sum (case when admission_count > 1 then 1 else 0 end) as repeat_count,
count (*) as total_patients
from patient_counts)

select  total_patients,
	round(new_count*100/total_patients,2) as new_pct,
	round(repeat_count*100/total_patients,2) as repeat_pct
from total;


--- How does LOS vary by severity level?

select severity,
	round(avg(length_of_stay_days),2) as avg_los,
	min(length_of_stay_days) as min_los,
	max(length_of_stay_days) as max_los,
	count(*) as patient_count
from admissions
group by severity
order by avg_los desc;


---  Which admission reasons result in longest stays?

select admission_reason,round(avg(length_of_stay_days),2) as avg_los
from admissions
group by admission_reason
order by avg_los desc;

---- Revenue & Financial Performance

--- Total revenue by department?

select 	a.department,sum(b.total_cost_usd) as total_revenue
from admissions a
inner join billing b
on b.admission_id = a.admission_id
group by a.department
order by total_revenue desc;

---  Highest average cost per patient by department?

select a.department,round(avg(b.total_cost_usd),2) as avg_cost
from admissions a
inner join billing b
on b.admission_id = a.admission_id
group by a.department
order by avg_cost desc;

---  Percentage of bills by payment status?

select total_payments,
		round(paid_count*100/total_payments,2) as paid_pct,
		round(partial_count*100/total_payments,2) as partial_pct,
		round(pending_count*100/total_payments,2) as pending_pct
from(select count(*) as total_payments,
	sum(case when payment_status = 'Paid' then 1 else 0 end) as paid_count,
	sum(case when payment_status = 'Partial Payment' then 1 else 0 end) as partial_count,
	sum(case when payment_status = 'Pending' then 1 else 0 end) as pending_count
	from billing);

---  How much revenue is at risk?

select sum(total_cost_usd) as risk_revenue
from billing
where payment_status in('Partial Payment','Pending')

---  Average insurance coverage % by insurance type?

select p.insurance_type,round(avg(b.insurance_coverage_percent),2) as avg_insurance_cov_pct
from patients p
inner join admissions a on p.patient_id = a.patient_id
inner join billing b on b.admission_id = a.admission_id
group by p.insurance_type
order by avg_insurance_cov_pct desc;

---  Which payment method generates most revenue?

select payment_method,sum(total_cost_usd) as total_revenue
from billing
where payment_status = 'Paid'
group by payment_method;

---  Patients with highest lifetime value?

select a.patient_id,sum(b.total_cost_usd) as total_paid
from admissions a
inner join billing b
on a.admission_id = b.admission_id
group by a.patient_id
order by total_paid desc;

--- ICU & Critical Care

---  What percentage of admissions require ICU care?

select total_admissions,
	round((yes_count*100/total_admissions),2) as yes_pct,
	round((no_count*100/total_admissions),2) as no_pct
from (select count(*) as total_admissions,
	count(case when icu_required = 'Yes' then 1 end) as yes_count,
	count(case when icu_required = 'No' then 1 end) as no_count
from admissions);


---  Which departments have highest ICU utilization rate?

select 
    department,
    count(*) as total_admissions,
    sum(case when  icu_required = 'Yes' then 1 else 0 end) as icu_cases,
    sum(case when icu_required = 'No' then 1 else 0 end) as non_icu_cases,
    round(sum(case when icu_required = 'Yes' then 1 else 0 END) * 100.0 / count(*), 2) as icu_percentage,
    rank() over (order by sum(case when icu_required = 'Yes' then 1 else 0 end) * 100.0 / count(*) desc) as icu_utilization_rank
from admissions
group by department
order by icu_percentage desc;


--- Average LOS for ICU vs non-ICU patients?
 
select 
    icu_required,
    count(*) as patient_count,
    round(AVG(length_of_stay_days), 2) as avg_los,
    round(MIN(length_of_stay_days), 2) as min_los,
    round(MAX(length_of_stay_days), 2) as max_los,
    round(STDDEV(length_of_stay_days), 2) as stddev_los
from admissions
group by icu_required
order by icu_required desc;

--- PATIENT DEMOGRAPHICS & RISK


--- Do smokers have longer stays?

select 
    p.smoker,
    count(distinct p.patient_id) as patient_count,
    count(a.admission_id) as total_admissions,
    round(avg(a.length_of_stay_days), 2) as avg_los,
    round(avg(b.total_cost_usd), 2) as avg_cost,
    sum(case when a.icu_required = 'Yes' then 1 else 0 end) as icu_cases
from patients p
inner join admissions a on p.patient_id = a.patient_id
inner join billing b on a.admission_id = b.admission_id
group by p.smoker;


--- Age distribution and which age group has most admissions?


select 
    case 
        when p.age < 30 then '18-29'
        when p.age < 50 then '30-49'
        when p.age < 65 then '50-64'
        else '65+'
    end as age_group,
    count(distinct p.patient_id) as unique_patients,
    count(a.admission_id) as total_admissions,
    round(avg(a.length_of_stay_days), 2) as avg_los,
    round(avg(b.total_cost_usd), 2) as avg_cost,
    rank() over (order by count(a.admission_id) desc) as admission_rank
from patients p
inner join admissions a on p.patient_id = a.patient_id
inner join billing b on a.admission_id = b.admission_id
group by 
    case 
        when p.age < 30 then '18-29'
        when p.age < 50 then '30-49'
        when p.age < 65 then '50-64'
        else '65+'
    end
order by total_admissions desc;

--- Most common chronic diseases?

-- Chronic disease distribution
select 
    chronic_disease,
    count(distinct patient_id) as patient_count,
    ROUND(count(distinct patient_id) * 100.0 / (select count(distinct patient_id) from patients), 2) as percentage_of_patients
from patients
group by chronic_disease
order  by patient_count desc;

--- Most expensive patient segment (age + chronic disease)?

create or replace view  age_segment as 
(select 
    case 
        when p.age < 30 then '18-29'
        when p.age < 50 then '30-49'
        when p.age < 65 then '50-64'
        else '65+'
    end as age_group,
    p.chronic_disease,
    count(distinct p.patient_id) as patient_count,
    count(a.admission_id) as total_admissions,
    round(avg(a.length_of_stay_days), 2) as avg_los,
    sum(b.total_cost_usd) as total_cost,
    round(avg(b.total_cost_usd), 2) as avg_cost_per_admission,
    rank() over (order by sum(b.total_cost_usd) desc) as cost_rank
from patients p
inner join admissions a on p.patient_id = a.patient_id
inner join billing b on a.admission_id = b.admission_id
group by 
    case 
        when p.age < 30 then '18-29'
        when p.age < 50 then '30-49'
        when p.age < 65 then '50-64'
        else '65+'
    end,
    p.chronic_disease
order by total_cost desc
limit 20);

select * from age_segment;

--- Month-over-Month Department Growth

create view monthly_department_growth as 
(with monthly_dept_stats as (
    select 
        department,
        extract(year from admission_date) as year,
        EXTRACT(month from admission_date) as month,
        count(*) as monthly_admissions,
        sum(b.total_cost_usd) as monthly_revenue
    from admissions a
    inner join billing b on a.admission_id = b.admission_id
    group by department, extract(year from admission_date), extract(month from admission_date)
)
select 
    department,
    year,
    month,
    monthly_admissions,
    monthly_revenue,
    lag(monthly_admissions) over (partition by department order by year, month) as prev_month_admissions,
    lag(monthly_revenue) over (partition by department order by year, month) as prev_month_revenue,
    monthly_admissions - lag(monthly_admissions) over (partition by department order by year, month) as admission_change,
    round(
        (monthly_admissions - lag(monthly_admissions) over (partition by department order by year, month)) * 100.0 
        / nullif(lag(monthly_admissions) over (partition by department order by year, month), 0)
    , 2) as admission_growth_pct,
    round(
        (monthly_revenue - lag(monthly_revenue) over (partition by department order by year, month)) * 100.0 
        / nullif(lag(monthly_revenue) over (partition by department order by year, month), 0)
    , 2) as revenue_growth_pct
from monthly_dept_stats
order by department, year, month);

select * from monthly_department_growth;

--- patient_risk_score

create view patient_risk_view as
(WITH patient_metrics AS (
    SELECT 
        p.patient_id,
        p.age,
        p.sex,
        p.chronic_disease,
        p.bmi,
        p.smoker,
        COUNT(a.admission_id) as total_admissions,
        SUM(a.length_of_stay_days) as total_days_hospitalized,
        ROUND(AVG(a.length_of_stay_days), 2) as avg_los,
        SUM(CASE WHEN a.icu_required = 'Yes' THEN 1 ELSE 0 END) as icu_admissions,
        SUM(b.total_cost_usd) as lifetime_value
    FROM patients p
    LEFT JOIN admissions a ON p.patient_id = a.patient_id
    LEFT JOIN billing b ON a.admission_id = b.admission_id
    GROUP BY p.patient_id, p.age, p.sex, p.chronic_disease, p.bmi, p.smoker
),
risk_scores AS (
    SELECT 
        *,
        CASE 
            WHEN age > 65 THEN 3
            WHEN age > 50 THEN 2
            ELSE 1
        END as age_risk_score,
        CASE 
            WHEN chronic_disease != 'None' THEN 3
            ELSE 0
        END as disease_risk_score,
        CASE 
            WHEN smoker = 'Yes' THEN 2
            ELSE 0
        END as lifestyle_risk_score,
        CASE 
            WHEN bmi > 30 THEN 2
            WHEN bmi < 18.5 THEN 1
            ELSE 0
        END as bmi_risk_score,
        CASE 
            WHEN icu_admissions > 0 THEN 3
            ELSE 0
        END as icu_risk_score
    FROM patient_metrics
),
final_scoring AS (
    SELECT 
        *,
        (age_risk_score + disease_risk_score + lifestyle_risk_score + bmi_risk_score + icu_risk_score) as total_risk_score,
        NTILE(4) OVER (ORDER BY lifetime_value DESC) as value_quartile
    FROM risk_scores
)
SELECT 
    patient_id,
    age,
    sex,
    chronic_disease,
    total_admissions,
    lifetime_value,
    total_risk_score,
    value_quartile,
    CASE 
        WHEN total_risk_score >= 8 THEN 'High Risk'
        WHEN total_risk_score >= 5 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END as risk_category,
    CASE 
        WHEN value_quartile = 1 AND total_risk_score >= 8 THEN 'High-Value High-Risk (Priority)'
        WHEN value_quartile = 1 AND total_risk_score < 8 THEN 'High-Value Low-Risk (Maintain)'
        WHEN value_quartile = 4 AND total_risk_score >= 8 THEN 'Low-Value High-Risk (Monitor)'
        ELSE 'Standard Care'
    END as patient_strategy
FROM final_scoring
ORDER BY lifetime_value DESC, total_risk_score DESC);

select * from patient_risk_view;
