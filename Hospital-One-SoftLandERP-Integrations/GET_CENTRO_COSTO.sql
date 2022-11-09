USE [AHPF_HN]
GO
/****** Object:  UserDefinedFunction [ASHPF].[GET_CENTRO_COSTO]    Script Date: 11/9/2022 3:50:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [ASHPF].[GET_CENTRO_COSTO]
(
	-- Add the parameters for the function here
	@ARTICULO			VARCHAR(20),
	@CLIENTE			VARCHAR(20)
)
RETURNS VARCHAR(25)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @CENTRO_COSTO		VARCHAR(25)

						SET @CENTRO_COSTO	=(
						SELECT CTR.CENTRO_COSTO 
						FROM   
						AHPF_HN.ASHPF.CENTRO_COSTO	AS	CTR	WITH(NOLOCK)
						WHERE  CTR.CENTRO_COSTO	=	
						(SELECT CASE WHEN C.LOCAL = 'L' THEN AC.CTR_VENTAS_LOC  ELSE AC.CTR_VENTAS_EXP END 
						FROM    
						AHPF_HN.ASHPF.CLIENTE C, 
						AHPF_HN.ASHPF.ARTICULO_CUENTA AC, 
						AHPF_HN.ASHPF.ARTICULO A 
						WHERE  C.CLIENTE = @CLIENTE
						AND A.ARTICULO		= @ARTICULO
						AND A.ARTICULO_CUENTA = AC.ARTICULO_CUENTA))

	RETURN @CENTRO_COSTO

END
