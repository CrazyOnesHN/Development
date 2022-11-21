--SELECT 

--		T2.CardCode			AS 'CustCode',
--		T2.CardName			AS 'CustName',
--		T2.SlpCode,
--		T3.SlpName,
--		T0.DocNum			AS 'PaymentNo',
--		T0.DocDate			AS 'PaymentDate',
--		T2.DocNum			AS 'InvoiceNo',		
--		T4.GroupNum,
--		T5.PymntGroup

--	FROM ORCT T0

--		INNER JOIN dbo.RCT2 T1 ON T1.DocNum		= T0.DocNum
--		INNER JOIN dbo.OINV T2 ON T2.DocEntry	= T1.DocENtry AND T1.InvType = '13'
--		LEFT  JOIN dbo.OSLP T3 ON T3.SlpCode	= T2.SlpCode 
--		INNER JOIN dbo.OCRD T4 ON T4.CardCode	= T2.CardCode 	
--		LEFT  JOIN dbo.OCTG T5 ON T5.GroupNum	= T4.GroupNum

--	WHERE 

--		T0.DocDate >=CONVERT(DATETIME, '20220301', 112) AND 
--		T0.DocDate <=CONVERT(DATETIME, '20220331', 112) AND
--		T0.Canceled='N'		AND 
--		T1.InvType=13		AND	
--		T2.DocType <> 'S'	AND 
--		T2.DocStatus='C'	AND 		
--		T2.CANCELED='N'		AND--		T2.DocTotal <>0--UNION ALLSELECT DISTINCT	T4.CardCode			AS 'CustCode',	T4.CardName			AS 'CustName',	T6.SlpCode,	T6.SlpName,	T7.DocEntry			AS  'DownPaymentNo.',		T4.DocDate			AS	'InvDate',	T4.DocNum,	'',	t7.BaseType, t7.LineTotal, t7.LineStatus	FROM DLN1 T0	--FETCH Sales Order	RIGHT OUTER JOIN RDR1	T1 ON T1.DocEntry=T0.BaseEntry	AND T1.TrgetEntry=T0.DocEntry	AND T1.LineNum=T0.LineNum		INNER JOIN ORDR T2 ON T2.DocEntry=T1.DocEntry	--FETCH Invoice	RIGHT OUTER JOIN INV1 T3 ON T3.DocEntry=T0.TrgetEntry	AND T3.BaseEntry=T0.DocEntry	AND T3.LineNum=T0.LineNum	INNER JOIN OINV T4 ON T4.DocEntry=T3.DocEntry	LEFT JOIN OCRD T5 ON T5.CardCode=T4.CardCode	LEFT JOIN OSLP T6 ON T6.SlpCode=T4.SlpCode	--FETCH Down Payment	LEFT  OUTER JOIN DPI1 T7 ON T7.BaseRef=T0.BaseRef AND T7.BaseEntry=T0.BaseEntry	AND T7.LineNum=T0.LineNumWHERE 	T4.DocDate >=CONVERT(DATETIME, '20220301', 112)	AND	T4.DocDate <=CONVERT(DATETIME, '20220331', 112)	AND	T4.CANCELED='N'		AND  T4.DocType <> 'S'  AND T7.DocEntry IS NOT NULL--SELECT * FROM OINV WHERE DocNum=710206
--SELECT * FROM INV1 WHERE DocEntry=14780

--SELECT * FROM ORDR WHERE DocNum=519844
--SELECT * FROM ODPI WHERE DocEntry=27
--select * from odln where DocNum=608701
--SELECT * FROM DPI1 WHERE DocEntry=27
--select * from dln1 where Docentry=11750

--SELECT * FROM INV1 WHERE DocEntry=14780


--select * from orct where docnum=7766
--select * from rct2 where docnum=7766

SELECT * FROM ODPI WHERE DocEntry in (28,27,32)