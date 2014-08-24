## FILE:  run_analysis.R
## CREATED BY:  SHLewis
## Programming Assignment for Getting & Cleaning Data, August 2014 offering
## Coursera course presented by Johns Hopkins

################################################################################
## SCRIPT PURPOSE: This script reads files from the "Human Activity Recognition
## Using Smartphones" data set; the files are combined and manipulated
## to produce a tidy data set providing the averages of each variable
## of interest (i.e., mean and standard deviation variables), for each unique
## subject-activity combination.
##
## INPUT:  The Human Activity Recognition (HAR) Data Set must be unzipped in the
## R working directory, from which this R script is run.  Here is link to the 
## data set zip file:
##    https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
## A full description of the data set is available at the site where the data 
## was obtained: 
##    http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
## 
## OUTPUT:  The tidy data set produced is output to file harmean.txt in the R 
## working directory.
##
## OVERVIEW: Here is an overview of steps taken in this script to go from raw
## data to the output.
##    1. Read and prepare common files... i.e., files that relate to both  
##       test set and training set. These are the file of descriptive 
##       activity labels and the file listing the feature vector variables. 
##       The file of feature vector variables is subsetted to include only
##       the mean and standard deviation variables of interest.  The variables
##       of interest are the 66 variable names that contain either 
##       "mean(" or "std(".
##    2. Read in and tidy the test and training data of interest:
##          a. Read in test and train data files
##          b. Exclude columns not of interest (i.e.,  keep only columns 
##             related to variables of interest identified in 1 above).
##          c. Set column names to descriptive variable names (from the file
##             of feature vector variables in 1 above.)
##          d. Add subjectID column and activityID column to each 
##             test and train data (obtained from y_test, y_train, subject_test
##             and subject_train text files).
##          e. Combine test and train data into one data frame (called har).
##    3. Create the final tidy data set... create data frame harmean, with the  
##       mean of each har variable for each unique subjectID and activityID 
##       combination. 
##          a. Use aggregate function by subjectID, activityID
##          b. Add activity label column to harmean data frame (based on
##             activityID)
##          c. Drop activityID column and re-order the remaining columns
##             to put subjectID and activity first
##          b. Sort data by subjectID then activity.
##    4. Output tidy data harmean to file harmean.txt
################################################################################

library(plyr)
library(stringr)

### Read and prepare common files that relate to both test set and train set

# read activities_labels.txt, which gives the activity name related to 
# each activity id found in y_test.txt and y_train.txt
activities <- read.table("./UCI HAR Dataset/activity_labels.txt",
                         col.names = c("activityID", "activity"))

# read features.txt, which gives the list of variables of each feature vector
features <- read.table("./UCI HAR Dataset/features.txt", 
                       col.names = c("findex", "feature"))
# reduce the list of features to only the mean and standard deviation (std) 
# variables
features <- subset(features, 
                   str_detect(features$feature, "mean\\(") | 
                         str_detect(features$feature, "std\\("))
# Change feature names to be valid variable names 
features$feature <- str_replace(features$feature, "\\(\\)", "")
features$feature <- str_replace(features$feature, "-mean", "Mean")
features$feature <- str_replace(features$feature, "-std", "Std")
features$feature <- str_replace(features$feature, "-", "")

### Read in and tidy each test and train data sets

# read in test and train Human Activity Recognition (HAR) feature variables
testhar <- read.table("./UCI HAR Dataset/test/X_test.txt")
trainhar <- read.table("./UCI HAR Dataset/train/X_train.txt")

# reduce columns in test and train data frames to only the meand and std
# features identified in features
testhar <- testhar[features$findex]
trainhar <- trainhar[features$findex]

# set column names for test and train data to the feature variable names
# given in features.txt
names(testhar) <- features$feature
names(trainhar) <- features$feature

# read in list of subject IDs that corresponds to the har feature variables
testsubjects <- read.table("./UCI HAR Dataset/test/subject_test.txt",
                           col.names = "subjectID")
trainsubjects <- read.table("./UCI HAR Dataset/train/subject_train.txt",
                           col.names = "subjectID")

# read in list of Activity IDs that corresponds to the har feature variables
testactivities <- read.table("./UCI HAR Dataset/test/y_test.txt",
                             col.names = "activityID")
trainactivities <- read.table("./UCI HAR Dataset/train/y_train.txt",
                             col.names = "activityID")

# add subjectID column and activityID column to each test and train data
testhar$subjectID <- testsubjects$subjectID
trainhar$subjectID <- trainsubjects$subjectID
testhar$activityID <- testactivities$activityID
trainhar$activityID <- trainactivities$activityID

### Combine test and train data into har data frame, then 
# remove test and train data frames from the environment
har <- rbind(testhar, trainhar)
remove(testhar, trainhar)

#### uncomment for visibility to intermediate view of data ####
# Sort the har data frame by subjectID, then activity 
#### har <- arrange(har, subjectID, activityID)
# take a look at some of the data to see how the data frame is looking.
#### har[1:20, c(1, 2, 67:68)]

### Create the final tidy data set, data frame harmean, with the mean of each 
# har variable for each unique subjectID and activity combination; 
# only the original har columns are included (excluding columns
# added by the aggregate function)
harmean <- aggregate(har, by = list(har$subjectID, har$activityID), FUN = mean)
harmean <- harmean[, c(69, 70, 3:68)]  # put subjectID & activityID as col 1:2

# add activity label column to harmean data frame, based on activityID match
# to the activities data frame (previously loaded from activity_labels.txt)
harmean <- merge(harmean, activities)

# Drop activityID column and re-order the remaining columns to put
# subjectID and activity first
harmean <- harmean[, c(2, 69, 3:68)]
harmean <- arrange(harmean, subjectID, activity) # sort result

### Output tidy data harmean to file harmean.txt
write.table(harmean, file = "harmean.txt", row.names = FALSE)

#### uncomment to read back in harmean.txt into another data frame
#### harmean1 <- read.table("harmean.txt", header = TRUE, check.names = FALSE)
