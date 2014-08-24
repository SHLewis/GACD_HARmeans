# Script run_analysis.R
By SHLewis<br>
Course Project for Getting & Cleaning Data, August 2014 offering<br>
Coursera course presented by Johns Hopkins

## Script Overview 

This script reads files from the *Human Activity Recognition Using Smartphones Data Set* Version 1.0 [citation below].  Script `run_analysis.R` combines and manipulates the data set files to produce a tidy data file with summary data of interest.  The data of interest from the original data set are the mean and standard deviation for each measurement.  The output tidy data gives the averages of each of those mean and standard deviation variables for each unique subject-activity combination. 

**Citation:** Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. *Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine*. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012


## Input

The *Human Activity Recognition (HAR) Using Smart Phones* Data Set must be unzipped in the R working directory.  Here is link to the data set zip file:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

A full description of the data set is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Additional important information on the data set is provided in the `README.txt` and `features_info.txt` files found in the zip file referenced above.  

Unzipping the data set zip file will create folder `UCI HAR DATASET` with a file structure under it.  Here are the folders and files used by script `run_analysis.R`:

    UCI HAR Dataset
        activity_labels.txt
        features.txt
        test
            subject_test.txt
            X_test.txt
            y_test.txt
        train
            subject_train.txt
            X_train.txt
            y_train.txt

The set of `test` files and set of `train` files each reflects data related to a subset of the subjects involved in the experiment.  For the purposes of this script, the split of subjects between test and training groups is not relevant.  Thus, script `run_analysis.R` combines the data from both groups and does not retain any link of subjects to the group assigned in the original data.

## Output

The script outputs the resulting tidy data set to file `harmean.txt` in the R working directory.  If file `harmean.txt` already exists, it will be overwritten without warning.

As indicated in the Script Overview section above, the output tidy data gives the averages of each variable of interest for each unique subject-activity combination.  The data of interest from the original data set are the variables giving mean and standard deviation for each measurement. The **codebook** for `harmean.txt` identifies the original variable associated with each column in `harmean.txt`.

## Process Description

Here a description of how script `run_analysis.R` uses the input data to create the output file.

#### PART A. Read in and prepare common files 
The common files are those that relate to both the test data set and the training data set. These are the file of descriptive activity labels (`activity_labels.txt`) and the file listing the feature vector variables (`features.txt`).  Detail steps:

1. Read in `activity_labels.txt` to data frame `activities`.
2. Read in `features.txt` to data frame `features`.
3. Set `features` to a subset of itself, to include only the mean and standard deviation variables of interest.  The variables of interest are the 66 variable names that contain either **mean(** or **std(**.  Other variable names that contain **Mean** are not included, as those are averages of the signals in a signal window sample and are not of interest for this exercise (per my interpretation of the assignment specifications).
4. Change feature names in `features` to be valid variable names (removing special characters).

#### PART B. Read in, process and tidy the test and training data

1. Read in test and train feature vector files, `X_test.txt` and `X_train.txt`, into data frames `testhar` and `trainhar`, respectively.
2. Exclude columns from `testhar` and `trainhar` that are not of interest (i.e., keep only columns related to variables idenified in `features`, per PART A, step 3 above).
3. Set column names in `testhar` and `trainhar` to descriptive variable names (using feature names in `features` built out in PART A, step 3 above).
4. Read in files `subject_test.txt` and `subject_train.txt` (subject IDs for test and train feature vectors).
5. Read in files `y_test.txt` and `y_train.txt` (activity IDs for test and train feature vectors).
6. Add `subjectID` column and `activityID` column to data frames `testhar` and `trainhar`.
7. Combine data frames `testhar` and `trainhar` into one data frame, `har`.

#### PART C. Create and output the final tidy data set, harmean

Per the following detail steps, create data frame `harmean`, with the mean of each `har` variable for each unique `subjectID` and `activityID` combination.

1. Use `aggregate` function on data fram `har` to calculate the mean for each variable, grouping data by `subjectID` and `activityID`, assigning the result to data frame `harmean` (thereby creating data frame `harmean`).
2. Use `merge` function to add the activity label column, `activity` to data frame `harmean`, based on `activityID` match to data frame `activities`.
3. Move `subjectID` and `activity` columns to be columns 1 and 2 in `harmean` and drop unneeded columns (i.e., drop the two columns added by the `aggregate` function and `activityID` column).
4. Use `write.table` to output tidy data from `harmean` to file `harmean.txt`.  If file `harmean.txt` already exists in the working directory, it will be overwritten without warning.