SELECT
	T0.[ItemCode],
	Replace(Substring(T0.[ItemCode], 3, 6), '/', '') 'Type',
	T0.[ItemCode] 'ST',
	SubString(T0.[ItemCode], 14, 1) 'Finish',
	T0.Width1 'Width',
	convert(numeric(10,4),T0.[U_Width]) 'Ordered Width',
	T0.Height1 'Gauge',
	convert(numeric(10,4),T0.[U_Gauge])'Ordered Gauge',
	T0.Length1  'Length',
	convert(numeric(10,4),T0.[U_Length]) 'Ordered Length',
	T1.[U_WidthLetter] 'Width',
	T3.[DocNum] 'SO #',
	T0.[U_ActualLineNum] 'Line',
	T3.[CardName] 'Customer',
	T3.[CardCode],
	T0.ShipDate AS 'ShipDate',
	CASE
		WHEN T0.[U_Ship_Quantity] IS NULL THEN T0.QUANTITY
		WHEN T0.[U_Ship_Quantity] IS NOT NULL THEN T0.U_Ship_Quantity
	END as 'Rolls Ordered' ,
	CASE
		WHEN t5.U_Roll IS NULL THEN COUNT(T4.Quantity)
		WHEN t5.U_Roll IS NOT NULL THEN count(t5.U_Roll)
	END as 'Rolls reserved',
	(T0.[U_Ship_Quantity] - count(t5.U_Roll)) AS 'Remaining',
	 T0.[U_Notes] AS 'Notes',
	 T4.Quantity as 'IBT1-Quantity',
	T0.[LineStatus],
	T4.Direction,
	T4.BatchNum,
	t7.QryGroup1
 
 
FROM RDR1 T0 
INNER JOIN OITM T1 ON T0.[ItemCode] = T1.[ItemCode]
INNER JOIN OITB T2 ON T1.[ItmsGrpCod] = T2.[ItmsGrpCod]
INNER JOIN ORDR T3 ON T0.[DocEntry] = T3.[DocEntry]
left join IBT1 t4 on T4.[BaseType] = T3.[ObjType] and T4.[BaseNum] =  T3.[DocNum] and t0.LineNum = t4.BaseLinNum and t0.ItemCode = t4.ItemCode 
LEFT join OBTN T5 ON T4.BatchNum = T5.DistNumber AND T4.ItemCode = T5.ItemCode
LEFT JOIN BMM_BINDETAIL T6 ON T5.DistNumber = T6.LotNo AND T5.ItemCode = T6.ItemCode AND T6.TotalQty > 0
Inner join OCRD T7 on T3.cardcode=t7.cardcode 

WHERE ((T0.[LineStatus] = 'O' AND T0.[ItemCode] LIKE '8%')
OR (T0.[LineStatus] = 'O' AND T0.[ItemCode] LIKE '9%'))

group by T0.[U_ActualLineNum] ,
T0.ItemCode , t3.DocNum , t0.Dscription ,T0.Quantity , t0.ShipDate , T0.OpenQty , T0.Width1, T1.U_WidthLetter, T0.LENGTH1, T0.U_Length , T0.HEIGHT1, t0.U_Gauge , t0.U_Width , T0.QUANTITY, t0.U_Ship_Quantity
,T0.[U_Notes], T3.CardName, T3.CardCode,  T4.Quantity,T0.[LineStatus], T4.Direction, T4.BatchNum, T5.U_Roll, t7.QryGroup1
 
ORDER BY T0.[ItemCode], SubString(T0.[ItemCode], 9, 1), T0.[ShipDate], T3.[DocNum]