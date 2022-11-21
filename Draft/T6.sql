

SELECT 

	T2.CardCode			AS 'CustCode',
	T2.CardName			AS 'CustName',
	T2.SlpCode,
	T3.SlpName,
	T0.DocNum			AS 'PaymentNo',
	T0.DocDate			AS 'PaymentDate',
	T2.DocNum			AS 'InvoiceNo',
	T1.SumApplied		AS 'AppliedTotal',
	T4.GroupNum,
	T5.PymntGroup

FROM ORCT T0

	INNER JOIN dbo.RCT2 T1 ON T1.DocNum		= T0.DocNum
	LEFT JOIN dbo.OINV T2 ON T2.DocEntry	= T1.DocENtry AND T1.InvType = '13'
	LEFT  JOIN dbo.OSLP T3 ON T3.SlpCode	= T2.SlpCode 
	INNER JOIN dbo.OCRD T4 ON T4.CardCode	= T2.CardCode 	
	LEFT  JOIN dbo.OCTG T5 ON T5.GroupNum	= T4.GroupNum

WHERE 

	T0.DocDate >=CONVERT(DATETIME, '20220301', 112) AND 
	T0.DocDate <=CONVERT(DATETIME, '20220331', 112) AND
	T0.Canceled='N'		AND 
	T1.InvType=13		AND	
	T2.DocType <> 'S'	AND 
	T2.DocStatus='C'	AND 
	--T2.DocTotal <>0		AND 
	T2.CANCELED='N'		
	AND	T3.SlpCode=7		

ORDER BY T2.DocNum,T0.DocDate


--SELECT * FROM OINV WHERE DocNum=710206
--select * from inv1 where docentry=14780
SELECT * FROM ORCT WHERE DocNum=7858

