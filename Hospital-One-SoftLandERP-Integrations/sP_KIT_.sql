USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_KIT_]    Script Date: 11/9/2022 3:44:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [ASHPF].[sP_KIT_]
	-- Add the parameters for the stored procedure here
	@MAX_AUDITORIA		AS INT, 
	@ARTICULO			AS VARCHAR(20),
	@PEDIDO				AS VARCHAR(20)
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		DECLARE @AUDIT_TRANS_INV						INT
		DECLARE @CONSECUTIVO							INT
		DECLARE @FECHA_HORA_TRANSAC						DATETIME
		DECLARE @FECHA									DATETIME
		DECLARE @NIT									VARCHAR(20)
		DECLARE @AJUSTE_CONFIG							VARCHAR(4)
		DECLARE @LOCALIZACION							VARCHAR(8)
		DECLARE @LOTE									VARCHAR(15)
		DECLARE @TIPO									VARCHAR(1)
		DECLARE @SUBTIPO								VARCHAR(1)
		DECLARE @SUBSUBTIPO								VARCHAR(1)
		DECLARE @NATURALEZA								VARCHAR(1)
		DECLARE @CANTIDAD								DECIMAL(28,8)
		DECLARE @CANTIDAD_KIT_T							DECIMAL(28,8)
		DECLARE @CANTIDAD_KIT							DECIMAL(28,8)
		DECLARE @COSTO_TOT_FISC_LOC						DECIMAL(28,8)
		DECLARE @COSTO_TOT_FISC_DOL						DECIMAL(28,8)
		DECLARE @COSTO_TOT_COMP_LOC						DECIMAL(28,8)
		DECLARE @COSTO_TOT_COMP_DOL						DECIMAL(28,8)
		DECLARE @PRECIO_TOTAL_LOCAL						DECIMAL(28,8)
		DECLARE @PRECIO_TOTAL_DOLAR						DECIMAL(28,8)
		DECLARE @CONTABILIZADA							VARCHAR(1)
		DECLARE @CENTRO_COSTO							VARCHAR(25)
		DECLARE @CUENTA_CONTABLE						VARCHAR(25)
		DECLARE @NOTEEXISTSFLAG							TINYINT
		DECLARE @RECORDDATE								DATETIME
		DECLARE @ROWPOINTER								UNIQUEIDENTIFIER
		DECLARE @CREATEDBY								VARCHAR(30)
		DECLARE @UPDATEDBY								VARCHAR(30)
		DECLARE @CREATEDATE								DATETIME
		DECLARE @CLIENTE								VARCHAR(20)
		DECLARE @BODEGA									VARCHAR(4)
		DECLARE @TIPO_A									VARCHAR(1)
		DECLARE @ARTICULO_HIJO							VARCHAR(20)
		DECLARE @LOCALIZACION_ENSAMBLE					VARCHAR(8)
		DECLARE @LOTE_ENSAMBLE							VARCHAR(15)
		DECLARE @CANT_DISPONIBLE_BODEGA					DECIMAL(28,8)
		DECLARE @COUNT_LINEA							INT
		DECLARE @Id_FC									INT

	BEGIN TRY
		BEGIN TRANSACTION 

		--- REGISTRO DE LA TRANSACCION POR ARTICULO ENSAMBLE CON NATURALEZA "S"
			
			SET @Id_FC = (SELECT Id_FC FROM H1_AHPF_HN.dbo.FC WHERE UDF_Pedido=@PEDIDO) 

			BEGIN

				SELECT 
				@CLIENTE	=	F0.Id_PT,
				@RECORDDATE	=	F0.Fecha,
				@CREATEDBY	=	F0.Usuario_Registro,
				@UPDATEDBY	=	F0.Usuario_Modificacion,			
				@CANTIDAD	=	F1.Cantidad,
				@BODEGA		=	F1.Id_AL,
				@PRECIO_TOTAL_LOCAL	=	(F1.PrecioUnitario * F1.Cantidad)

				FROM 
				H1_AHPF_HN.dbo.FC AS F0
				INNER JOIN H1_AHPF_HN.dbo.FCDT AS F1 ON F1.Id_FC = F0.Id_FC
				WHERE F0.Id_FC=@Id_FC AND F1.Id_AR= @ARTICULO

				SET @CENTRO_COSTO =	(SELECT CTR.CENTRO_COSTO FROM   AHPF_HN.ASHPF.CENTRO_COSTO	AS	CTR	WHERE  CTR.CENTRO_COSTO	=	
									(SELECT CASE WHEN C.LOCAL = 'L' THEN AC.CTR_VENTAS_LOC  ELSE AC.CTR_VENTAS_EXP END 	FROM   AHPF_HN.ASHPF.CLIENTE C, AHPF_HN.ASHPF.ARTICULO_CUENTA AC, AHPF_HN.ASHPF.ARTICULO A 
									WHERE  C.CLIENTE = @CLIENTE AND A.ARTICULO = @ARTICULO  AND A.ARTICULO_CUENTA = AC.ARTICULO_CUENTA))

				SET @CUENTA_CONTABLE = (SELECT CTA.CUENTA_CONTABLE	FROM   AHPF_HN.ASHPF.CUENTA_CONTABLE	AS	CTA	WHERE  CTA.CUENTA_CONTABLE =
										(SELECT CASE WHEN C.LOCAL = 'L' THEN AC.CTA_VENTAS_LOC ELSE AC.CTA_VENTAS_EXP  END 	FROM	AHPF_HN.ASHPF.CLIENTE C, AHPF_HN.ASHPF.ARTICULO_CUENTA AC, AHPF_HN.ASHPF.ARTICULO A 
										WHERE  C.CLIENTE = @CLIENTE AND A.ARTICULO = @ARTICULO	AND A.ARTICULO_CUENTA = AC.ARTICULO_CUENTA))

				--- OBTERNER CONSECUTIVO LINEA
			
				SET @COUNT_LINEA =(SELECT  ISNULL(MAX(TI.CONSECUTIVO),0)+1 FROM ASHPF.TRANSACCION_INV TI  WHERE TI.AUDIT_TRANS_INV= @MAX_AUDITORIA)

						INSERT INTO AHPF_HN.ASHPF.TRANSACCION_INV
						(AUDIT_TRANS_INV,CONSECUTIVO,FECHA_HORA_TRANSAC,NIT,AJUSTE_CONFIG,ARTICULO,BODEGA
						,LOTE,LOCALIZACION,TIPO,SUBTIPO,SUBSUBTIPO,NATURALEZA,CANTIDAD,COSTO_TOT_FISC_LOC,COSTO_TOT_FISC_DOL
						,COSTO_TOT_COMP_LOC,COSTO_TOT_COMP_DOL,PRECIO_TOTAL_LOCAL,PRECIO_TOTAL_DOLAR
						,CONTABILIZADA,FECHA,CENTRO_COSTO,CUENTA_CONTABLE,NoteExistsFlag,RecordDate,RowPointer,CreatedBy,UpdatedBy,CreateDate)

						VALUES(@MAX_AUDITORIA,@COUNT_LINEA,GETDATE(),'ND','~VV~',@ARTICULO,@BODEGA
						,NULL,NULL,'V','D','L','S',@CANTIDAD,0.000000,0.00000000
						,0.000000,0.00000000,@PRECIO_TOTAL_LOCAL,0.00000000
						,'S',GETDATE(),@CENTRO_COSTO,@CUENTA_CONTABLE,0,GETDATE(),NEWID(),@CREATEDBY,@UPDATEDBY,GETDATE())
			END

			--- REGISTRO DE LA TRANSACCION POR ARTICULO POR EL ARTICULO HIJO DEL ENSAMBLE 
			
			BEGIN  
				
				SET @ARTICULO_HIJO			=(SELECT A1.ARTICULO_HIJO FROM AHPF_HN.ASHPF.ARTICULO_ENSAMBLE AS A1 WHERE A1.ARTICULO_PADRE=@ARTICULO)
				SET @COUNT_LINEA			=(SELECT  ISNULL(MAX(TI.CONSECUTIVO),0)+1 FROM ASHPF.TRANSACCION_INV TI  WHERE TI.AUDIT_TRANS_INV= @MAX_AUDITORIA)
				SET @CANTIDAD_KIT			=(SELECT A1.CANTIDAD FROM AHPF_HN.ASHPF.ARTICULO_ENSAMBLE AS A1 WHERE A1.ARTICULO_HIJO=@ARTICULO_HIJO AND A1.ARTICULO_PADRE=@ARTICULO)
				SET @CANTIDAD_KIT_T		    = (@CANTIDAD * @CANTIDAD_KIT)


					SELECT 
					@CLIENTE	=	F0.Id_PT,
					@RECORDDATE	=	F0.Fecha,
					@CREATEDBY	=	F0.Usuario_Registro,
					@UPDATEDBY	=	F0.Usuario_Modificacion,			
					@CANTIDAD	=	F1.Cantidad,
					@BODEGA		=	F1.Id_AL,
					@PRECIO_TOTAL_LOCAL	=	(F1.PrecioUnitario * F1.Cantidad)

					FROM 
					H1_AHPF_HN.dbo.FC AS F0
					INNER JOIN H1_AHPF_HN.dbo.FCDT AS F1 ON F1.Id_FC = F0.Id_FC
					WHERE F0.Id_FC=@Id_FC AND F1.Id_AR= @ARTICULO

					SET @CENTRO_COSTO =	(SELECT CTR.CENTRO_COSTO FROM   AHPF_HN.ASHPF.CENTRO_COSTO	AS	CTR	WHERE  CTR.CENTRO_COSTO	=	
					(SELECT CASE WHEN C.LOCAL = 'L' THEN AC.CTR_VENTAS_LOC  ELSE AC.CTR_VENTAS_EXP END 	FROM   AHPF_HN.ASHPF.CLIENTE C, AHPF_HN.ASHPF.ARTICULO_CUENTA AC, AHPF_HN.ASHPF.ARTICULO A 
					WHERE  C.CLIENTE = @CLIENTE AND A.ARTICULO = @ARTICULO_HIJO  AND A.ARTICULO_CUENTA = AC.ARTICULO_CUENTA))

					SET @CUENTA_CONTABLE = (SELECT CTA.CUENTA_CONTABLE	FROM   AHPF_HN.ASHPF.CUENTA_CONTABLE	AS	CTA	WHERE  CTA.CUENTA_CONTABLE =
						(SELECT CASE WHEN C.LOCAL = 'L' THEN AC.CTA_VENTAS_LOC ELSE AC.CTA_VENTAS_EXP  END 	FROM	AHPF_HN.ASHPF.CLIENTE C, AHPF_HN.ASHPF.ARTICULO_CUENTA AC, AHPF_HN.ASHPF.ARTICULO A 
						WHERE  C.CLIENTE = @CLIENTE AND A.ARTICULO = @ARTICULO_HIJO	AND A.ARTICULO_CUENTA = AC.ARTICULO_CUENTA))
				-------------------------

				SELECT 
				@LOTE_ENSAMBLE					=	EB.LOTE,        
				@LOCALIZACION_ENSAMBLE			=	EB.LOCALIZACION
							
				FROM   ASHPF.EXISTENCIA_LOTE AS EB,        ASHPF.LOTE LOT 
				WHERE  EB.ARTICULO = @ARTICULO_HIJO       
				AND EB.LOTE = LOT.LOTE        
				AND EB.ARTICULO = LOT.ARTICULO        
				AND LOT.FECHA_VENCIMIENTO >= GETDATE()        
				AND EB.BODEGA = @BODEGA        
				AND EB.LOTE != 'ND'        
				AND EB.LOCALIZACION != 'ND' ORDER BY        LOT.FECHA_VENCIMIENTO

					INSERT INTO AHPF_HN.ASHPF.TRANSACCION_INV
					(AUDIT_TRANS_INV,CONSECUTIVO,FECHA_HORA_TRANSAC,NIT,AJUSTE_CONFIG,ARTICULO,BODEGA
					,LOTE,LOCALIZACION,TIPO,SUBTIPO,SUBSUBTIPO,NATURALEZA,CANTIDAD,COSTO_TOT_FISC_LOC,COSTO_TOT_FISC_DOL
					,COSTO_TOT_COMP_LOC,COSTO_TOT_COMP_DOL,PRECIO_TOTAL_LOCAL,PRECIO_TOTAL_DOLAR
					,CONTABILIZADA,FECHA,CENTRO_COSTO,CUENTA_CONTABLE,NoteExistsFlag,RecordDate,RowPointer,CreatedBy,UpdatedBy,CreateDate)

					VALUES(@MAX_AUDITORIA,@COUNT_LINEA,GETDATE(),'ND','~CC~',@ARTICULO_HIJO,@BODEGA
					,@LOTE_ENSAMBLE,@LOCALIZACION_ENSAMBLE,'C','D','N','S',@CANTIDAD_KIT_T,0.00000000,0.00000000
					,0.00000000,0.00000000,@PRECIO_TOTAL_LOCAL,0.00000000
					,'S',GETDATE(),@CENTRO_COSTO,@CUENTA_CONTABLE,0,GETDATE(),NEWID(),@CREATEDBY,@UPDATEDBY,GETDATE())
			END

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
		END
			EXECUTE ASHPF.Sp_LogError;

	END CATCH;
    
END
