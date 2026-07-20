# Ecommerce-Sales-Analysis
Data Analytic project showcasing Analysis including Sales, Product, Customers, Country and Return for a UK-based ecommerce company using Python, SQL and PowerBI

## Project Overview

This project presents an end-to-end analysis of a UK-based ecommerce transaction dataset using **Python**, **SQL**, and **Power BI**. The goal of the project is to clean and prepare transactional data, analyse business performance using SQL, and build an interactive Power BI dashboard to communicate key insights.

The dataset contains online retail transactions from a UK-based non-store online retail business. The analysis focuses on sales performance, product performance, customer behaviour, country-level revenue, and returns/cancellations.

## Tools Used

* **Python**: Data cleaning, transformation, and preparation
* **MySQL / SQL**: Data storage and business question analysis
* **Power BI**: Data modelling, DAX measures, and dashboard visualisation
* **GitHub**: Project documentation and portfolio presentation

## Business Questions

This project aims to answer the following business questions:

1. How much revenue did the business generate?
2. How did sales performance change over time?
3. Which products generated the most revenue?
4. Which products sold the highest quantity?
5. Which countries contributed the most revenue?
6. Who were the highest-value customers?
7. How much revenue was affected by returns and cancellations?
8. Which products had the highest return value?

## Dataset Description

The original dataset contains ecommerce transaction records with fields such as:

* `InvoiceNo`
* `StockCode`
* `Description`
* `Quantity`
* `InvoiceDate`
* `UnitPrice`
* `CustomerID`
* `Country`

A new sales column was created in Python:

```python
Sales = Quantity * UnitPrice
```

The cleaned data was separated into three main datasets:

| Table            | Description                         | Main Use                                       |
| ---------------- | ----------------------------------- | ---------------------------------------------- |
| `clean_sales`    | Cleaned sales transaction data      | Revenue, products, countries, monthly sales    |
| `customer_sales` | Sales rows with valid customer IDs  | Customer-level analysis                        |
| `returns`        | Cancelled and returned transactions | Return value, returned products, cancellations |

## Data Cleaning in Python

The data cleaning process was completed in Python before importing the data into SQL and Power BI.

Main cleaning steps included:

* Checked missing values and data types
* Converted `InvoiceDate` into datetime format
* Created the `Sales` column
* Removed or separated invalid and return-related transactions
* Created a clean sales dataset for general analysis
* Created a customer-level dataset by excluding missing `CustomerID` values
* Created a returns dataset using negative quantities and cancelled invoices
* Created `ReturnValue` as a positive value for return analysis

The final clean sales dataset contained **527,946 rows**.

## SQL Analysis

After cleaning the data in Python, the prepared datasets were imported into MySQL. SQL was used to answer business questions and validate key metrics.

Examples of SQL analysis included:

* Total revenue
* Monthly revenue trend
* Top products by revenue
* Top products by quantity sold
* Revenue by country
* Top customers by revenue
* Cancelled invoices
* Total return value
* Return rate

## Power BI Data Model

In Power BI, the data was organised into a star schema to improve reporting and analysis.

### Fact Tables

| Table         | Description                                 |
| ------------- | ------------------------------------------- |
| `FactSales`   | Main sales transaction table                |
| `FactReturns` | Returns and cancellations transaction table |

### Dimension Tables

| Table         | Description                                |
| ------------- | ------------------------------------------ |
| `DimDate`     | Date, month, quarter, and year information |
| `DimProduct`  | Unique product codes and descriptions      |
| `DimCustomer` | Unique customer IDs                        |
| `DimCountry`  | Country information                        |

The main relationships were:

* `DimDate[Date]` → `FactSales[InvoiceDateOnly]`
* `DimDate[Date]` → `FactReturns[InvoiceDateOnly]`
* `DimProduct[StockCode]` → `FactSales[StockCode]`
* `DimProduct[StockCode]` → `FactReturns[StockCode]`
* `DimCustomer[CustomerID]` → `FactSales[CustomerID]`
* `DimCountry[Country]` → `FactSales[Country]`
* `DimCountry[Country]` → `FactReturns[Country]`

## Key DAX Measures

Several DAX measures were created for dashboard reporting.

```DAX
Total Revenue = SUM(FactSales[Sales])
```

```DAX
Total Quantity Sold = SUM(FactSales[Quantity])
```

