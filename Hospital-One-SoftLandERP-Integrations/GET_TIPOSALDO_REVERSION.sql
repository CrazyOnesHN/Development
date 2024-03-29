USE [AHPF_HN]
GO
/****** Object:  UserDefinedFunction [ASHPF].[GET_TIPOSALDO_REVERSION]    Script Date: 11/9/2022 3:54:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [ASHPF].[GET_TIPOSALDO_REVERSION]
(
	-- Add the parameters for the function here
	@ASIENTO				VARCHAR(10),
	@CONSECUTIVO			INT,
	@CENTRO_COSTO			VARCHAR(25),
	@CUENTA_CONTABLE		VARCHAR(25)
)
RETURNS VARCHAR(1)
AS
BEGIN

		--- VARIABLES TEMPORALES PARA CARGA DE ASIENTO 
		DECLARE @TIPO											VARCHAR(1)
		DECLARE @TEMP_ASIENTO									VARCHAR(10)
		DECLARE @TEMP_CENTRO_COSTO								VARCHAR(25)
		DECLARE @TEMP_CUENTA_CONTABLE							VARCHAR(25)	
		DECLARE @TEMP_DEBITO_LOCAL								DECIMAL(28,8)
		DECLARE @TEMP_CREDITO_LOCAL								DECIMAL(28,8)
		DECLARE @TEMP_CONSECUTIVO								INT
		DECLARE @TEMP_TIPO										VARCHAR(1)

	-- Add the T-SQL statements to compute the return value here


							---------------------------------------------------------------------------------------
							---------------------------------------------------------------------------------------
							---------------------------------------------------------------------------------------
														--- INICIA EL PROCESO ---
														--- DETERMINAR TIPO ---
							---------------------------------------------------------------------------------------

												SELECT 
												@TEMP_CONSECUTIVO						=	L.CONSECUTIVO,
												@TEMP_ASIENTO							=	L.ASIENTO,
												@TEMP_CENTRO_COSTO						=	L.CENTRO_COSTO,
												@TEMP_CUENTA_CONTABLE					=	L.CUENTA_CONTABLE,
												@TEMP_DEBITO_LOCAL						=	ISNULL(L.DEBITO_LOCAL,0),
												@TEMP_CREDITO_LOCAL						=	ISNULL(L.CREDITO_LOCAL,0)
					

												FROM AHPF_HN.ASHPF.MAYOR AS L	WITH(NOLOCK)												
												WHERE 
												L.ASIENTO=@ASIENTO
												AND L.CENTRO_COSTO=@CENTRO_COSTO
												AND L.CUENTA_CONTABLE=@CUENTA_CONTABLE
												AND L.CONSECUTIVO=@CONSECUTIVO

												IF @TEMP_DEBITO_LOCAL != 0.00000000 
													BEGIN 
														
														SET @TIPO = 'C'
													END

												IF @TEMP_CREDITO_LOCAL != 0.00000000
													BEGIN 
														
														SET @TIPO = 'D'
													END

	RETURN @TIPO 

END