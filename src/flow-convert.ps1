param (
    [Parameter(Mandatory=$true)]
    [string] $solutionZipPath,

    [Parameter(Mandatory=$true)]
    [string] $replacementsFilePath,

    [Parameter(Mandatory=$true)]
    [string] $outputFolder
)


## Ensure solution file exists, Ensure replacement file exists
if (-not $(Test-Path $solutionZipPath)) {
    Write-Error "Solution file provided doesn't exist: $solutionZipPath" -ErrorAction Stop
}
if (-not $(Test-Path $replacementsFilePath)) {
    Write-Error "Replacement file provided doesn't exist: $replacementsFilePath" -ErrorAction Stop
}


## Ensure output folder exists
if (-not $(Test-Path ".\$outputFolder")) {
    mkdir ".\$outputFolder"
}


## Read contents of the XML file
$replacementsXml = [xml]($([IO.File]::ReadAllLines($replacementsFilePath)))
$replacements = $replacementsXml.SelectNodes("//Replacement")


## Extract solution to temp folder
$tempFolderName = "temp_$(Get-Date -Format "yyyyMMddHHmmss")"
Expand-Archive -Path $solutionZipPath -DestinationPath ".\$tempFolderName"


## Foreach JSON file, Foreach replacement, Replace
$jsonFiles = Get-ChildItem ".\$tempFolderName" -Recurse -Filter *.json
foreach ($jsonFile in $jsonFiles) {
    Write-Host "File: $($jsonFile.FullName)"

    foreach ($replacement in $replacements) {
        Write-Host " - $($replacement.Description)
        - $($replacement.SourceValue)  =>  $($replacement.TargetValue)"

        (Get-Content $jsonFile.FullName).replace($replacement.SourceValue, $replacement.TargetValue) | Set-Content $jsonFile.FullName
    }

    Write-Host ""
}


## Zip temp folder to output folder, delete temp folder
$solutionName = [System.IO.Path]::GetFileName($solutionZipPath)
Compress-Archive -Path ".\$tempFolderName\*" -DestinationPath ".\$outputFolder\$solutionName" -Update
Remove-Item -Path ".\$tempFolderName" -Recurse


Write-Host "Complete.
 - Output File: .\$outputFolder\$solutionName
"