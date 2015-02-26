[CmdletBinding()]
Param(
  [Parameter(Mandatory=$false,
    ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,
    HelpMessage='A stream of bytes in lieu of the Zip file; can be piped to this script')]
  [byte[]]$Content,

  [Parameter(Mandatory=$false,
    HelpMessage='The name of the Zip file')]
  [ValidatePattern("^.*\.zip$")]
  [string]$FileName,

  [Parameter(Mandatory=$false,
    HelpMessage='Absolute path to a pre-existing folder you would like to extract to')]
  [ValidateScript({($_ -match "^[a-z]\:.*") -and (Test-Path -PathType Container $_)})]
  [string]$ExpandTo,

  [Parameter(Mandatory=$false,
    HelpMessage='Do you want the Windows copy progress bar? (Default: NO)')]
  [switch]$Silent=$true,

  [Parameter(Mandatory=$false,
    HelpMessage='Over-write destination files? (Default: YES)')]
  [switch]$NoOverwrite=$false
 )

# The flags I use while copying to destination below
# Got from https://technet.microsoft.com/en-us/library/ee176633.aspx
# 0x10 => overwrite; 0x4 => silent; add these two if you want silent & overwrite
# I will stick with 0x14 as default
if ($Silent) { 
    if ($NoOverwrite) { $CopyFlags = 0x4 } else { $CopyFlags = 0x14 }
} else {
    if ($NoOverwrite) { $CopyFlags = 0x0 } else { $CopyFlags = 0x10 }
}

# Abort if a filename or stream are not given. Discovered this during testing. Rookie mistake! 
if (!$Content -and !$FileName) { throw "You must specify a filename or a stream of bytes. Aborting!" }

# If I am given a stream of bytes, create a temp file for later use
if ($Content) {
    $TempFile = Set-Content -Encoding Byte -Value $Content -Path "${Env:\TEMP}\$(Get-Random).zip" -PassThru
    $FileName = $TempFile.PSPath
}

# Create a new Shell COM object. See https://msdn.microsoft.com/en-us/library/windows/desktop/bb774094%28v=vs.85%29.aspx 
$Shell = New-Object -ComObject shell.application

# The NameSpace method takes a folder (zip file in this case) and returns a Folder object to it
# See https://msdn.microsoft.com/en-us/library/windows/desktop/bb774085%28v=vs.85%29.aspx
$ZipFile = $Shell.NameSpace($FileName)

# This is for the progress report below
$ItemCount = 0
$TotalCount = $ZipFile.Items().Count

# Enumerate the contents of the Zip file by going through each item in it. 
ForEach ($Item in $ZipFile.Items()) {
    # This time we create a Folder object to the destination path and use the CopyHere() method. 
    # See https://msdn.microsoft.com/en-us/library/windows/desktop/bb787866%28v=vs.85%29.aspx
    # This method takes a second flag which determines options for the Copy process. Above link has details. 
    # Not sure if those numbers are accurate though. I found another link - https://technet.microsoft.com/en-us/library/ee176633.aspx - 
    # based on which I decided to use 0x10 or 0x14 depending on what the user wants (see the variable $CopyFlags above)
    Write-Progress -Activity "Copying to $ExpandTo" -CurrentOperation "File: $($Item.Name)" -PercentComplete $($ItemCount/$TotalCount*100)
    $Shell.Namespace($ExpandTo).copyhere($Item, $CopyFlags)
    $ItemCount++
}

# Remove the temp file if I was given a stream of bytes
if ($Content) { Remove-Item -Force $TempFile.PSPath }

## TODO:
## <nothing as of now>

## INSPIRED BY:
## http://www.howtogeek.com/tips/how-to-extract-zip-files-using-powershell/