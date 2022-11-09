USE [AHPF_HN]
GO
/****** Object:  UserDefinedFunction [ASHPF].[GET_NETO]    Script Date: 11/9/2022 3:56:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [ASHPF].[GET_NETO] 
(
	-- Add the parameters for the function here
	@FACTURA			VARCHAR(50),
	@LINEA				SMALLINT,
	@CLIENTE_CORP		NVARCHAR(15)
)
RETURNS DECIMAL(28,8)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @NETO DECIMAL(28,8)
	

	-- Add the T-SQL statements to compute the return value here

				IF @LINEA =1 
					BEGIN
						SELECT 
						@NETO=
						((ROUND(ISNULL(SUM(F.TOTAL_FACTURA),0),2)) - 
						((ISNULL(AHPF_HN.ASHPF.GET_COPAGO(@FACTURA,@LINEA),0) + ISNULL(AHPF_HN.ASHPF.GET_TOTALDESCLINEA(@FACTURA,@CLIENTE_CORP),0)))
						)
						FROM   AHPF_HN.ASHPF.FACTURA F WITH(NOLOCK)
						WHERE  F.FACTURA =@FACTURA
						 
					END

				IF @LINEA <> 1
					BEGIN
						SET @NETO = 0.00
					END

	RETURN @NETO
END
