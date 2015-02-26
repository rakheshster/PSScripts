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
  [string]$ExpandTo
)

if (!$Content -and !$FileName) { throw "You must specify a filename or a stream of bytes. Aborting!" }

if ($Content) {
    $TempFile = Set-Content -Encoding Byte -Value $Content -Path "${Env:\TEMP}\$(Get-Random).zip" -PassThru
    $FileName = $TempFile.PSPath
}

$Shell = New-Object -ComObject shell.application
$ZipFile = $Shell.NameSpace($FileName)

ForEach ($Item in $ZipFile.items()) {
    $Shell.Namespace($ExpandTo).copyhere($Item)
}

if ($Content) { Remove-Item -Force $TempFile.PSPath }

## TODO:
## <nothing as of now>

## INSPIRED BY:
## http://www.howtogeek.com/tips/how-to-extract-zip-files-using-powershell/