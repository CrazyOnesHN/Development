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
--		T2.CANCELED='N'		AND
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