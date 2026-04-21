# Path to Assetto Corsa Competizione Customs Folder
$customsPath = "$env:USERPROFILE\Documents\Assetto Corsa Competizione\Customs\" 

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
        # Write-Output 'No Cars folder located in this directory. Was it moved to another drive?'
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
                    $text = Get-Content -$file -raw -Encoding UTF8 -ErrorAction Stop
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
        } if (($skinNames).count -gt 0) {
            return $skinNames
            if (($skipped).count -gt 0) {
                return $skipped
            }
        }
    }
}
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
        # Write-Output 'No Cars folder located in this directory. Was it moved to another drive?'
        return $false
    }

    if ((($false -ne $ddsFiles) -and ($ddsFiles).count -gt 0) -and $true -eq $Whatif) {
        $fileCountWhatIf = $ddsFiles.Count
        $whatifCount = 0
        do {
            for (($i=0), ($ddsFiles[$i]);$i -le $fileCountWhatIf; ($i++), ($ddsFiles[$i++])) {
                $percentage = ($i / $fileCountWhatIf) * 100
                $ddsFolderName = ($ddsFiles[$i] -split '\\')[$liveryFolderCount]
                $ddsFolderFile = ($ddsFiles[$i] -split '\\')[$liveryFolderCount + 1]
                $ddsRemovalDetails = $ddsFolderName, $ddsFolderFile -join ' contents '
                Write-Log -Message " Would remove folder $ddsRemovalDetails"
                Write-Progress -Activity "Deleting $i / $fileCountWhatIf files" -CurrentOperation "Removing $ddsFolderName file $ddsFolderFile" -Status "$percentage% Complete" -PercentComplete $percentage
                $whatifCount++
            }
        } until ($whatifCount -le $fileCountWhatIf)
    } elseif ((($false -ne $ddsFiles) -and ($ddsFiles).count -gt 0) -and $false -eq $Whatif) {
        $fileCount = $ddsFiles.Count
        $ddsFileCount = 0
        do {
            for (($i=0), ($ddsFiles[$i]);$i -le $fileCount; ($i++), ($ddsFiles[$i++])) {
                $percentage = ($i / $fileCount) * 100
                $ddsFolderName = ($ddsFiles[$i] -split '\\')[$liveryFolderCount]
                $ddsFolderFile = ($ddsFiles[$i] -split '\\')[$liveryFolderCount + 1]
                $ddsRemovalDetails = $ddsFolderName + " contents " + $ddsFolderFile
                Remove-Item -Path $ddsFiles[$i]
                Write-Progress -Activity "Deleting $i / $fileCount files" -CurrentOperation "Removing $ddsFolderName file $ddsFolderFile" -Status "$percentage% Complete" -PercentComplete $percentage
            }
        } until ($ddsFileCount -le $fileCount)
    } else {
        Write-Output "No dds files found"
    }
}
function Show-Menu {
    $Title = "What do you want the livery cleaner to do?
    To cancel, use CTRL+C"
    $Prompt = " 
    Option 0: See what would be removed(default)
    Option 1: Remove all liveries without Cars file
    Option 2: Remove _0.dds files
    Option 3: Remove _1.dds files
    Option 4: Remove all DDS files
    "
    $Choices = [System.Management.Automation.Host.ChoiceDescription[]] @("0","1","2","3","4")
    $Default = 0
    $Choice = $host.UI.PromptForChoice($Title, $Prompt, $Choices, $Default)
    switch ($choice) {
        0{Write-Output "Perform Test run of Option 1:Log File will be generated for review here: "}
        1{write-output "Removing all livery files you don't have a car file for. You will only see the liveries you can select in the menu"}
        2{write-output "Removing all _0.dds files from your liveries directory. You can regenerate them by loading the livery in the menu"}
        3{write-output "Removing all _1.dds files from your liveries directory. You can regenerate them by loading the livery on track"}
        4{write-output "Removing all dds files from your liveries directory. You can regenerate them by loading the livery in the menu and on track"}
    }
}