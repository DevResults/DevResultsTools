## Instance Export Power Shell

At DevResults we value the concept that the data is yours and you have rights of getting snapshots of it at anytime. For that reason, we have created a tool to make it possible for you to export and save all data you have at DevResults on your own machines.

In order to use it, you should:

1. Download the [InstanceExport.ps1](https://raw.githubusercontent.com/DevResults/DevResultsTools/main/InstanceExport/PowerShell/InstanceExport.ps1) PowerShell script available in this repo to your machine (right click the name of the file above and choose "Save link as..." to produce a save dialog box).

2. Reach out to us at help@devresults.com to request an Instance Export Manifest.

3. Save the manifest file in the same directory/folder you have saved the powershell script. It's important to save the file in the JSON format and that you remember what you named the file. In this tutorial the name we used is *manifest.json*.

4. Open a new command line interface (CLI) prompt that supports using of PowerShell commands (depending on your organizational IT policies, you may need to open an elevated/administator prompt, e.g. by right clicking on the Powershell icon and choosing "Run as administrator"). If you don't have PowerShell installed you can follow instructions at [Installing Power Shell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1).

5. Navigate to the directory you have saved the InstanceExport.ps1 and the JSON manifest file. 

    e.g.: `cd C:\Users\MyUser\InstanceExport`

6. In the cli prompt type the following command.
   
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
