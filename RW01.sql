declare	@BeginDate DATETIME='20220901' 
declare @EndDate   DATETIME='20220930'
declare	@SlpCode   INT=17


SELECT 

	T2.CardCode			AS 'CustCode',
	T2.CardName			AS 'CustName',
	T2.SlpCode,
	T3.SlpName,
	T0.InvoiceId,
	T0.DocNum			AS 'PaymentNo',
	T1.DocDate			AS 'PaymentDate',
	T2.DocNum			AS 'InvoiceNo',
	T4.GroupNum,
	T5.PymntGroup

FROM RCT2 T0

	INNER JOIN ORCT T1 ON T1.DocNum=T0.DocNum
	INNER JOIN OINV T2 ON T2.DocEntry	= T0.DocEntry AND T0.InvType = '13'	
	LEFT  JOIN dbo.OSLP T3 ON T3.SlpCode	= T2.SlpCode 
	INNER JOIN dbo.OCRD T4 ON T4.CardCode	= T2.CardCode 	
	LEFT  JOIN dbo.OCTG T5 ON T5.GroupNum	= T4.GroupNum

WHERE 

	T1.DocDate  >=CONVERT(DATETIME,@BeginDate, 112)	AND 
	T1.DocDate  <=CONVERT(DATETIME,@EndDate, 112)	AND
	T0.DocNum =(SELECT MAX(DocNum) FROM RCT2 WHERE DocEntry=T2.DocEntry)	AND
	T1.Canceled='N'		AND 
	T2.DocType <> 'S'	AND 
	T2.DocStatus='C'	AND 		
	T2.CANCELED='N'		AND
	T3.SlpCode=@SlpCode

ORDER BY T2.DocNum