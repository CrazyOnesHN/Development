USE [KINYO_DEVEL]
GO
/****** Object:  UserDefinedFunction [dbo].[Get_PymntGroup]    Script Date: 12/7/2022 8:49:47 AM ******/
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
