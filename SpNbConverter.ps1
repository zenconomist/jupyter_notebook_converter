
<# 
# This script will convert all stored procedures in a folder to IPYNB notebooks, execute the notebooks, and convert the executed notebooks to markdown files.

$notebooksFolderPath = "./" # path\to\your\generated\notebooks
$generatedSqlPath = "./" # path\to\generated\sql

$notebookFiles = Get-ChildItem -Path $notebooksFolderPath -Filter *.ipynb

foreach ($notebookFile in $notebookFiles) {
    $sqlFileName = $notebookFile.BaseName + ".sql"

    # Convert the IPYNB notebook back to a stored procedure .sql file
    Convert-NotebookToStoredProcedure -InputFile $notebookFile.FullName -OutputFile "$generatedSqlPath\$sqlFileName"
}
#>

function Convert-StoredProcedureToNotebook_Debug {
    param (
        [string]$InputFile,
        [string]$OutputFile
    )

    # Read the stored procedure script
    $scriptContent = Get-Content -Path $InputFile

    # Split the script into individual lines
    $lines = $scriptContent -split "`n"

    # Create the IPYNB file structure
    $notebook = @{
        cells    = @()
        metadata = @{
            kernelspec = @{
                display_name = "SQL"
                language     = "sql"
                name         = "mssql"
            }
            language_info = @{
                codemirror_mode = "sql"
                file_extension  = ".sql"
                mimetype        = "text/x-sql"
                name            = "sql"
            }
        }
        nbformat        = 4
        nbformat_minor  = 5
    }

    # Process each line
    $currentSql = ""

    # Process each line
    foreach ($line in $lines) {
        Write-Output $line


        if ($line -match "--\s*?SignedComment:\s*?(.+)") {
            $comment = $Matches[1]

            # Add the current SQL code cell, if any
            if ($currentSql -ne "") {
                $sqlCell = @{
                    cell_type = "code"
                    source    = $currentSql
                    metadata  = @{
                        trusted = $true
                    }
                    outputs = @()
                }

                $notebook.cells += $sqlCell
                $currentSql = ""
            }

            # Add the markdown cell
            $markdownCell = @{
                cell_type = "markdown"
                source    = $comment
                metadata  = @{}
            }

            $notebook.cells += $markdownCell
        }
        # Add other lines to the current SQL statement
        else {
            if ($line -match "--\s*?NewCellStart\s*?$") {
                $insideNewCell = $true
            } elseif ($line -match "--\s*?NewCellEnd\s*?$") {
                $insideNewCell = $false

                if ($currentSql -ne "") {
                    $sqlCell = @{
                        cell_type = "code"
                        source    = $currentSql
                        metadata  = @{
                            trusted = $true
                        }
                        outputs = @()
                    }

                    $notebook.cells += $sqlCell
                    $currentSql = ""
                }
            } elseif ($insideNewCell) {
                $currentSql += $line -replace "--\s*?DemoWhere", "" + "`n"
            } else {
                $currentSql += $line + "`n"
            }
        }

    }

    # Add the last SQL statement, if any
    if ($currentSql -ne "") {
        $sqlCell = @{
            cell_type = "code"
            source    = $currentSql
            metadata  = @{
                trusted = $true
            }
            outputs = @()
        }

        $notebook.cells += $sqlCell
    }

    # Convert the notebook structure to JSON and save it to the output file
    $json = $notebook | ConvertTo-Json -Depth 10
    Set-Content -Path $OutputFile -Value $json

        
}
# include the script that converts stored procedures to notebooks
. .\SpToNotebookConverter.ps1

# include the script that converts notebooks to stored procedures
. .\NbToSpConverter.ps1


# This script will convert all stored procedures in a folder to IPYNB notebooks, execute the notebooks, and convert the executed notebooks to markdown files.
$scriptFolderPath = "./" # path\to\your\stored\procedures
$generatedNotebooksPath = "./" # path\to\your\generated\notebooks
$generatedMarkdownPath = "./" # path\to\your\generated\markdown

$scriptFiles = Get-ChildItem -Path $scriptFolderPath -Filter *.sql

# $jupyter_path=$(pip show jupyter | grep -i 'Location:' | awk '{print $2 "/jupyter"}')

foreach ($scriptFile in $scriptFiles) {
    $notebookName = $scriptFile.BaseName + ".ipynb"
    $markdownName = $scriptFile.BaseName + ".md"

    # Generate the IPYNB notebook
    Convert-StoredProcedureToNotebook -InputFile $scriptFile.FullName -OutputFile "$generatedNotebooksPath\$notebookName"

    # Execute all cells in the IPYNB notebook
    #$jupyter_path nbconvert --to notebook --execute --inplace --ExecutePreprocessor.kernel_name=mssql --ExecutePreprocessor.timeout=600 "$generatedNotebooksPath\$notebookName"

    # Convert the executed IPYNB notebook to a markdown file
    #$jupyter_path nbconvert --to markdown "$generatedNotebooksPath\$notebookName" --output "$generatedMarkdownPath\$markdownName"
}

