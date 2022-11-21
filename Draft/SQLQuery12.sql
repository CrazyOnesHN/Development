

SELECT 

T2.DocNum					AS 'CreditMemo Num',
T7.BaseRef					AS 'OrderNum',
T2.DocDate,
T8.DocDate					AS  'OrderDate',
T2.CardName					AS  'Customer',
T2.CardCode					AS	'Customer Code',
T4.SlpName					AS  'Sales Employee',
T2.ShipToCode,T3.CityS,T3.StateS,T2.NumAtCard				AS  'CustPONum',
T0.LineNum,
T0.ItemCode,
T1.FrgnName					AS 'Base Itemcode',
T1.ItemName,
T1.slength1					AS 'Around', 
T1.swidth1					AS 'Across', 
T1.sheight1					AS 'Gauge',
T0.U_Ship_Quantity			AS 'Pieces',
T0.Quantity,
-(T0.Price),
-(T0.LineTotal)

FROM RIN1 T0 WITH(NOLOCK)

	LEFT	OUTER JOIN	OITM  T1	ON T1.ItemCode=T0.ItemCode	INNER	JOIN		ORIN  T2	ON T2.DocEntry=T0.DocEntry	LEFT	OUTER JOIN	RIN12 T3	ON T3.DocEntry=T0.DocEntry	LEFT	OUTER JOIN	OSLP  T4	ON T4.SlpCode=T2.SlpCode	LEFT	OUTER JOIN	CRD1  T5	ON T5.Address=T2.ShipToCode	AND T5.CardCode=T2.CardCode	AND T5.AdresType='S'	LEFT	OUTER JOIN  OCRD  T6	ON T6.CardCode=T2.CardCode	LEFT	OUTER JOIN  DLN1  T7	ON T7.TrgetEntry=T0.BaseEntry	AND T7.LineNum=T0.BaseLine	AND T7.TargetType=T0.BaseType	LEFT	OUTER JOIN  ORDR  T8	ON T8.DocNum=T7.BaseRef AND T8.DocEntry=T7.BaseEntryWHERE T2.DocDate >='2021-01-02 00:00:00'	AND	T2.DocDate <='2021-01-31 00:00:00'	ANDT2.CANCELED='N'				AND T6.QryGroup1='N'ORDER BY T2.DocNum