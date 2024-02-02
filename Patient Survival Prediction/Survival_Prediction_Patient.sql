-- Missing value treatment for variables
UPDATE Patient_Survival.dbo.survival_data
SET ethnicity = 'Mixed'
WHERE ethnicity IS NULL;

UPDATE Patient_Survival.dbo.survival_data
SET gender = 'Unknown'
WHERE gender IS NULL;

-- Calculate total hospital deaths and mortality rate
SELECT 
  COUNT(CASE WHEN hospital_death = 1 THEN 1 END) AS total_hospital_deaths,
  CONCAT(ROUND(COUNT(CASE WHEN hospital_death = 1 THEN 1 END) * 100.0 / COUNT(*), 2), '%') AS mortality_rate
FROM survival_data;

-- Death count by ethnicity
SELECT ethnicity, COUNT(hospital_death) AS total_deaths_by_ethnicity
FROM survival_data
WHERE hospital_death = 1
GROUP BY ethnicity;

-- Death count by gender
SELECT gender, COUNT(hospital_death) AS total_deaths_by_gender
FROM survival_data
WHERE hospital_death = 1
GROUP BY gender;

-- Compare average and max ages of patients who died and survived
SELECT 
  ROUND(AVG(age), 2) AS avg_age,
  MAX(age) AS max_age, 
  hospital_death
FROM survival_data
WHERE hospital_death IN ('1', '0')
GROUP BY hospital_death;

-- Compare patients who died and survived by each age
SELECT 
  age,
  COUNT(CASE WHEN hospital_death = 1 THEN 1 END) AS patient_died,
  COUNT(CASE WHEN hospital_death = 0 THEN 1 END) AS patient_survived
FROM survival_data
GROUP BY age
ORDER BY age ASC;

-- Age distribution of patients in intervals
SELECT
  CONCAT(FLOOR(age / 10) * 10, '-', FLOOR(age / 10) * 10 + 9) AS age_interval,
  COUNT(*) AS patient_count,
  COUNT(CASE WHEN hospital_death = 1 THEN 1 END) AS patient_died,
  CONCAT(ROUND(COUNT(CASE WHEN hospital_death = 1 THEN 1 END) * 100.0 / COUNT(*), 2), '%') AS mortality_rate
FROM survival_data
GROUP BY CONCAT(FLOOR(age / 10) * 10, '-', FLOOR(age / 10) * 10 + 9)
ORDER BY age_interval;

-- Patients above 65 vs patients between 50 and 65
SELECT 
  COUNT(CASE WHEN age > 65 THEN 1 END) AS total_patient_over_65,
  COUNT(CASE WHEN age > 65 AND hospital_death = 0 THEN 1 END) AS survived_over_65,
  COUNT(CASE WHEN age > 65 AND hospital_death = 1 THEN 1 END) AS death_over_65,
  COUNT(CASE WHEN age BETWEEN 50 AND 65 THEN 1 END) AS total_patient_between_50_65,
  COUNT(CASE WHEN age BETWEEN 50 AND 65 AND hospital_death = 0 THEN 1 END) AS survived_between_50_65,
  COUNT(CASE WHEN age BETWEEN 50 AND 65 AND hospital_death = 1 THEN 1 END) AS death_between_50_65
FROM survival_data;

-- Average probability of hospital death for different age groups
WITH cte_group AS (
  SELECT *,
    CASE
      WHEN age < 40 THEN 'Under 40'
      WHEN age BETWEEN 40 AND 59 THEN '40-59'
      WHEN age BETWEEN 60 AND 79 THEN '60-79'
      ELSE '80 and above'
    END AS age_group
  FROM survival_data
)
SELECT 
  age_group,
  ROUND(AVG(apache_4a_hospital_death_prob), 3) AS average_death_prob
FROM cte_group
GROUP BY age_group;

-- ICU admission source with most deaths and admissions
WITH ICU_Admission AS (
  SELECT DISTINCT 
    icu_admit_source,
    COUNT(CASE WHEN hospital_death = '1' THEN 1 END) AS total_died,
    COUNT(CASE WHEN hospital_death = '0' THEN 1 END) AS total_survived
  FROM survival_data
  GROUP BY icu_admit_source
)
SELECT 
  icu_admit_source,
  total_died,
  total_survived,
  (total_died + total_survived) AS total_admission
FROM ICU_Admission
ORDER BY total_admission;

-- Average age of people who died in each ICU admit source
SELECT DISTINCT 
  icu_admit_source,
  COUNT(hospital_death) AS total_died,
  ROUND(AVG(age), 2) AS avg_age
FROM survival_data
WHERE hospital_death = '1'
GROUP BY icu_admit_source;

