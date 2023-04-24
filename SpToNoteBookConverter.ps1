function Convert-StoredProcedureToNotebook {
    param (
        [string]$InputFile,
        [string]$OutputFile
    )

    # Read the stored procedure script
    $lines = Get-Content -Path $InputFile

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
    $insideNewCell = $false

    foreach ($line in $lines) {
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
                $line = $line -replace "--\s*?DemoWhere", ""
                if (-not ($line -match "^\s*WITH" -or $line -match "^\s*\)")) {
                    $currentSql += $line + "`n"
                }
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
