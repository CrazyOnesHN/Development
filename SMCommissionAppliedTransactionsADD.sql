USE [KINYO_DEVEL]
GO

/****** Object:  StoredProcedure [dbo].[SMCommissionAppliedTransactionsADD]    Script Date: 11/21/2022 1:41:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jose Rivera
-- Create date: 11/17/2022
-- Description:	Fetch commission SM2, Rewrite SQL Code using Internal reconciliation function allows the report to match transactions posted to business partner accounts.
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[SMCommissionAppliedTransactionsADD] 
	-- Add the parameters for the stored procedure here
	@BeginDate DATETIME, 
	@EndDate   DATETIME,
	@SlpCode   INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Commission Report
	--Internal reconciliation function allows the report to match transactions posted to business partner accounts.

	WITH InternalReconciliation	AS
	(
		SELECT 

			T1.[TransType], 
			T1.[BaseRef], 
			T1.[TransId], 
			T1.[Line_ID], 
			CASE 
				WHEN T2.[ReconType]=0 THEN 'Manual'
				WHEN T2.[ReconType]=1 THEN 'Automatic' 
				WHEN T2.[ReconType]=2 THEN 'Semi-Automatic'
				WHEN T2.[ReconType]=3 THEN 'Payment'
				WHEN T2.[ReconType]=4 THEN 'Credit Memo'
				WHEN T2.[ReconType]=6 THEN 'Zero Value'
				WHEN T2.[ReconType]=7 THEN 'Cancellation'
				WHEN T2.[ReconType]=8 THEN 'BoE'
				WHEN T2.[ReconType]=9 THEN 'Deposit'
				WHEN T2.[ReconType]=10 THEN 'Bank Statement Processing'
				WHEN T2.[ReconType]=11 THEN 'Period Closing'
				WHEN T2.[ReconType]=12 THEN 'Correction Invoice'
				WHEN T2.[ReconType]=13 THEN 'Inventory/Expense Allocation'
				WHEN T2.[ReconType]=14 THEN 'WIP'
				WHEN T2.[ReconType]=15 THEN 'Deferred Tax Interim Account'
				WHEN T2.[ReconType]=16 THEN 'Down Payment Allocation'
				WHEN T2.[ReconType]=17 THEN 'Auto. Conversion Difference'
				WHEN T2.[ReconType]=18 THEN 'Interim Document'
				WHEN T2.[ReconType]=19 THEN 'Withholding Tax Interim Account'
			END ReconType,
			T1.[RefDate]		'PostingDate', 
			T1.[DueDate]		'DueDate', 
			T2.[ReconDate]		'DateClosed', 	
			T1.[LineMemo], 	
			T0.[ReconSum], 	
			T1.BalDueDeb,
			T2.[ReconNum], 
			T1.[ShortName],
			T2.Canceled,
			T3.SlpCode,
			CASE
				WHEN T3.DocStatus='O' THEN 'Open'
				WHEN T3.DocStatus='C' THEN 'Closed'
			END 'DocStatus'
			
	   
		FROM ITR1 T0

				INNER JOIN JDT1 T1 ON T1.Line_ID=T0.TransRowId AND T1.TransId=T0.TransId
				INNER JOIN OITR T2 ON T2.ReconNum=T0.ReconNum
				LEFT JOIN OINV T3 ON T3.DocNum=T1.BaseRef


		WHERE 

			T2.[ReconDate]>=CONVERT(DATETIME,@BeginDate, 112)	AND 
			T2.[ReconDate]<=CONVERT(DATETIME,@EndDate, 112)		AND
			--T3.SlpCode=@SlpCode								AND
			T2.Canceled='N'									
			AND T2.[ReconType]<>6	
			AND T0.IsCredit='D'
			AND	T2.ReconNum =(SELECT MAX(TA.ReconNum) FROM ITR1 TA
								INNER JOIN JDT1 TB ON TB.Line_ID=TA.TransRowId AND TB.TransId=TA.TransId
								WHERE TB.BaseRef=T1.BaseRef AND TB.TransId=T1.TransId)


	)


		SELECT 

			IR.ReconNum,	
			T2.DocNum,
			T2.DocStatus,
			T2.SlpCode,	
			T3.Dscription,
			T2.DocDate																AS 'InvDate',
			IR.DueDate,
			IR.DateClosed,	
			ISNULL(T2.DocTotal,0)													AS 'DocTotal',
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
			IR.BalDueDeb
	
	   
		FROM OINV T2 

			INNER JOIN INV1 T3		 ON T3.DocEntry=T2.DocEntry
			LEFT  OUTER JOIN OSLP T4 ON T4.SlpCode=T2.SlpCode
			INNER JOIN OCRD T5		 ON T5.CardCode=T2.CardCode
			LEFT  OUTER JOIN OITM T6 ON T6.ItemCode=T3.ItemCode
			LEFT  OUTER JOIN OITB T7 ON T7.ItmsGrpCod=T6.ItmsGrpCod
			-- Link Sales Rep 2 --
			LEFT  OUTER JOIN [dbo].[@COMMSECOND] T8 ON T8.U_slpCode_P=T2.U_SM2 AND T8.U_itmsGrpCod=CAST(T7.ItmsGrpCod AS VARCHAR)
			LEFT  OUTER JOIN InternalReconciliation AS IR ON IR.BaseRef=T2.DocNum	AND IR.SlpCode=T2.SlpCode 
	

		WHERE 

			T2.CANCELED='N'										AND
			IR.DateClosed >=CONVERT(DATETIME,@BeginDate, 112)	AND
			IR.DateClosed <=CONVERT(DATETIME,@EndDate, 112)		AND	
			T2.DocType <> 'S'									AND 
			T2.DocStatus='C'									AND 
			T2.U_SM2=@SlpCode
	

		ORDER BY
			T2.DocNum,
			T3.LineNum
END
GO


