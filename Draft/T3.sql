
SELECT 
T0.DocNum, 
T0.DocType, 
T0.DocTotal, 
( T0.DocTotal - T0.VatSum) As "Document Total Without VAT"  , 
T1.SlpName, 
T1.Commission, 
( ( T0.DocTotal - T0.VatSum)*( T1.Commission/100)) As "Sum_Commissions" 

FROM OINV T0  
INNER JOIN OSLP T1 ON T0.SlpCode = T1.SlpCode 

WHERE 

T1.SlpName  ='Chris Crescenzo' AND 
T0.DocDate >= CONVERT(DATETIME, '20220301', 112) AND  T0.DocDate <= CONVERT(DATETIME, '20220329', 112) 
AND T0.DocStatus='C'	AND T0.DocTotal <> 0

