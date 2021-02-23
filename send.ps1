echo "s3-xxHash-transfer send.ps1 version 2.0.0"


# Lets check to make sure that mhl is properly installed

if ((Get-Command mhl.exe -ErrorAction SilentlyContinue) -eq $null)
    { throw "This script requires mhl.exe but it does not appear to be properly installed. Aborting. Please see https://mediahashlist.org/mhl-tool/ for more information." }

# Lets check to make sure that aws is properly installed
if ((Get-Command aws.exe -ErrorAction SilentlyContinue) -eq $null)
    { throw "This script requires aws.exe but it does not appear to be properly installed. Aborting. Please see https://aws.amazon.com/cli/ for more information." }

# Let's have the user specify which source folder should be uploaded into S3

Function Get-Folder($initialDirectory)

{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder"
    $foldername.rootfolder = "MyComputer"

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}

echo "From which directory on your local system are you uploading into AWS S3?"

$sourceLocalDirectory = Get-Folder

# Now $sourceLocalDirectory will work as the variable for the source folder from the local system that will be ingested into S3

# Let's prompt the user for the S3 URL

$s3url = Read-Host "What should the S3 URL be?"

# Now $s3url will work as the variable for the S3 URL

# Let's cd into the source directory, and then execute mhl seal for the whole directory, with the xxHash algorithm, which is nice and fast
#	N.B. mhl must be run from inside the source directory, so best practice is to cd in to the directory right within the shell script itself: https://stackoverflow.com/a/10566581/

cd $sourceLocalDirectory;

if ($LASTEXITCODE -ne 0)
    { Exit-PSSession }

echo "Sealing the contents of the directory with 64-bit xxHash checksums. Please wait...";

mhl seal -t xxhash64 *;

if ($LASTEXITCODE -ne 0)
    { Exit-PSSession }

# We're using the 64-bit xxHash algorithm specifically, because it's fast and reliable https://github.com/Cyan4973/xxHash

# Now that we've sealed the contents of the folder, let's sync the data from the local folder into the bucket https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html# Now that we've sealed the contents of the folder, let's sync the data from the local folder into the bucket https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html# Now that we've sealed the contents of the folder, let's sync the data from the local folder into the bucket https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html

aws s3 sync "$sourceLocalDirectory" $s3url;

if ($LASTEXITCODE -ne 0)
    { Exit-PSSession }

# Once the upload has finished, let's let the user know that the data has been sealed and ingested.

echo "Success! The data from <$sourceLocalDirectory> has been sealed with 64-bit xxHash checksums and has been ingested into AWS S3 at <$s3url>."

Read-Host -Prompt "Press the Enter key to exit"
