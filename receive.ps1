echo "s3-xxHash-transfer receive.ps1 version 2.0.0-beta"


# Lets check to make sure that mhl is properly installed

if ((Get-Command mhl.exe -ErrorAction SilentlyContinue) -eq $null)
    { throw "This script requires mhl.exe but it does not appear to be properly installed. Aborting. Please see https://mediahashlist.org/mhl-tool/ for more information." }

# Lets check to make sure that aws is properly installed
if ((Get-Command aws.exe -ErrorAction SilentlyContinue) -eq $null)
    { throw "This script requires aws.exe but it does not appear to be properly installed. Aborting. Please see https://aws.amazon.com/cli/ for more information." }

# Let's have the user specify from where on S3 they'll be downloading

$s3url = Read-Host "From where on S3 will you be downloading? Enter an S3 URL"

# Let's have the user specify exactly into which directory on the local system they want the data to go

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

echo "Into which local directory on your system are you downloading the data?"

$destinationLocalDirectory = Get-Folder

# Now $destinationLocalDirectory will work as the variable for the destination folder on the local system into which the data will go

# Let's now sync from the S3 bucket to the local system https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html

aws s3 sync $s3url $destinationLocalDirectory;

# Let's check to make sure that a .mhl file exists in the destination.

cd $destinationLocalDirectory

# If there are no MHL files in this directory, we'll throw an error.

if (((Get-ChildItem -Path $destinationLocalDirectory -filter *.mhl | Measure-Object | Select-Object -expandProperty Count) -eq 0))
    { throw "ERROR: The local directory does not seem to have an MHL file with which to verify the contents. The data integrity of the contents of this directory cannot be verified." }

# If there are more than one MHL files in the directory, we'll throw an error, because we don't know which MHL file to check.

elseif (((Get-ChildItem -Path $destinationLocalDirectory -filter *.mhl | Measure-Object | Select-Object -expandProperty Count) -gt 1))
    { throw "ERROR: There are more than one MHL files in the directory, so this shell script does not know which MHL to use to verify the contents of the directory. The data integrity of the contents of this directory cannot be verified." }

# If there's exactly one MHL file, let's grab the name of it and store that into a variable, and then verify the MHL file we found. Once the download has finished and the MHL file has been verified, let's let the user know that the data has been downloaded and verified.

else
    { $mhlFileName = gci *.mhl; echo "Verifying the 64-bit xxHash checksums. Please wait..." ; mhl verify -f $mhlFileName;
    if ($LASTEXITCODE -ne 0)
    { Exit-PSSession }
    else
    { echo "Success! The data from <$s3url> has been downloaded into $destinationLocalDirectory and has been verified." }}
   
Read-Host -Prompt "Press the Enter key to exit"   
