<#
.SYNOPSIS
    Performs cleanup of ACC Livery files which do not belong to cars you have.
.DESCRIPTION
    Function: Write-Log stores log file in "$env:USERPROFILE\Documents\Assetto Corsa Competizione\Customs\" to review if $true is passed to -Whatif
    Function: Get-CustomSkinNames searched for car json files and attempts to determine customSkinName to assist with sorting
    Function: Remove-DDSFiles takes parameters to remove *_1.dds and *_0.dds files and includes a -Whatif ability if OPTION 0 is used
    Function: Show-Menu wraps it all up and allows the tool to be ran by right clicking on file and selecting Run with Powershell
.PARAMETER customPath
    Default: "$env:USERPROFILE\Documents\Assetto Corsa Competizione\Customs\"
.PARAMETER choice
    Takes 0 through 4 for inputs
    Provide '!?' without the quotes to obtain help with options
.INPUTS
    OPTION 0
    Allows code to be ran and log what WOULD be deleted but does NOT remove ANYTHING
    Writes out to the log file "$env:USERPROFILE\Documents\Assetto Corsa Competizione\Customs\ACC_LIVERIES_CLEAN_UP.LOG"

    OPTION 1
    Remove all liveries without Cars file 

    OPTION 2
    Remove all *_0.dds files

    OPTION 3
    Remove all *_1.dds files

    OPTION 4
    Removes all DDS files    
.LINK
    https://github.com/Larjun/acc_liveries_clean_up
.INPUTS
    Running by right clicking and selecting Run with Powershell:
    cmdlet cleaner.ps1 at command pipeline position 1
    Supply values for the following parameters:
    (Type !? for Help.)
    choice: 0
.OUTPUTS
    cmdlet cleaner.ps1 at command pipeline position 1

    Deleting 607 / 4253 files
    14.2487655772396% Complete
    [ooooooooooooooo                                                                                             ]

    Would be removing 904_GT3_Lamborghini_PumpnPak file decals_1.dds
.NOTES
    Author: Carey Arnaud
    Date: 4/21/2026
    Note: Thanks for letting me assist with the project Arjun :)
#>
param (
    [CmdletBinding()]
    [Parameter(Mandatory=$false)]
    [string] $customsPath = "$env:USERPROFILE\Documents\Assetto Corsa Competizione\Customs\" ,
    [Parameter(Mandatory=$true, HelpMessage="
        Option 0: See what would be removed'default'
        Option 1: Remove all liveries without Cars file 
        Option 2: Remove _0.dds files 
        Option 3: Remove _1.dds files 
        Option 4: Remove all DDS files")]
    [ValidateSet("0","1","2","3","4")]
    [int]$choice
)

# Write-Log stores log file in "$env:USERPROFILE\Documents\Assetto Corsa Competizione\Customs\" to review if $true is passed to -Whatif
function Write-Log {
    param(
    [Parameter(Mandatory=$true)]
    [string]$Message
    )
    $Stamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $Line = "$Stamp INFO $Message"
    $logFileCustomsPath = $customsPath, "ACC_LIVERIES_CLEAN_UP.LOG" -join ''
    Add-Content -Path $logFileCustomsPath -Value $Line
}

# Function: Get-CustomSkinNames searched for car json files and attempts to determine customSkinName to assist with sorting
function Get-CustomSkinNames {
    param (
        [Parameter(Mandatory=$true)]
        [string]$path
    )
    $carsPath = $path, 'cars' -join ""
    $skinNames = @()
    $skipped = @()
    $carsPathCheck = Test-Path -Path $carsPath
    $jsonFile = if($carsPathCheck) {
        (Get-ChildItem -Path $carsPath -Filter "*.json").FullName
    } else {
        return $false
    }
    if ($false -ne $jsonFile) {
        foreach ($file in $jsonFile) {
            $data = $null
            $text = $null
            try {
                try {
                    $text = Get-content $file -raw -Encoding Unicode -ErrorAction Stop
                    $data = $text | ConvertFrom-Json -ErrorAction Stop
                } catch {
                    $text = Get-Content -Path $file -Raw -Encoding UTF8 -ErrorAction Stop
                    $data = $text | ConvertFrom-Json -ErrorAction Stop
                }
                if ($data.customSkinName) {
                    $skinNames += $data.customSkinName
                } 
            } catch {
                $skipped += [PSCustomObject]@{
                    File  = $file
                    Error = $_.Exception.Message
                }
            }
        }
    }
    return [PSCustomObject]@{ SkinNames = $skinNames; Skipped = $skipped }
}

# Remove-DDSFiles takes parameters to remove *_1.dds and *_0.dds files and includes a -Whatif ability if OPTION 0 is used
function Remove-DDSFiles {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("_0","_1", IgnoreCase = $false)]
        [string]$files,
        [Parameter(Mandatory=$true)]
        [string]$path,
        [Parameter(Mandatory=$true)]
        [bool]$Whatif
    )
    $liveryPath = $path, 'liveries' -join ""
    $liveryFolderCount = ($liveryPath -split '\\').count
    $liveryPathCheck = Test-Path -Path $liveryPath
    $ddsFiles = if($liveryPathCheck) {
        if ($files -contains "_0") {
             (Get-ChildItem -Path $liveryPath -Filter "*_0.dds" -Depth 1).FullName 
        } 
        if ($files -contains "_1") {
            (Get-ChildItem -Path $liveryPath -Filter "*_1.dds" -Depth 1).FullName
        }
    } else {
        # No Cars folder located in this directory
        return $false
    }

    if ((($false -ne $ddsFiles) -and ($ddsFiles).count -gt 0) -and $true -eq $Whatif) {
        $fileCountWhatIf = $ddsFiles.Count
        $whatifCount = 0
        do {
            for ($i = 0; $i -lt $fileCountWhatIf; $i++) {
                $percentage = ($i / $fileCountWhatIf) * 100
                $ddsFolderName = ($ddsFiles[$i] -split '\\')[$liveryFolderCount]
                $ddsFolderFile = ($ddsFiles[$i] -split '\\')[$liveryFolderCount + 1]
                $ddsRemovalDetails = $ddsFolderName, $ddsFolderFile -join ' contents '
                Write-Log -Message " Would remove folder $ddsRemovalDetails"
                Write-Progress -Activity "Deleting $($i+1) / $fileCountWhatIf files" -CurrentOperation "Would be removing $ddsFolderName file $ddsFolderFile" -Status "$percentage% Complete" -PercentComplete $percentage
                Start-Sleep -Milliseconds 0.5
                $whatifCount++
            }
        } until ($whatifCount -le $fileCountWhatIf)
    } elseif ((($false -ne $ddsFiles) -and ($ddsFiles).count -gt 0) -and $false -eq $Whatif) {
        $fileCount = $ddsFiles.Count
        $ddsFileCount = 0
        do {
            for ($i = 0; $i -lt $fileCount; $i++) {
                $percentage = ($i / $fileCount) * 100
                $ddsFolderName = ($ddsFiles[$i] -split '\\')[$liveryFolderCount]
                $ddsFolderFile = ($ddsFiles[$i] -split '\\')[$liveryFolderCount + 1]
                $ddsRemovalDetails = $ddsFolderName + " contents " + $ddsFolderFile
                Start-Sleep -Milliseconds 0.5
                Remove-Item -Path $ddsFiles[$i]
                Write-Progress -Activity "Deleting $($i+1) / $fileCount files" -CurrentOperation "Removing $ddsFolderName file $ddsFolderFile" -Status "$percentage% Complete" -PercentComplete $percentage
            }
        } until ($ddsFileCount -le $fileCount)
    } else {
        Write-Output "No dds files found"
    }
}

