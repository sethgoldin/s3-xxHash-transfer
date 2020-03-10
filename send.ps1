# Lets check to make sure that mhl is properly installed
if (Get-Command mhl -errorAction Stop)
{}

# Lets check to make sure that aws is properly installed
if (Get-Command aws -errorAction Stop)
{}

# Let's have the user specify which source folder should be uploaded into S3

$sourceLocalDirectory = Read-Host "From which directory on your local system are you uploading into AWS S3? Please enter the absolute path and escape any spaces if necessary: " 

# Now $sourceLocalDirectory will work as the variable for the source folder from the local system that will be ingested into S3

# Let's prompt the user for the name of the S3 bucket

$s3BucketName = Read-Host "What should the name of the AWS S3 bucket be? The name of the bucket should take the form <s3://bucket-name> with only lowercase letters and hyphens, but should use NO uppercase letters nor spaces: "

# Now $s3BucketName will work as the variable for the name of the S3 bucket