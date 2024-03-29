USE [AHPF_HN]
GO
/****** Object:  UserDefinedFunction [ASHPF].[GET_TOTALDESCLINEA]    Script Date: 11/9/2022 3:54:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [ASHPF].[GET_TOTALDESCLINEA] 
(
	-- Add the parameters for the function here
	@FACTURA			VARCHAR(50),
	@CLIENTE_CORP		NVARCHAR(15)
	
	
)
RETURNS DECIMAL(28,8)
AS
BEGIN
		-- Declare the return variable here
		DECLARE @TOTAL_DESC_LINEA DECIMAL(28,8)

		DECLARE @DESC_LINEA	AS TABLE(
		ID INT IDENTITY(1,1) PRIMARY KEY,
		FACTURA					VARCHAR(50),
		ARTICULO				NVARCHAR(20),
		DESC_TOT_LINEA			DECIMAL(28,8)
		)


		---------------------------------------------------------------------------------------------------
		----------------------------------- OBTENER TOTAL DESC_LINEA --------------------------------------
		---------------------------------------------------------------------------------------------------

		INSERT INTO @DESC_LINEA
		(FACTURA,ARTICULO,DESC_TOT_LINEA)

		SELECT 
		F.FACTURA, 
		FL.ARTICULO, 
		(ISNULL(AHPF_HN.ASHPF.GET_PORC_DESCUENTO_ASEGURADORA(F.CLIENTE,FL.ARTICULO),0) * (FL.PRECIO_TOTAL)) AS DESC_LINEA

		FROM AHPF_HN.ASHPF.FACTURA AS F WITH(NOLOCK)
		INNER JOIN  AHPF_HN.ASHPF.FACTURA_LINEA AS FL ON FL.FACTURA = F.FACTURA 
		WHERE F.FACTURA=@FACTURA AND F.CLIENTE=@CLIENTE_CORP

		--------------------------------------------------------------------------------------------------

				-- Add the T-SQL statements to compute the return value here
				
					SELECT 
					@TOTAL_DESC_LINEA=(ROUND(ISNULL(SUM(FL.DESC_TOT_LINEA),0),2)) 
					FROM   @DESC_LINEA FL 
					--WHERE  FL.FACTURA =@FACTURA
						

	RETURN @TOTAL_DESC_LINEA
END
