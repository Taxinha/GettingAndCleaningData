## Getting and Cleaning Data
## Course Project

library(plyr)
library(dplyr)
library(reshape2)


## Download Data file
fileURL   <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
localFile <- "./data/UCI_HAR_Dataset.zip"

## check if the data folder exists
if(!file.exists("data")){
  dir.create("data")
}

## check if file exists - if not download the zip file with the data
if(!file.exists(localFile)){
  download.file(fileURL, destfile = localFile, method = "curl")

  ## extract the zip file
  
  unzip(localFile, overwrite = TRUE, exdir = "./data")
}


#0 Read Files
#print("Reading Files")
activityLabels = read.table("./data/UCI HAR Dataset/activity_labels.txt")
features      = read.table("./data/UCI HAR Dataset/features.txt")

trainX = read.table("./data/UCI HAR Dataset/train/X_train.txt")
trainY = read.table("./data/UCI HAR Dataset/train/y_train.txt")
trainSubject = read.table("./data/UCI HAR Dataset/train/subject_train.txt")

testX = read.table("./data/UCI HAR Dataset/test/X_test.txt")
testY = read.table("./data/UCI HAR Dataset/test/y_test.txt")
testSubject = read.table("./data/UCI HAR Dataset/test/subject_test.txt")

#1) Merges the training and the test sets to create one data set.
#print("Merge Data 1")
#trainDS <- mutate(trainX, Subject = trainSubject$V1, Label = trainY$V1)
#print("Merge Data 2")
#testDS <- mutate(testX, Subject = testSubject$V1, Label = testY$V1 )


colnames(trainSubject) <- c("Subject")
colnames(trainY) <- c("Label")
trainDS <- cbind(trainX, trainY, trainSubject)

colnames(testSubject) <- c("Subject")
colnames(testY) <- c("Label")
testDS <- cbind(testX, testY, testSubject)
  
print("Merge Data 3")
mergedDS <- rbind(trainDS, testDS)
print("Merge Data - dimension check")
print(dim(mergedDS))


#2) Extracts only the measurements on the mean and standard deviation for each measurement. 
print("Extracts the mean and std")
meanAndStd <- features[grepl("-(mean|std)\\(\\)", features$V2, perl = TRUE), ]

## Get only the 66 columns for Mean and STD plus Subject and Label
reducedDS <- mergedDS[, c(meanAndStd$V1, ncol(mergedDS) - 1, ncol(mergedDS))]

## 10299 x 68 (66 mean&std + subject + label)
print("Dimensions of the reduced dataset")
print(dim(reducedDS))

#4) Appropriately labels the data set with descriptive variable names. 
colnames(reducedDS) <- c(as.character(meanAndStd$V2), "Subject", "Label")

#3) Uses descriptive activity names to name the activities in the data set
finalDS <- merge(reducedDS, activityLabels, by.x = "Label", by.y = "V1")
finalDS <- mutate(finalDS, Activity = V2)
finalDS <- select(finalDS, -V2)
dim(finalDS)

#5) From the data set in step 4, creates a second, independent tidy data set with the average 
## of each variable for each activity and each subject.
## Create step5_tidyData.txt file created with write.table() using row.name=FALSE 

tidyData <- finalDS %>%
  melt(id=c("Subject","Activity"))

##write.table()

