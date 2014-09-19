GettingAndCleaningData
======================

Getting And Cleaning Data - Course Project - getdata-007

### Pre-requirements
This R script requires the following libraries to be installed prior execution:

* __dplyr__: a grammar of data manipulation - version 0.2 or higher
* __reshape2__: Flexibly reshape data: a reboot of the reshape package.

### How to use the run_analysis.R script
To run the **run_analysis.R** script you will need to source the file in R or RStudio and then call the `main`function

```
> source('run_analysis.R')
> main()
[1] "Starting run_analysis..."
```

Once you sourced the script, the main function will be executed and will call the following functions: 

1. `downloadAndExtractZipFile()`: this function will create a folder _data_ locally if doesn't exist and download the data zip file in https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip. After downloading the function will extract all files.
Alternatively if you already have the zip file and don't want to download it again, please make sure you have the following folder structure - it'll prevent the function downloading and unzipping the file:
```
data
     |-UCI HAR Dataset
        |-activity_labels.txt
        |-features.txt
        |-features_info.tx
        |-README.txt
        |-test
        |   |-Inertial Signals (content ignored in this script)
        |   |-subject_test.txt
        |   |-X_test.txt
        |   |-y_test.txt
        |-train
            |-Inertial Signals (content ignored in this script)
            |-subject_train.txt
            |-X_train.txt
            |-y_train.txt
```

2. `readAndMergeTrainingAndTestSets()`: this function will read the following files:
* __X_train.txt__ - contain the training set - into `trainX`
* __y_train.txt__ - contain the training labels - into `trainY`
* __subject_train.txt__ - contain the training subjects per row - into `trainSubject`
* __X_test.txt__ - contain the test set - into `testX`
* __y_test.txt__ - contain the test labels - into `testY`
* __subject_test.txt__ - contain the test subjects per row - into `testSubject`
  
After reading the files, the function will assign _subject_ as the column name for the datasets `trainSubject` and `testSubject`, and assign _label_ as the column name for the datasets `trainY`and `testY`.
  
  Will then column bind the 3 training datasets into `trainDS` and the 3 test datasets into `testDS`:
  
```
trainDS <- cbind(trainX, trainY, trainSubject)  
testDS <- cbind(testX, testY, testSubject)
```
  Then will use the `trainDS` and `testDS` and perform a row bind to merge the training and test data:
  
```
mergedDS <- rbind(trainDS, testDS)
```

   The `mergedDS` will be returned.
   
3. `extractMeanAndSTD(dataSet)`: this function receives as input the merged dataset created on the previous function. This will read the __features.txt__ file into `features`. From this `features` data the function will filter only the mean and standard deviantion measures - for this it uses the `grepl` function using the patterns "-mean()" or "-std()"
```
meanAndStd <- features[grepl("-(mean|std)\\(\\)", features$V2, perl = TRUE), ]
```
The input dataset has 563 columns (561 columns with measures plus the subject and label).
Using the `meanAnStd` dataset the script reduced the input dataset to 68 columns (66 measure columns for mean and std plus subject and label). The new dataset is called `reducedDS`. After the reducion, the script will use the varibles names for the 66 columns on `meanAnStd$V2` and update them to have descriptive name and then update the `reducedDS`column names with those. The rules to have a descriptive name are:
* "-" was removed
* "()" was removed
* starting "t" -> "time"
* starting "f" -> "frequency"
* "BodyBody" -> "body"
* "Acc" -> "accelerator"
* "Gyro" -> "gyroscope"
* "Mag" -> "magnitude"
* characters were converted to lowercase

the function will return the `reducedDS` with the new columns names updated.

4. `updateActivityNames(dataSet)`: this function receives the reduced dataset return by the previous function as input and will merge it with the dataset with the content from the __activity_labels.txt__ file. For the merge, the script uses the _label_ as the key from the input dataset and _V1_ as the key from the __activity_labels.txt__ dataset. Then a new column called _activity_ with the content on the _V2_ will be created and the columns _V2_ and _label_ will be dropped from the final and reduced dataset. 

5. `tidyDataSet(dataSet)`: this function receives as input the dataset generated on the previous function, and will `melt` the input dataset using _subject_ and _activity_ as ids and _feature_ will be the variable name. Then it will `group_by` _subject_, _activity_ and _feature_ to finalize with a  call to the `summarise` function with `mean(value)`. The return of this function will be the narrow tidy data. 

6. `writeTidyDataFile(tidyData, fileName)`: this function receives two input parameters:
* `tidyData`: the dataset with the narrow tidy dataset to be written into the file
* `filename`: filename that will be created with the tidy data
 
The function will check if the file exists locally and delete it if exists. Then will write the tidy dataset using `write.table` with the flag `row.name = FALSE` using the `filename` and the name of the output file. 


### Auxiliar Functions

* `readDataFile(fileName, ...)`: this function checks if the file exists and if it exists will read the file using `read.table` function and will pass any extra parameters `...` directly. The function will return a dataset. If the file doesn't exist the function will `stop` with a "file doesn't exist" message.

* `readTidyDataFile()`: this function will call the `readDataFile` function with the filename and the flag `header = TRUE`

### How to read the tidy data file generated by this script
Assuming the file is in the same folder as the run_analysis.R script and has the original name *tidyData.txt* you can call the function `readTidyDataFile()` to load the file

```
> tidyData <- readTidyDataFile()
[1] "Reading file  tidyData.txt"
> dim(tidyData)
[1] 11880     4
> head(tidyData, n = 2)
  subject activity                    feature mean.value.
1       1   LAYING timebodyaccelerometermeanx  0.22159824
2       1   LAYING timebodyaccelerometermeany -0.04051395
```

September 20, 2014
