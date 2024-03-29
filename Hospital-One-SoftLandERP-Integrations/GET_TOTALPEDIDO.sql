USE [AHPF_HN]
GO
/****** Object:  UserDefinedFunction [ASHPF].[GET_TOTALPEDIDO]    Script Date: 11/9/2022 3:54:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [ASHPF].[GET_TOTALPEDIDO] 
(
	-- Add the parameters for the function here
	@PEDIDO			VARCHAR(50)	
)
RETURNS DECIMAL(28,8)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @TOTAL_PEDIDO				DECIMAL(28,8)
	
		
	-- Add the T-SQL statements to compute the return value here
						SELECT 
						@TOTAL_PEDIDO =
						(SUM(FL.PRECIO_UNITARIO * FL.CANTIDAD_FACTURADA)) - (SUM(MONTO_DESCUENTO))
						FROM AHPF_HN.ASHPF.PEDIDO_LINEA AS FL WITH(NOLOCK)
						WHERE FL.PEDIDO =@PEDIDO	
	


	RETURN @TOTAL_PEDIDO

END

