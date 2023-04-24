function Convert-StoredProcedureToNotebook {
    param (
        [string]$InputFile,
        [string]$OutputFile
    )

    # Read the stored procedure script
    $scriptContent = Get-Content -Path $InputFile

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

    # # Split the script into individual lines
    # $lines = $scriptContent -split "\r`n", 0, "RegexMatch"

    # Process each line
    $currentSql = ""

    foreach ($line in $scriptContent) {

        Write-Output "new line: " + $line

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
            $currentSql += $line + "`n"

            # If the current line is a SELECT statement or a custom NewCell annotation,
            # add the current SQL code cell and reset the currentSql variable
            if (($line -match "^\s*SELECT") -or ($line -match "--\s*?NewCell\s*?$")) {
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