# Set the working directory
setwd("C:/Users/mark__000/Documents/Springboard/Data-Wrangling-Project/UCI HAR Dataset")

# Load necessary packages
library(tidyr)
library(dplyr)

# Read in the raw data
activity_labels <- read.table("activity_labels.txt",stringsAsFactors = F)
features <- read.table("features.txt",stringsAsFactors = F)
X_train <- read.table("train/X_train.txt")
y_train <- read.table("train/y_train.txt")
subject_train <- read.table("train/subject_train.txt")
X_test <- read.table("test/X_test.txt")
y_test <- read.table("test/y_test.txt")
subject_test <- read.table("test/subject_test.txt")

# Label column names as appropriate 
colnames(subject_train) <- c("Subject")
colnames(subject_test) <- c("Subject")
colnames(activity_labels) <- c("ID","ActivityName")
colnames(features) <- c("ID","Feature")
colnames(X_train) <- make.names(features$Feature, unique = T)
colnames(X_test) <- make.names(features$Feature, unique = T)
colnames(y_train) <- c("ActivityLabel")
colnames(y_test) <- c("ActivityLabel")

# Extract mean and std dev columns
X_train_sel <- X_train %>% select(contains("mean..",ignore.case=F),contains("std..",ignore.case=F))
X_test_sel <- X_test %>% select(contains("mean..",ignore.case=F),contains("std..",ignore.case=F))

# Fuse train and test data together including subject and activity label
fused_train <- bind_cols(subject_train,y_train,X_train_sel)
fused_test <- bind_cols(subject_test,y_test,X_test_sel)
fused_data <- bind_rows(fused_train, fused_test)

# Merge fused data with activity labels to include the description of the activity
fused_data <- inner_join(fused_data,activity_labels,by=c("ActivityLabel"="ID"))

# Compute avg of each variable for each group of subject activity
final_data <- fused_data %>% group_by(Subject,ActivityLabel,ActivityName) %>% 
  summarise_each(funs(mean))
