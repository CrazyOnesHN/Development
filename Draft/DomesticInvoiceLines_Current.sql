SELECT DISTINCT	T1.DocNum			AS	'Invoice/Credit Num',	T2.DocNum			AS  'OrderNum',	T1.DocDate			AS	'InvDate',	T2.DocDate			AS  'OrderDate',	T3.CardName			AS  'Customer',	T3.CardCode			AS	'Customer Code',	T4.SlpName,	T1.ShipToCode,	T5.CityS,	T5.StateS,	T1.NumAtCard		AS  'CustPONum',	T6.LineNum,	T6.ItemCode,	T7.FrgnName			AS  'Base Itemcode',	T7.ItemName,	T7.SLength1			AS  'Around',	T7.SWidth1			AS  'Across',	T7.SHeight1			AS  'Gauge',	T6.U_Ship_Quantity	AS	'Pieces',	T6.Quantity,	T6.Price,	T6.LineTotalFROM DLN1 T0    WITH (NOLOCK)	RIGHT OUTER JOIN OINV  T1	ON T1.DocEntry=T0.TrgetEntry  	LEFT  OUTER JOIN ORDR  T2	ON T2.DocNum=T0.BaseRef AND T2.DocEntry=T0.BaseEntry	LEFT  OUTER JOIN OCRD  T3   ON T3.CardCode=T1.CardCode	LEFT  OUTER JOIN OSLP  T4	ON T4.SlpCode=T1.SlpCode	LEFT  OUTER JOIN INV12 T5	ON T5.DocEntry=T1.DocEntry	LEFT  OUTER JOIN INV1  T6   ON T6.DocEntry=T1.DocEntry	LEFT  OUTER JOIN OITM  T7   ON T7.ItemCode=T6.ItemCodeWHERE 	T1.DocDate >='2021-01-02 00:00:00'	AND	T1.DocDate <='2021-01-31 00:00:00'	AND	T1.CANCELED='N'		AND T3.QryGroup1='N' AND T1.DocNum=700289ORDER BY 	T1.DocNum		