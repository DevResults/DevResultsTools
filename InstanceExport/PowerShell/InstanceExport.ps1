[CmdletBinding()]
param(    
     [Parameter(Mandatory=$True, HelpMessage='Path of manifest file')][String] $manifestFilePath,
     [Parameter(Mandatory=$True, HelpMessage='Path where to create the exported files')][String] $exportFilePath,
     [Parameter(Mandatory=$True, HelpMessage='Your username on DevResults')][String] $userName,
     [Parameter(Mandatory=$True, HelpMessage='Your password on DevResults')][SecureString] $password,
     [Parameter(Mandatory=$False, HelpMessage='Flag to overwrite all files that already exists')][boolean] $overwrite = $false
)
Function Write-ColorOutput($ForegroundColor)
{
    # save the current color
    $fc = $host.UI.RawUI.ForegroundColor

    # set the new color
    $host.UI.RawUI.ForegroundColor = $ForegroundColor

    # output
    if ($args) {
        Write-Output $args
    }
    else {
        $input | Write-Output
    }

    # restore the original color
    $host.UI.RawUI.ForegroundColor = $fc
}

Function Log {
    param(
        [Parameter(Mandatory=$true)][String]$msg,
        [Parameter(Mandatory=$false)][String]$displayMsg,
        [Parameter(Mandatory=$true)][String]$logLevel,
        [Parameter(Mandatory=$true)][String]$currentDate
    )
    switch($logLevel)
    {
        "error"{
            if ($displayMsg){
                Write-ColorOutput red $displayMsg
            }
        }
        "displayInfo"{
            if ($displayMsg){
                Write-ColorOutput yellow $displayMsg
            }
        }
        "info"{
            if ($displayMsg){
                Write-Information $displayMsg
            }
        }
        "success"{
            if ($displayMsg){
                Write-ColorOutput green $displayMsg
            }
        }
    }
    Add-Content "$($exportFilePath)/InstanceExport_$($currentDate)_log.txt" $msg
}

Function CreateDirectoryIfDoesNotExist{
    param (
        [Parameter(Mandatory=$true)][String]$directoryPath,
        [Parameter(Mandatory=$true)][String] $currentDate
    )
    $directoryExists = Test-Path -Path $directoryPath
    if (!$directoryExists)
    {
        try{
            New-Item -Path $directoryPath -ItemType "directory" | Out-Null
            $msg = "$directoryPath created"
            Log -msg $msg -displayMsg $msg -logLevel "info" -currentDate $currentDate
        }
        catch{ 
            $msg = "Error trying to create $directoryPath directory"
            $displayMsg = "Error creating directory"
            Log -msg $msg -displayMsg $displayMsg -logLevel "error" -currentDate $currentDate
        }
    }
}

Function Login(){
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
    $UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

    $Body = @{
        UserName = $userName
        Password = $UnsecurePassword
    }

    $Parameters = @{
        Method = "POST"
        Uri = "https://$($manifestJson.SubDomain).$($manifestJson.HostName)/api/login"
        Body = ($Body | ConvertTo-Json)
        ContentType = "application/json"
    }

    $accessTokenResponseModel = Invoke-RestMethod @Parameters
    
    return $accessTokenResponseModel
}

