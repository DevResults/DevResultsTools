[CmdletBinding()]
param(    
     [Parameter(Mandatory=$True, HelpMessage='Path of manifest file')][String] $manifestFilePath,
     [Parameter(Mandatory=$True, HelpMessage='Path where to create the exported files')][String] $exportFilePath,
     [Parameter(Mandatory=$True, HelpMessage='Your username on DevResults')][String] $userName,
     [Parameter(Mandatory=$True, HelpMessage='Your password on DevResults')][SecureString] $password,
     [Parameter(Mandatory=$False, HelpMessage='Flag to override all files that already exists')][boolean] $override = $false
)
$manifestJson = Get-Content -Raw -Path $manifestFilePath | ConvertFrom-Json
$currentDate = Get-Date $manifestJson.CreateDate -Format "MM_dd_yyyy_HH_mm_ss"
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

function Write-ColorOutput($ForegroundColor)
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
        [Parameter(Mandatory=$true)][String]$msg
    )
    $directoryPath = $exportFilePath
    $directoryExists = Test-Path -Path $directoryPath
    if (!$directoryExists)
    {
        New-Item -Path $directoryPath -ItemType "directory" | Out-Null
        Write-Information ($directoryPath + " created")
        Log ($directoryPath + " created")
    }
    Add-Content ($directoryPath + "/InstanceExport_" + $currentDate +"_log.txt") $msg
}

function Export
{
<#
.Description
This function exports an given instancce and save it to your disk in the specified exportFilePath from a JSON manifest file
#>    

    $Body = @{
        UserName = $userName
        Password = $UnsecurePassword
    }

    $Parameters = @{
        Method = "POST"
        Uri = "https://" + $manifestJson.SubDomain + "." + $manifestJson.HostName + "/api/login"
        Body = ($Body | ConvertTo-Json)
        ContentType = "application/json"
    }

    try{
        $accessTokenResponseModel = Invoke-RestMethod @Parameters

        $accessToken = $accessTokenResponseModel.access_token

        $Header = @{
            "authorization" = "Bearer $accessToken"
        }

        try
        {
            $currentCategory = "";
            foreach ($entry in $manifestJson.Entries)
            {
                if ($currentCategory -ne $entry.Category)
                {
                    $currentCategory = $entry.Category;
                    Write-ColorOutput yellow ("Starting extraction of " + $entry.Category + " category.")
                    Log ("Starting extraction of " + $entry.Category + " category.")
                }
                
                Write-Information yellow ("Extracting data from " + $entry.Url)
                Log ("Extracting data from " + $entry.Url)
                $directoryPath = $exportFilePath + "/" + $entry.Path
                $directoryExists = Test-Path -Path $directoryPath
                if (!$directoryExists)
                {
                    New-Item -Path $directoryPath -ItemType "directory" | Out-Null
                    Write-Information ($directoryPath + " created")
                    Log ($directoryPath + " created")
                }

                $filePath =  $directoryPath + "/" + $entry.FileName
                $fileAlreadyExists = Test-Path -Path $filePath -PathType Leaf

                if (!$fileAlreadyExists -or $override)
                {
                    if ($entry.Url.Contains("/content") -or $entry.Url.Contains("xlsx") -or $entry.Url.Contains("/template")){
                        $entryExportParameters = @{
                            Method      = "GET"
                            Uri         = "https://" + $manifestJson.SubDomain + "." + $manifestJson.HostName + $entry.Url
                            Headers     = $Header
                            ContentType = "application/json"  
                        }
                        
                        try{
                            $GetEntriesResponse = Invoke-RestMethod @entryExportParameters -OutFile $filePath
                        }
                        catch{
                            $message = "Error occured when extracting data from " + $entry.Url
                            Write-ColorOutput red ($message)
                            Log ($message)
                        }
                    }
                    else{
                        $entryExportParameters = @{
                            Method      = "GET"
                            Uri         = "https://" + $manifestJson.SubDomain + "." + $manifestJson.HostName + $entry.Url
                            Headers     = $Header
                            ContentType = "application/json"   
                        }
                        try{
                            $GetEntriesResponse = Invoke-RestMethod @entryExportParameters

                            $GetEntriesResponse | ConvertTo-Json  | Out-File -FilePath $filePath
                        }
                        catch{
                            $message = "Error occured when extracting data from " + $entry.Url
                            Write-ColorOutput red ($message)
                            Log ($message)
                        }
                    }
                }
                else{
                    $message = "Skipping " + $filePath + " because file already exists"
                    ## This can be uncommented for debug purposes
                    # Write-ColorOutput white ($message)
                    Log ($message)
                }
            }
        }
        catch{
            Write-ColorOutput red "Authorization error for Instance Export"
            Log "Authorization error for Instance Export"
        }
        Write-ColorOutput green "Exporting Instance finished."
        Log "Exporting Instance finished."
    }
    catch{
        Write-ColorOutput red "An error occurred when logging in"
        Log "Authorization error for Instance Export"
    }
}
Export