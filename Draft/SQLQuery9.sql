SELECT 
	  
	 T0.[DocNum]			AS 'CreditMemo Num',
	 T0.[DocDate]			AS 'Doc. Date',
				
	 T1.CardName			AS  'Customer',
	 T0.[CardCode]			AS	'Customer Code'


  
FROM   ORIN T0	WITH(NOLOCK)

  INNER JOIN OCRD T1 ON T1.CardCode=T0.CardCode
  INNER JOIN RIN1 T2 ON T2.DocEntry=T0.DocEntry
  LEFT  JOIN INV1 T3 ON T3.DocEntry=T2.BaseEntry	AND T3.LineNum=T2.BaseLine AND T2.BaseType=13
  INNER JOIN OINV T4 ON T4.DocEntry=T3.DocEntry
  LEFT OUTER JOIN INV12 T5 ON T5.DocEntry=T0.DocEntry 
  LEFT OUTER JOIN OITM  T6 ON T6.ItemCode=T2.ItemCode
  
WHERE
	T0.[DocDate] BETWEEN '2022-02-01' AND '2022-02-28'	AND
	T0.[CANCELED] = 'N'				  AND T1.QryGroup1='N'





--SELECT * FROM OINV T0 WHERE T0.DocNum=709307
--SELECT * FROM INV1 T0 WHERE T0.DocEntry=13881
--SELECT * FROM INV12 T0 WHERE T0.DocEntry=13881
--SELECT * FROM ORIN T0 WHERE T0.DocNum=645
--SELECT * FROM RIN1 T0 WHERE T0.DocEntry=645

--SELECT * FROM ORIN T0 WHERE T0.DocEntry=13881
--SELECT * FROM INV12 T0 WHERE T0.DocEntry=13881