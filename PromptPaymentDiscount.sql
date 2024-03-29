USE [KINYO_DEVEL]
GO
/****** Object:  UserDefinedFunction [dbo].[PromptPaymentDiscount]    Script Date: 12/7/2022 8:50:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose Rivera
-- Create date: 11/22/2022
-- Description:	Prompt Payment Discount from Customer
-- =============================================
ALTER FUNCTION [dbo].[PromptPaymentDiscount]
(
	-- Add the parameters for the function here
	@BaseRef	NVARCHAR(11),
	@TransType	NVARCHAR(20),
	@DocEntry	INT
	
)
RETURNS NUMERIC(19,6)
AS
BEGIN
	-- Declare the return variable here
	--DECLARE @TransId		INT
	DECLARE @Debit			NUMERIC(19,6)
	DECLARE @Account		NVARCHAR(15)
	DECLARE @DebitAmount	NUMERIC(19,6)

	-- Add the T-SQL statements to compute the return value here
	--SET	@TransId = (SELECT TransId FROM OJDT WHERE BaseRef=@BaseRef AND TransType=@TransType)	
	--SET @Account='_SYS00000000460'
	--SET @DebitAmount= ISNULL((SELECT SUM(Debit) FROM JDT1 WHERE TransId=@TransId	AND Account=@Account),0)

	SET @DebitAmount= ISNULL((SELECT DcntSum FROM RCT2 WHERE DocNum=@BaseRef AND DocEntry=@DocEntry),0)

	-- Return the result of the function
	RETURN @DebitAmount

END
