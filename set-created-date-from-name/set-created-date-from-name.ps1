# Looks for files in the given directory with names containing a date with format yyyy-mm-dd_hh:mm:ss
# Sets CreationTime and CreateDate (with exiftool)
# NOTE: REQUIRES exiftool in directory or in PATH
#
# Contains DryRun option to see which files will be processed

param(
    # Directory to look in
    [Parameter(Mandatory)]
    [string]$Directory,
    
    # Filter for files
    [Parameter(Mandatory=$false)]
    [string]$Filter = "*",

    # Flag to perform dry run
    [Parameter(Mandatory=$false)]
    [switch]$DryRun = $false
)

$filesToProcess = Get-ChildItem -Path $Directory -Filter $Filter

Write-Output "Start processing $($filesToProcess.Length)..."     
Write-Output ""
Write-Output ""

foreach ($file in $filesToProcess){
    if($File.BaseName -match '(\d{4})-?(\d{2})?-?(\d{2})?_?(\d{2})?-?(\d{2})?.?(\d{2})?'){
   
        #$file | Select-Object *

        $file | Select-Object Name,CreationTime

        $year = $Matches[1]
        $month = If ($Matches[2]) {$Matches[2]} Else {"01"}
        $day = If ($Matches[3]) {$Matches[3]} Else {"01"}
        $hour = If ($Matches[4]) {$Matches[4]} Else {"12"}
        $minute = If ($Matches[5]) {$Matches[5]} Else {"00"}

        $date = "$year-$month-$day ${hour}:$minute"

        $date_from_file = Get-Date $date
        Write-Output "Parsed date: $($date_from_file.ToString("s"))"

        Write-Output "Setting file.CreationTime"
        if ($DryRun) 
        { 
            "Dry run ... set file.CreationTime = $date_from_file" 
        }
        else
        {
            $file.CreationTime   = $date_from_file
            #$file.LastAccessTime = $date_from_file
            #$file.LastWriteTime  = $date_from_file
        }

        Write-Output "Setting CreateDate with exiftool"
        $exifToolCommand = "exiftool.exe -overwrite_original_in_place -api QuickTimeUTC -CreateDate=""$($date_from_file.ToString("s"))"" ""$($file.FullName)""" 

        if ($DryRun) 
        { 
            Write-Output "Dry run ... $exifToolCommand" 
        }
        else 
        { 
            Invoke-Expression $exifToolCommand 
        }
        
        Write-Output ""
    }
}

Write-Output ""
Write-Output ""
Write-Output "End processing"