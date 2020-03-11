#!/bin/bash

echo "s3-xxHash-transfer receive.sh version 0.0.4"

# Lets check to make sure that mhl is properly installed https://stackoverflow.com/a/677212/

command -v mhl >/dev/null 2>&1 || { echo >&2 "This script requires mhl but it does not appear to be properly installed. Aborting. Please see https://mediahashlist.org/mhl-tool/ for more information."; exit 1; }

# Lets check to make sure that aws is properly installed https://stackoverflow.com/a/677212/

command -v aws >/dev/null 2>&1 || { echo >&2 "This script requires aws but it does not appear to be properly installed. Aborting. Please see https://aws.amazon.com/cli/ for more information."; exit 1; }

# Let's have the user specify from which bucket they'll be downloading

read -e -p "What is the name of the AWS S3 bucket from which you'll be downloading the data? The name of a bucket takes the form <s3://bucket-name> with only lowercase letters and hyphens, but uses NO uppercase letters nor spaces: " s3BucketName

# Let's have the user specify exactly into which directory on the local system they want the data to go

read -e -p "Into which local directory on your system are you downloading the data? Please enter the absolute path and escape any spaces if necessary: " destinationLocalDirectory

# Now $destinationLocalDirectory will work as the variable for the destination folder on the local system into which the data will go

# Let's now sync from the S3 bucket to the local system https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html

aws s3 sync $s3BucketName "$destinationLocalDirectory" &&

# Let's check to make sure that a .mhl file exists in the destination.

cd "$destinationLocalDirectory"

# We're putting that variable inside double quotes, just in case the path has any spaces https://stackoverflow.com/questions/43787476/how-to-add-path-with-space-in-bash-variable/#43793896

# Now let's see if the root level of the folder contains exactly one MHL file https://stackoverflow.com/questions/3856747/check-whether-a-certain-file-type-extension-exists-in-directory/3856879#3856879

count=`ls -1 *.mhl 2>/dev/null | wc -l`
if [ $count = 1 ];

# If it does contain exactly one MHL file, we'll grab the name of that one filename and set it as the $mhlFileName variable. We'll use the `find` command https://stackoverflow.com/a/5927391/

# We're going to use process substitution to set the results of the `find` command to a variable, $mhlFileName https://askubuntu.com/a/1022178/ 

# We're going to use the `-maxdepth 1` flag in the `find` command to make sure that we're only grabbing the very root level of the folder, since there might be other MHL files down in the depths of subdirectories https://stackoverflow.com/a/3925376/

then 
	mhlFileName=$(find $destinationLocalDirectory -maxdepth 1 -type f -name "*.mhl");

# If there are no MHL files in this directory, we'll throw an error.

elif [ $count = 0 ];
then
	echo "ERROR: The local directory does not seem to have an MHL file with which to verify the contents. The data integrity of the contents of this directory cannot be verified."; exit 1;

# If there are more than one MHL files in this directory, we don't know which one to use to verify, so we'll throw an error.

elif [ $count > 1 ];
then
	echo "ERROR: There are more than one MHL files in the directory, so this script does not know which MHL to use to verify the contents of the directory. The data integrity of the contents of this directory cannot be verified."; exit 1;
fi 

# Let's go ahead and verify the MHL file we found

# We're incuding the variable in double quotes, in case there are spaces in the filename https://stackoverflow.com/questions/43787476/how-to-add-path-with-space-in-bash-variable/#43793896

mhl verify -f "$mhlFileName" &&

# Whatever the mhl binary displays will just get passed through into the script: https://unix.stackexchange.com/a/266111/

# Once the download has finished and the MHL file has been verified, let's let the user know that the data has been downloaded and verified.

echo "The data from the AWS S3 bucket named <$s3BucketName> has been downloaded into $destinationLocalDirectory and has been verified."
