	DECLARE @DATE_FROM	DATETIME
DECLARE @DATE_TO	DATETIME
DECLARE @EXTRACT	VARCHAR(10)

SET @DATE_FROM=(SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0))
SET @EXTRACT=CONVERT(VARCHAR(8),DATEADD(MONTH,1,@DATE_FROM),112)
SET @DATE_TO=DATEADD(DAY,-1,LEFT(@EXTRACT,6)+'01')
	
	SELECT

	T2.CardName														'Customer',
	T2.DocNum														'SO',
	T1.LineNum,
	T1.ItemCode,
	([dbo].[FETCH_BATCHNO] (T1.ItemCode,T2.DocNum,T2.DocEntry))		'BatchNo.',
	([dbo].[C_MM_INCH] (T4.SLength1))								'Length(in)',
	([dbo].[C_MM_INCH] (T4.SWidth1))								'Width(in)',
	T4.SHeight1														'Gauge',
	T1.ShipDate														'PSD',
	ISNULL(T1.Quantity,0)											'Ordered',
	ISNULL(T0.Quantity,0)											'Delivered',
	ISNULL(T4.OnHand,0)												'Reserved',
	ISNULL((T1.Quantity-T0.Quantity-T4.OnHand),0)					'Remaining',
	T1.U_Notes

	FROM DLN1 T0

		--FETCH Sales Order
		RIGHT OUTER JOIN RDR1	T1 ON T1.DocEntry=T0.BaseEntry	AND T1.TrgetEntry=T0.DocEntry
		INNER JOIN ORDR T2 ON T2.DocEntry=T1.DocEntry
		LEFT JOIN OCRD T3 ON T3.CardCode=T2.CardCode
		INNER JOIN OITM T4 ON T4.ItemCode=T1.ItemCode
		LEFT  OUTER JOIN OITB T5 ON T5.ItmsGrpCod=T4.ItmsGrpCod

	WHERE

		T1.ShipDate >=CONVERT(DATETIME,@DATE_FROM, 112)	AND
		T1.ShipDate <=CONVERT(DATETIME,@DATE_TO, 112)	AND
		T3.QryGroup1='N'		AND (T1.LineStatus='O'	AND T1.ItemCode LIKE '8%') OR (T1.LineStatus='O'	AND T1.ItemCode LIKE '9%')

	ORDER BY

		T2.DocNum,
		T1.LineNum,
		T1.ItemCode