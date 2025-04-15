<#PSScriptInfo

.VERSION -1.0.0-dev-

.GUID -githubsha-

.AUTHOR fred@devresults.com

.COMPANYNAME DevResults

.COPYRIGHT

.TAGS 

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 DevResults Instance Export script 

#> 
[CmdletBinding()]
param(    
    [Parameter(Mandatory = $True, HelpMessage = 'Path of manifest file')][String] $manifestFilePath,
    [Parameter(Mandatory = $True, HelpMessage = 'Path where to create the exported files')][String] $exportFilePath,
    [Parameter(Mandatory = $True, HelpMessage = 'Your username on DevResults')][String] $userName,
    [Parameter(Mandatory = $True, HelpMessage = 'Your password on DevResults')][SecureString] $password,
    [Parameter(Mandatory = $False, HelpMessage = 'Flag to overwrite all files that already exists')][boolean] $overwrite = $false
)
Function Write-ColorOutput($ForegroundColor) {
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
        [Parameter(Mandatory = $true)][String]$msg,
        [Parameter(Mandatory = $false)][String]$displayMsg,
        [Parameter(Mandatory = $true)][String]$logLevel,
        [Parameter(Mandatory = $true)][String]$currentDate
    )
    switch ($logLevel) {
        "error" {
            if ($displayMsg) {
                Write-ColorOutput red $displayMsg
            }
        }
        "displayInfo" {
            if ($displayMsg) {
                Write-ColorOutput yellow $displayMsg
            }
        }
        "info" {
            if ($displayMsg) {
                Write-Information $displayMsg
            }
        }
        "success" {
            if ($displayMsg) {
                Write-ColorOutput green $displayMsg
            }
        }
    }
    Add-Content "$($exportFilePath)/InstanceExport_$($currentDate)_log.txt" $msg
}

Function CreateDirectoryIfDoesNotExist {
    param (
        [Parameter(Mandatory = $true)][String]$directoryPath,
        [Parameter(Mandatory = $true)][String] $currentDate
    )
    $directoryExists = Test-Path -Path $directoryPath
    if (!$directoryExists) {
        try {
            New-Item -Path $directoryPath -ItemType "directory" | Out-Null
            $msg = "$directoryPath created"
            Log -msg $msg -displayMsg $msg -logLevel "info" -currentDate $currentDate 
        }
        catch { 
            $msg = "Error trying to create $directoryPath directory"
            $displayMsg = "Error creating directory"
            Log -msg $msg -displayMsg $displayMsg -logLevel "error" -currentDate $currentDate
        }
    }
}

Function GetPassword() {
    # assume powershell 7 first
    try {    
        return ConvertFrom-SecureString -SecureString $password -AsPlainText
    }
    catch {
        Log -msg $_.Exception.Message -logLevel "displayInfo" -currentDate $currentDate 
    }
    # fallback to powershell 5
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
    $UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    if ($UnsecurePassword.Length -gt 1) {
        return $UnsecurePassword
    }
    # we're probably on some non-windows environment... fall back to unsecured
    $msg = "Warning: Unable to handle password securely. Falling back to plain text password"
    Log -msg $msg -logLevel "displayInfo" -currentDate $currentDate 
    return Read-Host "$msg. To continue, please enter the password again"
}

Function Login() {
    $UnsecurePassword = GetPassword

    $Body = @{
        UserName = $userName
        Password = $UnsecurePassword
    }

    $Parameters = @{
        Method      = "POST"
        Uri         = "https://$($manifestJson.SubDomain).$($manifestJson.HostName)/api/login"
        Body        = ($Body | ConvertTo-Json)
        ContentType = "application/json"
    }

    $accessTokenResponseModel = Invoke-RestMethod @Parameters
    
    return $accessTokenResponseModel
}

Function Logout($header) {
    $Parameters = @{
        Method      = "POST"
        Uri         = "https://$($manifestJson.SubDomain).$($manifestJson.HostName)/api/logout"
        Headers     = $header
        ContentType = "application/json"
    }

    Invoke-RestMethod @Parameters | Out-Null
    
}

Function ServerHealtCheck($Uri) {
    $response = $null;
    try {
        Write-Verbose "Calling HealthCheck $Uri"
        $response = Invoke-RestMethod -Uri $Uri
    }
    catch {
        $response = $_
        Start-Sleep -Seconds 5
    }
    return $response
}


