### Unsupervised Learning Project: AllLife Bank Customer Segmentation
**_Learning Outcome_**
- Exploratory Data Analysis where I checked for missing values, duplicates, outliers, and correlation
- Scaled the data using standardization method
- Applied PCA technique for feature engineering
- Created Clusters using K-Means, K-Medoids, and Gaussian Mixture Model

**_Tools used_** <br>
- Python, Pandas, Numpy, Seaborn, SKLearn, Jupyter Notebook

**_Results_** <br>
- **K-Medoids** provide the best cluster as it give same weitage to each customer clusters and select more realistic features for each clusters.



**_Context_** <br>
- **AllLife Bank wants to focus on its credit card customer base** in the next financial year. 
They have been advised by their marketing research team, that the penetration in the market can be improved. 
Based on this input, the marketing team proposes to run personalized campaigns to target new customers as well as upsell to existing customers. 
Another insight from the market research was that the customers perceive the support services of the bank poorly. 
Based on this, the operations team wants to upgrade the service delivery model, to ensure that customers' queries are resolved faster. 
The head of marketing and the head of delivery, both decide to reach out to the Data Science team for help.
<br>

**_Objective_** <br>
- **Identify different segments in the existing customer base**, taking into account their spending patterns as well as past interactions with the bank.
<br>

**_[About the data](https://github.com/ruhularahi/Portfolio_Projects/blob/main/Bank%20Customer%20Segmentation/Credit%20Card%20Customer%20Data.xlsx)_** <br>
Data is available on customers of the bank with their credit limit, the total number of credit cards the customer has, and different channels through 
which the customer has contacted the bank for any queries. These different channels include visiting the bank, online, and through a call center.

- **Sl_no** - Customer Serial Number
- **Customer Key** - Customer identification
- **Avg_Credit_Limit**	- Average credit limit (currency is not specified, you can make an assumption around this)
- **Total_Credit_Cards** - Total number of credit cards 
- **Total_visits_bank**	- Total bank visits
- **Total_visits_online** - Total online visits
- **Total_calls_made** - Total calls made