-- Average age of people in each type of ICU
SELECT DISTINCT 
  icu_type,
  COUNT(hospital_death) AS total_died,
  ROUND(AVG(age), 2) AS avg_age
FROM survival_data
WHERE hospital_death = '1'
GROUP BY icu_type;

-- Average weight, BMI, and max heartrate of people who died
SELECT 
  ROUND(AVG(weight), 2) AS avg_weight,
  ROUND(AVG(bmi), 2) AS avg_bmi, 
  ROUND(AVG(d1_heartrate_max), 2) AS avg_max_heartrate
FROM survival_data
WHERE hospital_death = '1';

-- Top 5 ethnicities with the highest BMI
SELECT TOP 5
  ethnicity,
  ROUND(AVG(bmi), 2) AS average_bmi
FROM survival_data
GROUP BY ethnicity
ORDER BY average_bmi DESC;

-- Patients suffering from each comorbidity
SELECT
  COUNT(CASE WHEN aids = 1 THEN 1 END) AS patients_with_aids,
  COUNT(CASE WHEN cirrhosis = 1 THEN 1 END) AS patients_with_cirrhosis,
  COUNT(CASE WHEN diabetes_mellitus = 1 THEN 1 END) AS patients_with_diabetes,
  COUNT(CASE WHEN hepatic_failure = 1 THEN 1 END) AS patients_with_hepatic_failure,
  COUNT(CASE WHEN immunosuppression = 1 THEN 1 END) AS patients_with_immunosuppression,
  COUNT(CASE WHEN leukemia = 1 THEN 1 END) AS patients_with_leukemia,
  COUNT(CASE WHEN lymphoma = 1 THEN 1 END) AS patients_with_lymphoma,
  COUNT(CASE WHEN solid_tumor_with_metastasis = 1 THEN 1 END) AS patients_with_solid_tumor
FROM survival_data;

-- Percentage of patients with each comorbidity among those who died
SELECT
  ROUND(SUM(CASE WHEN aids = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS aids_percentage,
  ROUND(SUM(CASE WHEN cirrhosis = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cirrhosis_percentage,
  ROUND(SUM(CASE WHEN diabetes_mellitus = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS diabetes_percentage,
  ROUND(SUM(CASE WHEN hepatic_failure = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS hepatic_failure_percentage,
  ROUND(SUM(CASE WHEN immunosuppression = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS immunosuppression_percentage,
  ROUND(SUM(CASE WHEN leukemia = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS leukemia_percentage,
  ROUND(SUM(CASE WHEN lymphoma = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS lymphoma_percentage,
  ROUND(SUM(CASE WHEN solid_tumor_with_metastasis = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS solid_tumor_percentage
FROM survival_data
WHERE hospital_death = 1;

-- Percentage of patients who underwent elective surgery
SELECT
  COUNT(CASE WHEN elective_surgery = 1 THEN 1 END) * 100.0 / COUNT(*) AS elective_surgery_percentage
FROM survival_data;

-- Top 10 ICUs with the highest hospital death probability
SELECT TOP 10
  icu_id, 
  apache_4a_hospital_death_prob AS hospital_death_prob
FROM survival_data
ORDER BY apache_4a_hospital_death_prob DESC;

-- Average length of stay at each ICU for patients who survived and those who didn't
SELECT
  icu_type,
  ROUND(AVG(CASE WHEN hospital_death = 1 THEN pre_icu_los_days END), 2) AS avg_icu_stay_death,
  ROUND(AVG(CASE WHEN hospital_death = 0 THEN pre_icu_los_days END), 2) AS avg_icu_stay_survived
FROM survival_data
GROUP BY icu_type
ORDER BY icu_type;

-- Death percentage for each ethnicity
SELECT
  ethnicity,
  CAST(COUNT(CASE WHEN hospital_death = 1 THEN 1 END) * 100.0 / (SELECT COUNT(*) FROM survival_data) AS DECIMAL(10, 5)) AS death_percentage
FROM survival_data
GROUP BY ethnicity;

-- Patients in each BMI category based on BMI value
SELECT
  COUNT(*) AS patient_count,
  bmi_category   
FROM (
  SELECT
    patient_id,
    ROUND(bmi, 2) AS bmi,
    CASE
      WHEN bmi < 18.5 THEN 'Underweight'
      WHEN bmi >= 18.5 AND bmi < 25 THEN 'Normal'
      WHEN bmi >= 25 AND bmi < 30 THEN 'Overweight'
      ELSE 'Obese'
    END AS bmi_category
  FROM survival_data
  WHERE bmi IS NOT NULL
) AS subquery
GROUP BY bmi_category;
