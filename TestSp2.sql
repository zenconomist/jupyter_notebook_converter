/* SignedComment: ## Test2 Stored Procedure
    This is an example stored procedure that demonstrates
    the use of various custom annotations for converting
    to a Jupyter notebook.
*/

CREATE PROCEDURE Test2
AS
BEGIN
    -- SignedComment: ### Step 1: Create a Common Table Expression (CTE)

    WITH cte_example AS (
    --NewCellBegin_0
        SELECT
            Column1,
            Column2,
            Column3
        FROM
            SomeTable
        -- DemoWhere: Column1 = 'example'
    --NewCellEnd_0
    )
    -- SignedComment: ### Step 2: Insert data into a temporary table
    -- NewCellBegin_1
    SELECT
        Column1,
        Column2,
        Column3
    INTO
        #TempTable
    FROM
        cte_example
    -- DemoWhere: WHERE Column2 > 100
    -- NewCellEnd_1

    -- SignedComment: ### Step 3: Perform a final SELECT
    -- NewCellBegin_2
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
    -- NewCellEnd_2


    -- CTE example where 2 CTEs are used and a final SELECT is performed
    -- NewCellBegin_3
    ;WITH cte_example AS (
        SELECT
            Column1,
            Column2,
            Column3
        FROM
            SomeTable
        -- DemoWhere: Column1 = 'example'
    ),
    cte_example2 AS (
        -- NewCellBegin_4
        SELECT
            Column1,
            Column2,
            Column3
        FROM
            SomeTable
        -- DemoWhere: WHERE Column1 = 'example2'
        -- NewCellEnd_4
    )
    SELECT
        Column1,
        Column2,
        SUM(Column3) AS TotalColumn3
    FROM

        cte_example
    INNER JOIN
        cte_example2
    ON
        cte_example.Column1 = cte_example2.Column1

    GROUP BY
        Column1,
        Column2
    -- DemoWhere: WHERE TotalColumn3 > 1000
    -- NewCellEnd_3
END
