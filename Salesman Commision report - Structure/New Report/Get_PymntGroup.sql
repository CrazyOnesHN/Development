USE [KINYO_DEV]
GO
/****** Object:  UserDefinedFunction [dbo].[Get_PymntGroup]    Script Date: 1/23/2023 3:55:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jose Rivera
-- Create date: 11/22/2022
-- Description:	Payment Group when Prompt Payment Discount exists
-- =============================================
ALTER FUNCTION [dbo].[Get_PymntGroup] 
(
	-- Add the parameters for the function here
	@ShortName	NVARCHAR(15)
)
RETURNS NVARCHAR(100)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @PymntGroup NVARCHAR(100)

	-- Add the T-SQL statements to compute the return value here
	SET @PymntGroup=(SELECT PT.PymntGroup	FROM OCRD T0
						INNER JOIN OCTG PT ON PT.GroupNum=T0.GroupNum
					WHERE T0.CardCode=@ShortName)

	-- Return the result of the function
	RETURN @PymntGroup

END
