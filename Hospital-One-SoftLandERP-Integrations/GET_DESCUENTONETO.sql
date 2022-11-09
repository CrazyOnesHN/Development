USE [AHPF_HN]
GO
/****** Object:  UserDefinedFunction [ASHPF].[GET_DESCUENTONETO]    Script Date: 11/9/2022 3:52:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [ASHPF].[GET_DESCUENTONETO] 
(
	-- Add the parameters for the function here
	@FACTURA				VARCHAR(50),	
	@CLIENTE_CORP		NVARCHAR(15),
	@LINEA				    SMALLINT
)
RETURNS DECIMAL(28,8)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @NETO DECIMAL(28,8)
	

	-- Add the T-SQL statements to compute the return value here

				IF @LINEA =1 
					BEGIN
						SET	@NETO=(SELECT [ASHPF].[GET_TOTALDESCLINEA] (@FACTURA,@CLIENTE_CORP))					 
					END

				IF @LINEA <> 1
					BEGIN
						SET @NETO = 0.00
					END

	RETURN @NETO
END
