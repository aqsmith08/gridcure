library(caret)
library(data.table)
library(dplyr)
library(dtplyr)
library(rpart)
library(tidyr)

# Load the required files
ev.train <- data.table(read.csv("EV_files/EV_train.csv", stringsAsFactors = FALSE))
ev.train.labels <- data.table(read.csv("EV_files/EV_train_labels.csv", stringsAsFactors = FALSE))

train.org <- data.table(gather(ev.train, interval, reading.val, -House.ID))
train.labels.org <- data.table(gather(ev.train.labels, interval, label, -House.ID))

train.org$interval.num <- sapply(X = train.org$interval,
                                 function(x) as.integer(strsplit(x, "_")[[1]][2]))
train.labels.org$interval.num <- sapply(X = train.labels.org$interval,
                                        function(x) as.integer(strsplit(x, "_")[[1]][2]))

### Take sample to play around and avoid memory errors
# TODO: Remove this when errors are solved
train.org <- train.org[1:500000,]
train.labels.org <- train.labels.org[1:500000]

# Remove 'extra' columns and dataframes to avoid memory errors
train.org$interval <- NULL
train.labels.org$interval <- NULL
rm(ev.train, ev.train.labels)

# Merge the training data with the labels
train.final <- merge(x = train.org, y = train.labels.org, by = c("House.ID", "interval.num"))
train.final <- arrange(train.final, House.ID, interval.num)

# Remove 'extra' dataframes to avoid memory errors
rm(train.org, train.labels.org)

# Create average, stdev, min,  max and other values per house
train.final <- group_by(train.final, House.ID) %>%
  mutate(
    house.avg =   mean(reading.val, na.rm = TRUE),
    house.stdev = sd(reading.val, na.rm = TRUE),
    house.min =   min(reading.val, na.rm = TRUE),
    house.max =   max(reading.val, na.rm = TRUE),
    val.pct =    (reading.val - house.avg) / house.avg,
    val.var =    (reading.val - house.avg) ^2,
    val.per =     percent_rank(reading.val))

# Get the difference in values
train.final$val.diff <- ave(train.final$reading.val,
                            factor(train.final$House.ID), FUN = function(x) c(NA, diff(x)))

# Assign the house mean for observations where reading.val doesn't exist
train.final[is.na(train.final$reading.val),]$reading.val <- train.final[
  is.na(train.final$reading.val),]$house.avg

# Assign no difference for observations where val.diff doesn't exist
train.final[is.na(train.final$val.diff),]$val.diff <- 0

train.final$label <- as.factor(train.final$label)

# WORK-IN-PROGRESS
# Start ML model work
set.seed(88)
train.index <- createDataPartition(y = train.final$House.ID, p = .8, list = FALSE)

# Create training and validation data frames with labels
train <- train.final[train.index,]
validation  <- train.final[-train.index,]

# GLM model
model <- train(label ~ val.per + val.pct + val.diff + house.avg + val.var + house.stdev,
               data = train,
               method = "glm")
pred <- predict(model, newdata=validation)
confusionMatrix(data=pred, validation$label)
confusionMatrix(model)

# Tree model
tree <- rpart(label ~ reading.val + house.avg + house.stdev + house.min +
                house.max + val.pct + val.var + val.per,
              data = train,
              method = "class")
summary(tree)
summary(predict(tree, validation, type="class"))
validation$tree.pred <- predict(tree, validation, type="class")
table(validation$tree.pred, validation$label)


# TODO: Prepare the test file
test <- read.csv("EV_files/EV_test.csv", stringsAsFactors = FALSE)
test.org <- gather(test, interval, reading.val, -House.ID)
test.org$interval.num <- sapply(X = test.org$interval,
                                function(x) as.integer(strsplit(x, "_")[[1]][2]))
test.org$interval <- NULL
test.final <- group_by(test.org, House.ID) %>%
  mutate(
    house.avg =   mean(reading.val, na.rm = TRUE),
    house.stdev = sd(reading.val, na.rm = TRUE),
    house.min =   min(reading.val, na.rm = TRUE),
    house.max =   max(reading.val, na.rm = TRUE),
    val.pct =    (reading.val - house.avg) / house.avg,
    val.var =    (reading.val - house.avg) ^2,
    val.per =     percent_rank(reading.val))

# Assign the house mean for observations where reading.val doesn't exist
test.final[is.na(test.final$reading.val),]$reading.val <- test.final[
  is.na(test.final$reading.val),]$house.avg

