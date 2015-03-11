# # See http://rakhesh.com/powershell/search-firefox-bookmarks-using-powershell/

# 1) Source the script
# 2) Export your Firefox bookmarks into a JSON file
# 3) Read those bookmarks into a variable
#    $bookmarks = Get-Content \path\to\bookmarks-2015-03-11.json | ConvertFrom-Json 
# 4) Then do Search-FxBookmarks -Bookmarks $bookmarks -SearchString "whatever"

function Search-FxBookmarks {
    param($Bookmarks, [string]$PathSoFar="", [string]$SearchString)
    
    $NodeName = $Bookmarks.title
    $NewPath = "$PathSoFar\$NodeName"

    if ($Bookmarks.type -eq "text/x-moz-place-container") {
        # We are on a non-leaf node
        # Check if the non-leaf node name itself matches the search string
        if ($NodeName -match $SearchString) { Write-Host -ForegroundColor Cyan "$PathSoFar\$NodeName" } 

        # Then call ourselves recursively for each of the children
        foreach ($Bookmark in $Bookmarks.children) {
            Search-FxBookmarks -Bookmarks $Bookmark -PathSoFar $NewPath -SearchString $SearchString
        }
    }

    if ($Bookmarks.type -eq "text/x-moz-place") {
        # We are on a leaf node, search if the title matches the search string
        if ($NodeName -match $SearchString) { Write-Host -ForegroundColor Green "$PathSoFar\$NodeName" } 
    }
}