## Instance Export Power Shell

At DevResults we value the concept that the data is yours and you have rights of getting snapshots of it at anytime. For that reason,
we have created a tool to make it possible for you to export and save all data you have at DevResults on your own machines.

In order to use it, you should:

1. Download the InstanceExport power shell script available in this repo to your machine.

2. Use our API to make a POST request an updated Instance Export Manifest:
 ```POST https://{myInstanceName}.devresults.com/api/currentinstance/export```

where {myInstanceName} is the name of your site in DevResults

3. Save the file in the same directory you have saved the powershell script. It's important to save the file in the JSON format and that you keep in mind the name you saved the file. In this tutorial the name we used is *manifest.json*

4. Open a new command line interface (CLI) prompt that supports using PowerShell commands. If you don't have PowerShell installed you can follow instructions at [Installing Power Shell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1)

5. Navigate to the directory you have saved the InstanceExport.ps1 and the JSON manifest file.

e.g.: cd C:\Users\MyUser\InstanceExport

6. In the cli prompt create the following variables
```
$manifestFilePath="{manifestPathFileName}"
```
> PS.: In this turorial example is manifest.json because it is in same folder of the PS script

```
$exporttFilePath="{exportFilePath}"
```
> where {exportFilePath} should be replace with path where you want to save the exported files. In this example case we have used "C:/InstanceExport" but you can define any other if you wish.

```
$userName="{myuser}@devresults.com"
```
> where {myUser} should be replaced by your username at your DevResults site to login

```
$password="{myPassword}"
```
> where {myPassword} should be replaced by your password at your DevResults site to login

```
$encryptedPassword = ConvertTo-SecureString $password -AsPlainText -Force
```

7. After creating all those variables you can begin exporting your data using the following command
   
```
.\InstanceExport -manifestFilePath $manifestFilePath -exportFilePath $exportFilePath -userName $userName -password $encryptedPassword -override $true
```

The process will run automatically and it will propmt the progress of yourdata been exported by each available category. When all is finishedd you should see a message "Exporting Instance finished"

The created power shell script has four parameters that are explained below:
- manifestFilePath : Path of the manifest file you have downloaded using step 2
- exportFilePath: Path to create the folder for the export files
- userName: Your username for login at DevResults
- password: Your password, should be a encrypted string (see step 6), for login at DevResults
- override: Optional parameter to inform if you will override files that already exist and replace them. If you don't use the value of it will be false, which means that if a file already exists in the exportFilePath it will be skipped.
