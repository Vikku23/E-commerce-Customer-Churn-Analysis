create database ecommercechurn;
use ecommercechurn;

select * from ecommerce_churn;

/* Data Cleaning */


alter table ecommerce_churn
rename column ï»¿CustomerID to CustomerID;

/*1. Find the total number of customers. */
select  distinct count(CustomerID) as total_no_of_customer from ecommerce_churn;

/* Check for duplicate rows*/

select CustomerID ,count(*) 
from ecommerce_churn
group by CustomerID
having count(*) > 1;

/*3. Check for null values count for columns with null values.*/
select
count(case when Tenure is null then 1 end ) as Tenure_null_count,
count(case when WarehouseToHome is null then 1 end ) as WarehouseToHome_null_count,
count(case when HourSpendonApp is null then 1 end ) as HourSpendonApp_null_count,
count(case when OrderAmountHikeFromLastYear is null then 1 end ) as OrderAmountHikeFromLastYear_null_count,
count(case when CouponUsed is null then 1 end ) as CouponUsed_null_count,
count(case when OrderCount is null then 1 end ) as OrderCount_null_count,
count(case when DaySinceLastOrder is null then 1 end ) as DaySinceLastOrder_null_count
from ecommerce_churn;

/* checking blank value in the coulumn */
select
count(case when Tenure = '' then 1 end ) as TenureBlank_count,
count(case when WarehouseToHome = '' then 1 end ) as WarehouseToHomeBlank_count,
count(case when HourSpendonApp = '' then 1 end ) as HourSpendonAppBlank_count,
count(case when OrderAmountHikeFromLastYear = '' then 1 end ) as OrderAmountHikeFromLastYearBlank_count,
count(case when CouponUsed = '' then 1 end ) as CouponUsedBlank_count,
count(case when OrderCount = '' then 1 end ) as OrderCountBlank_count,
count(case when DaySinceLastOrder = '' then 1 end ) as DaySinceLastOrderBlank_count
from ecommerce_churn;

/*4. Create a new column based off the values of complain column.*/
-- The values in complain column are 0 and 1 values were O means No and 1 means Yes. I will create a new column 
-- called complainrecieved that shows 'Yes' and 'No' instead of 0 and 1 
alter table ecommerce_churn
add complainReceived varchar(10);

update ecommerce_churn
set ComplainReceived =
case 
when Complain = 1 then 'Yes' 
when Complain = 0 then 'No'
end;

/*Check values in each column for correctness and accuracy*/
select distinct preferredLoginDevice from ecommerce_churn;

## here mobile phone and phone are the same thing so we have to replaced mobile phone with phone

update ecommerce_churn
set preferredLoginDevice = 'Phone'
where preferredLoginDevice = 'Mobile Phone';

select distinct PreferredPaymentMode from ecommerce_churn;
## here Cash on delivery and COD are the same payment mode then i will replaced  Cash on Delivery with COD.

update ecommerce_churn 
set PreferredPaymentMode = 'COD'
where PreferredPaymentMode = 'Cash on Delivery';

select distinct Gender from ecommerce_churn;
select distinct preferedOrderCat from ecommerce_churn;
## replaced the mobile phone to mobile
update ecommerce_churn 
set preferedOrderCat = 'Mobile'
where preferedOrderCat = 'Mobile Phone';

select distinct WarehouseToHome from ecommerce_churn;

/* Data Exploration and Answering business questions */

/*1. What is the overall customer churn rate?*/ 
select 
round((count(case when churn = 1 then 1 end )/count(*))*100,2) as Overall_chrun_rate 
from ecommerce_churn;

/*How does the churn rate vary based on the preferred login device?*/

select PreferredLoginDevice,
concat(format((sum(case when churn = 1 then 1 end)/count(*))*100,2),"%") as customer_churn_rate
from ecommerce_churn
group by PreferredLoginDevice;

##The prefered login devices are computer and phone. Computer accounts for the highest churn rate
## with 20.66 % and then phone with 16.79%. 

/* 3. What is the distribution of customers across different city tiers? */


select CityTier, count(*) as Total_customer
from ecommerce_churn
group by CityTier;

##city tier 3 has the highest churn rate, followed by city tier 2 and 
## then city tier 1 has the least churn rate

/* 4. Which is the most prefered payment mode among churned customers? */

