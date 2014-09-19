## Getting and Cleaning Data
## Course Project

library(dplyr)
library(reshape2)

outputFile <- "tidyData.txt"
fileURL    <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
localFile  <- "./data/UCI_HAR_Dataset.zip"

## Download and Extract Zip data file
downloadAndExtractZipFile <- function(){
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
}

## Reads the data file
readDataFile <- function(fileName, ...){
  if(! file.exists(fileName)){
    stop(paste("readDataFile: File ", fileName, " doesn't exist"))
  }
  
  print(paste("Reading file ", fileName))
  read.table(fileName, ...)
}

## Read the files and merges the training and test sets to create one data set.
readAndMergeTrainingAndTestSets <- function(){
  # Read Files
  print("Reading Files")
  trainX = readDataFile("./data/UCI HAR Dataset/train/X_train.txt")
  trainY = readDataFile("./data/UCI HAR Dataset/train/y_train.txt")
  trainSubject = readDataFile("./data/UCI HAR Dataset/train/subject_train.txt")
  
  testX = readDataFile("./data/UCI HAR Dataset/test/X_test.txt")
  testY = readDataFile("./data/UCI HAR Dataset/test/y_test.txt")
  testSubject = readDataFile("./data/UCI HAR Dataset/test/subject_test.txt")
  
  # Merge data sets
  print("Start merging...")
  colnames(trainSubject) <- c("subject")
  colnames(trainY) <- c("label")
  trainDS <- cbind(trainX, trainY, trainSubject)
  
  colnames(testSubject) <- c("subject")
  colnames(testY) <- c("label")
  testDS <- cbind(testX, testY, testSubject)
  
  mergedDS <- rbind(trainDS, testDS)
  print("Merged DataSet - dimensions check")
  print(dim(mergedDS))
  
  mergedDS
}

## Extracts only the measurements on the mean and standard deviation for 
## each measurement. 
extractMeanAndSTD <- function(dataSet){
  print("Extracts the mean and std")
  
  ## Read the features file
  features = readDataFile("./data/UCI HAR Dataset/features.txt")
  
  ## Get the Mean and STD rows
  meanAndStd <- features[grepl("-(mean|std)\\(\\)", features$V2, perl = TRUE), ]
  
  ## Get only the 66 columns for Mean and STD plus Subject and Label
  reducedDS <- dataSet[, c(meanAndStd$V1, ncol(dataSet) - 1, ncol(dataSet))]
  
  ## 10299 x 68 (66 mean&std + subject + label)
  print("Reduced DataSet - dimensions check")
  print(dim(reducedDS))
  
  ## Create descriptive activity names
  variables <- meanAndStd$V2 %>%
    gsub(pattern = "-|\\(|\\)", replacement = "") %>%
    gsub(pattern = "^t", replacement = "time") %>%
    gsub(pattern = "^f", replacement = "frequency") %>%
    gsub(pattern = "BodyBody", replacement = "body") %>%
    gsub(pattern = "Acc", replacement = "accelerometer") %>%
    gsub(pattern = "Gyro", replacement = "gyroscope") %>%
    gsub(pattern = "Mag", replacement = "magnitude") %>%
    tolower()
  
  ## Appropriately labels the data set with descriptive variable names.
  colnames(reducedDS) <- c(variables, "label", "subject")
  
  reducedDS
}

## Uses descriptive activity names to name the activities in the data set
updateActivityNames <- function(dataSet){
  print("Final DataSet")
  activityLabels = readDataFile("./data/UCI HAR Dataset/activity_labels.txt")
  
  finalDS <- dataSet %>%
    merge(activityLabels, by.x = "label", by.y = "V1") %>%
    mutate(activity = V2) %>%
    select(-V2, -label)
  
  print("Final reduced DataSet - dimensions check")
  print(dim(finalDS))
  
  finalDS
}

## From the data set in step 4, creates a second, independent tidy data set 
## with the average of each variable for each activity and each subject.
tidyDataSet <- function(dataSet){
  tidyData <- 
    dataSet %>%
    melt(id=c("subject","activity"), variable.name = "feature") %>%
    group_by(subject, activity, feature) %>%
    summarise(mean(value))
  
  print("TidyData")
  print(dim(tidyData))
  
  tidyData
}

## Create the file with the TidyData
writeTidyDataFile <- function(tidyData, fileName){
  if(file.exists(fileName)){
    file.remove(fileName) 
  }
  
  write.table(tidyData, fileName, row.name = FALSE)
}

## Read the tidy data file created before
readTidyDataFile <- function(){
  readDataFile(outputFile, header = TRUE)
}

## Main function
main <- function(){
  print("Starting run_analysis...")
  downloadAndExtractZipFile()
  
  readAndMergeTrainingAndTestSets() %>%   ## Step 1
    extractMeanAndSTD() %>%               ## Step 2 & 4
    updateActivityNames() %>%             ## step 3
    tidyDataSet() %>%                     ## Step 5
    writeTidyDataFile(outputFile)         ## step 5
  
  print("Finish")
}

## main()


