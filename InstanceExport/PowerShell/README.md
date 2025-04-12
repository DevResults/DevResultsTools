## Instance Export Power Shell

At DevResults we value the concept that your data belongs to _you_, and you have rights of getting snapshots of it at anytime. For that reason, we have created a tool to make it possible for you to export and save all the data that you have in DevResults to your own machines.

In order to use it, you should:

1. Download the [InstanceExport.ps1](https://github.com/DevResults/DevResultsTools/releases/download/1.0.3/InstanceExport.ps1) PowerShell script.

2. Reach out to us at help@devresults.com to request an Instance Export Manifest. Or Manifests in case you need to export more than one instance you own.

3. Save the `InstanceExport.ps1` file in a directory in your machine like `C:\Users\MyUser\InstanceExport`.

4. Inside the folder created on step 3. create a `manifest` folder. 

5. Save your manifest file(s) inside the `manifest` folder. The manifest files come in the JSON format and they are necessary to be that way to be read by the script. In this tutorial consider that your file(s) will be named in the pattern yourInstanceName_manifest.json_.

4. Open a new command line interface (CLI) prompt that supports PowerShell commands (depending on your organizational IT policies, you may need to open an elevated/administrator prompt, e.g. by right clicking on the Powershell icon and choosing "Run as administrator"). If you don't have PowerShell installed you can follow instructions at [Installing Power Shell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5).

Please note that there will be subtle differences between `Windows PowerShell` and `PowerShell 7` command prompts:

`Windows PowerShell` usually comes installed with Windows. It uses the `PowerShell 5` version as you can see from the image below:

![image](https://github.com/user-attachments/assets/3f61a5d3-8b95-43cb-b85d-d030b598aa1f)

`PowerShell 7` is the most recent version of PowerShell released by Microsoft. We recommend using it as it supports longer file paths, which allows our `InstanceExport` script to export files with long names properly. After you install `PowerShell 7` and open its command line prompt, you should be able to see the version of PowerShell using the `$PSVersionTable.PSVersion` command as shown in the image below:

![image](https://github.com/user-attachments/assets/9e7449fb-fe9d-414c-8b93-eaaf7f4ded0b)

6. Navigate to the directory where you have saved the `InstanceExport.ps1` and that has also the `manifest` folder.

   e.g.: `cd C:\Users\MyUser\InstanceExport`

6. In the cli prompt, type the following command. **Be very careful not to click inside the cli prompt while it's running, or it may go into "select mode" and pause.**

   `.\InstanceExport`

The process will prompt you to enter the required fields: `$manifestFilePath`, `$exportFilePath`, `$userName` and `$password`. Because you navigated to the directory/folder in step 5, you do not need to enter the full path, just the file names (see example below).

![image](https://github.com/user-attachments/assets/eca84717-d4b1-40a6-a8ef-415f11bdc546)

It will run automatically after you enter all required fields. The progress of your data export will be logged by each available category. When all is finished you should see the message "Exporting Instance finished".

The PowerShell script has five parameters that are explained below:

- manifestFilePath: Path (or just folder name, if in the same directory) of the manifest file(s) you have added inside the `manifest` folder from step 3, e.g. `C:\Users\MyUser\InstanceExport\manifest`.
- exportFilePath: Path (or just folder name, if in the same directory) to create a folder that will contain all instance(s) you are going to export, e.g. `C:\Users\MyUser\InstanceExport\2025_Export\`; you do not need to create this folder manually, the script will do so for you.
- userName: Your username (work email) for login at DevResults, e.g. `first.last@org.org`.
- password: Your password for login at DevResults or API Key's Secret. (If you're using a password manager and copy/pasting your password, be aware that CTRL-V does not work in Powershell; try right clicking in the window to paste instead.)
- overwrite: Optional parameter to confirm whether or not you want to overwrite files that already exist and replace them. This field defaults to `false`, which means that if a file already exists in the exportFilePath, it will be skipped.

Please note that if you use `.\InstanceExport.ps1` without passing any parameters you will be asked to provide the information and will not be able to use the overwrite parameter. If you are more experienced with PowerShell, you can also use the command by passing parameters as shown in the image below:

![image](https://github.com/user-attachments/assets/de040cf5-f268-4316-8ef5-2276b1e72648)

### Output
We expect that things will go smoothly while you are using the DevResults InstanceExport script and that you get a result similar to the following image:

![image](https://github.com/user-attachments/assets/0af5a12c-4c5e-4fc2-b737-1901d2d5739f)

In the folder you've saved the `InstanceExport` script you will noticed that a new folder `export` (or other name you've provided in the $exportFilePath parameter) and inside that folder you will have a folder with the name of the exported instance. You should expect that your data exported will be there in subfolders and a log file will be generated with the pattern `yourInstance_InstanceExport_MM_dd_yyyy_HH_mm_ss_log.txt`

![image](https://github.com/user-attachments/assets/2078418b-77ea-4131-9f4a-3f075cc3b300)

In case you are exporting more than one instance you will have a similar output but with more log information like the following image:

![image](https://github.com/user-attachments/assets/9f425cd6-34b2-449a-af71-bdc2de9bae6d)

And similarly you will have as many folders as manifests files you have inside your `manifest` folder. You will notice that the script would be generating one folder for each instance you've own.

![image](https://github.com/user-attachments/assets/be64f831-f668-45e0-aceb-7bb1d153e0b4)


### Troubleshooting

Below you will find examples of the kinds of error messages you may encounter when running the export script. While the examples focus on documents and folders, these errors can occur anywhere user-named items (data tables, photos, etc.) are found in the database. We offer potential solutions, but note that **in most cases you will need to request a new manifest file before you re-run the script.**

```
An error occurred
Error occurred when extracting data from /api/awards/123/documents/Project name that is very long/Quarterly and Annual Report/Q04 Reporting submissions 2019/Annual Workplan Progress Review/A_very_long_file_name_that_will_cause_exception_v1.xlsx
StatusCode:
Url: /api/awards/123/documents/Project name that is very long/Quarterly and Annual Report/Q04 Reporting submissions 2019/Annual Workplan Progress Review/A_very_long_file_name_that_will_cause_exception_v1.xlsx
StatusDescription:
```

This error message means the Instance Export script found the data on our servers but something is wrong with the file path. For example, some earlier versions of PowerShell cannot handle long file names or long path names. 

**Recommendation**: install PowerShell 7 (64 bit version) which can accommodate longer file/path names. You may need to rename the file after the export run if your are using Windows OS.

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
2. The item may have been deleted because it contained a invalid character in the filename. 

**Recommendation**: check if the name of the item has any special characters like the ones mentioned above and remove them from the name.

```
An error occurred
Error occurred when extracting data from /api/awards/123/documents/O1. Project Development/O8.1 Evidence/Extra CP Messages 10.04.2055¿Edited-Approved Messages.docx
StatusCode: 400
Url: /api/awards/123/documents/O1. Project Development/O8.1 Evidence/Extra CP Messages 10.04.2055¿Edited-Approved Messages.docx
StatusDescription: Bad Request
```

This error message means that the Instance Export script sent a request to our API and that was not accepted as a valid request in our API server, possibly due to invalid characters. 

**Recommendation**: check if the name of the item has any special characters like the ones mentioned above and remove them from the name.

```
An error occurred
Error occurred when extracting data from /api/awards/123/documents/ProjecT/ProjectT Q08 Approval Docs/A Cluster/#Example/02 Indicator Monitoring Findings/9001-Example-Q1-Monitoring-Report.docx
StatusCode: 503
Url: /api/awards/123/documents/ProjecT/ProjectT Q08 Approval Docs/A Cluster/#Example/02 Indicator Monitoring Findings/9001-Example-Q1-Monitoring-Report.docx
StatusDescription: Service Unavailable
```

This error message means that the connection to our server was lost temporarily and the Instance Export script was not able to download the file on the first try. The script does have a retry mechanism that should download the file as soon as the server connection is reestablished. 

**Recommendation**: Check the log file after the export run finishes and see if the data/file was successfully extracted/downloaded. If not, try to run the Instance Export again and if the issue persists.
