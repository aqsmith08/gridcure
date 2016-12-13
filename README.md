# gridcure
Predictive modeling challenge from https://www.gridcure.com/contact/#openings

## Electric Vehicle Detection

The training set contains two months of smart meter power readings from 1590 houses. The readings were taken at half-hour intervals.  Some of the homes have electric vehicles and some do not.

The file  "EV_train_labels.csv" indicates the time intervals on which an electric vehicle was charging (1 indicates a vehicle was charging at some point during the interval and 0 indicates no vehicle was charging at any point during the interval).  Can you determine:

* A. Which residences have electric vehicles?
* B. When the electric vehicles were charging?
* C. Any other interesting aspects of the dataset?

A solution to part B might consist of a prediction of the probability that an electric car was charging for each house and time interval in the test set.

Please include code and explain your reasoning.  What do you expect the accuracy of your predictions to be?

## Sample Observations

Reading values when the EV is charging tend to be greater than the 75th percentile value per house.

![boxplot_percentile](https://github.com/aqsmith08/gridcure/blob/master/boxplot_percentile.png)

However, precision is poor if only considering reading value percentile. 

Percentile | Precision | Recall
---------- | ----------|-------
65 | .06 | .926
75 | .08 | .878
85 | .125 | .784
95 | .227 | .479
