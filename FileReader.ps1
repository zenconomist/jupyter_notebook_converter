function ReadFileLineByLine {
    param (
        [string]$InputFile
    )

    # Read the file content
    $fileContent = Get-Content -Path $InputFile

    # Process each line and write it to the standard output
    foreach ($line in $fileContent) {
        Write-Output "new line: " + $line
    }
}

# Example usage
ReadFileLineByLine -InputFile "./TestSp2.sql"
