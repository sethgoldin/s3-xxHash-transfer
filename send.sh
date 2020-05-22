#!/bin/bash

echo "s3-xxHash-transfer send.sh version 2.0.0-beta"

# Lets check to make sure that mhl is properly installed https://stackoverflow.com/a/677212/

command -v mhl >/dev/null 2>&1 || { echo >&2 "This script requires mhl but it does not appear to be properly installed. Aborting. Please see https://mediahashlist.org/mhl-tool/ for more information."; exit 1; }

# Lets check to make sure that aws is properly installed https://stackoverflow.com/a/677212/

command -v aws >/dev/null 2>&1 || { echo >&2 "This script requires aws but it does not appear to be properly installed. Aborting. Please see https://aws.amazon.com/cli/ for more information."; exit 1; }

# Let's have the user specify which source folder should be uploaded into S3

read -e -p "From which directory on your local system are you uploading into AWS S3? Please enter the absolute path and escape any spaces if necessary: " sourceLocalDirectory

# Now $sourceLocalDirectory will work as the variable for the source folder from the local system that will be ingested into S3

# Let's prompt the user for the S3 URL

read -e -p "What should the S3 URL be? " s3url

# Now $s3url will work as the variable for the S3 URL

# Let's cd into the source directory, and then execute mhl seal for the whole directory, with the xxHash algorithm, which is nice and fast
#	N.B. mhl must be run from inside the source directory, so best practice is to cd in to the directory right within the shell script itself: https://stackoverflow.com/a/10566581/

cd "$sourceLocalDirectory"

# We're putting that variable inside double quotes, just in case the path has any spaces https://stackoverflow.com/questions/43787476/how-to-add-path-with-space-in-bash-variable/#43793896

echo "Sealing the contents of the directory with 64-bit xxHash checksums. Please wait..."

mhl seal -t xxhash64 * &&

# We're using the 64-bit xxHash algorithm specifically, because it's fast and reliable https://github.com/Cyan4973/xxHash

# Now that we've sealed the contents of the folder, let's sync the data from the local folder into the bucket https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html

aws s3 sync "$sourceLocalDirectory" $s3url &&

# Whatever the program displays will just get passed through into the script https://unix.stackexchange.com/a/266111/

# Once the upload has finished, let's let the user know that the data has been sealed and ingested.

echo "The data from <$sourceLocalDirectory> has been sealed with 64-bit xxHash checksums and has been ingested into AWS S3 at <$s3url>."