# Show-Menu wraps it all up and allows the tool to be ran by right clicking on file and selecting Run with Powershell
function Show-Menu {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("0","1","2","3","4")]
        [int]$choice
    )
    switch ($choice) {
        0{Write-Output "Perform Test run of Option 1:Log File will be generated for review here: "
            $result = Get-CustomSkinNames -path $customsPath
            if ($result -eq $false) { Write-Output "Cars folder not found." }
            else {
                Write-Output "Found $($result.SkinNames.Count) skin names, $($result.Skipped.Count) file(s) skipped"
                $liveryPath = $customsPath + 'liveries'
                $toDelete = Get-ChildItem -Path $liveryPath -Directory | Where-Object { $_.Name -notin $result.SkinNames }
                if ($toDelete.Count -eq 0) {
                    Write-Output "No unused livery directories found."
                } else {
                    Remove-DDSFiles -files _0 -path $customsPath -Whatif $true
                    Remove-DDSFiles -files _1 -path $customsPath -Whatif $true
                }
            }
        }
        1{write-output "Removing all livery files you don't have a car file for. You will only see the liveries you can select in the menu"
            $result = Get-CustomSkinNames -path $customsPath
            if ($result -eq $false) { Write-Output "Cars folder not found." }
            else {
                Write-Output "Found $($result.SkinNames.Count) skin names, $($result.Skipped.Count) file(s) skipped"
                $liveryPath = $customsPath + 'liveries'
                $toDelete = Get-ChildItem -Path $liveryPath -Directory | Where-Object { $_.Name -notin $result.SkinNames }
                if ($toDelete.Count -eq 0) {
                    Write-Output "No unused livery directories found."
                } else {
                    $total = $toDelete.Count
                    for ($i = 0; $i -lt $total; $i++) {
                        $percentage = [int](($i + 1) / $total * 100)
                        Write-Progress -Activity "Deleting $($i+1) / $total directories" -Status "$percentage% Complete" -PercentComplete $percentage
                        Start-Sleep -Milliseconds 0.5
                        Remove-Item -Path $toDelete[$i].FullName -Recurse -Force
                    }
                    Write-Progress -Completed -Activity "Done"
                    Write-Output "Deleted $total unused livery directories."
                    Write-Log -Message "Deleted $total livery directories"
                }
            }
        }
        2{write-output "Removing all _0.dds files from your liveries directory. You can regenerate them by loading the livery in the menu"
            Remove-DDSFiles -files "_0" -path $customsPath -Whatif $false   
        }
        3{write-output "Removing all _1.dds files from your liveries directory. You can regenerate them by loading the livery on track"
            Remove-DDSFiles -files "_1" -path $customsPath -Whatif $false
        }
        4{write-output "Removing all dds files from your liveries directory. You can regenerate them by loading the livery in the menu and on track"
            Remove-DDSFiles -files "_0" -path $customsPath -Whatif $false
            Remove-DDSFiles -files "_1" -path $customsPath -Whatif $false
        }
    }
    return $choice
}

# Main
Show-Menu -choice $choice