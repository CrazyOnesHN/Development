USE [AHPF_HN]
GO
/****** Object:  UserDefinedFunction [ASHPF].[GET_COPAGO]    Script Date: 11/9/2022 3:51:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [ASHPF].[GET_COPAGO] 
(
	-- Add the parameters for the function here
	@FACTURA	VARCHAR(50),
	@LINEA		SMALLINT
)
RETURNS DECIMAL(28,8)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @COPAGO DECIMAL(28,8)
	

	-- Add the T-SQL statements to compute the return value here

				IF @LINEA =1 
					BEGIN
						SELECT 
						@COPAGO=(ROUND(ISNULL(SUM(FC.MONTO),0),2))
						FROM   AHPF_HN.ASHPF.FACTURA_CANCELA FC WITH(NOLOCK)
						WHERE  FC.FACTURA =@FACTURA
						AND FC.TIPO <> 'X' 
					END

				IF @LINEA <> 1
					BEGIN
						SET @COPAGO = 0.00
					END

	RETURN @COPAGO
END
