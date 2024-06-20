USE coffee_shop_sales_db;

SELECT * FROM coffee_shop_sales

  # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 
  
#KPI's Requirements

#1. Total Sales Analysis
#Calculate the total sales for each respective month

SELECT CONCAT(ROUND(SUM(unit_price*transaction_qty),1),"K") AS total_value
FROM coffee_shop_sales
WHERE
MONTH(transaction_date) = 5;

#Determine the month-on-month increase or decrease in sales
#Calculate the difference in sales between the selected month and the previous month

SELECT
	MONTH(transaction_date) AS month,
	ROUND(SUM(unit_price * transaction_qty),1) AS total_sales,
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty),1) OVER (ORDER BY Month(transaction_date))) * 100
    / LAG(SUM(unit_price * transaction_qty),1) OVER (ORDER BY Month(transaction_date)) AS mom_increase_percentage
FROM 
	coffee_shop_sales 
WHERE 
	MONTH(transaction_date) BETWEEN 4 AND 6
GROUP BY
	MONTH(transaction_date)
ORDER BY
	MONTH(transaction_date);
    
    
#2. Total Orders Analysis
# Calculate the total number of orders for each respective month

SELECT COUNT(transaction_id) AS total_orders
FROM 
	coffee_shop_sales 
WHERE 
	MONTH(transaction_date) = 5;
    


# Determine the month-on-month increase or decrease in the number of orders
# Calculate the difference in the number of orders between the selected month and the previous month

SELECT 
	MONTH(transaction_date),
    COUNT(transaction_id) AS total_orders,
    (COUNT(transaction_id) - LAG(COUNT(transaction_id),1) OVER (ORDER BY MONTH(transaction_date)))*100
    / LAG(COUNT(transaction_id),1) OVER (ORDER BY MONTH(transaction_date)) AS mom_increase_percent
    
FROM
	coffee_shop_sales
WHERE
	MONTH(transaction_date) BETWEEN 4 AND 6
GROUP BY
	MONTH(transaction_date)
ORDER BY
	MONTH(transaction_date);
    
    
  # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 
  
  
#Charts Requirements 
#1.Calender Heat Map
# Display detailed metrics (Sales, Orders, Quantity) when hovering over a specific day

SELECT 
	CONCAT(ROUND(SUM(transaction_qty*unit_price)/1000,1),'K') AS Total_Sales,
    CONCAT(ROUND(SUM(transaction_qty)/1000,1),'K') AS Total_Orders,
    CONCAT(ROUND(COUNT(transaction_id)/1000,1),'K') AS Total_Quantity
FROM 
	coffee_shop_sales
WHERE 
	transaction_date = '2023-03-27';

#2. Sales Analysis by Weekdays and Weekends 

-- Weekends - Sat and Sun
-- Weekdays - Mon to Fri

# Sales data between weekdays and weekends

SELECT 	
	CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends' # 1:Sunday, 7:Saturday
    ELSE 'Weekdays'
    END AS Day_Type,
    CONCAT(ROUND(SUM(transaction_qty*unit_price)/1000,1),'K') As Total_Sales
FROM 
	coffee_shop_sales
WHERE
	MONTH(transaction_date) = 5
GROUP BY
	CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends' 
    ELSE 'Weekdays'
    END;


#3 Sales Analysis By Store Location
SELECT * 
FROM 
	coffee_shop_sales;

SELECT
	store_location,
    MONTH(transaction_date),
	ROUND(SUM(unit_price * transaction_qty),1) AS total_sales,
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty),1) OVER (partition by store_location)) * 100
    / LAG(SUM(unit_price * transaction_qty),1) OVER (partition by store_location) AS mom_increase_percentage
FROM 
	coffee_shop_sales 
WHERE 
	MONTH(transaction_date) BETWEEN 4 AND 6
GROUP BY
	store_location,
    MONTH(transaction_date)
ORDER BY
	MONTH(transaction_date) ;


SELECT
	store_location,
	CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,2),'K') AS total_sales
FROM 
	coffee_shop_sales 
WHERE 
	MONTH(transaction_date) = 6
GROUP BY
	store_location
ORDER BY 
	SUM(unit_price * transaction_qty) DESC;
    
    
#4. Daily Sales Analysis with Average Line


SELECT 
	CONCAT(ROUND(AVG(total_sales)/1000),1,'K') AS Avg_Sales
FROM
	(
			SELECT 
				SUM(transaction_qty * unit_price) AS total_sales
			FROM  
				coffee_shop_sales
			WHERE 
				MONTH(transaction_date) =5 
			GROUP BY
				transaction_date
    ) AS Internal_query;


SELECT 
    DAY(transaction_date) AS day_of_month,
    SUM(unit_price * transaction_qty) AS total_sales
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 5
GROUP BY 
	DAY(transaction_date)
ORDER BY
	DAY(transaction_date);
    


SELECT
	day_of_month,
	CASE 
		WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
	END AS sales_status,
    total_sales
FROM(
	SELECT	
		DAY(transaction_date) AS day_of_month,
		SUM(unit_price * transaction_qty) AS total_sales,
		AVG(SUM(unit_price * transaction_qty)) OVER() AS avg_sales
	FROM
		coffee_shop_sales
	WHERE 
		MONTH(transaction_date) = 5
	GROUP BY 
		DAY(transaction_date)
        ) AS sales_data
ORDER BY 
	day_of_month;
    
#5 Sales Analysis by Product Category

    
SELECT * FROM coffee_shop_sales; 

SELECT 
	product_category,
    CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000,1),'K') AS total_sales_category
FROM 
	coffee_shop_sales
WHERE 
	MONTH(transaction_date) = 5
GROUP BY
	product_category
ORDER BY 
	SUM(unit_price*transaction_qty) DESC;
    
#6 Top 10 Products by Sales

SELECT 
	product_type,
    CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000,1),'K') AS total_sales
FROM 
	coffee_shop_sales
WHERE 
	MONTH(transaction_date) = 5
GROUP BY 
	product_type
ORDER BY 
	SUM(unit_price*transaction_qty) DESC LIMIT 10;

#7 Sales Analysis by Days and Hours


SELECT 
    CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000,1),'K') AS total_sales,
    SUM(transaction_qty) AS total_quantity,
    COUNT(*) AS total_orders
FROM 
	coffee_shop_sales
WHERE 
	DAYOFWEEK(transaction_date) = 3 -- 3 is Tuesday
    AND HOUR(transaction_time) = 8
    AND MONTH(transaction_date) = 5 ;
    
-- Get sales from monday to sunday for month of may

SELECT 
	CASE 
		WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thurday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
        END AS day_of_week,
        ROUND(SUM(unit_price*transaction_qty)) AS total_sales
FROM
        coffee_shop_sales 
WHERE
	MONTH(transaction_date) = 5
GROUP BY
	day_of_week;


-- Get sales for all hours for month of may

SELECT 
    HOUR(transaction_time) AS hour_of_day,
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 
GROUP BY 
    HOUR(transaction_time)
ORDER BY 
    HOUR(transaction_time);

