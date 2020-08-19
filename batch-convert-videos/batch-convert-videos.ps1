# Batch convert videos with HandbrakeCLI. Assumes exe to be alongside this script

param(
    # Directory to look in
    [Parameter(Mandatory)]
    [string]$Directory,
    
    # Filter for files
    [Parameter(Mandatory=$false)]
    [string]$Filter = "*.ts",

    # Name of Handbrake preset
    [Parameter(Mandatory=$false)]
    [string]$PresetName = "Fast 1080p30",

    # Path to custom preset file
    [Parameter(Mandatory=$false)]
    [string]$PresetImportFile,

    # Extension of output file
    [Parameter(Mandatory=$false)]
    [string]$ExportFileExtension = "m4v",

    # Whether to delete converted file
    [Parameter(Mandatory=$false)]
    [switch]$KeepOriginal = $false,

    # Flag to perform dry run
    [Parameter(Mandatory=$false)]
    [switch]$DryRun = $false
)

$filelist = Get-ChildItem -Path $Directory -Filter $Filter -Recurse
 
$num = $filelist | Measure-Object
$filecount = $num.count
 
$i = 0;
ForEach ($file in $filelist)
{
    $i++;
    $oldfile = $file.DirectoryName + "\" + $file.BaseName + $file.Extension;
    $newfile = $file.DirectoryName + "\" + $file.BaseName + ".$ExportFileExtension";
      
    $progress = ($i / $filecount) * 100
    $progress = [Math]::Round($progress,2)
 
    Clear-Host
    Write-Host -------------------------------------------------------------------------------
    Write-Host Handbrake Batch Encoding
    Write-Host "Processing - $oldfile"
    Write-Host "File $i of $filecount - $progress%"
    Write-Host -------------------------------------------------------------------------------
     
    $presetImportFileArgument = ""
    if ($PresetImportFile -ne "")
    {
        $presetImportFileArgument = "--preset-import-file ""$PresetImportFile"""
    }

    #Start-Process "C:\Program Files\HandBrake\HandBrakeCLI.exe" -ArgumentList "-i `"$oldfile`" -t 1 --angle 1 -c 1 -o `"$newfile`" -f mp4  -O  --decomb --modulus 16 -e x264 -q 32 --vfr -a 1 -E lame -6 dpl2 -R Auto -B 48 -D 0 --gain 0 --audio-fallback ffac3 --x264-preset=veryslow  --x264-profile=high  --x264-tune=`"animation`"  --h264-level=`"4.1`"  --verbose=0" -Wait -NoNewWindow
    $handbrakeCommand =  """$presetImportFileArgument"" -Z ""$PresetName"" -i ""$oldfile"" -o ""$newfile"""

    if ($DryRun)
    {
        Write-Output "Dry run ... Start-Process HandBrakeCLI.exe $handbrakeCommand"
    }
    else 
    {
        Start-Process "$PSScriptRoot\HandBrakeCLI.exe" -ArgumentList "$handbrakeCommand" -Wait -NoNewWindow
    }

    if (!$DryRun && !$KeepOriginal) 
    {
        if (Test-Path $newfile) 
        {
            Remove-Item -path $oldfile
            Write-Host "Deleted: $oldfile"
        }
    }
}