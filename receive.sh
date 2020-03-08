#!/bin/bash

# Lets check to make sure that mhl is properly installed https://stackoverflow.com/a/677212/

command -v mhl >/dev/null 2>&1 || { echo >&2 "This script requires mhl but it does not appear to be properly installed. Aborting."; exit 1; }

# Lets check to make sure that aws is properly installed https://stackoverflow.com/a/677212/

command -v aws >/dev/null 2>&1 || { echo >&2 "This script requires aws but it does not appear to be properly installed. Aborting."; exit 1; }

# Let's have the user specify from what bucket they'll be downloading

read -e -p "What is the name of the S3 bucket from which you'll be downloading? The name of the bucket should take the form <s3://bucket-name> with only lowercase letters and hyphens, but should use NO uppercase letters nor spaces: " s3BucketName

# Let's have the user specify exactly into what directory on the local system they want the data to go

read -e -p "Into what directory do you want the data to download? Please enter the absolute path and escape any spaces if necessary: " destinationLocalDirectory

# Now $destinationLocalDirectory will work as the variable for the destination folder on the local system where the data will go

# Let's now sync from the S3 bucket to the local system

aws s3 sync $s3BucketName "$destinationLocalDirectory" &&

# Let's check to make sure that a .mhl file exists in the destination.

cd "$destinationLocalDirectory"

count=`ls -1 *.mhl 2>/dev/null | wc -l`
if [ $count = 1 ];
then 
	mhlFileName=$(find $destinationLocalDirectory -maxdepth 1 -type f -name "*.mhl");
elif [ $count = 0 ];
then
	echo "ERROR: The local directory does not seem to have an MHL file with which to verify the contents. The data integrity of the contents of this directory cannot be verified."; exit 1;
elif [ $count > 1 ];
then
	echo "ERROR: There are more than one MHL files in the directory, and this script does not know which MHL to use to verify the contents of the directory. The data integrity of the contents of this directory cannot be verified."; exit 1;
fi 

# cd into the $destinationLocalDirectory and verify the MHL file


mhl verify -f "$mhlFileName" &&

# Whatever the program displays will just get passed through into the script: https://unix.stackexchange.com/a/266111/

# Once the download has finished and the MHL file has been verified, let's let the user know that the data has been downloaded and verified.

echo "The data from the AWS S3 bucket named <$s3BucketName> has been downloaded into $destinationLocalDirectory and has been verified by checking xxHash checksums."
