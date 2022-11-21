SELECT 

	T4.DocNum			AS	'Invoice/Credit Num',
	CASE
		WHEN	T3.BaseType='17'	THEN T3.BaseRef
		WHEN	T3.BaseType='15'	THEN (SELECT T4.BaseRef FROM DLN1 T4 WHERE T3.BaseEntry = T4.DocEntry AND T3.BaseLine = T4.LineNum)
	END					AS  'OrderNum',	
	T4.DocDate			AS	'InvDate',
	T2.DocDate			AS  'OrderDate',
	T4.CardName			AS	'Customer',
	T4.CardCode			AS	'CustCode',
	T6.SlpName			AS  'Sales Employee',
	T4.ShipToCode,
	T7.CityS,
	T7.StateS,
	T4.NumAtCard		AS  'CustPONum',
	T3.LineNum,
	T3.ItemCode,
	T8.FrgnName,
	T8.ItemName,
	CASE
		WHEN T5.QryGroup1='Y' THEN (SELECT T0.U_Length FROM INV1 T0 WHERE T0.DocEntry=T4.DocEntry AND T0.LineNum=T3.LineNum AND T0.ItemCode=T3.ItemCode )
		WHEN T5.QryGroup1='N' THEN (SELECT T0.SLength1 FROM OITM T0 WHERE T0.ItemCode=T3.ItemCode )
	END 'Around',
	CASE
		WHEN T5.QryGroup1='Y' THEN (SELECT T0.U_Width FROM INV1 T0 WHERE T0.DocEntry=T4.DocEntry AND T0.LineNum=T3.LineNum AND T0.ItemCode=T3.ItemCode )
		WHEN T5.QryGroup1='N' THEN (SELECT T0.SWidth1 FROM OITM T0 WHERE T0.ItemCode=T3.ItemCode )
	END 'Across',
	CASE
		WHEN T5.QryGroup1='Y' THEN (SELECT T0.U_Gauge FROM INV1 T0 WHERE T0.DocEntry=T4.DocEntry AND T0.LineNum=T3.LineNum AND T0.ItemCode=T3.ItemCode )
		WHEN T5.QryGroup1='N' THEN (SELECT T0.SHeight1 FROM OITM T0 WHERE T0.ItemCode=T3.ItemCode )
	END 'Gauge',
	T3.U_Ship_Quantity	AS	'Pieces',
	T3.Quantity,
	T3.Price,
	T3.LineTotal



FROM DLN1 T0

	--FETCH Sales Order
	RIGHT OUTER JOIN RDR1	T1 ON T1.DocEntry=T0.BaseEntry	AND T1.TrgetEntry=T0.DocEntry	AND T1.LineNum=T0.LineNum	
	INNER JOIN ORDR T2 ON T2.DocEntry=T1.DocEntry
	--FETCH Invoice
	RIGHT OUTER JOIN INV1 T3 ON T3.DocEntry=T0.TrgetEntry	AND T3.BaseEntry=T0.DocEntry	AND T3.LineNum=T0.LineNum
	INNER JOIN OINV T4 ON T4.DocEntry=T3.DocEntry
	LEFT JOIN OCRD T5 ON T5.CardCode=T4.CardCode
	LEFT JOIN OSLP T6 ON T6.SlpCode=T4.SlpCode
	LEFT JOIN INV12 T7 ON T7.DocEntry=T4.DocEntry
	INNER JOIN OITM T8 ON T8.ItemCode=T3.ItemCode


WHERE 
	T4.DocDate >='2021-01-02 00:00:00'	AND	T4.DocDate <'2021-01-31 00:00:00'	AND
	T4.CANCELED='N'		AND T5.QryGroup1='N'	AND  T4.DocType <> 'S'


UNION ALL

SELECT

	T2.DocNum ,
    NULL                                                 AS 'OrderNum',
	T2.DocDate,
	NULL,
	T2.Cardname as 'Customer', 
	T2.CardCode as 'Cust Code',
	T4.Slpname                                           AS 'Sales Employee', 	
	T2.ShipToCode, 
	T3.CityS, 
	T3.StateS, 
	T2.NumAtCard                    AS 'CustPONum', 
	T0.LineNum, 
	T0.ItemCode,
	T1.frgnname                     AS 'Base Itemcode',
	T1.itemname, 
	T1.slength1                     AS 'Around', 
	T1.swidth1                      AS 'Across', 
	T1.sheight1                     AS 'Gauge',
	T0.u_ship_quantity              AS 'Pieces',
	T0.Quantity, 
	-(T0.Price), 
	-(T0.LineTotal)

FROM RIN1 T0
LEFT OUTER JOIN OITM  T1 ON T0.ItemCode = T1.ItemCode
INNER	   JOIN ORIN  T2 ON T0.DocEntry = T2.DocEntry
LEFT OUTER JOIN RIN12 T3 ON T0.DocEntry = T3.DocEntry
LEFT OUTER JOIN OSLP  T4 ON T2.SlpCode  = T4.SlpCode
LEFT OUTER JOIN CRD1  T5 ON T5.address  = T2.ShipToCode AND T2.cardcode = T5.cardcode AND T5.adrestype = 'S'
LEFT OUTER JOIN OCRD  T6 on T2.cardcode = T6.cardcode

WHERE

T2.DocDate >='2021-01-02 00:00:00' AND T2.DocDate <'2021-01-31 00:00:00' AND
T2.CANCELED ='N'					    AND T6.QryGroup1='N'

ORDER BY T4.DocNum,T3.LineNum