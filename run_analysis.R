# Getting the list of files

path_rf <- file.path("C://Users//AnandVasumathi//Documents" , "UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)
files

## Read data from the files into the variables

# Read the activity files
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)

# Read the subject files
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)

# Read the features files
dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)

## Look at the properties of the above varibles
str(dataActivityTest)
str(dataActivityTrain)
str(dataSubjectTrain)
str(dataSubjectTest)
str(dataFeaturesTest)
str(dataFeaturesTrain)

## Step 1 : Merges the training and the test sets to create one data set

# 1a : Concatenate the data tables by rows
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

# 1b: Set names to variables
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

# 1c: Merge columns to get the data frame Data for all data
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)


## Step 2: Extracts only the measurements on the mean and standard deviation for each measurement

# 2a: Subset Name of Features by measurements on the mean and standard deviation
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

# 2b: Subset the data frame Data by seleted names of Features
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

# Check Step 2: Check the structures of the data frame Data
str(Data)


## Step 3: Uses descriptive activity names to name the activities in the data set

# 3a: Read descriptive activity names from "activity_labels.txt"
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)

# 3b: Factorise Variable activity in the data frame Data using descriptive activity names
Data$activity<-factor(Data$activity);
Data$activity<- factor(Data$activity,labels=as.character(activityLabels$V2))

# Check
head(Data$activity,30)

## Step 4: Appropriately labels the data set with descriptive variable names

# prefix t is replaced by time
# Acc is replaced by Accelerometer
# Gyro is replaced by Gyroscope
# prefix f is replaced by frequency
# Mag is replaced by Magnitude
# BodyBody is replaced by Body

names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

# Check step 4

names(Data)


## Step 5: Creates a second,independent tidy data set and ouput it

# In this part,a second, independent tidy data set will be created with the average of each variable 
# for each activity and each subject based on the data set in previous step.

library(plyr)
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)


## Prouduce Codebook

library(knitr)
knit2html("codebook.Rmd")