library(RCurl)

if (!file.info('UCI HAR Dataset')$isdir) {
  dataFile <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
  dir.create('UCI HAR Dataset')
  download.file(dataFile, 'UCI-HAR-dataset.zip', method='curl')
  unzip('./UCI-HAR-dataset.zip')
}

# Merges the training and the test sets to create one data set.
x.train <- read.table('./UCI HAR Dataset/train/X_train.txt')
x.test <- read.table('./UCI HAR Dataset/test/X_test.txt')
x <- rbind(x.train, x.test)

subj.train <- read.table('./UCI HAR Dataset/train/subject_train.txt')
subj.test <- read.table('./UCI HAR Dataset/test/subject_test.txt')
subj <- rbind(subj.train, subj.test)

y.train <- read.table('./UCI HAR Dataset/train/y_train.txt')
y.test <- read.table('./UCI HAR Dataset/test/y_test.txt')
y <- rbind(y.train, y.test)

# Extracts only the measurements on the mean and standard deviation for each measurement. 
features <- read.table('./UCI HAR Dataset/features.txt')
mean.sd <- grep("-mean\\(\\)|-std\\(\\)", features[, 2])
x.mean.sd <- x[, mean.sd]

# Uses descriptive activity names to name the activities in the data set
names(x.mean.sd) <- features[mean.sd, 2]
names(x.mean.sd) <- tolower(names(x.mean.sd)) 
names(x.mean.sd) <- gsub("\\(|\\)", "", names(x.mean.sd))

activities <- read.table('./UCI HAR Dataset/activity_labels.txt')
activities[, 2] <- tolower(as.character(activities[, 2]))
activities[, 2] <- gsub("_", "", activities[, 2])

y[, 1] = activities[y[, 1], 2]
colnames(y) <- 'activity'
colnames(subj) <- 'subject'

# Appropriately labels the data set with descriptive activity names.
data <- cbind(subj, x.mean.sd, y)
str(data)
write.table(data, './Project/merged.txt', row.names = F)

# Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
average.df <- aggregate(x=data, by=list(activities=data$activity, subj=data$subject), FUN=mean)
average.df <- average.df[, !(colnames(average.df) %in% c("subj", "activity"))]
str(average.df)
write.table(average.df, './Project/average.txt', row.names = F)
