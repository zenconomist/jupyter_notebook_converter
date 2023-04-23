function Convert-StoredProcedureToNotebook {
    param (
        [string]$InputFile,
        [string]$OutputFile
    )

    # Read the stored procedure script
    $scriptContent = Get-Content -Path $InputFile -Raw

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

    # Split the script into individual lines
    $lines = $scriptContent -split "`r`n"

    # Process each line
    $currentSql = ""
    foreach ($line in $lines) {
        # Detect a signed comment
        if ($line -match "--\s*?SignedComment:\s*?(.*)") {
            $comment = $Matches[1]

            $markdownCell = @{
                cell_type = "markdown"
                source    = $comment
                metadata  = @{}
            }

            $notebook.cells += $markdownCell
        }
        # Detect a custom annotation for a new code cell
        elseif ($line -match "(--\s*?NewCell\s*?$)") {
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
        }
        # Detect a custom annotation to add a WHERE clause for demonstration purposes
        elseif ($line -match "(--\s*?DemoWhere:\s*?(.+))") {
            $demoWhere = $Matches[2]
            $currentSql += " WHERE $demoWhere`n"
        }
        # Add other lines to the current SQL statement
        else {
            $currentSql += $line + "`n"
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