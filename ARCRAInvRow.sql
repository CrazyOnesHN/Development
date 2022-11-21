-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE ARCRAInvRow
	-- Add the parameters for the stored procedure here
	@DocNum	INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 	
		T2.DocNum,		
		T3.Dscription,
		T2.DocDate																AS 'InvDate',	
		ISNULL(T2.DocTotal,0)													AS 'DocTotal',	
		T3.LineNum,
		T3.LineTotal,
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
		ISNULL(T8.U_commPerc,0)													AS 'CommissionsPerc',
		-- FETCH COMMISSIONS PERC --
		ISNULL((T8.U_commPerc/100*T3.LineTotal),0)								AS 'Commissions',
		T2.SlpCode,	
		(SELECT TA.SlpName FROM OSLP TA WHERE TA.SlpCode=T2.SlpCode)			AS 'PrimarySlp'
	   
	FROM OINV T2 

		INNER JOIN INV1 T3		 ON T3.DocEntry=T2.DocEntry
		LEFT  OUTER JOIN OSLP T4 ON T4.SlpCode=T2.SlpCode
		INNER JOIN OCRD T5		 ON T5.CardCode=T2.CardCode
		LEFT  OUTER JOIN OITM T6 ON T6.ItemCode=T3.ItemCode
		LEFT  OUTER JOIN OITB T7 ON T7.ItmsGrpCod=T6.ItmsGrpCod
		LEFT  OUTER JOIN [dbo].[@COMMPRIMARY] T8 ON T8.U_slpCode_P=T2.SlpCode AND T8.U_itmsGrpCod=CAST(T7.ItmsGrpCod AS VARCHAR)

	WHERE 

		T2.CANCELED='N'			AND	
		T2.DocType <> 'S'		AND	
		T2.DocNum=@DocNum
	END
GO
