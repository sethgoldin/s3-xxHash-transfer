# s3-xxHash-transfer
Included in this repository are a couple of shell scripts that glue together the [MHL tool](https://github.com/pomfort/mhl-tool) and the [AWS CLI](https://docs.aws.amazon.com/cli/index.html). This allows for a workflow that can transfer enormous amounts of data through an [S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html) with extremely fast checksum verification. These scripts ensure bulletproof data integrity, verifying every single bit, with blazingly fast speed afforded by 64-bit xxHash and AWS S3.

## Workflow

1. On the "source" computer, run `$ sh send.sh`. `sudo` privilege is _not_ required. `send.sh` will prompt for the source destination directory, "seal" the contents of the directory with 64-bit xxHash checksums, prompt for the name of a new S3 bucket, automatically make that bucket, and then ingest the entire directory into the bucket.
2. On the "destination" computer, run `$ sh receive.sh`. `sudo` privilege is _not_ required. `receive.sh` will prompt for the name of the S3 bucket that had been created by `send.sh`, prompt for the local directory path into where the data will be downloaded, and then will automatically download all data from the S3 bucket and verify the 64-bit xxHash checksums for every single file.

The MHL file generated on the sending side and verified on the receiving side functions as as a kind of manifest for the data, which ensures end-to-end data integrity. These scripts use the extremely fast [64-bit xxHash hashing algorithm](https://github.com/Cyan4973/xxHash).

## System requirements
- The [MHL tool](https://github.com/pomfort/mhl-tool) should be installed into your `$PATH`. On CentOS 7.7 and Fedora 31, after compiling from source so that `mhl` will call the properly installed versions of the OpenSSL libraries, it is [recommended](https://unix.stackexchange.com/questions/8656/usr-bin-vs-usr-local-bin-on-linux/8658#8658) to manually move the `mhl` binary into `/usr/local/bin`, since the program will not be managed by the distribution's package manager.
- The [`.pkg` installer from Pomfort]() will install a precompiled binary for macOS into `/usr/local/bin`, which is included by default in macOS's `$PATH`.
- On Windows, download and extract [the precompiled binary from Pomfort](http://download.pomfort.com/mhl-tool.zip), and then copy or move `mhl.exe` into `C:\Windows\System32\`, which should already be included by default in the `Path` system environment variables.
- The [AWS CLI](https://aws.amazon.com/cli/) should be installed and configured on both endpoints, with:
  - The sending IAM user having at least full S3 write access on the AWS account
  - The receiving IAM user having at least full S3 read access on the AWS account
  - Both endpoints connected to the same [region](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions)
  - The command output format set to [text](https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-output.html#text-output)

## Compatible platforms
Release 0.0.3 has tested on Linux and macOS endpoints, specifically on:
- Fedora 31
- CentOS 7.7
- macOS Catalina 10.15.3
- Windows 10 1909

There aren't too many dependencies, so these scripts seem like they should work flawlessly on other major Linux distributions as well, though no other distributions have been tested.

Both the MHL tool and the AWS CLI are available across Linux, macOS, and Windows, so the same `bash` scripts work identically on Linux and macOS.

Though `zsh` is now the default shell on macOS Catalina, the script runs in `bash`, as specified from the first line of the script: `#!/bin/bash`. For now, Catalina still ships `bash`. Whether future releases of macOS will contain `bash` is an open question. The scripts may need to be modified in the future to run natively in `zsh`, but at least for now, on Catalina, `bash` works.

The [Windows command shells](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/windows-commands), both the Command shell and PowerShell, are quite a bit different than `bash`, so porting to Windows will take a bit more effort, and will come in a future release.
