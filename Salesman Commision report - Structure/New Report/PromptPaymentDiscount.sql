USE [KINYO_DEV]
GO
/****** Object:  UserDefinedFunction [dbo].[PromptPaymentDiscount]    Script Date: 1/23/2023 3:56:03 PM ******/
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
	DECLARE @DebitAmount	NUMERIC(19,6)

	-- Add the T-SQL statements to compute the return value here

	SET @DebitAmount= ISNULL((SELECT	DcntSum FROM RCT2 WHERE DocNum=@BaseRef AND DocEntry=@DocEntry),0)

	-- Return the result of the function
	RETURN @DebitAmount

END
