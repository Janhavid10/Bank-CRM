-- ---------------------Objective Questions ------------

-- 2.	Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)

SELECT c.CustomerId, c.Surname, c.EstimatedSalary,c.JoiningDate
FROM customerinfo c
JOIN bank_churn b ON c.CustomerId = b.CustomerId
WHERE EXTRACT(QUARTER FROM c.JoiningDate) = 4  
ORDER BY c.EstimatedSalary DESC
LIMIT 5;

#--------------------------------------------------------------------------------------------------------------------------#


-- 3.	Calculate the average number of products used by customers who have a credit card. (SQL)

SELECT AVG(NumOfProducts) AS AverageNoProducts
FROM bank_churn
WHERE HasCrcard = 1;

-- 5.	Compare the average credit score of customers who have exited and those who remain. (SQL)

SELECT Exited, AVG(CreditScore) AS CreditScoreAverage
FROM bank_churn
GROUP BY Exited;
#--------------------------------------------------------------------------------------------------------------------------#

-- 6.	Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)

WITH ActiveAccounts AS (
    SELECT CustomerId, COUNT(*) AS ActiveAccounts
    FROM bank_churn
    WHERE IsActiveMember = 1
    GROUP BY CustomerId
)
SELECT 
    CASE WHEN ci.GenderID = 1 THEN 'Male'  ELSE 'Female'   END AS Gender,
    COUNT(aa.CustomerId) AS ActiveAccounts, AVG(EstimatedSalary) AS AverageSalary
FROM customerinfo ci LEFT JOIN ActiveAccounts aa ON ci.CustomerId = aa.CustomerId
GROUP BY Gender
ORDER BY AverageSalary DESC;
#--------------------------------------------------------------------------------------------------------------------------#

-- 7.	Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)

SELECT 
Credit_segment,
round(avg(Exited)*100,2) as rate_of_exited
from (
select bc.CustomerId,
case
when bc.CreditScore <500 then "Poor Credit"
when bc.CreditScore between 500 and 600 then "Good Credit"
when bc.CreditScore between 600 and 700 then "Very Good Credit"
when bc.CreditScore between 700 and 800 then "Excellent Credit"
else "Super Credit"
end as Credit_segment, bc.Exited
From bank_churn bc
inner join customerinfo cf
on bc.CustomerId = cf.CustomerId
) as segments
group by Credit_segment
order by rate_of_exited desc;
#--------------------------------------------------------------------------------------------------------------------------#

-- 8.	Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)

SELECT g.GeographyLocation, COUNT(b.CustomerId) AS active_customers
FROM geography g
INNER JOIN customerinfo c ON g.GeographyID = c.GeographyID
INNER JOIN bank_churn b ON c.CustomerId = b.CustomerId
WHERE b.Tenure > 5
and isactivemember =1
GROUP BY g.GeographyLocation
ORDER BY active_customers DESC
LIMIT 1;

#--------------------------------------------------------------------------------------------------------------------------#

-- QUESTION 11 : Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly). 
-- Prepare the data through SQL and then visualize it.

select year(bankDOJ) as year, count(c.CustomerId) as Exited_cust_count
from bank_churn bc
inner join customerinfo c ON bc.CustomerId= c.CustomerId
where exited =1
group by year;

-- 15.	Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. Also, rank the gender according to the average value. (SQL)

WITH AverageGeographySalary AS (
    SELECT 
        g.GeographyLocation,
        CASE 
            WHEN c.GenderID = 1 THEN 'Male'
            ELSE 'Female'
        END AS Gender,
        AVG(c.EstimatedSalary) AS avg_salary
    FROM customerinfo c
    INNER JOIN geography g ON c.GeographyID = g.GeographyID
    GROUP BY g.GeographyLocation, c.GenderID
    ORDER BY g.GeographyLocation
)
SELECT *,
    RANK() OVER (PARTITION BY GeographyLocation ORDER BY avg_salary DESC) AS 'rank'
FROM AverageGeographySalary;

-- 20.	According to the age buckets find the number of customers who have a credit card. Also retrieve those buckets that have lesser than average number of credit cards per bucket.

  WITH creditinfo AS (
    SELECT 
        CASE 
            WHEN age BETWEEN 18 AND 30 THEN 'Adult'
            WHEN age BETWEEN 31 AND 50 THEN 'Middle-Aged'
            ELSE 'Old-Aged'
        END AS AgeBrackets,
        COUNT(c.CustomerId) AS HasCrCard
    FROM customerinfo c
    JOIN bank_churn b ON c.CustomerId = b.CustomerId
    WHERE b.HasCrcard = 1  -- Ensures filtering is done before counting
    GROUP BY AgeBrackets
)
SELECT *
FROM creditinfo
WHERE HasCrCard < (
    SELECT AVG(HasCrCard) 
    FROM creditinfo
);

-- 21 Rank the Locations as per the number of people who have churned the bank and average balance of the customers.

SELECT 
    g.GeographyLocation, 
    COUNT(b.CustomerId) AS TotalExited, 
    round(AVG(b.Balance),2) AS avg_bal
FROM bank_churn b
JOIN customerinfo c ON b.CustomerId = c.CustomerId
JOIN geography g ON c.GeographyID = g.GeographyID
WHERE b.Exited = 1
GROUP BY g.GeographyLocation
ORDER BY COUNT(b.CustomerId) DESC;

-- 23.	Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.

SELECT 
    CustomerId, 
    CreditScore, 
    Tenure, 
    Balance, 
    NumOfProducts, 
    HasCrCard, 
    IsActiveMember,
    CASE 
        WHEN Exited = 0 THEN 'Retain'
        ELSE 'Exit'
    END AS ExitCategory
FROM bank_churn;

-- 25.	Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.


-- 26.	Can you observe any data disrupency in the Customer’s data? As a hint it’s present in the IsActiveMember and Exited columns. One more point to consider is that the data in the Exited Column is absolutely correct and accurate.

SELECT *
FROM bank_churn b join customerinfo c on b.CustomerId = c.CustomerId
WHERE b.Exited =1 and b.IsActiveMember =1;