select preferredPaymentMode,
count(*) as Total_customer,
sum(churn) as churn_customer,
cast(sum(churn)*1.0 /count(*) * 100 as decimal(10,2)) as churn_rate
from ecommerce_churn 
group by PreferredPaymentMode
order by churn_rate desc;

##The most prefered payment mode among churned customers is COD


/* 5. What is the typical tenure for churned customers? */

## First, we will create a new column that provides a tenure range based on the values in tenure column

alter table ecommerce_churn
add tenure_range varchar(50);

update ecommerce_churn
set tenure_range = 
 case 
   when Tenure <= 6 then '6 Months'
   when Tenure > 6 and Tenure <= 12 then '1 Years'
   when Tenure > 12 and Tenure <= 24 then '2 Years'
   else '3 Years'
   end; 
   
   /*Then find the typical tenure for churn customer*/
select tenure_range,
count(*) as Total_customer,
sum(churn) as churn_customer,
cast(sum(churn)*1.0 /count(*) * 100 as decimal(10,2)) as churn_rate
from ecommerce_churn 
group by tenure_range
order by churn_rate desc;
-- Most customers churn within a period of 6 months. 

/* 6. Is there any difference in churn rate between male and female customers?*/

select gender,count(*) as Total_customer,
sum(churn) as churn_customer,
cast(sum(churn)*1.0 /count(*) * 100 as decimal(10,2)) as churn_rate
from ecommerce_churn
group by gender
order by churn_rate desc;
-- here we can see most male churn customer is more as copare to female churn customer. 

/* 7. How does the average time spent on the app differ for churned and non-churned customers? */

select churn, avg(HourSpendOnApp) as avgtimespendon_mobile
from ecommerce_churn
group by churn;
-- There is minor difference between the average time spent on the app for churned and non-churned customers.

/* 8. Does the number of registered devices impact the likelihood of churn?*/

select NumberOfDeviceRegistered ,count(*) as Total_customer,
sum(churn) as churn_customer,
cast(sum(churn)*1.0 /count(*) * 100 as decimal(10,2)) as churn_rate
from ecommerce_churn
group by NumberOfDeviceRegistered
order by churn_rate desc;
-- As the number of registered devices increseas the churn rate increases.

/*9. Which order category is most prefered among churned customers?*/

select PreferedOrderCat ,count(*) as Total_customer,
sum(churn) as churn_customer,
cast(sum(churn)*1.0 /count(*) * 100 as decimal(10,2)) as churn_rate
from ecommerce_churn
group by PreferedOrderCat
order by churn_rate desc;
-- Mobile phone category has the highest churn rate and grocery has the least churn rate.

/*10. Is there any relationship between customer satisfaction scores and churn?*/

select SatisfactionScore, count(*) as Total_customer,
sum(churn) as churn_customer,
cast(sum(churn)*1.0/ count(*) *100  as decimal(10,2)) as churn_rate
from ecommerce_churn
group by SatisfactionScore
order by churn_rate desc;
-- Customer satisfaction score of 5 has the highest churn rate, satisfaction score of 1 has the least churn rate

/*11. Does the marital status of customers influence churn behavior?*/

select MaritalStatus, count(*) as Total_customer,
sum(churn) as churn_customer,
cast(sum(churn)*1.0/ count(*) *100  as decimal(10,2)) as churn_rate
from ecommerce_churn
group by MaritalStatus
order by churn_rate desc;
-- Single customers have the highest churn rate while married customers have the least churn rate


/*12. Does customer complaints influence churned behavior? */

select complainReceived, count(*) as Total_customer,
sum(churn) as churn_customer,
cast(sum(churn)*1.0/ count(*) *100  as decimal(10,2)) as churn_rate
from ecommerce_churn
group by complainReceived
order by churn_rate desc;
-- Customers with complains had the highest churn rate.

/*13. How does the usage of coupons differ between churned and non-churned customers?*/
select churn, sum(CouponUsed) as Total_coupanused
from ecommerce_churn
group by churn;
-- Churned customers used less coupons in comparison to non churned customers

/*14. What is the average number of days since the last order for churned customers? */
select avg(DaySinceLastOrder) as avg_daysincelastorder
from ecommerce_churn
where churn = 1;
-- The average number of days since last order for churned customer is 3

select* from ecommerce_churn;

select gender,
sum(churn) as churn_customer
from ecommerce_churn
group by gender;