USE [AHPF_HN]
GO
/****** Object:  UserDefinedFunction [ASHPF].[GET_PRECIO_TOTAL]    Script Date: 11/9/2022 3:55:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [ASHPF].[GET_PRECIO_TOTAL] 
(
	-- Add the parameters for the function here
	@FACTURA	VARCHAR(50)	
)
RETURNS DECIMAL(28,8)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @PRECIO_TOTAL DECIMAL(28,8)
	
	-- Add the T-SQL statements to compute the return value here
						SELECT 
						@PRECIO_TOTAL=(ROUND(ISNULL(SUM(FL.PRECIO_TOTAL),0),2))
						FROM   AHPF_HN.ASHPF.FACTURA_LINEA FL WITH(NOLOCK)
						WHERE  FL.FACTURA =@FACTURA

	RETURN @PRECIO_TOTAL
END
