USE [AHPF_HN]
GO
/****** Object:  UserDefinedFunction [ASHPF].[GET_SALDO_NORMAL]    Script Date: 11/9/2022 3:55:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [ASHPF].[GET_SALDO_NORMAL]
(
	-- Add the parameters for the function here
	@CUENTA_CONTABLE		VARCHAR(25)
)
RETURNS VARCHAR(1)
AS
BEGIN

		--- VARIABLES TEMPORALES PARA CARGA DE ASIENTO 
		DECLARE @SALDO_NORMAL							VARCHAR(1)

	-- Add the T-SQL statements to compute the return value here

	
							---------------------------------------------------------------------------------------
							---------------------------------------------------------------------------------------
							---------------------------------------------------------------------------------------
														--- INICIA EL PROCESO ---
														--- DETERMINAR NATURALEZA DE LA CTA ---
							---------------------------------------------------------------------------------------

												SELECT 
												@SALDO_NORMAL =	 CC.SALDO_NORMAL 
												FROM AHPF_HN.ASHPF.CUENTA_CONTABLE AS CC	WITH(NOLOCK)												
												WHERE 
												CC.CUENTA_CONTABLE=@CUENTA_CONTABLE
												

									

	RETURN  @SALDO_NORMAL

END
