USE [AHPF_HN]
GO
/****** Object:  UserDefinedFunction [ASHPF].[GET_TOTALFACTURA]    Script Date: 11/9/2022 3:54:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [ASHPF].[GET_TOTALFACTURA] 
(
	-- Add the parameters for the function here
	@FACTURA	VARCHAR(50),
	@LINEA		SMALLINT
)
RETURNS DECIMAL(28,8)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @PRECIO DECIMAL(28,8)
	

	-- Add the T-SQL statements to compute the return value here

				IF @LINEA =1 
					BEGIN
						SELECT 
						@PRECIO=(ROUND(ISNULL(SUM(F.TOTAL_FACTURA),0),2))
						FROM   AHPF_HN.ASHPF.FACTURA F WITH(NOLOCK)
						WHERE  F.FACTURA =@FACTURA
						 
					END

				IF @LINEA <> 1
					BEGIN
						SET @PRECIO = 0.00
					END

	RETURN @PRECIO
END
