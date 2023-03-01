## Instance Export Power Shell

At DevResults we value the concept that the data is yours and you have rights of getting snapshots of it at anytime. For that reason, we have created a tool to make it possible for you to export and save all data you have at DevResults on your own machines.

In order to use it, you should:

1. Download the [InstanceExport.ps1](https://raw.githubusercontent.com/DevResults/DevResultsTools/main/InstanceExport/PowerShell/InstanceExport.ps1) PowerShell script available in this repo to your machine. One way to do this is to right click the link to the file name in the previous sentence and choose "Save link as..." to produce a save dialog box.

2. Reach out to us at help@devresults.com to request an Instance Export Manifest.

3. Save the manifest file in the same directory/folder you have saved the powershell script. It's important to save the file in the JSON format and that you remember what you named the file. In this tutorial the name we used is _manifest.json_.

4. Open a new command line interface (CLI) prompt that supports using of PowerShell commands (depending on your organizational IT policies, you may need to open an elevated/administator prompt, e.g. by right clicking on the Powershell icon and choosing "Run as administrator"). If you don't have PowerShell installed you can follow instructions at [Installing Power Shell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1).

5. Navigate to the directory you have saved the InstanceExport.ps1 and the JSON manifest file.

   e.g.: `cd C:\Users\MyUser\InstanceExport`

6. In the cli prompt type the following command. **Be very careful not to click inside the cli prompt while it's running, or it may go into "select mode" and pause.**

   `.\InstanceExport`

The process will prompt to you the mandatory fields to be typed in your screen `$manifestFilePath`, `$exportFilePath`, `$userName` and `$password`. Because you navigated to the directory/folder in step 5, you do not need to enter the full path, just the file names (see example below).

<img width="668" alt="image" src="https://user-images.githubusercontent.com/4453639/189958873-5a325524-3ec9-42da-932a-a090e99f37b0.png">

It will run automatically after you enter the fields and it will prompt the progress of your data been exported by each available category. When all is finished you should see the message "Exporting Instance finished".

The created power shell script has five parameters that are explained below:

- manifestFilePath: Path (or just file name, if same directory) of the manifest file you have downloaded using step 2, e.g. `C:\Users\MyUser\InstanceExport\manifest.json`.
- exportFilePath: Path (or just file name, if same directory) to create a folder for the exported files, e.g. `C:\Users\MyUser\InstanceExport\2021_Export\`; you do not need to create this folder manually, the script will do so for you.
- userName: Your username (work email) for login at DevResults, e.g. `first.last@org.org`.
- password: Your password for login at DevResults or API Key's Secret.
- overwrite: Optional parameter to inform if you want to overwrite files that already exist and replace them. If you don't use the value of it will be false, which means that if a file already exists in the exportFilePath it will be skipped.

### Troubleshooting

Below you will find examples of the kinds of error messages you can encounter when running the export script. While the examples focus on documents and folders, these errors can occur anywhere user-named items (data tables, photos, etc.) are found in the database. We offer potential solutions, but note that **in most cases you will need to request a new manifest file before you re-run the script.**

```
An error occurred
Error occurred when extracting data from /api/awards/123/documents/Project name that is very long/Quarterly and Annual Report/Q04 Reporting submissions 2019/Annual Workplan Progress Review/A_very_long_file_name_that_will_cause_exception_v1.xlsx
StatusCode:
Url: /api/awards/123/documents/Project name that is very long/Quarterly and Annual Report/Q04 Reporting submissions 2019/Annual Workplan Progress Review/A_very_long_file_name_that_will_cause_exception_v1.xlsx
StatusDescription:
```

This error message means the Instance Export script found the data on our servers but something is wrong with the file path. For example, some versions of PowerShell cannot handle long file names or long path names. 

**Recommendation**: install PowerShell 7 (64 bit version) the accomodate longer file/path names. You may need to rename the file after the export run if your are using Windows OS.

```
An error occurred
Error occurred when extracting data from /api/awards/123/documents/Evaluation/Folder Name with ’ invalid character/My file for reports on May 2018.docx
StatusCode: 500
Url: /api/awards/123/documents/Evaluation/Folder Name with ’ invalid character/My file for reports on May 2018.docx
StatusDescription: Internal Server Error
```

This error message means that the Instance Export script found but was not able to download the file due an invalid or reserved character present in the folder path or file name. 

**Recommendation**: change the name of the file or folder and remove any special characters. Known problematic characters include but are not limited to: `<>:"/\|?*’¿™[]`. Other characters from non-Latin scripts or currency symbols can also cause issues.

```
An error occurred
Error occurred when extracting data from /api/awards/123/documents/Evaluation/FileName with a ’ character that may be ´ invalidçã£.pptx
StatusCode: 404
Url: /api/awards/123/documents/Evaluation/FileName with a ’ character that may be ´ invalidçã£.pptx
StatusDescription: Not Found
```

This error message means that the Instance Export script was not able to find the data/file to be exported. This can occur in two situations: 

1. The item may have been deleted
2. The item may have been deleted because it can contain a invalid character in the filename. 

**Recommendation**: check if the name of the item has any special characters like the ones mentioned above and remove it from the name.

```
An error occurred
Error occurred when extracting data from /api/awards/123/documents/O1. Project Development/O8.1 Evidence/Extra CP Messages 10.04.2055¿Edited-Approved Messages.docx
StatusCode: 400
Url: /api/awards/123/documents/O1. Project Development/O8.1 Evidence/Extra CP Messages 10.04.2055¿Edited-Approved Messages.docx
StatusDescription: Bad Request
```

This error message means that the Instance Export script sent a request to our API and that was not accepted as a valid request in our API server, possibly due to invalid characters. 

**Recommendation**: check if the name of the item has any special characters like the ones mentioned above and remove it from the name.

```
An error occurred
Error occurred when extracting data from /api/awards/123/documents/ProjecT/ProjectT Q08 Approval Docs/A Cluster/#Example/02 Indicator Monitoring Findings/9001-Example-Q1-Monitoring-Report.docx
StatusCode: 503
Url: /api/awards/123/documents/ProjecT/ProjectT Q08 Approval Docs/A Cluster/#Example/02 Indicator Monitoring Findings/9001-Example-Q1-Monitoring-Report.docx
StatusDescription: Service Unavailable
```

This error message means that the connection to our server was lost temporarily and the Instance Export script was not able to download the file on the first try. The script does have a retry mechanism that should download the file as soon as the server connection is reestablished. 

**Recommendation**: Check the log file after the export run finishes and see if the data/file was succesfully extracted/downloaded. If not, try to run the Instance Export again and if the issue persists.
