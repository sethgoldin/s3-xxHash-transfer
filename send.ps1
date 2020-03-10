# Lets check to make sure that mhl is properly installed
if (Get-Command mhl -errorAction Stop)
{}

# Lets check to make sure that aws is properly installed
if (Get-Command aws -errorAction Stop)
{}

# Let's have the user specify which source folder should be uploaded into S3

$sourceLocalDirectory = Read-Host "From which directory on your local system are you uploading into AWS S3? Please enter the absolute path and escape any spaces if necessary" 

# Now $sourceLocalDirectory will work as the variable for the source folder from the local system that will be ingested into S3

# Let's prompt the user for the name of the S3 bucket

$s3BucketName = Read-Host "What should the name of the AWS S3 bucket be? The name of the bucket should take the form <s3://bucket-name> with only lowercase letters and hyphens, but should use NO uppercase letters nor spaces"

# Now $s3BucketName will work as the variable for the name of the S3 bucket

# Let's make the S3 bucket first, because this is probably the most likely source of an error. According to Amazon, "An Amazon S3 bucket name is globally unique, and the namespace is shared by all AWS accounts. This means that after a bucket is created, the name of that bucket cannot be used by another AWS account in any AWS Region until the bucket is deleted. You should not depend on specific bucket naming conventions for availability or security verification purposes."

aws s3 mb $s3BucketName;

# Let's cd into the source directory, and then execute mhl seal for the whole directory, with the xxHash algorithm, which is nice and fast
#	N.B. mhl must be run from inside the source directory, so best practice is to cd in to the directory right within the shell script itself: https://stackoverflow.com/a/10566581/

cd $sourceLocalDirectory;

mhl seal -t xxhash64 *;

# We're using the 64-bit xxHash algorithm specifically, because it's fast and reliable https://github.com/Cyan4973/xxHash

# Now that we've sealed the contents of the folder, let's sync the data from the local folder into the bucket https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html# Now that we've sealed the contents of the folder, let's sync the data from the local folder into the bucket https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html# Now that we've sealed the contents of the folder, let's sync the data from the local folder into the bucket https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html

aws s3 sync "$sourceLocalDirectory" $s3BucketName;

# Once the upload has finished, let's let the user know that the data has been sealed and ingested.

echo "The data from <$sourceLocalDirectory> has been sealed with xxHash checksums and has been ingested into the AWS S3 bucket named <$s3BucketName>."
