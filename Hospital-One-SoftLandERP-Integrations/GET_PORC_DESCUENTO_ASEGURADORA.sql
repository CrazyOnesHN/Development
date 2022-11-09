USE [AHPF_HN]
GO
/****** Object:  UserDefinedFunction [ASHPF].[GET_PORC_DESCUENTO_ASEGURADORA]    Script Date: 11/9/2022 3:56:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [ASHPF].[GET_PORC_DESCUENTO_ASEGURADORA]
(
	@CLIENTE_CORP		NVARCHAR(15),
	@ARTICULO			NVARCHAR(20)
)
RETURNS DECIMAL(28,8)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @PORC DECIMAL(28,8)

	-- Add the T-SQL statements to compute the return value here
	
			SELECT 
			@PORC=A0.PORC
			FROM H1_AHPF_HN.dbo.UT_DESC_ASEGURADORA AS A0 WITH(NOLOCK)
			LEFT JOIN AHPF_HN.ASHPF.ARTICULO AS A1 
			ON A1.CLASIFICACION_5 
			COLLATE SQL_Latin1_General_CP850_CI_AS = A0.CLASIFICACION 
			WHERE ARTICULO=@ARTICULO AND CLIENTE=@CLIENTE_CORP

	-- Return the result of the function
	RETURN @PORC

END
