-- 01 - How many orders were booked by employees from the 425 area code?
-- Using a sub-query
SELECT COUNT(*) # outer query
FROM Orders
WHERE EmployeeID IN
    (
        SELECT EmployeeID # nested/sub query
        FROM Employees
        WHERE EmpAreaCode = 425
    );

-- 02 - How many orders were booked by employees from the 425 area code? 
-- Use a JOIN instead of a subquery. (inner join)
SELECT COUNT(*)
FROM Orders
JOIN Employees
    ON Employees.EmployeeID = Orders.EmployeeID
WHERE EmpAreaCode = 425;

-- 03 - Show me the average number of days to deliver products per vendor name.
-- Filter the results to only show vendors where the 
-- average number of days to deliver is greater than 5.
SELECT VendName, AVG(DaysToDeliver)
FROM Product_Vendors
JOIN Vendors
    ON Product_Vendors.VendorID = Vendors.VendorID
GROUP BY VendName
HAVING AVG(DaysToDeliver) > 5;

-- Avoid GROUP BY column_#
SELECT VendName, AVG(DaysToDeliver)
FROM Product_Vendors
JOIN Vendors
    ON Product_Vendors.VendorID = Vendors.VendorID
GROUP BY 1 # column # - avoid this!
HAVING AVG(DaysToDeliver) > 5;

-- 04 - Show me the average number of days to deliver products per vendor name 
-- where the average is greater than the average delivery days for all vendors.
SELECT VendName, AVG(DaysToDeliver)
FROM Product_Vendors
JOIN Vendors
    ON Product_Vendors.VendorID = Vendors.VendorID
GROUP BY VendName
HAVING AVG(DaysToDeliver) > 
    (
        SELECT AVG(DaysToDeliver)
        FROM Product_Vendors
        JOIN Vendors
            ON Product_Vendors.VendorID = Vendors.VendorID
    );


-- 05 - Return just the number of vendors where their number of days to deliver 
-- products is greater than the average days to deliver across all vendors.
SELECT COUNT(*) as Number_Vendors
FROM
(
    SELECT VendName
    FROM Product_Vendors
    JOIN Vendors
        ON Product_Vendors.VendorID = Vendors.VendorID
    GROUP BY VendName
    HAVING AVG(Product_Vendors.DaysToDeliver) > 
    (
        SELECT AVG(DaysToDeliver)
        FROM Product_Vendors
    )
) as Vend_Avg;

-- 06 - How many products are associated to each category name?
-- Alias the aggregate expression
-- Sort the product counts from high to low
SELECT 
    Products.CategoryID, 
    CategoryDescription, 
    COUNT(Products.ProductNumber) as ProductCount
FROM Products
JOIN Categories
    ON Products.CategoryID = Categories.CategoryID
GROUP BY Products.CategoryID
ORDER BY ProductCount DESC;


-- 07 - List the categories with more than 3 products.
SELECT 
    Products.CategoryID, 
    CategoryDescription, 
    COUNT(Products.ProductNumber) as ProductCount
FROM Products
JOIN Categories
    ON Products.CategoryID = Categories.CategoryID
GROUP BY Products.CategoryID
HAVING ProductCount > 3
ORDER BY ProductCount DESC;


-- 08 - List the categories with a product count greater than the average.
-- Average based on grouped results and not just a column's value.

-- 08.01 - Select the product counts per category
SELECT 
    Products.CategoryID, 
    CategoryDescription,
    COUNT(*) as ProductCount 
FROM Products
JOIN Categories
    ON Products.CategoryID = Categories.CategoryID
GROUP BY Products.CategoryID
ORDER BY ProductCount DESC;


-- 08.02 - Get average # of products per category
SELECT
    Products.CategoryID, 
    CategoryDescription, 
    AVG(Products.ProductNumber) as AvgProdCountByCat
FROM Products
JOIN Categories
    ON Products.CategoryID = Categories.CategoryID
GROUP BY Products.CategoryID
ORDER BY AvgProdCountByCat DESC;


-- 08.03 - Add the average # of products per category as a subquery 
-- to the right-hand side of the HAVING comparison operator 
SELECT 
    Products.CategoryID, 
    CategoryDescription,
    COUNT(*) as ProductCount 
FROM Products
JOIN Categories
    ON Products.CategoryID = Categories.CategoryID
GROUP BY Products.CategoryID
HAVING ProductCount >
    (
        SELECT AVG(ProductCount) as AvgProdCount
        FROM 
            (
                SELECT
                    Products.CategoryID, 
                    CategoryDescription,
                    COUNT(*) as ProductCount 
                FROM Products
                JOIN Categories
                    ON Products.CategoryID = Categories.CategoryID
                GROUP BY Products.CategoryID
                ORDER BY ProductCount DESC
            ) AS ProdCountByCat
    )
ORDER BY ProductCount DESC;


-- 08.04 - Display the average product count alongside the category product count
SELECT 
    Products.CategoryID, 
    CategoryDescription,
    COUNT(*) as ProductCount,
    (
        SELECT AVG(ProductCount) as AvgProdCount
        FROM 
            (
                SELECT
                    Products.CategoryID, 
                    CategoryDescription,
                    COUNT(*) as ProductCount 
                FROM Products
                JOIN Categories
                    ON Products.CategoryID = Categories.CategoryID
                GROUP BY Products.CategoryID
                ORDER BY ProductCount DESC
            ) AS AvgCatProdCount
    )AS AvgerageProductCount
FROM Products
JOIN Categories
    ON Products.CategoryID = Categories.CategoryID
GROUP BY Products.CategoryID
ORDER BY ProductCount DESC;


-- 09 - How many categories have more products than the average product count per category?
SELECT COUNT(*) AS CategoryCount
FROM
    (
        SELECT 
            Products.CategoryID, 
            CategoryDescription,
            COUNT(*) as ProductCount 
        FROM Products
        JOIN Categories
            ON Products.CategoryID = Categories.CategoryID
        GROUP BY Products.CategoryID
        HAVING ProductCount >
            (
                SELECT AVG(ProductCount) 
                FROM 
                    (
                        SELECT
                            Products.CategoryID, 
                            CategoryDescription,
                            COUNT(*) as ProductCount 
                        FROM Products
                        JOIN Categories
                            ON Products.CategoryID = Categories.CategoryID
                        GROUP BY Products.CategoryID
                    ) AS ProductCountByCategory
            )
    ) AS ProductCountGreaterThanAvg;