SELECT
    '{company_code}' AS "company_code",
    CAST(T0."DocNum" AS NVARCHAR(50)) AS "doc_no",
    T0."CardCode" AS "bp_id",
    T0."DocDate" AS "posting_date",
    T0."DocDueDate" AS "due_date",
    COALESCE(T0."DocTotal", 0) - COALESCE(T0."PaidToDate", 0) AS "open_amount_lc",
    CASE
        WHEN DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 0 THEN DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE)
        ELSE 0
    END AS "days_overdue"
FROM "{schema}"."OPCH" T0
WHERE T0."DocStatus" = 'O'

UNION ALL

SELECT
    '{company_code}' AS "company_code",
    CAST(T0."DocNum" AS NVARCHAR(50)) AS "doc_no",
    T0."CardCode" AS "bp_id",
    T0."DocDate" AS "posting_date",
    T0."DocDueDate" AS "due_date",
    (COALESCE(T0."DocTotal", 0) - COALESCE(T0."PaidToDate", 0)) * -1 AS "open_amount_lc",
    CASE
        WHEN DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 0 THEN DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE)
        ELSE 0
    END AS "days_overdue"
FROM "{schema}"."ORPC" T0
WHERE T0."DocStatus" = 'O';
