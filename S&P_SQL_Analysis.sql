--The data here comes from two Excel worksheets containing data from the S&P 500 taken two weeks apart.
--I made several adjustments to the first worksheet in Excel to make the data ready for use in SQL.  However,
--for the second worksheet I was only interested in how the stock prices had changed over two weeks so the only
--modification I made was to switch the price from a currency to a number.  Starting out, I ran some queries to 
--explore the data

SELECT * FROM [dbo].[stocks1]

SELECT Sector, SUM(MarketCap) AS "Total Market Capitalization by Sector" 
FROM [dbo].[stocks1]
GROUP BY Sector
ORDER BY 1 DESC

SELECT Sector, AVG(MarketCap) AS "Average Market Capitalization by Sector" 
FROM [dbo].[stocks1]
GROUP BY Sector
ORDER BY 1 DESC

SELECT TOP 10 Sector, AVG(_5yrReturn) AS "Avg. 5 Year Return"
FROM [dbo].[stocks1]
WHERE Size = 'Large'
GROUP BY Sector
ORDER BY 2 DESC

SELECT Sector, MAX(_1yrReturn)
FROM [dbo].[stocks1]
WHERE Size = 'Large'
GROUP BY Sector
ORDER BY 2 DESC

--the two most recent queries show that the Information Technology Sector has experienced significant growth. 
--it could be worth exploring that sector further

--going forward I primarily want to concentrate on the large companies because they may be more stable and reliable
--I used an inner join because I am only interested in descriptions from the two tables that are an exact match 
--this query uses my new table to determine the change in price percentage

SELECT s1.Description, ROUND(((s2.price - s1.price)/s1.price)*100,2) AS "Two Week Price Change Percentage"
FROM [dbo].[stocks1] s1
JOIN [dbo].[stocks2] s2
ON s1.Description = s2.Description
WHERE Size = 'Large'
ORDER BY 2 DESC

--looking at the company with the highest 5 year return by sector 

SELECT fd.Sector, fd.Description, fd._5yrReturn
FROM [dbo].[stocks1] fd
INNER JOIN (
    SELECT Sector, MAX(_5yrReturn) AS max_return
    FROM [dbo].[stocks1]
    GROUP BY Sector
) AS maxes 
ON fd.sector = maxes.sector AND fd._5yrReturn = maxes.max_return
ORDER BY 3 DESC

--let's do some queries to look at stocks that have been trending upwards 

SELECT Description, _5yrReturn, _3yrReturn, _1yrReturn
FROM [dbo].[stocks1]
WHERE _5yrReturn < _3yrReturn AND _3yrReturn < _1yrReturn

--before I move on to focusing on the large companies I wanted to take a look at the mid and small companies to 
--see how well they have grown over the past five years

SELECT Description, Sector, Size, _5yrReturn
FROM  [dbo].[stocks1]
WHERE (Size LIKE 'Mid' OR Size LIKE 'Small') AND _5yrReturn > 0
ORDER BY 4 DESC

--thinking about how many stocks i should limit my queries to

SELECT COUNT(*)
FROM [dbo].[stocks1]
WHERE Size = 'Large'

--for these next two queries, I was thinking companies with good long term prospects and short-term dips in performance
--could make for interesting candidates for investing in.  I wanted to return a handful of companies that had performed
--well over an extended period but had seem a recent short-term drop.  To do that, I joined a list of top long run
--companies with a list of the lowest performing short-term.  The next two queries show two potential examples for 
--implementing this strategy but of course I could do the exact same thing with different combinations.  For instance,
--with a couple of substitutions I could look at 3 year return versus two week return.

WITH fyr AS 
	(SELECT TOP 60 Description, Sector, _5yrReturn
	FROM [dbo].[stocks1]
	WHERE Size = 'Large'
	ORDER BY 3 DESC),
	ytd AS (SELECT TOP 60 Description, Sector, Price_Change_YTD
	FROM [dbo].[stocks1] 
	WHERE Size = 'Large'
	ORDER BY 3 ASC)
SELECT fyr.Description, fyr.Sector, fyr._5yrReturn, ytd.Price_Change_YTD
FROM fyr
JOIN ytd
ON fyr.Description = ytd.Description

WITH oyr AS
	(SELECT TOP 50 Description, Sector, _1yrReturn
	FROM [dbo].[stocks1]
	WHERE Size = 'Large'
	ORDER BY 3 DESC),
	tweek AS
	(SELECT TOP 50 s1.Description, ROUND(((s2.price - s1.price)/s1.price)*100,2) AS "Two Week Price Change Percentage"
	FROM [dbo].[stocks1] s1
	JOIN [dbo].[stocks2] s2
	ON s1.Description = s2.Description
	WHERE Size = 'Large'
	ORDER BY 2 asc)
SELECT oyr.Description, oyr.Sector, oyr._1yrReturn, tweek."Two Week Price Change Percentage"
FROM oyr
JOIN tweek
ON oyr.Description = tweek.Description


