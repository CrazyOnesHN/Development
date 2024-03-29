USE [AHPF_HN]
GO
/****** Object:  UserDefinedFunction [ASHPF].[GET_DIASNETOS]    Script Date: 11/9/2022 3:57:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [ASHPF].[GET_DIASNETOS] 
(
	-- Add the parameters for the function here
	@DOCUMENTO		AS VARCHAR(50)
)
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @DIAS_NETO INT
	DECLARE @CONDICION_PAGO VARCHAR(4)

	-- Add the T-SQL statements to compute the return value here
	SET @CONDICION_PAGO =
	(SELECT CONDICION_PAGO FROM AHPF_HN.ASHPF.FACTURA WITH(NOLOCK) WHERE FACTURA=@DOCUMENTO)

	SELECT 
	@DIAS_NETO =DIAS_NETO 
	FROM AHPF_HN.ASHPF.CONDICION_PAGO cp WITH(NOLOCK)
	WHERE cp.CONDICION_PAGO=@CONDICION_PAGO
	

	-- Return the result of the function
	RETURN @DIAS_NETO

END
