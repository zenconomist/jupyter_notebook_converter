-- SignedComment: ## Test2 Stored Procedure
-- This is an example stored procedure that demonstrates
-- the use of various custom annotations for converting
-- to a Jupyter notebook.

CREATE PROCEDURE Test2
AS
BEGIN
    -- SignedComment: ### Step 1: Create a Common Table Expression (CTE)
    -- NewCell
    WITH cte_example AS (
        SELECT
            Column1,
            Column2,
            Column3
        FROM
            SomeTable
        -- DemoWhere: Column1 = 'example'
    )
    -- SignedComment: ### Step 2: Insert data into a temporary table
    -- NewCell
    SELECT
        Column1,
        Column2,
        Column3
    INTO
        #TempTable
    FROM
        cte_example
    -- DemoWhere: Column2 > 100

    -- SignedComment: ### Step 3: Perform a final SELECT
    -- NewCell
    SELECT
        Column1,
        Column2,
        SUM(Column3) AS TotalColumn3
    FROM
        #TempTable
    GROUP BY
        Column1,
        Column2
    -- DemoWhere: TotalColumn3 > 1000
END
