CREATE DATABASE HOSP_ANALYSIS;
USE HOspitality;

/* 
----------------------------------------------
    Hospitality Analytics SQL Queries
----------------------------------------------
*/

/* 1. Total Revenue */
SELECT 
    CONCAT(ROUND(SUM(revenue_realized) / 1000000000, 2), ' Bn') AS Total_Revenue
FROM 
    fact_bookings;

/* 2. Occupancy Rate */
SELECT 
    CONCAT(ROUND(SUM(succesfull_bookings) / SUM(capacity) * 100, 2), ' %') AS Occupancy_Rate
FROM 
    fact_aggregated_bookings;

/* 3. Cancellation Rate */
SELECT 
    CONCAT(ROUND(SUM(CASE WHEN booking_status = 'cancelled' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2), ' %') AS Cancellation_Rate
FROM 
    fact_bookings;

/* 4. Total Bookings */
SELECT 
    CONCAT(ROUND(COUNT(booking_id) / 1000), 'K') AS Total_Bookings
FROM 
    fact_bookings;

/* 5. Total Capacity Utilized */
SELECT 
    CONCAT(ROUND(SUM(capacity) / 1000), 'K') AS Utilize_Capacity
FROM 
    fact_aggregated_bookings;

/* 
----------------------------------------------
    Revenue and Trend Analysis
----------------------------------------------
*/

/* 6. Revenue by City (Trend Analysis) */
SELECT 
    dim_hotels.city AS City,
    CONCAT(ROUND(SUM(fact_bookings.revenue_generated) / 1000000), 'M') AS Revenue_Generated
FROM 
    dim_hotels 
JOIN 
    fact_bookings ON dim_hotels.property_id = fact_bookings.property_id
GROUP BY 
    dim_hotels.city
ORDER BY 
    Revenue_Generated DESC;

/* 7. Weekday & Weekend Revenue and Bookings */
SELECT 
    dim_date.day_type AS Day_Type,
    CONCAT(ROUND(SUM(fact_bookings.revenue_realized) / 1000000000, 1), 'Bn') AS Total_Revenue,
    CONCAT(ROUND(COUNT(DISTINCT fact_bookings.booking_id) / 1000), 'K') AS Total_Bookings
FROM 
    dim_date 
JOIN 
    fact_bookings ON fact_bookings.check_in_date = dim_date.dates
GROUP BY 
    dim_date.day_type;

/* 8. Revenue by State & Hotel */
SELECT 
    dim_hotels.city AS City,
    dim_hotels.property_name AS PropertyNames,
    CONCAT(ROUND(SUM(fact_bookings.revenue_realized) / 1000000), 'M') AS Total_Revenue
FROM 
    fact_bookings 
JOIN 
    dim_hotels ON fact_bookings.property_id = dim_hotels.property_id
GROUP BY 
    dim_hotels.city, dim_hotels.property_name
ORDER BY 
    SUM(fact_bookings.revenue_realized) DESC;

/* 9. Class-Wise Revenue */
SELECT 
    dim_rooms.room_type AS RoomClass,
    CONCAT(ROUND(SUM(fact_bookings.revenue_realized) / 1000000), 'M') AS Total_Revenue
FROM 
    dim_rooms 
JOIN 
    fact_bookings ON dim_rooms.room_id = fact_bookings.room_id
GROUP BY 
    dim_rooms.room_type
ORDER BY 
    SUM(fact_bookings.revenue_realized) DESC;

/* 
----------------------------------------------
    Booking Status Analysis
----------------------------------------------
*/

/* 10. Booking Status Breakdown (Checked Out, Cancelled, No Show) */
SELECT 
    booking_status,
    CONCAT(ROUND(COUNT(*) / 1000), 'K') AS BookingStatusCount
FROM 
    fact_bookings
WHERE 
    booking_status IN ('Checked Out', 'Cancelled', 'No Show') 
GROUP BY 
    booking_status;

/* 
----------------------------------------------
    Weekly Key Trends
----------------------------------------------
*/

/* 11. Weekly Trends (Revenue, Total Bookings, Occupancy) */
SELECT 
    DIM_DATE.WEEK_NO,
    CONCAT(ROUND(SUM(FACT_BOOKINGS.REVENUE_REALIZED) / 1000000), 'M') AS Total_Revenue,
    CONCAT(ROUND(COUNT(FACT_BOOKINGS.BOOKING_ID) / 1000), 'K') AS Total_Bookings
FROM 
    DIM_DATE 
JOIN 
    FACT_BOOKINGS ON DIM_DATE.DATEs = FACT_BOOKINGS.CHECK_IN_DATE
GROUP BY 
    DIM_DATE.WEEK_NO;
