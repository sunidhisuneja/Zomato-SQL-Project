# Zomato-SQL-Project 🍕🍔

## Project Overview

This project focuses on analyzing Zomato food delivery data using SQL. The aim is to design a relational database, clean and preprocess the data, and run analytical queries to generate insights into customer behavior, restaurant performance, rider efficiency, and order trends.

## Database Schema

The database consists of the following tables:

**Customers** → Stores customer details

**Restaurants** → Contains restaurant info (city, opening hours, etc.)

**Orders** → Captures customer orders and transaction details

**Riders** → Stores delivery partner details

**Deliveries** → Tracks delivery status, time, and assigned rider

## Data Cleaning

Before analysis, data was validated for:

Missing customer names, order items, and timestamps

Orders without valid delivery details

Inconsistent/null delivery records (deleted for accuracy)

## Analytical Insights

Designed and implemented relational database schema and executed 20+ advanced SQL queries to analyze customers, restaurants, orders, riders, and deliveries for Zomato.

Identified peak order slots (12–2 PM & 8–10 PM, ~40% of daily orders) and top dishes per customer, enabling personalized recommendations and operational efficiency.

Segmented customers into Gold/Silver categories based on AOV (~₹322), highlighting high-value users spending ₹100K+ and supporting targeted loyalty campaigns.

Ranked restaurants and cities by revenue and analyzed rider efficiency (avg. <15 min = 5-star deliveries), providing insights to improve retention, delivery performance, and revenue growth.

## Acknowledgments

This project is inspired by real-world food delivery platforms and serves as a hands-on practice for SQL data analysis.
