## Getting and Cleaning Data
## Course Project

library(dplyr)
library(reshape2)

## Download and Extract Zip data file
downloadAndExtractZipFile <- function(){
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
}

## Reads the data file
readDataFile <- function(fileName){
  if(! file.exists(fileName)){
    stop(paste("readDataFile: File ", fileName, " doesn't exist"))
  }
  
  print(paste("Reading ", fileName))
  read.table(fileName)
}

#1) Merges the training and the test sets to create one data set.
#print("Merge Data 1")
#trainDS <- mutate(trainX, Subject = trainSubject$V1, Label = trainY$V1)
#print("Merge Data 2")
#testDS <- mutate(testX, Subject = testSubject$V1, Label = testY$V1 )

mergeTrainingAndTestSets <- function(){
  #0 Read Files
  print("Reading Files")
  trainX = readDataFile("./data/UCI HAR Dataset/train/X_train.txt")
  trainY = readDataFile("./data/UCI HAR Dataset/train/y_train.txt")
  trainSubject = readDataFile("./data/UCI HAR Dataset/train/subject_train.txt")
  
  testX = readDataFile("./data/UCI HAR Dataset/test/X_test.txt")
  testY = readDataFile("./data/UCI HAR Dataset/test/y_test.txt")
  testSubject = readDataFile("./data/UCI HAR Dataset/test/subject_test.txt")
  
  print("Start merging...")
  colnames(trainSubject) <- c("Subject")
  colnames(trainY) <- c("Label")
  trainDS <- cbind(trainX, trainY, trainSubject)
  
  colnames(testSubject) <- c("Subject")
  colnames(testY) <- c("Label")
  testDS <- cbind(testX, testY, testSubject)
  
  mergedDS <- rbind(trainDS, testDS)
  print("Merge Data - dimension check")
  print(dim(mergedDS))
  
  mergedDS
}

#2) Extracts only the measurements on the mean and standard deviation for each measurement. 
extractMeanAndSTD <- function(dataSet){
  print("Extracts the mean and std")
  features = readDataFile("./data/UCI HAR Dataset/features.txt")
  
  ## Get the Mean and STD rows
  meanAndStd <- features[grepl("-(mean|std)\\(\\)", features$V2, perl = TRUE), ]
  
  ## Get only the 66 columns for Mean and STD plus Subject and Label
  reducedDS <- dataSet[, c(meanAndStd$V1, ncol(dataSet) - 1, ncol(dataSet))]
  
  ## 10299 x 68 (66 mean&std + subject + label)
  print("Dimensions of the reduced dataset")
  print(dim(reducedDS))
  
  #4) Appropriately labels the data set with descriptive variable names. 
  colnames(reducedDS) <- c(as.character(meanAndStd$V2), "Label", "Subject")
  
  reducedDS
}

#3) Uses descriptive activity names to name the activities in the data set
updateActivityNames <- function(dataSet){
  print("Final DS")
  activityLabels = readDataFile("./data/UCI HAR Dataset/activity_labels.txt")
  
  finalDS <- dataSet %>%
    merge(activityLabels, by.x = "Label", by.y = "V1") %>%
    mutate(Activity = V2) %>%
    select(-V2, -Label)
  
  print("Dimensions of the final reduced dataset")
  print(dim(finalDS))
  
  finalDS
}

#5) From the data set in step 4, creates a second, independent tidy data set with the average 
## of each variable for each activity and each subject.
tidyDataSet <- function(dataSet){
  tidyData <- 
    dataSet %>%
    melt(id=c("Subject","Activity"), variable.name = "Feature") %>%
    group_by(Subject, Activity, Feature) %>%
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
  
  write.table(tidyData, fileName, row.name=FALSE)
}

## Main function
main <- function(){
  outputFile <- "tidyData.txt"
  
  downloadAndExtractZipFile()
  
  mergeTrainingAndTestSets() %>%   ## Step 1
    extractMeanAndSTD() %>%        ## Step 2 & 4
    updateActivityNames() %>%      ## step 3
    tidyDataSet() %>%              ## Step 5
    writeTidyDataFile(outputFile)  ## step 5
  
  ## readDataFile(outputFile)
}

main()


