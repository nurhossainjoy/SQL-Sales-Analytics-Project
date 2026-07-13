# Dataset

This folder contains the Excel datasets used in this project.

## Files

| File | Description |
|------|-------------|
| Sales.xlsx | Transactional sales data including sales amount, boxes sold, customer count, product ID, salesperson ID, and geographic ID. |
| Products.xlsx | Product details including product name, category, size, and cost per box. |
| People.xlsx | Salesperson information including salesperson name, team, and location. |
| Geo.xlsx | Geographic information including country and region. |

## Data Source

The datasets were imported from Microsoft Excel into PostgreSQL for analysis.

## Relationships

- Sales.pid → Products.pid
- Sales.spid → People.spid
- Sales.geoid → Geo.geoid

These datasets are used for educational and portfolio purposes to demonstrate SQL querying, data analysis, and business reporting.
