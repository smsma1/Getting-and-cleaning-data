setwd("D:/GitHub/GettingAndCleaningDataProject")

# Sourcing the Data
## Create a folder to hold source data (if it doesn't already exist)
if(!file.exists("./Course3Week4Assign1")){dir.create("./Course3Week4Assign1")}

## Define the source and download the file
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./Course3Week4Assign1/Course3Week4Assign1.zip", mode = "wb")

## Unzip the file
#unzip("./Course3Week4Assign1/Course3Week4Assign1.zip", exdir = "./Course3Week4Assign1")

# Inspecting the data
## Get list of files unzipped
path_rf <- file.path("./Course3Week4Assign1" , "UCI HAR Dataset")
# files<-list.files(path_rf, recursive=TRUE)

# Merge the training and the test sets to create one data
# There are three types of data sets, and we merge each respectively
# 1. Activity Files - 'Y' prefix files
# 2. Subject Files - 'subject' prefix files
# 3. Feature files - 'X' prefix files

## Read the Activity files
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)

# View(dataActivityTest)
# View(dataActivityTrain)

## Read the Subject files
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)

#View(dataSubjectTrain)
#View(dataSubjectTest)

## Read Features files
dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)

#View(dataFeaturesTest)
#View(dataFeaturesTrain)

## Merge datasets all into one
dataActivity <- rbind(dataActivityTest, dataActivityTrain)
dataSubject <- rbind(dataSubjectTest, dataSubjectTrain)
dataFeatures <- rbind(dataFeaturesTest, dataFeaturesTrain)

## Name the columns in each dataset
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

#UnCommented out commands to inspect the tables 
# View(dataActivity)
# View(dataSubject)
# View(dataFeatures)
# str(dataActivity)
# str(dataSubject)
# str(dataFeatures)


#Combine the subject, activity, and feature data
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

#Uncomment out to inspect the tables
# View(dataCombine)
# dim(dataCombine)
# dim(dataFeatures)
# View(Data)
# dim(Data)
# str(Data)

#get the list of cols that has mean or std.
#also include subject and activity
subdataFeatureNames <- dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectedNames <- c(as.character(subdataFeatureNames), "subject", "activity")
#selectedNames

#Subset the data fram Data by the cols that have mean or standard
subData <- subset(Data, select = selectedNames)
# View(subData)
# str(subData)


#Name the activities in the data set
#First get the activity labels
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
setNames(activityLabels, c("activityNum", "activity"))
names(activityLabels) <- c("activityNum", "activity")

#set the activity to lowercase
activityLabels$activity <- tolower(activityLabels$activity)

# View(activityLabels)
# str(activityLabels)


relabeledData <- merge(activityLabels, subData, by.x = "activityNum", by.y = "activity")
# View(relabeledData)

#sort
relabeledData <- arrange(relabeledData, subject, activity)


#Label the dataset with descriptive variable names
names(relabeledData)<-gsub("^t", "time", names(relabeledData))
names(relabeledData)<-gsub("^f", "frequency", names(relabeledData))
names(relabeledData)<-gsub("Acc", "Accelerometer", names(relabeledData))
names(relabeledData)<-gsub("Gyro", "Gyroscope", names(relabeledData))
names(relabeledData)<-gsub("Mag", "Magnitude", names(relabeledData))
names(relabeledData)<-gsub("BodyBody", "Body", names(relabeledData))
#names(relabeledData)

#str(relabeledData)

#From the data set in step 4, creates a second, independent tidy 
#data set with the average of each variable for each activity and 
#each subject.

library(plyr)
AveragedData<-aggregate(. ~subject + activity, relabeledData, mean)
AveragedData<-AveragedData[order(AveragedData$subject,AveragedData$activity),]
#View(AveragedData)
write.table(AveragedData, file = "tidydata.txt",row.name=FALSE)