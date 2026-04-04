SELECT
    '{company_code}' AS "company_code",
    T0."ItemCode" AS "item_id",
    COALESCE(T1."ItmsGrpNam", '') AS "item_group",
    COALESCE(T0."U_BusinessType", '') AS "business_type_udf",
    COALESCE(T0."InvntryUom", '') AS "uom",
    CASE
        WHEN COALESCE(T0."validFor", 'Y') = 'Y' AND COALESCE(T0."frozenFor", 'N') = 'N' THEN 1
        ELSE 0
    END AS "active_flag"
FROM "{schema}"."OITM" T0
LEFT JOIN "{schema}"."OITB" T1
    ON T0."ItmsGrpCod" = T1."ItmsGrpCod";
