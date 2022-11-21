

SELECT
	
	T0.U_ITEMCODE,	
	([dbo].[C_MM_INCH] (T1.SWidth1))	'Width',
	T4.U_Width							'OrderedWidth',
	T1.SHeight1							'Gauge', 
	T4.U_Gauge							'OrderedGauge',
	([dbo].[C_MM_INCH] (T1.SLength1))	'Length',
	T4.U_Length							'OrderedLength',	
	T2.DocNum							'SO',
	T0.U_BATCHNO						'BatchNo.',	
	T4.LineNum,
	UPPER(T2.CardName)					'Customer', 
	T2.CardCode, 
	T4.ShipDate,
	T4.Quantity							'Ordered',
	T6.Quantity							'Delivered',
	T1.OnHand							'Reserved',
	(T4.Quantity-T6.Quantity-T1.OnHand)	'Remaining'


FROM  "@BMM_PNMAST" T0

	LEFT OUTER JOIN OITM T1 ON T1.ItemCode=T0.U_ITEMCODE
	LEFT OUTER JOIN ORDR T2 ON T2.DocNum=T0.U_SONUMBER
	INNER JOIN "@BMM_PNITEM" T3 ON T3.DocEntry=T0.DocEntry
	LEFT OUTER JOIN RDR1 T4 ON T4.ItemCode=T1.ItemCode AND T4.DocEntry=T2.DocEntry
	INNER JOIN OCRD T5 ON T5.CardCode=T2.CardCode
	RIGHT OUTER JOIN DLN1 T6 ON  T6.BaseEntry=T4.DocEntry	AND T6.DocEntry=T4.TrgetEntry AND T6.LineNum=T4.LineNum

	
WHERE 

	T4.ShipDate	>=CONVERT(DATETIME, '20220401', 112)	AND 
	T4.ShipDate	<=CONVERT(DATETIME, '20220405', 112)	AND	
	T3.U_LINETYPE=7										AND
	T4.LineStatus='O'									AND
	T5.QryGroup1='N'


ORDER BY

	T2.DocNum,
	T4.LineNum

--SELECT * FROM ORDR WHERE DocNum=511331
--SELECT * FROM RDR1 WHERE DocEntry=9005