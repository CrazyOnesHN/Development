USE [AHPF_HN]
GO
/****** Object:  UserDefinedFunction [ASHPF].[GET_DX]    Script Date: 11/9/2022 3:56:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [ASHPF].[GET_DX] 
(
	-- Add the parameters for the function here
	@Id_PC				INT
)
RETURNS NVARCHAR(10)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @DX	NVARCHAR(10)

	-- Add the T-SQL statements to compute the return value here
	SELECT 
	@DX =MAX(CodigoDiagnostico) 
	FROM H1_AHPF_HN.dbo.UT_EXDX_ WITH(NOLOCK) WHERE Id_PC=@Id_PC

	-- Return the result of the function
	RETURN @DX

END
