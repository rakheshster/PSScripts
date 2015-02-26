[CmdletBinding()]
Param(
  [Parameter(Mandatory=$true)]
  [ValidatePattern("^(http|https|ftp)\://.*$")]
  [string]$Url,

  [Parameter(Mandatory=$false)]
  [string]$FileName,

  [Parameter(Mandatory=$false)]
  [switch]$PassThru
)

# Note: 
# 1) I don't check if $FileName already exists or whether the path is correct. Maybe add that later ...

if ($PassThru) { 
    Invoke-WebRequest $Url
} else {
    if ($FileName) { 
        Invoke-WebRequest $Url -OutFile $FileName
    } else {
        Invoke-WebRequest $url -OutFile $(Split-Path -Leaf $Url)
    } 
}