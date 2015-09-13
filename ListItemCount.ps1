# Load SharePoint library
[system.reflection.assembly]::LoadWithPartialName("Microsoft.Sharepoint")

# Connect to the site collection http://SP2010 and store the object in the $site variable
$site = New-Object Microsoft.SharePoint.SPSite("http://Site Name/")

# Connect to the root site in the site collection and store the object in $root
$root = $site.rootweb

# Library name
$docs = $root.lists["Library name"]

# Count the library item
$listitems = $docs.Items.Count
Write-Host "Items in list: " $listitems
 