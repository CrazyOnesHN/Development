USE [AHPF_HN]
GO
/****** Object:  UserDefinedFunction [ASHPF].[GET_CLASIFICACION]    Script Date: 11/9/2022 3:51:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [ASHPF].[GET_CLASIFICACION]
(
	-- Add the parameters for the function here
	@CLIENTE_CORP		NVARCHAR(15),
	@ARTICULO			NVARCHAR(20)
)
RETURNS VARCHAR(100)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @GRUPO	VARCHAR(100)

	-- Add the T-SQL statements to compute the return value here
		SELECT 
		@GRUPO=A0.DESCRIPCION
		FROM H1_AHPF_HN.dbo.UT_DESC_ASEGURADORA AS A0 WITH(NOLOCK)
		LEFT JOIN AHPF_HN.ASHPF.ARTICULO AS A1 
		ON A1.CLASIFICACION_5 
		COLLATE SQL_Latin1_General_CP850_CI_AS = A0.CLASIFICACION 
		WHERE ARTICULO=@ARTICULO AND CLIENTE=@CLIENTE_CORP

	-- Return the result of the function
	RETURN @GRUPO

END
