
library("data.table")
library("reshape2")

labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")[,2]
features <- read.table("./data/UCI HAR Dataset/features.txt")[,2]
MeanStd <- grepl("mean|std", features)

Xtest <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
ytest <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subjectTest <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
names(Xtest) <- features
Xtest <- Xtest[,MeanStd]

names(ytest) <- "activityID"
ytest$activityLabel <- labels[ytest$activityID]
names(subjectTest) <- "subject"
testData <- cbind(subjectTest, ytest, Xtest)

Xtrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
ytrain <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subjectTrain <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
names(Xtrain) <- features
Xtrain <- Xtrain[,MeanStd]

names(ytrain) <- "activityID"
ytrain$activityLabel <- labels[ytrain$activityID]
names(subjectTrain) <- "subject"
trainData <- cbind(subjectTrain, ytrain, Xtrain)

data <- rbind(testData, trainData)

meltData <- melt(data, id.vars = c("subject", "activityID", "activityLabel"),
                 measure.vars = setdiff(colnames(data), c("subject", "activityID", "activityLabel")) )

tidyData <- dcast(meltData, subject + activityLabel ~ variable, mean)

write.table(tidyData, file <- "./data/tidyData.txt")

