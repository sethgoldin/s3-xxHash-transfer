#!/bin/bash

# Here's where the user is going to specify what source folder should be uploaded into S3

read -e -p "From what directory do you want to upload data into S3? Please enter the absolute path and escape any spaces if necessary: " sourceLocalDirectory

# Now $sourceLocalDirectory will work as the variable for the source folder from the local system that will be ingested into S3

# Let's prompt the user for the name of the S3 bucket

read -e -p "What should the name of the S3 bucket be? The name of the bucket should take the form: s3://bucket-name with no uppercase letters and no spaces: " s3BucketName

# Now $s3BucketName will work as the variable for the name of the S3 bucket

# Let's make the S3 bucket first, because this is probably the most likely source of an error. According to Amazon, "An Amazon S3 bucket name is globally unique, and the namespace is shared by all AWS accounts. This means that after a bucket is created, the name of that bucket cannot be used by another AWS account in any AWS Region until the bucket is deleted. You should not depend on specific bucket naming conventions for availability or security verification purposes."

aws s3 mb $s3BucketName &&

# Let's cd into the source directory, and then execute mhl seal for the whole directory, with the xxHash algorithm, which is nice and fast
#	N.B. mhl must be run from inside the source directory, so best practice is to cd in to the directory right within the shell script itself: https://stackoverflow.com/a/10566581/

cd "$sourceLocalDirectory"

mhl seal -t xxhash * &&
# Let's sync the data from the local folder into the bucket

aws s3 sync "$sourceLocalDirectory" $s3BucketName &&

# Whatever the program displays will just get passed through into the script: https://unix.stackexchange.com/a/266111/

# Let's let the user know that the data has been sealed and ingested.

echo "The data from <$sourceLocalDirectory> has been sealed with xxHash checksums and and ingested into the S3 bucket named <$s3BucketName>."
