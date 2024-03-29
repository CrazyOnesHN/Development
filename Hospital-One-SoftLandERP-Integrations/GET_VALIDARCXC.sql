USE [AHPF_HN]
GO
/****** Object:  UserDefinedFunction [ASHPF].[GET_VALIDARCXC]    Script Date: 11/9/2022 3:53:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [ASHPF].[GET_VALIDARCXC] 
(
	-- Add the parameters for the function here
	@FACTURA	VARCHAR(50)
	
)
RETURNS DECIMAL(28,8)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Out							INT ;  -- Assume FALSE
	DECLARE @CXC							INT
	

	-- Add the T-SQL statements to compute the return value here

						SELECT @CXC = COUNT(TIPO) 	FROM   AHPF_HN.ASHPF.FACTURA_CANCELA FC WITH(NOLOCK) WHERE  FC.FACTURA =@FACTURA  AND FC.TIPO = 'X' 		

						IF @CXC = 0
						BEGIN
							SET @Out = 0
						END

	RETURN @Out
END
