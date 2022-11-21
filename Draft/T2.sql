

SELECT 

T1.CardCode,
T1.CardName,
T2.SlpName,
T1.DocNum,
T1.DocDate,
T1.DocTotal,
T4.DocNum,
T3.SumApplied,
T4.DocEntry,
T3.DocEntry


FROM OCRD T0

	INNER JOIN ORCT T1 ON T0.CardCode=T1.CardCode
	LEFT  JOIN OSLP T2 ON T2.SlpCode=T0.SlpCode
	INNER JOIN RCT2 T3 ON T3.DocNum=T1.DocNum
	INNER JOIN OINV T4 ON T4.DocEntry=T3.DocEntry AND T3.InvType='13'

WHERE 
T1.DocDate >='2022-03-01 00:00:00.000' AND 
T1.DocDate <='2022-03-29 00:00:00.000'


ORDER BY T4.DocNum,T1.DocDate