USE [KINYO_DEVEL]
GO

/****** Object:  StoredProcedure [dbo].[SMCommission_ADD]    Script Date: 4/12/2022 3:44:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jose Rivera
-- Create date: 04/08/2022
-- Description:	FETH THE COMMISSION SM2
-- =============================================
CREATE PROCEDURE [dbo].[SMCommission_ADD] 
	-- Add the parameters for the stored procedure here
	@BeginDate DATETIME, 
	@EndDate   DATETIME,
	@SlpCode   INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
WITH IncomingPayment_DownPayment AS
(

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

	T1.DocDate  >=@BeginDate	AND 
	T1.DocDate  <=@EndDate		AND
	T0.DocNum =(SELECT MAX(DocNum) FROM RCT2 WHERE DocEntry=T2.DocEntry)	AND
	T1.Canceled='N'		AND 
	T2.DocType <> 'S'	AND 
	T2.DocStatus='C'	AND 		
	T2.CANCELED='N'		

UNION ALL

SELECT DISTINCT

	T4.CardCode			AS 'CustCode',
	T4.CardName			AS 'CustName',
	T6.SlpCode,
	T6.SlpName,
	T7.DocEntry			AS  'DownPaymentNo.',	
	T4.DocDate			AS	'InvDate',
	T4.DocNum,
	'',
	'',
	''

FROM DLN1 T0

	--FETCH Sales Order
	RIGHT OUTER JOIN RDR1	T1 ON T1.DocEntry=T0.BaseEntry	AND T1.TrgetEntry=T0.DocEntry	AND T1.LineNum=T0.LineNum	
	INNER JOIN ORDR T2 ON T2.DocEntry=T1.DocEntry
	--FETCH Invoice
	RIGHT OUTER JOIN INV1 T3 ON T3.DocEntry=T0.TrgetEntry	AND T3.BaseEntry=T0.DocEntry	AND T3.LineNum=T0.LineNum
	INNER JOIN OINV T4 ON T4.DocEntry=T3.DocEntry
	LEFT JOIN OCRD T5 ON T5.CardCode=T4.CardCode
	LEFT JOIN OSLP T6 ON T6.SlpCode=T4.SlpCode
	--FETCH Down Payment
	LEFT  OUTER JOIN DPI1 T7 ON T7.BaseRef=T0.BaseRef AND T7.BaseEntry=T0.BaseEntry	AND T7.LineNum=T0.LineNum



WHERE 
T4.DocDate >=@BeginDate	AND	
T4.DocDate <=@EndDate	AND
T4.CANCELED='N'		AND  
T4.DocType <> 'S'   AND 
T7.DocEntry IS NOT NULL



)

SELECT 

	TA.PaymentNo,	
	T2.DocNum,
	T2.DocStatus,
	T2.SlpCode,	
	T3.Dscription,
	T2.DocDate																AS 'InvDate',
	TA.PaymentDate,	
	T2.DocTotal,
	(SELECT TA.SlpName FROM OSLP TA WHERE TA.SlpCode=T2.SlpCode)			AS 'PrimarySlp',
	T7.ItmsGrpCod,
	-- FETCH ITEMS GROUP - COMMISIONS TYPE --
	CASE
		WHEN T7.ItmsGrpCod IN (110,111,114,112)		THEN 'Blanket'
		WHEN T7.ItmsGrpCod IN (131,132)				THEN 'Non KVI Blanket'
		WHEN T7.ItmsGrpCod IN (130)					THEN 'Chemicals'
		WHEN (SUBSTRING(T6.FrgnName,6,2)) = 'CW'	THEN 'Rapid Wash'
		WHEN T6.FrgnName=NULL						THEN 'All'
		ELSE 'Non Commissionable'
	END																		AS 'CommisionsType',		
	T3.LineNum,
	T3.LineTotal,
	ISNULL(T8.U_commPerc,0)													AS 'CommissionsPerc',
	-- FETCH COMMISSIONS PERC --
	ISNULL((T8.U_commPerc/100*T3.LineTotal),0)								AS 'Commissions',
	T6.FrgnName,
	T2.CANCELED,
	UPPER(T2.ShipToCode)													AS 'ShipToCode',
	T2.PaidToDate,	
	T3.ItemCode,
	T2.TotalExpns,
	T2.VatSum,
	T5.U_SM2,
	(SELECT TB.SlpName FROM OSLP TB WHERE TB.SlpCode=T2.U_SM2)				AS 'SecondSlp',
	TA.GroupNum,
	TA.PymntGroup
	
	   
FROM OINV T2 

	INNER JOIN INV1 T3		 ON T3.DocEntry=T2.DocEntry
	LEFT  OUTER JOIN OSLP T4 ON T4.SlpCode=T2.SlpCode
	INNER JOIN OCRD T5		 ON T5.CardCode=T2.CardCode
	LEFT  OUTER JOIN OITM T6 ON T6.ItemCode=T3.ItemCode
	LEFT  OUTER JOIN OITB T7 ON T7.ItmsGrpCod=T6.ItmsGrpCod
	LEFT  OUTER JOIN [dbo].[@COMMSECOND] T8 ON T8.U_slpCode_P=T2.U_SM2 AND T8.U_itmsGrpCod=CAST(T7.ItmsGrpCod AS VARCHAR)
	LEFT  OUTER JOIN IncomingPayment_DownPayment AS TA ON TA.InvoiceNo=T2.DocNum	AND TA.SlpCode=T2.SlpCode 
	

WHERE 

	T2.CANCELED='N'				AND
	TA.PaymentDate >=@BeginDate	AND 
	TA.PaymentDate <=@EndDate	AND		
	T2.DocType <> 'S'			AND 
	T2.DocStatus='C'			AND 
	T2.U_SM2=@SlpCode			
	

ORDER BY
	T2.DocNum,
	T3.LineNum

END

GO


