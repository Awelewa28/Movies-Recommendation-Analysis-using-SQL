SELECT * FROM movies_metadata

----Checking for Duplicates, The Loaded data have 45,466 rows
SELECT DISTINCT * FROM movies_metadata  ---The data contains duplicates

---Removing Duplicates and baccking up original data information---

SELECT adult, belongs_to_collection, budget,genres,
					  homepage, id, imdb_id, original_language, overview,
					  popularity, poster_path, production_companies, 
					  release_date, revenue, runtime, spoken_languages, status, 
					  tagline, title, video, vote_average, vote_count, COUNT(id) as id_count

FROM movies_metadata


GROUP BY adult, belongs_to_collection, budget,genres,
					  homepage, id, imdb_id, original_language, overview,
					  popularity, poster_path, production_companies, 
					  release_date, revenue, runtime, spoken_languages, status, 
					  tagline, title, video, vote_average, vote_count
order by id_count DESC                                    ---This query is to show number of duplicate input in this data by rows

                             ---DATA CLEANING PROCESSES----------

---Filtering out distinct values into a new table without deleting any information from movies_metadata

CREATE TABLE clean_movies_metadata
(adult NVARCHAR(255), belong_to_collection NVARCHAR(255), budget INT,
genres NVARCHAR (255), homepaage NVARCHAR(255), id INT, imdb_id NVARCHAR(255),
original_language NVARCHAR(255), original_title NVARCHAR(255), overview NVARCHAR(MAX),
popularity FLOAT, poster_path NVARCHAR(255), production_companies NVARCHAR(MAX),
production_countries NVARCHAR(255), release_date DATETIME, revenue FLOAT, runtime FLOAT,
spoken_languages NVARCHAR(255), status NVARCHAR(255), tagline NVARCHAR(255),
title NVARCHAR(255), video NVARCHAR(255), vote_average FLOAT, vote_count FLOAT)

INSERT INTO clean_movies_metadata
SELECT DISTINCT * FROM movies_metadata ----- movies data duplicate has been removed and we are left with 45,499 rows

DELETE  FROM clean_movies_metadata
WHERE budget = 0 OR revenue = 0   ----Removing rows of budget and revenue equal to zero, About 40,115 movie rows dosent have budget or revenue

SELECT * FROM clean_movies_metadata
WHERE budget > revenue                ---Movies that run at loss---

DELETE  FROM clean_movies_metadata
WHERE budget IS NULL                 -----------Removing blanks in the budget column---

          
ALTER TABLE clean_movies_metadata
DROP COLUMN overview, homepaage, original_title,
			poster_path, video, tagline, popularity,
			belong_to_collection, spoken_languages,runtime,adult   ----Dropping unwanted columns for our analysis-----
alter table clean_movies_metadata
drop column production_companies

DELETE FROM clean_movies_metadata
where production_companies = '[]' or production_countries = '[]' or genres = '[]'  ----Removing empty rows in the respective columns for better 
																					---extraction of sample----
SELECT * FROM clean_movies_metadata

SELECT budget, revenue, title
FROM clean_movies_metadata
WHERE budget <= 5000 or revenue <= 5000
ORDER BY budget DESC

DELETE FROM clean_movies_metadata
WHERE budget <= 5000 or revenue <= 5000    ---removing outliers that can skew my analysis and visualization----

SELECT id, original_language,
CASE
	WHEN original_language = 'en' THEN 'English'
	WHEN original_language = 'fr' THEN 'French'
	WHEN original_language = 'ko' THEN 'Korean'
	WHEN original_language = 'hi' THEN 'Hindu'
	WHEN original_language = 'it' THEN 'Italian'
	WHEN original_language = 'ja' THEN 'Japanese'
	ELSE 'Others'
END AS language_category                 ----Pre-Viewing conditions for language category Classification---
FROM clean_movies_metadata

ALTER TABLE clean_movies_metadata
ADD language_category NVARCHAR(255) ----- Adding language_Category Column into the Table---

UPDATE clean_movies_metadata
SET language_category =
	CASE
	WHEN original_language = 'en' THEN 'English'
	WHEN original_language = 'fr' THEN 'French'
	WHEN original_language = 'ko' THEN 'Korean'
	WHEN original_language = 'hi' THEN 'Hindu'
	WHEN original_language = 'it' THEN 'Italian'
	WHEN original_language = 'ja' THEN 'Japanese'
	ELSE 'Others'
END                                         ----Inserting Conditions into language_category column----


SELECT id,SUBSTRING(production_countries,18,2) 
FROM clean_movies_metadata					----Pre-viewing major country of movie production----

ALTER TABLE clean_movies_metadata
ADD production_major_country NVARCHAR(255)           ----Adding a new column for the country category---

UPDATE clean_movies_metadata
SET production_major_country = SUBSTRING(production_countries,18,2)    ---filling the new added column---

ALTER TABLE clean_movies_metadata
ADD country_category NVARCHAR(255)

UPDATE clean_movies_metadata
SET country_category = CASE
	WHEN production_countries LIKE '%US%' THEN 'USA'
	WHEN production_countries LIKE '%GB%' THEN 'United Kingdom'
	WHEN production_countries LIKE '%FR%' THEN 'France'
	WHEN production_countries LIKE '%JP%' THEN 'Japan'
	WHEN production_countries LIKE '%KR%' THEN 'South Korea'
	ELSE 'Others'
END															-----Filling the country catagory column---
					
SELECT * FROM clean_movies_metadata

CREATE TABLE clean_ratings
(userid INT,moviedid INT, rating FLOAT) 
											---Changing the datatype and filtering colunmn (by creating an inserting in my secong table called ratings
INSERT INTO clean_ratings
SELECT userid, movieid, rating
FROM ratings

CREATE TABLE CleanMoviesJoint1
(MovieId INT, MovieTitle NVARCHAR(255), AverageRating FLOAT, Budget FLOAT, Revenue FLOAT, Country NVARCHAR(255), Status NVARCHAR(255),
Language NVARCHAR(255), NumberOfViewers INT, Release_Date DATE)

INSERT INTO CleanMoviesJoint1
SELECT cle.id, title, AVG(rating)  Average_movieRating, budget, revenue, country_category,status,language_category, COUNT(userid) NUmber_of_Viewers, release_date
FROM clean_movies_metadata AS cle
INNER JOIN clean_ratings AS rat      ---Joinning Both cleaned tables and filtering out required column for my visualization---
ON cle.id = rat.userid
GROUP BY cle.id, title, budget, revenue, country_category, status, language_category, release_date

SELECT MovieId,Release_Date FROM CleanMoviesJoint1

SELECT *
FROM movies_metadata
LEFT JOIN CleanMoviesJoint
ON movies_metadata.id = CleanMoviesJoint.MovieId
WHERE CleanMoviesJoint.MovieId IS NULL

----Sample Dataset has been extracted through series of cleaning procedures and exploratory analysis, the visualization of this sample will be done using
		---POWER BI:--------