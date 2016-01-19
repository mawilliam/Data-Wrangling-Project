# Set the working directory * change for Github*
setwd("C:/Users/mark__000/Documents/Springboard/UCI HAR Dataset")

# Read in the raw data
activity_labels <- read.table("activity_labels.txt",stringsAsFactors = F)
features <- read.table("features.txt",stringsAsFactors = F)
X_train <- read.table("train/X_train.txt")
y_train <- read.table("train/y_train.txt")
subject_train <- read.table("train/subject_train.txt")
X_test <- read.table("test/X_test.txt")
y_test <- read.table("test/y_test.txt")
subject_test <- read.table("test/subject_test.txt")

# Label column names as appropriate and fuse training and testing sets
colnames(subject_train) <- c("Subject")
colnames(subject_test) <- c("Subject")
colnames(activity_labels) <- c("ID","ActivityName")
colnames(features) <- c("ID","Feature")
colnames(X_train) <- make.names(features$Feature, unique = T)
colnames(X_test) <- make.names(features$Feature, unique = T)
colnames(y_train) <- c("ActivityLabel")
colnames(y_test) <- c("ActivityLabel")

# Extract columns containing mean and std dev for each measurement
X_train_mean <- X_train[,grepl("mean..",colnames(X_train),fixed=T)]
X_test_mean <- X_test[,grepl("mean..",colnames(X_test),fixed=T)]
X_train_std <- X_train[,grepl("std..",colnames(X_train),fixed=T)]
X_test_std <- X_test[,grepl("std..",colnames(X_test),fixed=T)]

# Fuse train and test data together including subject and activity label
fused_train <- cbind(subject_train,y_train,X_train_mean,X_train_std)
fused_test <- cbind(subject_test,y_test,X_test_mean,X_test_std)
fused_data <- rbind(fused_train, fused_test)

# Merge fused data with activity labels to include the description of the activity
fused_data <- merge(fused_data,activity_labels,by.x="ActivityLabel",by.y="ID")

# Split data by subject and activity
fused_split <- split(fused_data, fused_data[,c("Subject","ActivityLabel")])

# Apply avg to each column
# This is not quite working yet
fused_apply <- lapply(fused_split, function(x){
  col_mean <- colMeans(x[,setdiff(colnames(x),c("Subject","ActivityLabel","ActivityName"))])
  df <- data.frame(t(col_mean))
  df <- cbind(Subject=x$Subject[1],
              ActivityLabel=x$ActivityLabel[1],
              ActivityName=x$ActivityName[1],
              df)
  return(df)
})

# Combine data
final_data <- do.call(rbind, fused_apply)
