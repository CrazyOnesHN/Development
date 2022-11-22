-- ================================================
-- Template generated from Template Explorer using:
-- Create Scalar Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose Rivera
-- Create date: 11/22/2022
-- Description:	Prompt Payment Discount from Customer
-- =============================================
CREATE FUNCTION PromptPaymentDiscount
(
	-- Add the parameters for the function here
	@BaseRef	NVARCHAR(11),
	@TransType	NVARCHAR(20)
	
)
RETURNS NUMERIC(19,6)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @TransId		INT
	DECLARE @Debit			NUMERIC(19,6)
	DECLARE @Account		NVARCHAR(15)
	DECLARE @DebitAmount	NUMERIC(19,6)

	-- Add the T-SQL statements to compute the return value here
	SET	@TransId = (SELECT TransId FROM OJDT WHERE BaseRef=@BaseRef AND TransType=@TransType)
	SET @Account='_SYS00000000460'

	SET @DebitAmount= ISNULL((SELECT Debit FROM JDT1 WHERE TransId=@TransId	AND Account=@Account),0)

	-- Return the result of the function
	RETURN @DebitAmount

END
GO

