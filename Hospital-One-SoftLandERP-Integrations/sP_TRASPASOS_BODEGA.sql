USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_TRASPASOS_BODEGA]    Script Date: 11/9/2022 3:47:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [ASHPF].[sP_TRASPASOS_BODEGA]
	-- Add the parameters for the stored procedure here
	@BODEGA		AS	VARCHAR(4),
	@FC_I		AS  DATETIME,
	@FC_F		AS	DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
		SELECT I1.AUDIT_TRANS_INV, 
			(CASE WHEN I2.AJUSTE_CONFIG='~TT~' THEN 'Traspaso'END) AS Transaccion, 
			I2.ARTICULO, I2.BODEGA, I2.LOCALIZACION, I2.LOTE, I2.CANTIDAD, 
			(CASE WHEN I2.NATURALEZA='E' THEN 'Entrada'  WHEN I2.NATURALEZA='S' THEN 'Salida'  END) AS Naturaleza, 
			I1.APLICACION AS Documento, I1.REFERENCIA

		FROM ASHPF.AUDIT_TRANS_INV AS I1
		INNER JOIN ASHPF.TRANSACCION_INV AS I2 ON I2.AUDIT_TRANS_INV = I1.AUDIT_TRANS_INV
		WHERE  I2.BODEGA=@BODEGA 
		AND CONVERT(CHAR(8) ,I1.FECHA_HORA ,112)>=@FC_I
		AND CONVERT(CHAR(8) ,I1.FECHA_HORA ,112)<=@FC_F
		AND I2.AJUSTE_CONFIG='~TT~'
END