function Export
{
<#
.Description
This function exports an given instancce and save it to your disk in the specified exportFilePath from a JSON manifest file
#>    
    $manifestFileExists = Test-Path -Path $manifestFilePath

    if ($manifestFileExists)
    {
        $manifestJson = Get-Content -Raw -Path $manifestFilePath | ConvertFrom-Json
        if ($manifestJson.CreateDate){
            $currentDate = Get-Date $manifestJson.CreateDate -Format "MM_dd_yyyy_HH_mm_ss"
        }
        else{
            $msg = "Error in reading manifest file"
            $displayMsg = "An error occurred when reading manifest file"
            Log -msg $msg -displayMsg $displayMsg -logLevel "error"  -currentDate $currentDate
        }
    
        try{
            CreateDirectoryIfDoesNotExist -directoryPath $exportFilePath -currentDate $currentDate
        }
        catch{
            $msg = "Error trying to create $directoryPath directory"
            $displayMsg = "An error occurred when trying to create a new directory"
            Log -msg $msg -displayMsg $displayMsg -logLevel "error" -currentDate $currentDate
        }

        try{
            $accessTokenResponseModel = Login
        }
        catch{
            Log -msg "An error occurred" -displayMsg "$($_.Exception.Response.StatusCode.value__): An error occurred when logging in" -logLevel "error" -currentDate $currentDate
            Log -msg "Authorization error for Instance Export" -logLevel "error" -currentDate $currentDate
            Log -msg "StatusCode: $($_.Exception.Response.StatusCode.value__)" -logLevel "error" -currentDate $currentDate
            Log -msg "Url: api/login" -logLevel "error" -currentDate $currentDate
            Log -msg "StatusDescription: $($_.Exception.Response.StatusDescription)" -logLevel "error" -currentDate $currentDate
        }

        if ($accessTokenResponseModel){

            $accessToken = $accessTokenResponseModel.access_token

            $Header = @{
                "authorization" = "Bearer $accessToken"
            }

            $currentCategory = "";
            foreach ($entry in $manifestJson.Entries)
            {
                if ($currentCategory -ne $entry.Category)
                {
                    $currentCategory = $entry.Category;
                    $message = "Starting extraction of $($entry.Category) category."
                    Log -msg $message -displayMsg $message -logLevel "displayInfo" -currentDate $currentDate
                }
                $message = "Extracting data from $($entry.Url)"
                Log -msg $message -displayMsg $message -logLevel "displayInfo" -currentDate $currentDate
                $directoryPath = $exportFilePath + "/" + $entry.Path
            
                try{
                    CreateDirectoryIfDoesNotExist -directoryPath $directoryPath -currentDate $currentDate
                }
                catch{
                    $msg = "Error trying to create $directoryPath directory"
                    $displayMsg = "An error occurred when trying to create a new directory"
                    Log -msg $msg -displayMsg $displayMsg -logLevel "error" -currentDate $currentDate
                }
                $fileName = $entry.FileName.Split([IO.Path]::GetInvalidFileNameChars()) -join ''
                $filePath = "$directoryPath/$fileName"
                $fileAlreadyExists = Test-Path -Path $filePath -PathType Leaf
                if (!$fileAlreadyExists -or $overwrite)
                {
                    $entryExportParameters = @{
                        Method      = "GET"
                        Uri         = "https://$($manifestJson.SubDomain).$($manifestJson.HostName)$($entry.Url)"
                        Headers     = $Header
                        ContentType = "application/json"  
                    }
                        
                    try{
                        if (!$entry.fileName.Contains(".json")){
                            Invoke-RestMethod @entryExportParameters -OutFile $filePath | Out-Null
                        }
                        else{
                            $GetEntriesResponse = Invoke-RestMethod @entryExportParameters
                            $GetEntriesResponse | ConvertTo-Json -Depth 100 | Out-File -FilePath $filePath
                        }
                    }
                    catch{
                        $message = "Error occurred when extracting data from $($entry.Url)"
                        Log -msg "An error occured" -displayMsg $message -logLevel "error" -currentDate $currentDate
                        Log -msg $message -logLevel "error" -currentDate $currentDate
                        Log -msg "StatusCode: $($_.Exception.Response.StatusCode.value__)" -logLevel "error" -currentDate $currentDate
                        Log -msg "Url: $($entry.Url)" -logLevel "error" -currentDate $currentDate
                        Log -msg "StatusDescription: $($_.Exception.Response.StatusDescription)" -logLevel "error" -currentDate $currentDate
                    }
                }
                else{
                    $message = "Skipping $filePath because file already exists"
                    Log -msg $message -displayMsg $message -logLevel "info" -currentDate $currentDate
                }
            }
            $msg = "Exporting Instance run finished."
            Log -msg $msg -displayMsg $msg -logLevel "success" -currentDate $currentDate
        }
        else{
            $msg = "Exporting Instance run finished with errors."
            $displayMsg = "Exporting Instance run was not succesfull. Check the log file for more details."
            Log -msg $msg -displayMsg $displayMsg -logLevel "error" -currentDate $currentDate
        }
        
    }
    else{
        $currentDate = Get-Date -Format "MM_dd_yyyy_HH_mm_ss"
    
        try{
            CreateDirectoryIfDoesNotExist -directoryPath $exportFilePath -currentDate $currentDate
        }
        catch{
            $displayMsg = "An error occurred when trying to create a new directory"
            Log -msg "Error trying to create $directoryPath directory" -displayMsg $displayMsg -logLevel "error" -currentDate $currentDate
        }

        $displayMsg = "An error occurred when looking for manifest file"
        Log -msg "Error in finding manifest file" -displayMsg $displayMsg -logLevel "error" -currentDate $currentDate
    }
}
Export