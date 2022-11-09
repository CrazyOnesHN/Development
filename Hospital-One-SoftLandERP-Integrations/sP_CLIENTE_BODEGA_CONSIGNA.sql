USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_CLIENTE_BODEGA_CONSIGNA]    Script Date: 11/9/2022 3:32:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [ASHPF].[sP_CLIENTE_BODEGA_CONSIGNA] 
	-- Add the parameters for the stored procedure here
	@Cliente			AS VARCHAR(20)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		C1.CLIENTE, 
		C1.NOMBRE, 
		C2.BODEGA_CONSIGNA, 
		C3.COD_ZON, 
		R1.DESCRIPCION,
		(SELECT C5.NOMBRE FROM ASHPF.CLIENTE AS C5 WHERE C5.CLIENTE=@Cliente ) AS PROMOTOR

		FROM ASHPF.CLIENTE AS C1
			INNER JOIN ERPADMIN.CLIENTE_ASOC_RT AS C2 ON C2.CLIENTE = C1.CLIENTE
			INNER JOIN ERPADMIN.CLIENTE AS C3 ON C3.COD_CLT = C1.CLIENTE
			INNER JOIN erpadmin.RUTA_RT AS R1 ON R1.RUTA = C3.COD_ZON

		WHERE C1.ACTIVO='S' 
		AND C1.CLI_CORPORAC_ASOC=@Cliente
		AND R1.ACTIVA='S'
		
END
