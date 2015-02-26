# via http://www.howtogeek.com/tips/how-to-extract-zip-files-using-powershell/
Function Expand-ZipFile($file, $destination) 
{
    $shell = new-object -com shell.application
    $zip = $shell.NameSpace($file)
    foreach($item in $zip.items()) {
        $shell.Namespace($destination).copyhere($item)
    }
}

## TODO:
## 1) Take the inputs from pipeline so I can download something and unzip