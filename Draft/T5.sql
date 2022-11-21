

SELECT 
	
	T0.DocEntry			AS 'DocNum_ORCT',
	T0.Canceled,
	T0.DocDate			AS 'DocDateIPInv',
	T3.DocEntry			AS 'DocEntryInv',
	T3.DocNum,
	T3.SlpCode, 
	T1.SumApplied


FROM ORCT T0 

	INNER JOIN RCT2 T1 ON T1.DocNum=T0.DocNum 
	INNER JOIN OINV T3 ON T3.DocEntry=T1.DocEntry	AND T1.InvType=13

WHERE 

	T0.Canceled='N'	AND	T1.InvType=13	AND
	T0.DocDate >=CONVERT(DATETIME, '20220101', 112) AND T0.DocDate <=CONVERT(DATETIME, '20220131', 112)	AND
	T3.SlpCode=11 AND T3.DocNum=703117 

GROUP BY
	T0.DocEntry,
	T0.Canceled,
	T0.DocDate,
	T3.DocEntry,
	T3.DocNum,
	T3.SlpCode,
	T1.SumApplied
