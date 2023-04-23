
function Convert-NotebookToStoredProcedure {
    param (
        [string]$InputFile,
        [string]$OutputFile
    )

    # Read the IPYNB notebook content
    $notebookContent = Get-Content -Path $InputFile -Raw | ConvertFrom-Json

    # Initialize the SQL script content
    $sqlScript = ""

    # Iterate through the cells in the notebook
    foreach ($cell in $notebookContent.cells) {
        if ($cell.cell_type -eq "markdown") {
            # Convert markdown cells back to signed comments
            $sqlScript += "-- SignedComment: " + ($cell.source -join "`n") + "`n"
        } elseif ($cell.cell_type -eq "code") {
            # Add the SQL statements from code cells
            $sqlScript += ($cell.source -join "`n") + "`n"
        }
    }

    # Save the SQL script to the output file
    Set-Content -Path $OutputFile -Value $sqlScript
}