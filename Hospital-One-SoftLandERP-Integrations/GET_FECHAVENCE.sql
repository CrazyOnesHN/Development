USE [AHPF_HN]
GO
/****** Object:  UserDefinedFunction [ASHPF].[GET_FECHAVENCE]    Script Date: 11/9/2022 3:56:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [ASHPF].[GET_FECHAVENCE] 
(
	-- Add the parameters for the function here
	@FACTURA	VARCHAR(50),
	@DIAS_NETO	INT
)
RETURNS DATETIME
AS
BEGIN
	-- Declare the return variable here
	DECLARE @FECHA_VENCE	DATETIME
	
	-- Add the T-SQL statements to compute the return value here
	SET 
	@FECHA_VENCE = (SELECT  DATEADD(DAY,@DIAS_NETO,FECHA_VENCE) FROM AHPF_HN.ASHPF.DOCUMENTOS_CC WITH(NOLOCK) WHERE DOCUMENTO=@FACTURA)


	-- Return the result of the function
	RETURN  @FECHA_VENCE

END
