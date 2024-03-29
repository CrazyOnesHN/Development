USE [AHPF_HN]
GO
/****** Object:  UserDefinedFunction [ASHPF].[GET_COSTO_ARTICULO]    Script Date: 11/9/2022 3:51:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [ASHPF].[GET_COSTO_ARTICULO]
(
	-- Add the parameters for the function here
	@ARTICULO				AS VARCHAR(20),
	@BODEGA				AS VARCHAR(4),
	@CANTIDAD				AS DECIMAL(28,8)
)
RETURNS DECIMAL(28,8)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @COSTO_UNT_PROMEDIO_LOC	DECIMAL(28,8)

			SET @COSTO_UNT_PROMEDIO_LOC 
			=(
			SELECT ISNULL((EB.COSTO_UNT_PROMEDIO_LOC * @CANTIDAD),0)
			FROM AHPF_HN.ASHPF.EXISTENCIA_BODEGA AS EB WITH(NOLOCK)
			WHERE EB.ARTICULO	=@ARTICULO
			AND EB.BODEGA = @BODEGA )

	RETURN @COSTO_UNT_PROMEDIO_LOC

END
