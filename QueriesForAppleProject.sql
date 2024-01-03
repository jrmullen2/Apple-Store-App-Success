--EXPLORATORY DATA ANALYSIS

--Check the number of unique apps in each table
SELECT COUNT(DISTINCT id) AS UniqueApps 
FROM AppleStore$

SELECT COUNT(DISTINCT id) AS UniqueApps 
FROM appleStore_description$

--Check for any missing values in key fields

SELECT COUNT(*) as MissingValues
FROM AppleStore$
WHERE track_name is NULL OR user_rating is NULL OR prime_genre is NULL

SELECT COUNT(*) as MissingValues
FROM appleStore_description$
WHERE app_desc is NULL

--Find out the number of apps per genre

SELECT prime_genre, COUNT(*) as NumberOfApps
FROM AppleStore$
GROUP BY prime_genre
ORDER BY NumberOfApps DESC

--Retrieve overview of app ratings

SELECT MIN(user_rating) as LowestRating,
	   MAX(user_rating) as HighestRating,
	   AVG(user_rating) as AveragetRating
FROM AppleStore$

--DATA ANALYSIS

--Determine whether paid apps have a higher rating than free apps

SELECT CASE 
			WHEN price > 0 THEN 'Paid'
			ELSE 'Free'
	   END AS App_Type,
	   AVG(user_rating) as AvgRating
FROM AppleStore$
GROUP BY (CASE 
			WHEN price > 0 THEN 'Paid'
			ELSE 'Free'
	      END)
--Check if apps with more supported languages have higher ratings

SELECT CASE
			WHEN lang#num < 10 THEN '<10 languages'
			WHEN lang#num BETWEEN 10 AND 30 THEN '10-30 languages'
			ELSE '>30 languages'
	   END as Language_Bucket,
	   AVG(user_rating) as AvgRating
FROM AppleStore$
GROUP BY (CASE
			WHEN lang#num < 10 THEN '<10 languages'
			WHEN lang#num BETWEEN 10 AND 30 THEN '10-30 languages'
			ELSE '>30 languages'
	      END )
ORDER BY AvgRating DESC

--Check genres with low ratings

SELECT TOP 10
	   prime_genre,
	   AVG(user_rating) AS AvgRating
FROM AppleStore$
GROUP BY prime_genre
ORDER BY AvgRating DESC

--Check if the length of app description correlates with the user rating

SELECT CASE
			WHEN LEN(b.app_desc) < 500 THEN 'short'
			WHEN LEN(b.app_desc) BETWEEN 500 AND 1000 THEN 'medium'
			ELSE 'long'
	   END AS Description_Length,
	   AVG(a.user_rating) as AvgRating
FROM AppleStore$ a JOIN appleStore_description$ b
	 ON a.id = b.id
GROUP BY (CASE
			WHEN  LEN(b.app_desc) < 500 THEN 'short'
			WHEN  LEN(b.app_desc) BETWEEN 500 AND 1000 THEN 'medium'
			ELSE 'long'
	     END)
ORDER BY AvgRating DESC

--Check the top rated apps for each genre

SELECT prime_genre,
	   track_name,
	   user_rating
FROM (
		
	   SELECT prime_genre,
	   track_name,
	   user_rating,
	   RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) as rank
	   FROM AppleStore$
	 ) as a
WHERE a.rank = 1
