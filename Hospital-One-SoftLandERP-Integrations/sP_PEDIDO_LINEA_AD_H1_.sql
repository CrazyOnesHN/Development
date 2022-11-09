USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_PEDIDO_LINEA_AD_H1_]    Script Date: 11/9/2022 3:45:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [ASHPF].[sP_PEDIDO_LINEA_AD_H1_]
	-- Add the parameters for the stored procedure here
	@Id_AD				AS INT, 
	@Id_PT				AS VARCHAR(50),
	@FLAG_PEDIDO		AS VARCHAR(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

		DECLARE @FLAG				AS INT 
		DECLARE	@PEDIDO				AS VARCHAR(20)
		DECLARE	@PEDIDO_LINEA		AS SMALLINT 
		DECLARE @ARTICULO			AS VARCHAR(20)
		DECLARE @FECHA_ENTREGA		AS DATE
		DECLARE	@LINEA_USUARIO		AS SMALLINT
		DECLARE	@PRECIO_UNITARIO	AS DECIMAL(28,8)
		DECLARE	@CANTIDAD_PEDIDA	AS DECIMAL(28,8)
		DECLARE	@CANTIDAD_A_FACTURA	AS DECIMAL(28,8)
		DECLARE	@CANTIDAD_FACTURADA	AS DECIMAL(28,8)
		DECLARE @CANTIDAD_RESERVADA	AS DECIMAL(28,8)
		DECLARE @CANTIDAD_BONIFICAD	AS DECIMAL(28,8)
		DECLARE @CANTIDAD_CANCELADA	AS DECIMAL(28,8)
		DECLARE @TIPO_DESCUENTO		AS VARCHAR(1)
		DECLARE @MONTO_DESCUENTO	AS DECIMAL(28,8)
		DECLARE @PORC_DESCUENTO		AS DECIMAL(28,8)
		DECLARE	@BODEGA				AS VARCHAR(4)
		DECLARE @LOTE				AS VARCHAR(15)
        DECLARE @LOCALIZACION		AS VARCHAR(8)
		DECLARE @ESTADO				AS VARCHAR(1)		
		DECLARE @FECHA_PROMETIDA	AS DATE
		DECLARE @NoteExistsFlag		AS TINYINT
		DECLARE @RecordDate			AS DATETIME
		DECLARE @RowPointer			AS UNIQUEIDENTIFIER 
		DECLARE @CreatedBy			AS VARCHAR(30)
		DECLARE @UpdatedBy			AS VARCHAR(30)
		DECLARE @CreateDate			AS DATETIME
		DECLARE @PROYECTO			AS VARCHAR(25)
		DECLARE @FASE				AS VARCHAR(25)
		DECLARE @CENTRO_COSTO		AS VARCHAR(25)
        DECLARE @CUENTA_CONTABLE	AS VARCHAR(25)
		DECLARE @COUNT_LINEA		AS INT
     
	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION;
		INSERT INTO AHPF_HN.ASHPF.PEDIDO_LINEA
		(PEDIDO,PEDIDO_LINEA,ARTICULO,ESTADO,FECHA_ENTREGA,LINEA_USUARIO,
		BODEGA,LOTE,LOCALIZACION,
		PRECIO_UNITARIO,
		CANTIDAD_PEDIDA,CANTIDAD_A_FACTURA,CANTIDAD_FACTURADA,CANTIDAD_RESERVADA,CANTIDAD_BONIFICAD,CANTIDAD_CANCELADA,
		TIPO_DESCUENTO,MONTO_DESCUENTO,PORC_DESCUENTO,FECHA_PROMETIDA,
		NoteExistsFlag,RecordDate,RowPointer,CreatedBy,UpdatedBy,CreateDate,PROYECTO,FASE,
		CENTRO_COSTO,CUENTA_CONTABLE)
		
		SELECT @FLAG_PEDIDO,ROW_NUMBER() OVER(ORDER BY ADEC.Id_ADEC ASC), ADEC.Id_AR,'N',AD.Fecha_Registro,ROW_NUMBER() OVER(ORDER BY ADEC.Id_ADEC ASC)-1,
		
		ISNULL(ADEC.Id_AL,H1_AHPF_HN.dbo._Almacen (ADEC.Id_AR)) Id_AL,
		(select Top 1 Lote from AHPF_HN.ASHPF.LOTE where ARTICULO=ADEC.Id_AR COLLATE SQL_Latin1_General_CP850_CI_AS ) as Lote,
		LC.LOCALIZACION,
		ADEC.PrecioUnitario,
		ADEC.Cantidad,ADEC.Cantidad,ADEC.Cantidad,0.00000000,0.00000000,0.00000000,
		'P',ADEC.Descuento,0.00000000,AD.Fecha_Registro,0,AD.Fecha_Registro,NEWID(),AD.Usuario_Registro,AD.Usuario_Modificacion,AD.Fecha_Registro,NULL, NULL,
		(SELECT CTR.CENTRO_COSTO FROM   AHPF_HN.ASHPF.CENTRO_COSTO	AS	CTR	WHERE  CTR.CENTRO_COSTO	=	
		(SELECT CASE WHEN C.LOCAL = 'L' THEN AC.CTR_VENTAS_LOC  ELSE AC.CTR_VENTAS_EXP END 
		FROM   AHPF_HN.ASHPF.CLIENTE C, AHPF_HN.ASHPF.ARTICULO_CUENTA AC, AHPF_HN.ASHPF.ARTICULO A 
		WHERE  CONVERT(VARCHAR(20), C.CLIENTE) = ADEC.Id_PT COLLATE SQL_Latin1_General_CP850_CI_AS  
		AND CONVERT(VARCHAR(20),A.ARTICULO) = ADEC.Id_AR COLLATE SQL_Latin1_General_CP850_CI_AS  
		AND A.ARTICULO_CUENTA = AC.ARTICULO_CUENTA)),
		(SELECT CTA.CUENTA_CONTABLE	FROM   AHPF_HN.ASHPF.CUENTA_CONTABLE	AS	CTA	WHERE  CTA.CUENTA_CONTABLE =
		(SELECT CASE WHEN C.LOCAL = 'L' THEN AC.CTA_VENTAS_LOC ELSE AC.CTA_VENTAS_EXP  END 
		FROM	AHPF_HN.ASHPF.CLIENTE C, AHPF_HN.ASHPF.ARTICULO_CUENTA AC, AHPF_HN.ASHPF.ARTICULO A 
		WHERE  CONVERT(VARCHAR(20), C.CLIENTE) = ADEC.Id_PT COLLATE SQL_Latin1_General_CP850_CI_AS 
		AND CONVERT(VARCHAR(20),A.ARTICULO) =ADEC.Id_AR 	COLLATE SQL_Latin1_General_CP850_CI_AS
		AND A.ARTICULO_CUENTA = AC.ARTICULO_CUENTA))
		FROM H1_AHPF_HN.dbo.ADEC AS ADEC
			INNER JOIN H1_AHPF_HN.dbo.AD AS AD ON AD.Id_AD=ADEC.Id_AD
			LEFT OUTER JOIN  AHPF_HN.ASHPF.EXISTENCIA_BODEGA AS EB ON EB.BODEGA = ADEC.Id_AL COLLATE SQL_Latin1_General_CP850_CI_AS AND EB.ARTICULO = ADEC.Id_AR COLLATE SQL_Latin1_General_CP850_CI_AS 
			LEFT OUTER JOIN  AHPF_HN.ASHPF.EXISTENCIA_LOTE AS LC ON LC.BODEGA = ADEC.Id_AL COLLATE SQL_Latin1_General_CP850_CI_AS 
			AND LC.ARTICULO = ADEC.Id_AR COLLATE SQL_Latin1_General_CP850_CI_AS 
			AND LC.LOTE = ADEC.Lote COLLATE SQL_Latin1_General_CP850_CI_AS
			
		WHERE ADEC.Id_AD=@Id_AD AND ADEC.Id_PT=@Id_PT AND Adec.Preciounitario!=0
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH

	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END
			EXECUTE ASHPF.Sp_LogError;
	END CATCH;	
		
END



