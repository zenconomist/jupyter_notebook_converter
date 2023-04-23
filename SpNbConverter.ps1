
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