Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

#Log the exception

function log($string)
{
write-host $string -foregroundcolor "white"
$a =  Get-Date -format "dd_mm_yyyy_hh_mm_tt"
$string | out-file -Filepath "C:\$a.txt" -append
}

#Specify the path here where document you want to download

$destination = "C:\"

#Specify the site url here from where you wanted to download files

$webUrl = "http://Sharepoint site url/"

#Specify the share point library name here 

$listUrl = "ABC"

$web = Get-SPWeb -Identity $webUrl
$list = $web.GetList($listUrl)
function ProcessFolder {
param($folderUrl)
$folder = $web.GetFolder($folderUrl)
foreach($file in $folder.Files) {

#Ensure destination directory

Try {
$destinationFolder = $destination + "/" + $folder.Url
if(!(Test-Path -path $destinationFolder))
{
$dest = New-Item $destinationFolder -type directory
}

#Download file

$binary = $file.openBinary()

$stream = New-Object System.IO.FileStream($destinationFolder + "/" + $file.Name), Create

$writer = New-Object System.IO.BinaryWriter($stream)
$writer.write($binary)
$writer.Close()
}
Catch {
log $_  
}
}
}

#Download root files

ProcessFolder($list.RootFolder.Url)

#Download files in folders

foreach($folder in $list.Folders) {
ProcessFolder($folder.Url)
}
}
Write-Output ("Operation Completed Successfully")