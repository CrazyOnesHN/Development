USE [KINYO_DEVEL]
GO
/****** Object:  UserDefinedFunction [dbo].[Get_PymntDiscount]    Script Date: 12/7/2022 8:48:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jose Rivera
-- Create date: 11/22/2022
-- Description:	Payment Group when Prompt Payment Discount exists
-- =============================================
ALTER FUNCTION [dbo].[Get_PymntDiscount] 
(
	-- Add the parameters for the function here
	@ShortName	NVARCHAR(15)
)
RETURNS NUMERIC(19,6)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @GroupNum NVARCHAR(100)
	DECLARE @Discount	NUMERIC(19,6)

	-- Add the T-SQL statements to compute the return value here
	SET @GroupNum=(SELECT PT.GroupNum	FROM OCRD T0
						INNER JOIN OCTG PT ON PT.GroupNum=T0.GroupNum
					WHERE T0.CardCode=@ShortName)

	SET @Discount =(SELECT T1.Discount		FROM OCTG T0
						INNER JOIN CDC1 T1 ON T1.CdcCode=T0.DiscCode
					WHERE T0.GroupNum=@GroupNum)

	-- Return the result of the function
	RETURN @Discount

END