function Export {
    <#
.Description
This function exports an given instancce and save it to your disk in the specified exportFilePath from a JSON manifest file
#>    
    $currentDate = Get-Date -Format "MM_dd_yyyy_HH_mm_ss"
	
    $manifestFilePathExists = Test-Path -Path $manifestFilePath
	
    $target = Get-Item $manifestFilePath
	
    if ($manifestFilePathExists) {
        if (!$target.PSIsContainer) {
            $manifestJson = Get-Content -Raw -Path $manifestFilePath | ConvertFrom-Json
            $instance = $manifestJson.subdomain
			
            if ($manifestJson.CreateDate) {
                $currentDate = Get-Date $manifestJson.CreateDate -Format "MM_dd_yyyy_HH_mm_ss"
            }
            else {
                $msg = "Error in reading manifest file"
                $displayMsg = "An error occurred when reading manifest file"
                Log -msg $msg -displayMsg $displayMsg -logLevel "error"  -currentDate $currentDate
                Exit 1
            }
		
            $directoryPath = $exportFilePath + "/" + $instance
            try {
                CreateDirectoryIfDoesNotExist -directoryPath $directoryPath -currentDate $currentDate
            }
            catch {
                $msg = "Error trying to create $directoryPath directory"
                $displayMsg = "An error occurred when trying to create a new directory"
                Log -msg $msg -displayMsg $displayMsg -logLevel "error" -currentDate $currentDate
                Exit 1
            }

            try {
                $accessTokenResponseModel = Login
            }
            catch {
                Log -msg "An error occurred" -displayMsg "$($_.Exception.Response.StatusCode.value__): An error occurred when logging in" -logLevel "error" -currentDate $currentDate
                Log -msg "Authorization error for Instance Export" -logLevel "error" -currentDate $currentDate 
                Log -msg "StatusCode: $($_.Exception.Response.StatusCode.value__)" -logLevel "error" -currentDate $currentDate
                Log -msg "Url: api/login" -logLevel "error" -currentDate $currentDate 
                Log -msg "StatusDescription: $($_.Exception.Response.StatusDescription)" -logLevel "error" -currentDate $currentDate 
            }

            if ($accessTokenResponseModel) {

                $accessToken = $accessTokenResponseModel.access_token

                $header = @{
                    "authorization" = "Bearer $accessToken"
                }
				
                $msg = "$instance"
                $displayMsg = "Starting exporting data for instance $instance"
                Log -msg $msg -displayMsg $displayMsg -logLevel "success" -currentDate $currentDate 

                $currentCategory = "";
                $i = 0;
                for (; $i -lt $manifestJson.Entries.Length; $i = $i + 1) {
                    $entry = $manifestJson.Entries[$i]
                    if ($currentCategory -ne $entry.Category) {
                        $currentCategory = $entry.Category;
                        $message = "Starting extraction of $($entry.Category) category."
                        Log -msg $message -displayMsg $message -logLevel "displayInfo" -currentDate $currentDate 
                    }
                    $message = "Extracting data from $($entry.Url)"
                    Log -msg $message -displayMsg $message -logLevel "info" -currentDate $currentDate 
                    $directoryPath = $exportFilePath + "/" + $instance + "/" + $entry.Path
				
                    try {
                        CreateDirectoryIfDoesNotExist -directoryPath $directoryPath -currentDate $currentDate 
                    }
                    catch {
                        $msg = "Error trying to create $directoryPath directory"
                        $displayMsg = "An error occurred when trying to create a new directory"
                        Log -msg $msg -displayMsg $displayMsg -logLevel "error" -currentDate $currentDate 
                    }
                    $fileName = $entry.FileName.Split([IO.Path]::GetInvalidFileNameChars()) -join ''
                    $filePath = "$directoryPath/$fileName"
                    $fileAlreadyExists = Test-Path -Path $filePath -PathType Leaf
                    if (!$fileAlreadyExists -or $overwrite) {
                        $entryExportParameters = @{
                            Method      = "GET"
                            Uri         = "https://$($manifestJson.SubDomain).$($manifestJson.HostName)$($entry.Url)"
                            Headers     = $header
                            ContentType = "application/json"  
                        }
							
                        try {
                            if (!$entry.fileName.Contains(".json")) {
                                Invoke-RestMethod @entryExportParameters -OutFile $filePath | Out-Null
                            }
                            else {
                                $GetEntriesResponse = Invoke-RestMethod @entryExportParameters
                                $GetEntriesResponse | ConvertTo-Json -Depth 100 | Out-File -FilePath $filePath
                            }
                        }
                        catch {
                            $message = "Error occurred when extracting data from $($entry.Url)"
                            Log -msg "An error occurred" -displayMsg $message -logLevel "error" -currentDate $currentDate 
                            Log -msg $message -logLevel "error" -currentDate $currentDate 
                            Log -msg "StatusCode: $($_.Exception.Response.StatusCode.value__)" -logLevel "error" -currentDate $currentDate 
                            Log -msg "Url: $($entry.Url)" -logLevel "error" -currentDate $currentDate 
                            Log -msg "StatusDescription: $($_.Exception.Response.StatusDescription)" -logLevel "error" -currentDate $currentDate 
                            Log -msg "Exception: $($_.Exception)" -logLevel "error" -currentDate $currentDate 
                            Write-Verbose $_.Exception
                            Write-Verbose $_.Exception.Response
                            if ($_.Exception.Response.StatusCode -eq 503) {
                                $message = "Lost connection to server. Waiting to restablish connection."
                                Write-ColorOutput red $message
                                Log -msg $message -displayMsg $message -logLevel "info" -currentDate $currentDate 
                                do {
                                    $response = ServerHealtCheck("https://$($manifestJson.SubDomain).$($manifestJson.HostName)/en/healthcheck");
									
                                } while ($response.Exception)
                                $message = "Server connection reestablished. Resuming export"
                                Write-ColorOutput green $message
                                Log -msg $message -displayMsg $message -logLevel "info" -currentDate $currentDate 
                                $i = $i - 1;
                            }
                        }
                    }
                    else {
                        $message = "Skipping $filePath because file already exists"
                        Log -msg $message -displayMsg $message -logLevel "info" -currentDate $currentDate 
                    }
                }
                $msg = "Exporting Instance run finished."
                Log -msg $msg -displayMsg $msg -logLevel "success" -currentDate $currentDate 

                try {
                    Logout($header)
                }
                catch {
                    $message = "Error occurred when logging out"
                    Log -msg $message -displayMsg $message -logLevel "error" -currentDate $currentDate 
                }
            }
            else {
                $msg = "Exporting Instance run finished with errors."
                $displayMsg = "Exporting Instance run was not successful. Check the log file for more details."
                Log -msg $msg -displayMsg $displayMsg -logLevel "error" -currentDate $currentDate 
            }
        }
        else { 
            $manifestFilePath = $manifestFilePath.TrimEnd('\')  # Trim any trailing backslash if it exists
		
            $manifestJsonFiles = Get-ChildItem -Path "$manifestFilePath\*" -Include "*.json"
		
            try {
                CreateDirectoryIfDoesNotExist -directoryPath "$exportFilePath" -currentDate $currentDate
            }
            catch {
                $msg = "Error trying to create $directoryPath directory"
                $displayMsg = "An error occurred when trying to create a new directory"
                Log -msg $msg -displayMsg $displayMsg -logLevel "error" -currentDate $currentDate 
                Exit 1
            }
			
            if ($manifestJsonFiles) {	
				
                foreach ($manifestFile in $manifestJsonFiles) {
					
                    $manifestFileExists = Test-Path -Path $manifestFile
			
                    if ($manifestFileExists) {
                        $manifestJson = Get-Content -Raw -Path $manifestFile | ConvertFrom-Json
				
                        $instance = $manifestJson.subdomain
				
                        try {
                            CreateDirectoryIfDoesNotExist -directoryPath "$exportFilePath\$instance" -currentDate $currentDate 
                        }
                        catch {
                            $msg = "Error trying to create $directoryPath directory"
                            $displayMsg = "An error occurred when trying to create a new directory"
                            Log -msg $msg -displayMsg $displayMsg -logLevel "error" -currentDate $currentDate 
                            Exit 1
                        }

                        try {
                            $accessTokenResponseModel = Login
                        }
                        catch {
                            Log -msg "An error occurred" -displayMsg "$($_.Exception.Response.StatusCode.value__): An error occurred when logging in" -logLevel "error" -currentDate $currentDate 
                            Log -msg "Authorization error for Instance Export" -logLevel "error" -currentDate $currentDate 
                            Log -msg "StatusCode: $($_.Exception.Response.StatusCode.value__)" -logLevel "error" -currentDate $currentDate 
                            Log -msg "Url: api/login" -logLevel "error" -currentDate $currentDate 
                            Log -msg "StatusDescription: $($_.Exception.Response.StatusDescription)" -logLevel "error" -currentDate $currentDate 
                        }

                        if ($accessTokenResponseModel) {

                            $accessToken = $accessTokenResponseModel.access_token

                            $header = @{
                                "authorization" = "Bearer $accessToken"
                            }
					
                            $message = "Starting exporting data for instance $instance"
                            Log -msg $message -displayMsg $message -logLevel "success" -currentDate $currentDate 

                            $currentCategory = "";
                            $i = 0;
                            for (; $i -lt $manifestJson.Entries.Length; $i = $i + 1) {
                                $entry = $manifestJson.Entries[$i]
                                if ($currentCategory -ne $entry.Category) {
                                    $currentCategory = $entry.Category;
                                    $message = "Starting extraction of $($entry.Category) category."
                                    Log -msg $message -displayMsg $message -logLevel "displayInfo" -currentDate $currentDate 
                                }
                                $message = "Extracting data from $($entry.Url)"
                                Log -msg $message -displayMsg $message -logLevel "info" -currentDate $currentDate 
                                $directoryPath = $exportFilePath + "/" + $instance + "/" + $entry.Path
								
                                try {
                                    CreateDirectoryIfDoesNotExist -directoryPath $directoryPath -currentDate $currentDate 
                                }
                                catch {
                                    $msg = "Error trying to create $directoryPath directory"
                                    $displayMsg = "An error occurred when trying to create a new directory"
                                    Log -msg $msg -displayMsg $displayMsg -logLevel "error" -currentDate $currentDate 
                                }
                                $fileName = $entry.FileName.Split([IO.Path]::GetInvalidFileNameChars()) -join ''
                                $filePath = "$directoryPath/$fileName"
                                $fileAlreadyExists = Test-Path -Path $filePath -PathType Leaf
                                if (!$fileAlreadyExists -or $overwrite) {
                                    $entryExportParameters = @{
                                        Method      = "GET"
                                        Uri         = "https://$($manifestJson.SubDomain).$($manifestJson.HostName)$($entry.Url)"
                                        Headers     = $header
                                        ContentType = "application/json"  
                                    }
								
                                    try {
                                        if (!$entry.fileName.Contains(".json")) {
                                            Invoke-RestMethod @entryExportParameters -OutFile $filePath | Out-Null
                                        }
                                        else {
                                            $GetEntriesResponse = Invoke-RestMethod @entryExportParameters
                                            $GetEntriesResponse | ConvertTo-Json -Depth 100 | Out-File -FilePath $filePath
                                        }
                                    }
                                    catch {
                                        $message = "Error occurred when extracting data from $($entry.Url)"
                                        Log -msg "An error occurred" -displayMsg $message -logLevel "error" -currentDate $currentDate 
                                        Log -msg $message -logLevel "error" -currentDate $currentDate 
                                        Log -msg "StatusCode: $($_.Exception.Response.StatusCode.value__)" -logLevel "error" -currentDate $currentDate 
                                        Log -msg "Url: $($entry.Url)" -logLevel "error" -currentDate $currentDate 
                                        Log -msg "StatusDescription: $($_.Exception.Response.StatusDescription)" -logLevel "error" -currentDate $currentDate 
                                        Log -msg "Exception: $($_.Exception)" -logLevel "error" -currentDate $currentDate 
                                        Write-Verbose $_.Exception
                                        Write-Verbose $_.Exception.Response
                                        if ($_.Exception.Response.StatusCode -eq 503) {
                                            $message = "Lost connection to server. Waiting to restablish connection."
                                            Write-ColorOutput red $message
                                            Log -msg $message -displayMsg $message -logLevel "info" -currentDate $currentDate
                                            do {
                                                $response = ServerHealtCheck("https://$($manifestJson.SubDomain).$($manifestJson.HostName)/en/healthcheck");
                                            } while ($response.Exception)
                                            $message = "Server connection reestablished. Resuming export"
                                            Write-ColorOutput green $message
                                            Log -msg $message -displayMsg $message -logLevel "info" -currentDate $currentDate
                                            $i = $i - 1;
                                        }
                                    }
                                }
                                else {
                                    $message = "Skipping $filePath because file already exists"
                                    Log -msg $message -displayMsg $message -logLevel "info" -currentDate $currentDate 
                                }
                            }
                            $msg = "Exporting data for instance $instance was succesful."
                            Log -msg $msg -displayMsg $msg -logLevel "success" -currentDate $currentDate 

                            try {
                                Logout($header)
                            }
                            catch {
                                $message = "Error occurred when logging out"
                                Log -msg $message -displayMsg $message -logLevel "error" -currentDate $currentDate 
                            }
                        }
                        else {
                            $msg = "Exporting data for instance $instance finished with errors."
                            $displayMsg = "Exporting data for instance $instance was not successful. Check the log file for more details."
                            Log -msg $msg -displayMsg $displayMsg -logLevel "error" -currentDate $currentDate 
                        }
                    }
                    else {
                        $displayMsg = "An error occurred when looking for manifest file"
                        Log -msg "Error in finding manifest file" -displayMsg $displayMsg -logLevel "error" -currentDate $currentDate
                    }
                }
            }			
            else {
                $msg = "Manifest file path doesn't contain valid json file(s)."
                Log -msg $msg -displayMsg $msg -logLevel "error" -currentDate $currentDate
            }
		
            $msg = "Exporting Instance script run finished."
            Log -msg $msg -displayMsg $msg -logLevel "success" -currentDate $currentDate
        }
    }
    else {
        $msg = "Manifest file path provided doesn't exist."
        Log -msg $msg -displayMsg $msg -logLevel "error" -currentDate $currentDate
    }
}
Export
