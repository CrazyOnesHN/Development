 SELECT 
 "INV1"."Quantity", 
 "INV1"."LineTotal", 
 "INV1"."PriceBefDi", 
 "INV1"."DiscPrcnt", 
 "INV1"."Dscription", 
 "OITM"."SLength1", 
 "OITM"."SWidth1", 
 "OITM"."SHeight1", 
 "OINV"."DocNum", 
 "OINV"."DocDate", 
 "OINV"."Comments", 
 "INV1"."BaseType", 
 "DLN1"."BaseRef", 
 "INV1"."BaseRef", 
 "OINV"."CardName", 
 "OINV"."CANCELED", 
 "OSLP"."SlpName", 
 "OSLP"."SlpCode"


 FROM  
  ((("KINYO-LIVE"."dbo"."OINV" "OINV" INNER JOIN 
  "KINYO-LIVE"."dbo"."INV1" "INV1" ON "OINV"."DocEntry"="INV1"."DocEntry") 
  INNER JOIN "KINYO-LIVE"."dbo"."OSLP" "OSLP" ON "OINV"."SlpCode"="OSLP"."SlpCode") 

  LEFT OUTER JOIN "KINYO-LIVE"."dbo"."OITM" "OITM" ON "INV1"."ItemCode"="OITM"."ItemCode") 
  LEFT OUTER JOIN "KINYO-LIVE"."dbo"."DLN1" "DLN1" ON ("INV1"."BaseEntry"="DLN1"."DocEntry")   AND ("INV1"."LineNum"="DLN1"."LineNum")
  LEFT OUTER JOIN "KINYO-LIVE"."dbo"."OCRD" "OCRD" ON ("OCRD"."CardCode"="OINV"."CardCode") 

 WHERE  

 "OINV"."CANCELED"='N' AND 
 ("OINV"."DocDate">={ts '2021-01-02 00:00:00'} AND 
 "OINV"."DocDate"<{ts '2021-01-31 00:00:00'}) 

 AND "OCRD"."QryGroup1"='N'	--AND  "OINV"."DocType"='S'
 
 ORDER BY "OINV"."DocNum"


