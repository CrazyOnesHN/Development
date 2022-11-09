USE [KINYO-LIVE-15-Aug]
GO
/****** Object:  StoredProcedure [dbo].[ARInvoicePastDue]    Script Date: 11/9/2022 2:25:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[ARInvoicePastDue] 
	-- Add the parameters for the stored procedure here
	@BeginDate	DATETIME, 
	@EndDate	DATETIME,
	@SlpCode	INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT

		T0.CardCode,
		T0.CardName,
		T0.DocNum,
		T0.DocDate,
		T0.DocDueDate,
		(T0.DocTotal-T0.PaidToDate) 'Due Amount',
		CASE 
			WHEN T0.DocStatus='O'	THEN 'Open'
			WHEN T0.DocStatus='C'	THEN 'Closed'
		END 'Status'

	FROM OINV T0 

		LEFT JOIN OSLP T1 ON T1.SlpCode=T0.SlpCode

	WHERE

		DATEDIFF(DD,T0.DocDueDate, GETDATE()) > 0	AND
		T0.DocDate >=@BeginDate	AND
		T0.DocDate <=@EndDate	AND
		T1.SlpCode	=@SlpCode	AND 
		T0.CANCELED='N'			AND
		T0.DocType <> 'S'		AND 
		T0.DocTotal>T0.PaidToDate

	ORDER BY

		T0.DocDate, T0.DocNum
END
