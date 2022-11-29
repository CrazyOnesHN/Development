

SELECT 

T2.DocNum					AS 'CreditMemo Num',
T7.BaseRef					AS 'OrderNum',
T2.DocDate,
T8.DocDate					AS  'OrderDate',
T2.CardName					AS  'Customer',
T2.CardCode					AS	'Customer Code',
T4.SlpName					AS  'Sales Employee',
T2.ShipToCode,
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

	LEFT	OUTER JOIN	OITM  T1	ON T1.ItemCode=T0.ItemCode