```DAX
Total Orders = DISTINCTCOUNT(FactSales[InvoiceNo])
```

```DAX
Average Order Value = DIVIDE([Total Revenue], [Total Orders])
```

```DAX
Total Customers =
CALCULATE (
    DISTINCTCOUNT ( FactSales[CustomerID] ),
    NOT ISBLANK ( FactSales[CustomerID] )
)
```

```DAX
Total Return Value = SUM(FactReturns[ReturnValue])
```

```DAX
Total Returned Quantity =
SUMX (
    FactReturns,
    ABS ( FactReturns[Quantity] )
)
```

```DAX
Return Rate = DIVIDE([Total Return Value], [Total Revenue])
```

```DAX
Net Revenue = [Total Revenue] - [Total Return Value]
```

## Dashboard Structure

The Power BI dashboard contains four main pages.

### 1. Sales Overview

The Sales Overview page provides a high-level summary of business performance. It includes key metrics such as total revenue, total orders, total customers, average order value, net revenue, and return rate.

Main visuals include:

* KPI cards
* Monthly revenue trend
* Revenue share by market group
* Top product revenue contribution
* Country-level revenue summary
* Interactive slicers for date, country, and product

### 2. Product Performance

The Product Performance page analyses product-level sales results.

Main visuals include:

* Top products by revenue
* Top products by quantity sold
* Product revenue contribution
* Product details table

This page helps identify whether high-revenue products are also high-volume products.

### 3. Customer Analysis

The Customer Analysis page focuses on identifiable customers.

Main visuals include:

* Total customers
* Average revenue per customer
* Top customers by revenue
* Top customers by order activity
* Customer details table

Transactions with missing customer IDs were excluded from customer-level analysis.

### 4. Country and Returns Analysis

The Country and Returns Analysis page examines geographical revenue distribution and return behaviour.

Main visuals include:

* Revenue by country
* UK vs non-UK revenue share
* Average order value by country
* Total return value
* Return rate
* Top returned products by return value
* Monthly return trend

Non-product entries such as manual adjustments, postage, discounts, and charges were excluded from product-level return charts to focus on actual merchandise returns.

## Key Findings

* The business generated approximately **£10 million** in total revenue.
* Sales increased strongly toward the later months of 2011.
* The **United Kingdom** accounted for the majority of revenue, showing strong dependence on the domestic market.
* Some international markets showed higher average order values, suggesting that overseas customers may place larger orders even when total revenue is lower.
* The highest revenue products were not always the same as the highest quantity products, showing that both price and sales volume are important in product performance analysis.
* A relatively small number of customers contributed a large share of revenue, highlighting the importance of customer retention.
* Returns and cancellations represented a meaningful revenue loss.
* Product-level return analysis required filtering out non-product transaction entries such as manual adjustments and postage.

## Business Recommendations

Based on the analysis, the following recommendations were identified:

1. **Monitor high-revenue products**
   The company should continue tracking top-performing products and ensure that high-revenue products remain well stocked.

2. **Support international market growth**
   Since revenue is highly concentrated in the UK, the business could explore opportunities to grow international markets with high average order values.

3. **Focus on customer retention**
   High-value customers contribute significantly to total revenue. The company could create loyalty offers, targeted promotions, or personalised campaigns for these customers.

4. **Track returned products regularly**
   Returned products should be monitored to identify possible quality issues, fulfilment problems, or products with unusually high return values.

5. **Review return and cancellation patterns**
   Since returns affect net revenue, the company should regularly monitor return rate and return value as part of business performance reporting.

## Limitations

* Some transactions had missing customer IDs, so customer-level analysis was limited to identifiable customers.
* The dataset does not contain customer demographics, marketing channels, product categories, or profit margins.
* December 2011 appears to contain partial data, so monthly comparisons involving December should be interpreted carefully.
* Some transaction codes represented non-product items such as postage, discounts, charges, or manual adjustments, which required filtering for product-level analysis.

## Conclusion

This project demonstrates an end-to-end data analytics workflow using Python, SQL, and Power BI. Python was used to clean and prepare the data, SQL was used to answer business questions, and Power BI was used to create an interactive dashboard for business reporting. The final dashboard provides insights into sales performance, product performance, customer behaviour, country-level revenue, and returns/cancellations.

