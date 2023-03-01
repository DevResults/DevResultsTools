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

When running the InstanceExport script in your local machine you might see a few error messages that could indicate an issue with downloading the information from our servers and saving it to your choosen folder. The following error messages are examples of what kind of messages you can see in the Power Shell window that you've run the script and that also should be present in a log file created for each run of the export. In order to help you solve these issues we provide here a few possible solutions that can help you solve the issues and successfully extract the data you need.

```
An error occurred
Error occurred when extracting data from /api/awards/123/documents/Project long name/Quarterly and Annual Report long name/Q04 Reporting submissions May - Jul 2019/Annual Workplan Progress Review/A_very_long_file_name_that_will_cause_exception_v1.xlsx
StatusCode:
Url: /api/awards/123/documents/Project long name/Quarterly and Annual Report long name/Q04 Reporting submissions May - Jul 2019/Annual Workplan Progress Review/A_very_long_file_name_that_will_cause_exception_v1.xlsx
StatusDescription:
```

- This error message means that the Instance Export script was able to find the data on our servers but most probably something is wrong with the file path. For example, the path can be too long so PowerShell did not succeed on saving the file to your export folder. Our recommendation to solve the problem is : please try again to run PowerShell 7 (64 bit version) in your local machine so the path too long would not be a problem to download and be saved to local folder. You probably will need to rename the file after the export run if your are using Windows OS.

```
An error occurred
Error occurred when extracting data from /api/awards/123/documents/Evaluation/NewProject/Baseline/Folder Name with ’ invalid character/My file for reports on May 2018.docx
StatusCode: 500
Url: /api/awards/123/documents/Evaluation/NewProject/Baseline/Folder Name with ’ invalid character/My file for reports on May 2018.docx
StatusDescription: Internal Server Error
```

- This error message means that the Instance Export script was not able to download the file. It is most probably due to the ’ character or any other invalid character that exist currently in the folder name or else in the file name. Our recommendation to solve the problem is: please try to change the name of the file and remove any special characters like for example ’, ¿, ™ and try to run the script again and see if the error goes away

```
An error occurred
Error occurred when extracting data from /api/awards/123/documents/Annual Reviews 2020/FileName with a ’ character that may be ´ invalidçã£.pptx
StatusCode: 404
Url: /api/awards/123/documents/Annual Reviews 2020/FileName with a ’ character that may be ´ invalidçã£.pptx
StatusDescription: Not Found
```

- This error message means that the Instance Export script was not able to find the data/file to be exported. It can indicate two things: 1. The award probably could have been deleted 2. We couldn't find the document because it can contain a invalid character in the filename. Our recommendation to solve the problem is: please try to check if the name of the file has any special characters like for example ’, ´ , £ and remove it from the name. Then try to run the script again and see if the error goes away. If the error persists, please contact us through help desk and we can investigate it further and help you with it

```
An error occurred
Error occurred when extracting data from /api/awards/123/documents/O1. Project Development/O8.1 Evidence/Extra CP Messages 10.04.2055¿Edited-Approved Messages.docx
StatusCode: 400
Url: /api/awards/123/documents/O1. Project Development/O8.1 Evidence/Extra CP Messages 10.04.2055¿Edited-Approved Messages.docx
StatusDescription: Bad Request
```

- This error message means that the Instance Export script sent a request to our API and it was not processed because we couldn't find the document because it contains a invalid character like a ¿ or something else in the filename that was not accept as a valid request in our API server. Our recommendation to solve the problem is: pleas contact us through help desk and we can investigate it furter and help you to solve the problem but it might be related to renaming the file and removing the invalid characters in the file name.

```
An error occurred
Error occurred when extracting data from /api/awards/123/documents/ProjecT/ProjectT Q08 Approval Docs/A Cluster/#Example/02 Indicator Monitoring Findings/9001-Example-Q1-Monitoring-Report.docx
StatusCode: 503
Url: /api/awards/123/documents/ProjecT/ProjectT Q08 Approval Docs/A Cluster/#Example/02 Indicator Monitoring Findings/9001-Example-Q1-Monitoring-Report.docx
StatusDescription: Service Unavailable
```

- This error message means that our servers might have been temporarily unavailable and the Instance Export script was not able to download the file in the first time. Our Instance Export has a retry mechanism that should retry to download the file as soon as the server is available again. Our recommendation to solve the issue is: Check the log file after the export run finishes and see if the data/file was succesfully extracted/downloaded. If not, try to run the Instance Export again and if the issue persists please contact us through help desk and we will help you with it
