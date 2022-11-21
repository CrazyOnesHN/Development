

--SELECT 

--	T0.DocNum				AS	'Invoice',
--	T4.BaseRef				AS  'OrderNum',
--	T0.Comments,
--	T0.DocDate,
--	T0.CardName,
--	T0.CardCode,
--	T2.SlpName,
--	T1.LineNum,
--	T1.LineTotal,
--	T1.Dscription,
--	T1.PriceBefDi,
--	T1.DiscPrcnt,
--	T3.SLength1				AS  'Around',
--	T3.SWidth1				AS  'Across',
--	T3.SHeight1				AS  'Gauge',
--	T1.Quantity





--FROM OINV T0	WITH (NOLOCK)

--	INNER JOIN INV1			T1		ON	T1.DocEntry=T0.DocEntry
--	INNER JOIN OSLP			T2		ON	T2.SlpCode=T1.SlpCode
--	LEFT  OUTER JOIN OITM	T3		ON	T3.ItemCode=T1.ItemCode
--	LEFT  OUTER JOIN DLN1	T4		ON	T4.DocEntry=T1.BaseEntry	AND	T1.LineNum=T4.LineNum
--	LEFT  OUTER JOIN OCRD	T5		ON	T5.CardCode=T0.CardCode

--WHERE 
--	T0.DocDate >='2022-02-01 00:00:00'	AND	T0.DocDate <='2022-03-01 00:00:00'	AND--	T0.CANCELED='N'						AND T5.QryGroup1='N'							----AND----T0.SlpCode=7--ORDER BY T0.DocNumSELECT T0.DocNum,T0.DocDate,T0.DocTotal,T0.GrosProfitFROM OINV T0 WITH (NOLOCK)WHERE 	T0.DocDate >='2022-02-01 00:00:00'	AND	T0.DocDate <='2022-02-28 00:00:00'	AND	T0.CANCELED='N'	