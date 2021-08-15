# gcpvision-pdf2json
This is a shell script used to convert pdf into json

## Instructions for running on Windows 
- Download and install Cygwin. Ensure package "curl" is also installed
- Install Google SDK. Refer https://cloud.google.com/sdk/docs/install
- Setup vision api by following this link - https://cloud.google.com/vision/docs/setup#linux-or-macos


Limitations :
- Create the bucket in GCP manually before running the shell scripts
- The script does not delete the pdf file uploaded or the transformed json. Delete them manually.
- The script works with only *one* file right now. It renames the original file with a timestamp. Manully rename them again if required. 
