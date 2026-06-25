# SQL-Data-Cleaning-and-EDA-Layoffs

1. SQL Data Cleaning & Exploratory Analysis: Layoffs Dataset

Project Overview:
This project involved cleaning and analyzing a dataset of global company layoffs using SQL. We removed duplicates, standardized data, handled missing values, and performed exploratory data analysis to uncover insights.


Dataset:
The dataset contains information on layoffs: companies, industries, countries, number of layoffs, and percentages, along with dates and funding information.


Tools Used:
MySQL (or whichever SQL DBMS you used)
GitHub for version control


Data Cleaning Steps:
1.Created a staging table and identified duplicate records.
2.Standardized text fields (e.g., trimming spaces, unifying industry names).
3.Converted date formats to SQL DATE type.
4.Filled missing values where possible.
5.Removed records with no useful data.


Exploratory Data Analysis (EDA):
Identified maximum layoffs and impacted companies.
Analyzed layoffs by industry, country, and year.
Calculated monthly trends and cumulative layoffs.
Ranked top companies by layoffs per year.


Key Insights:
Highest layoffs by company
Industry trends
Country trends
Monthly layoffs
Top companies each year


How to Run:
Import the dataset into your SQL environment.
Run the cleaning script first.
Run the EDA script to reproduce the analysis



2. Business Insights

At the end write something like

Top affected industry:
Consumer

Country with highest layoffs:
United States

Year with highest layoffs:
2023

Company with highest layoffs:
Amazon