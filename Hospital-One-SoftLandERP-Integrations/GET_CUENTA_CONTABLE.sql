USE [AHPF_HN]
GO
/****** Object:  UserDefinedFunction [ASHPF].[GET_CUENTA_CONTABLE]    Script Date: 11/9/2022 3:51:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [ASHPF].[GET_CUENTA_CONTABLE]
(
	-- Add the parameters for the function here
	@ARTICULO			VARCHAR(20),
	@CLIENTE			VARCHAR(20)
)
RETURNS VARCHAR(25)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @CUENTA_CONTABLE		VARCHAR(25)

						SET @CUENTA_CONTABLE	=(
						SELECT CTA.CUENTA_CONTABLE	
						FROM   AHPF_HN.ASHPF.CUENTA_CONTABLE	AS	CTA	WITH(NOLOCK)
						WHERE  CTA.CUENTA_CONTABLE =
						(SELECT CASE WHEN C.LOCAL = 'L' THEN AC.CTA_VENTAS_LOC ELSE AC.CTA_VENTAS_EXP  END 
						FROM	AHPF_HN.ASHPF.CLIENTE C, AHPF_HN.ASHPF.ARTICULO_CUENTA AC, AHPF_HN.ASHPF.ARTICULO A 
						WHERE  C.CLIENTE = @CLIENTE
						AND A.ARTICULO		= @ARTICULO
						AND A.ARTICULO_CUENTA = AC.ARTICULO_CUENTA))

	RETURN @CUENTA_CONTABLE

END
