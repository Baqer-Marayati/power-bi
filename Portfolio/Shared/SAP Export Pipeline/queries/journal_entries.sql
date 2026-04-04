SELECT
    '{company_code}' AS "company_code",
    T1."TransId" AS "journal_no",
    T1."Line_ID" AS "line_no",
    T0."RefDate" AS "posting_date",
    T1."Account" AS "account_code",
    COALESCE(T1."Debit", 0) AS "debit_lc",
    COALESCE(T1."Credit", 0) AS "credit_lc",
    CAST(COALESCE(T0."UserSign", -1) AS NVARCHAR(50)) AS "user_id"
FROM "{schema}"."OJDT" T0
INNER JOIN "{schema}"."JDT1" T1
    ON T0."TransId" = T1."TransId";
