USE [KINYO_DEVEL]
GO

/****** Object:  StoredProcedure [dbo].[SMCommissionCreditMemo]    Script Date: 4/12/2022 3:45:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jose Rivera
-- Create date: 04/07/2022
-- Description:	SM Commission Credit Memo SubReport
-- =============================================
CREATE PROCEDURE [dbo].[SMCommissionCreditMemo] 
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
			SELECT
			T2.DocEntry,
			T4.SlpCode,
			T4.SlpName,
			T2.DocNum ,
			T0.BaseRef,
			T2.DocDate,	
			T2.Cardname, 
			T2.CardCode,	 		
			T0.LineNum, 
			T0.ItemCode,	
			T0.Dscription, 
			T0.Quantity, 	
			T0.LineTotal,
			-- FETCH ITEMS GROUP - COMMISIONS TYPE --
			CASE
				WHEN T1.ItmsGrpCod IN (110,111,114,112)		THEN 'Blanket'
				WHEN T1.ItmsGrpCod IN (131,132)				THEN 'Non KVI Blanket'
				WHEN T1.ItmsGrpCod IN (130)					THEN 'Chemicals'
				WHEN (SUBSTRING(T1.FrgnName,6,2)) = 'CW'	THEN 'Rapid Wash'
				WHEN T1.FrgnName=NULL						THEN 'All'
				ELSE 'Non Commissionable'
			END																		AS 'CommisionsType',
			ISNULL(T7.U_commPerc,0)													AS 'CommissionsPerc',
			-- FETCH COMMISSIONS PERC --
			ISNULL((T7.U_commPerc/100*T0.LineTotal),0)								AS 'Commissions',
			T2.DocTotal

		FROM RIN1 T0
			LEFT OUTER JOIN OITM  T1 ON T0.ItemCode = T1.ItemCode
			INNER	   JOIN ORIN  T2 ON T0.DocEntry = T2.DocEntry
			LEFT OUTER JOIN RIN12 T3 ON T0.DocEntry = T3.DocEntry
			LEFT OUTER JOIN OSLP  T4 ON T2.SlpCode  = T4.SlpCode
			LEFT OUTER JOIN CRD1  T5 ON T5.address  = T2.ShipToCode AND T2.cardcode = T5.cardcode AND T5.adrestype = 'S'
			LEFT OUTER JOIN OCRD  T6 on T2.cardcode = T6.cardcode
			LEFT  OUTER JOIN [dbo].[@COMMPRIMARY] T7 ON T7.U_slpCode_P=T4.SlpCode AND T7.U_itmsGrpCod=CAST(T1.ItmsGrpCod AS VARCHAR)

		WHERE

			T2.DocDate >=@BeginDate AND 
			T2.DocDate <=@EndDate	AND
			T4.SlpCode=@SlpCode		AND
			T2.CANCELED ='N'		AND 
			T0.LineTotal<>0			AND 
			T2.DocType<>'S'

		ORDER BY 

			T0.BaseRef,
			T2.DocEntry

END
GO


