#### Auto MPG Analysis using PCA and t-SNE

#### Learning Outcome
- treated missing value, removed outliers, measured correlation among variables
- standardized the data for scaling
- used PCA technique to reduce dimensionality
- used t-SNE for grouping the data

#### Tools Used 
Python, Pandas, Numpy, Matplotlib, Seaborn, SKLearn

#### Result
Using t-SNE, I segment the data into three distinct groups. While most of the cars in group 1 contains higher mpg and accelaration, they have lower displacement, horsepower, and weight. 
Group 2 mostly includes cars with mid-category features. Group 3 includes large number of old cars with lower accelaration, higher weight, displacement, and horsepower.

#### Objective
The objective of this problem is to **explore the data, reduce the number of features by using dimensionality reduction techniques like PCA and t-SNE, and extract meaningful insights**.

#### Dataset
There are 8 variables in the data: 

- mpg: miles per gallon
- cyl: number of cylinders
- disp: engine displacement (cu. inches) or engine size
- hp: horsepower
- wt: vehicle weight (lbs.)
- acc: time taken to accelerate from 0 to 60 mph (sec.)
- yr: model year
- car name: car model name
