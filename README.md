---
title: "How run_analysis works on data"
output: html_document
---

First we load the data into the directory "./data/UCI HAR Dataset". The data is the result of the experiments carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING UPSTAIRS, WALKING DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

We read each data saved in the txt files "activity labels.txt" and "features.txt" as two rows called labels and features. These would describe the activity names as a factor with six levels and the features which have been measured in the "X test.txt" with activity factors in "y test.txt" and test subjects in "subject test.txt"


```r
library("data.table"); library("reshape2")
labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")[,2]
features <- read.table("./data/UCI HAR Dataset/features.txt")[,2]
```

We read the data in "X test.txt", "y test.txt" and "subject test.txt". The features can be used to name the columns of data frame in Xtest. 


```r
Xtest <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
ytest <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subjectTest <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
names(Xtest) <- features
```

As we only need the measurements on the mean and standard deviation for each measurement, we continue with narrowing our data frame Xtest to only columns including either mean or standard deviation.  


```r
MeanStd <- grepl("mean|std", features)
Xtest <- Xtest[,MeanStd]
```

Then we can bind three data frames subjectTest, ytest and Xtest to create a testData set having our data for test subjects in one data frame. We also have added column names for ytest and subjectTest and added the activity name to each corresponding activity factor in ytest.



```r
names(ytest) <- "activityID"
ytest$activityLabel <- labels[ytest$activityID]
names(subjectTest) <- "subject"
testData <- cbind(subjectTest, ytest, Xtest)
```

Next we repeat the exact same process with the training data sets.


```r
Xtrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
ytrain <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subjectTrain <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
names(Xtrain) <- features
Xtrain <- Xtrain[,MeanStd]

names(ytrain) <- "activityID"
ytrain$activityLabel <- labels[ytrain$activityID]
names(subjectTrain) <- "subject"
trainData <- cbind(subjectTrain, ytrain, Xtrain)
```

The last step in this process is to row bind the test and train data sets and use the melt and dcast functions from "reshape2" package to create a new tidy data set with the average of each variable for each activity and each subject.
The result has been written in "./data/tidyData.txt".


```r
data <- rbind(testData, trainData)

meltData <- melt(data, id.vars = c("subject", "activityID", "activityLabel"),
                 measure.vars = setdiff(colnames(data), c("subject", "activityID", "activityLabel")) )

tidyData <- dcast(meltData, subject + activityLabel ~ variable, mean)

write.table(tidyData, file <- "./data/tidyData.txt")
```


