/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.1742)
    Source Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2016
    Target Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [AHPF_HN]
GO

/****** Object:  UserDefinedFunction [ASHPF].[VALIDAR_EXISTENCIA_BODEGA]    Script Date: 15/10/2017 10:39:54 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [ASHPF].[VALIDAR_EXISTENCIA_BODEGA] 
(
	-- Add the parameters for the function here
	@ARTICULO		VARCHAR(20),
	@BODEGA			VARCHAR(4)
)
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Out	INT = 0;  -- Assume FALSE

	-- Add the T-SQL statements to compute the return value here

	DECLARE @TIPO				AS VARCHAR(1)
	DECLARE @ARTICULO_HIJO		AS VARCHAR(20)
	DECLARE @CANT_DISPONIBLE	AS DECIMAL(28,8)

	SET @TIPO	=	(SELECT A0.TIPO FROM AHPF_HN.ASHPF.ARTICULO  AS A0 WHERE A0.ARTICULO=@ARTICULO )

	IF @TIPO	=	'K'		--- ARTICULOS TIPO KIT
	BEGIN
		SET @ARTICULO_HIJO		= (SELECT A1.ARTICULO_HIJO FROM AHPF_HN.ASHPF.ARTICULO_ENSAMBLE AS A1 WHERE A1.ARTICULO_PADRE=@ARTICULO)
		SET @CANT_DISPONIBLE	= (SELECT ISNULL(CANT_DISPONIBLE,0) FROM AHPF_HN.ASHPF.EXISTENCIA_BODEGA AS A2 WHERE A2.ARTICULO=@ARTICULO_HIJO AND A2.BODEGA=@BODEGA)
		
		IF @CANT_DISPONIBLE > 0
		BEGIN 
			SET @Out = 1  --Assume TRUE
		END
	END

	IF @TIPO	=	'T'		--- ARTICULOS TERMINADOS 
	BEGIN
		SET @CANT_DISPONIBLE	= (SELECT ISNULL(CANT_DISPONIBLE,0) FROM AHPF_HN.ASHPF.EXISTENCIA_BODEGA AS A2 WHERE A2.ARTICULO=@ARTICULO AND A2.BODEGA=@BODEGA)
		
		IF @CANT_DISPONIBLE > 0
		BEGIN 
			SET @Out = 1  --Assume TRUE
		END
	END

	IF @TIPO	=	'U'		--- ARTICULOS CONSUMO
	BEGIN
		SET @CANT_DISPONIBLE	= (SELECT ISNULL(CANT_DISPONIBLE,0) FROM AHPF_HN.ASHPF.EXISTENCIA_BODEGA AS A2 WHERE A2.ARTICULO=@ARTICULO AND A2.BODEGA=@BODEGA)
		
		IF @CANT_DISPONIBLE > 0
		BEGIN 
			SET @Out = 1  --Assume TRUE
		END
	END

	IF @TIPO	=	'V'		--- ARTICULOS SERVICIOS, SU EXISTENCIA SIEMPRE SERA 0
	BEGIN
		
		SET @Out = 0  --Assume TRUE
		
	END



	-- Return the result of the function
	RETURN @Out;

END
GO

