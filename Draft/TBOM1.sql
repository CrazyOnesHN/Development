 SELECT 
 "OINV"."DocDate", 
 "OINV"."DocNum", 
 "INV1"."ItemCode", 
 "INV1"."LineNum", 
 "INV1"."Quantity", 
 "OINV"."CANCELED", 
 "Z_CSTDIST"."LaborCost", 
 "OITM"."ItmsGrpCod", 
 "Z_CSTDIST"."LaborOHCost", 
 "Z_CSTDIST"."MFGOHCost", 
 "OITM"."AvgPrice", 
 "Z_CSTDIST"."ValidTo", 
 "Z_COST"."ValidTo" 
 
 FROM   
 ((("OINV" "OINV" INNER JOIN "INV1" "INV1" ON "OINV"."DocEntry"="INV1"."DocEntry") 
 LEFT OUTER JOIN "Z_CSTDIST" "Z_CSTDIST" ON "INV1"."ItemCode"="Z_CSTDIST"."ItemCode") 
 LEFT OUTER JOIN "Z_COST" "Z_COST" ON "INV1"."ItemCode"="Z_COST"."ItemCode") 
 LEFT OUTER JOIN "OITM" "OITM" ON "INV1"."ItemCode"="OITM"."ItemCode" 
 
 WHERE  
 "OINV"."CANCELED"='N' AND 
 ("OINV"."DocDate">={ts '2022-04-01 00:00:00'} AND 
 "OINV"."DocDate"<{ts '2022-05-01 00:00:00'}) AND 
 "Z_CSTDIST"."ValidTo" IS  NULL  AND "Z_COST"."ValidTo" IS  NULL 


 ORDER BY "OINV"."DocNum"