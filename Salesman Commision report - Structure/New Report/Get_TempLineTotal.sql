USE [KINYO_DEV]
GO
/****** Object:  UserDefinedFunction [dbo].[Get_TempLineTotal]    Script Date: 1/23/2023 3:55:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jose Rivera
-- Create date: 11/22/2022
-- Description:	Payment Group when Prompt Payment Discount exists
-- =============================================
ALTER FUNCTION [dbo].[Get_TempLineTotal] 
(
	-- Add the parameters for the function here
	@DocEntry	INT,
	@LineNum	INT,
	@Discount	NUMERIC(19,6)
)
RETURNS NUMERIC(19,6)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @LineTotal		NUMERIC(19,6)
	DECLARE @TempDiscount	NUMERIC(19,6)
	
	-- Add the T-SQL statements to compute the return value here
	SET @TempDiscount=(SELECT ISNULL((@Discount/100*LineTotal),0) FROM INV1 WHERE DocEntry=@DocEntry AND LineNum=@LineNum)
	
	SET @LineTotal=(SELECT (LineTotal - ISNULL(@TempDiscount,0)) FROM INV1 WHERE DocEntry=@DocEntry AND LineNum=@LineNum)

	-- Return the result of the function
	RETURN @LineTotal

END
