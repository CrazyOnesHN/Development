
DECLARE @BeginDate DATETIME='20221001' 
DECLARE @EndDate   DATETIME='20221031'
DECLARE	@SlpCode   INT=9



SELECT 

	
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

	T1.DocDate  >=@BeginDate	AND 
	T1.DocDate  <=@EndDate		AND
	T0.DocNum =(SELECT MAX(DocNum) FROM RCT2 WHERE DocEntry=T2.DocEntry)	AND
	T1.Canceled='N'		AND 
	T2.DocType <> 'S'	AND 
	T2.DocStatus='C'	AND 		
	T2.CANCELED='N'		
	
ORDER BY
T0.DocNum