USE [AHPF_HN]
GO
/****** Object:  UserDefinedFunction [ASHPF].[GET_DXTEXTO]    Script Date: 11/9/2022 3:56:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [ASHPF].[GET_DXTEXTO] 
(
	-- Add the parameters for the function here
	@Id_PC				INT
)
RETURNS NVARCHAR(500)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @DXTEXTO 	NVARCHAR(500)

	-- Add the T-SQL statements to compute the return value here
	SELECT 
	@DXTEXTO 	 =UPPER(Descripcion) 
	FROM H1_AHPF_HN.dbo.UT_EXDX_  AS DX0 WITH(NOLOCK)
	LEFT JOIN H1_AHPF_HN.dbo.DX AS DX1 ON DX1.Codigo = DX0.CodigoDiagnostico
	WHERE DX0.Id_PC=@Id_PC

	-- Return the result of the function
	RETURN @DXTEXTO

END



