USE [AHPF_HN]
GO
/****** Object:  UserDefinedFunction [ASHPF].[GET_TIPOARTICULO]    Script Date: 11/9/2022 3:55:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [ASHPF].[GET_TIPOARTICULO]
(
	-- Add the parameters for the function here
	@ARTICULO								VARCHAR(20)
)
RETURNS VARCHAR(1)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @TIPO		VARCHAR(1)

	-- Add the T-SQL statements to compute the return value here
			SELECT @TIPO =
			(SELECT TIPO 
			FROM AHPF_HN.ASHPF.ARTICULO WITH(NOLOCK)
			WHERE ARTICULO=@ARTICULO)

	-- Return the result of the function
	RETURN @TIPO

END
