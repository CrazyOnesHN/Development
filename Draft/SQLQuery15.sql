

SELECT 

	T2.SlpName			AS	'Sales Employee',
	T0.DocNum			AS	'Invoice',
	T1.BaseRef			AS	'OrderNum',
	T0.Comments,
	T0.DocDate,
	T0.CardName,
	T0.CardCode,
	T1.LineNum,
	T1.ItemCode,
	T1.Dscription,
	T1.Price,
	T1.DiscPrcnt,
	CASE
		WHEN T5.QryGroup1='Y' THEN (SELECT T01.U_Length FROM INV1 T01 WHERE T01.DocEntry=T0.DocEntry AND T01.LineNum=T1.LineNum AND T01.ItemCode=T3.ItemCode )
		WHEN T5.QryGroup1='N' THEN (SELECT T0.SLength1 FROM OITM T0 WHERE T0.ItemCode=T3.ItemCode )
	END 'Around',
	CASE
		WHEN T5.QryGroup1='Y' THEN (SELECT T01.U_Width FROM INV1 T01 WHERE T01.DocEntry=T0.DocEntry AND T01.LineNum=T1.LineNum AND T01.ItemCode=T3.ItemCode )
		WHEN T5.QryGroup1='N' THEN (SELECT T0.SWidth1 FROM OITM T0 WHERE T0.ItemCode=T3.ItemCode )
	END 'Across',
	CASE
		WHEN T5.QryGroup1='Y' THEN (SELECT T01.U_Gauge FROM INV1 T01 WHERE T01.DocEntry=T0.DocEntry AND T01.LineNum=T1.LineNum AND T01.ItemCode=T3.ItemCode )
		WHEN T5.QryGroup1='N' THEN (SELECT T0.SHeight1 FROM OITM T0 WHERE T0.ItemCode=T3.ItemCode )
	END 'Gauge',
	T1.Quantity,
	T1.LineTotal



FROM OINV T0	WITH (NOLOCK)

	INNER JOIN INV1 T1 ON T1.DocEntry=T0.DocEntry
	INNER JOIN OSLP T2 ON T2.SlpCode=T0.SlpCode
	LEFT OUTER JOIN OITM T3 ON T3.ItemCode=T1.ItemCode
	LEFT OUTER JOIN DLN1 T4 ON T4.DocEntry=T1.BaseEntry AND T4.LineNum=T1.LineNum
	LEFT OUTER JOIN OCRD T5	ON T5.CardCode=T0.CardCode

WHERE 
T0.DocDate>='2022-02-01 00:00:00'	AND T0.DocDate<'2022-03-01 00:00:00'	AND
T0.CANCELED='N'						AND T0.DocType <> 'S'					AND T5.QryGroup1='N'

UNION ALL

SELECT

	T4.SlpName																AS 'Sales Employee',
	T2.DocNum ,
	CASE
		WHEN T0.BaseType = '13' THEN (SELECT T4.BaseRef FROM DLN1 t4 
									  WHERE  T4.TrgetEntry = T0.BaseEntry AND
									  T0.BaseLine = T4.LineNum AND 
									  T4.TargetType=T0.BaseType)
		ELSE NULL
	END																		AS 'OrderNum',
	NULL,
	T2.DocDate,	
	T2.Cardname																AS 'Customer', 
	T2.CardCode																AS 'CustCode',	 		
	T0.LineNum, 
	T0.ItemCode,	
	T0.Dscription, 
	-(T0.Price), 
	NULL,
	T1.slength1																AS 'Around', 
	T1.swidth1																AS 'Across', 
	T1.sheight1																AS 'Gauge',
	T0.Quantity, 	
	-(T0.LineTotal)

FROM RIN1 T0
	LEFT OUTER JOIN OITM  T1 ON T0.ItemCode = T1.ItemCode
	INNER	   JOIN ORIN  T2 ON T0.DocEntry = T2.DocEntry
	LEFT OUTER JOIN RIN12 T3 ON T0.DocEntry = T3.DocEntry
	LEFT OUTER JOIN OSLP  T4 ON T2.SlpCode  = T4.SlpCode
	LEFT OUTER JOIN CRD1  T5 ON T5.address  = T2.ShipToCode AND T2.cardcode = T5.cardcode AND T5.adrestype = 'S'
	LEFT OUTER JOIN OCRD  T6 on T2.cardcode = T6.cardcode

WHERE

	T2.DocDate >='2022-02-01 00:00:00' AND T2.DocDate <='2022-03-01 00:00:00' AND
	T2.CANCELED ='N'				   AND T6.QryGroup1 ='N'
 
ORDER BY T0.DocNum
