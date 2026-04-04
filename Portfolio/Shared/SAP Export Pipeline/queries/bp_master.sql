SELECT
    '{company_code}' AS "company_code",
    T0."CardCode" AS "bp_id",
    CASE
        WHEN T0."CardType" = 'C' THEN 'customer'
        WHEN T0."CardType" = 'S' THEN 'vendor'
        ELSE 'lead'
    END AS "bp_type",
    COALESCE(T2."GroupName", '') AS "bp_group",
    COALESCE(T1."PymntGroup", '') AS "payment_terms",
    CASE
        WHEN COALESCE(T0."validFor", 'Y') = 'Y' AND COALESCE(T0."frozenFor", 'N') = 'N' THEN 1
        ELSE 0
    END AS "active_flag"
FROM "{schema}"."OCRD" T0
LEFT JOIN "{schema}"."OCTG" T1
    ON T0."GroupNum" = T1."GroupNum"
LEFT JOIN "{schema}"."OCRG" T2
    ON T0."GroupCode" = T2."GroupCode";
