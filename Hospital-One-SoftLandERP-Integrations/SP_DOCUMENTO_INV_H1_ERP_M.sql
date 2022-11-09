USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[SP_DOCUMENTO_INV_H1_ERP_M]    Script Date: 11/9/2022 3:36:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [ASHPF].[SP_DOCUMENTO_INV_H1_ERP_M]
	@Id_AD AS		INT
	,@Almacen		VARCHAR(50)
	,@Cantidad		INT
	,@Medicamento	VARCHAR(100)
	,@Lote			VARCHAR(50)
	,@Ubicacion		VARCHAR(50)
	,@Mensaje		INT OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	DECLARE @PAQUETE_INVENTARIO		VARCHAR(4)
	DECLARE @DOCUMENTO_INV			VARCHAR(50)=''
	DECLARE @CONSECUTIVO			VARCHAR(10)
	DECLARE @REFERENCIA				VARCHAR(200)
	DECLARE @FECHA_HOR_CREACION		DATETIME
	DECLARE @FECHA_DOCUMENTO		DATETIME
	DECLARE @SELECCIONADO			VARCHAR(1)
	DECLARE @USUARIO				VARCHAR(25)
	DECLARE @NoteExistsFlag			TINYINT
	DECLARE @RecordDate				DATETIME
	DECLARE @RowPointer				UNIQUEIDENTIFIER	
	DECLARE @CreatedBy				VARCHAR(30)
	DECLARE @UpdatedBy				VARCHAR(30)
	DECLARE @CreateDate				DATETIME
	DECLARE @REF					VARCHAR(200)

	SET NOCOUNT ON;
	SELECT @Mensaje=0

	BEGIN TRY
		BEGIN TRANSACTION;
					DECLARE	 @GetSerie		VARCHAR(10)
					DECLARE  @ConvertSerie	VARCHAR(10)
					DECLARE	 @NewSerie		VARCHAR(10)
					DECLARE	 @NewAudit		VARCHAR(10)
					
				
					SET @GetSerie   = (SELECT SIGUIENTE_CONSEC FROM AHPF_HN.ASHPF.CONSECUTIVO_CI c WHERE c.CONSECUTIVO = 'SOL-H1')
					SET @ConvertSerie =  RIGHT(@GetSerie,7) + 1
					SET @NewSerie = REPLICATE('0',7-LEN(@ConvertSerie))+RTRIM(CONVERT(char(9),@ConvertSerie))
				
					UPDATE  AHPF_HN.ASHPF.CONSECUTIVO_CI Set SIGUIENTE_CONSEC=LEFT(@GetSerie,2) + @NewSerie WHERE CONSECUTIVO = 'SOL-H1'
					SET @NewAudit = (SELECT LEFT(@GetSerie,3) + @NewSerie)

						--- Insert DocumentInv from H1 to ERP
												-- Insert statements for procedure here
						SELECT @PAQUETE_INVENTARIO	 = 'SCON', @DOCUMENTO_INV=@NewAudit, @CONSECUTIVO ='SOL-H1'
						,@REFERENCIA = 'Admision No : ' + CONVERT(VARCHAR(8),Id_AD) + ' ' +  'Clínica origen: ' + CONVERT(VARCHAR(8),Id_UH)
						,@FECHA_HOR_CREACION = Fecha, @FECHA_DOCUMENTO = Fecha, @SELECCIONADO = 'N'
						,@USUARIO = Usuario_Registro,@NoteExistsFlag =0, @RecordDate = Fecha_Registro
						,@RowPointer = NEWID(), @CreatedBy=Usuario_Registro,@UpdatedBy =Usuario_Modificacion, @CreateDate =Fecha
						FROM H1_AHPF_HN.dbo.AD WHERE Id_AD=@Id_AD

						INSERT INTO AHPF_HN.ASHPF.DOCUMENTO_INV
						(PAQUETE_INVENTARIO,DOCUMENTO_INV,CONSECUTIVO,REFERENCIA,FECHA_HOR_CREACION
						,FECHA_DOCUMENTO,SELECCIONADO,USUARIO,NoteExistsFlag,RecordDate
						,RowPointer,CreatedBy,UpdatedBy,CreateDate)

						VALUES(@PAQUETE_INVENTARIO,@DOCUMENTO_INV, @CONSECUTIVO,@REFERENCIA,GETDATE()
						,GETDATE(),@SELECCIONADO,@USUARIO,@NoteExistsFlag, @RecordDate
						,@RowPointer,@CreatedBy,@UpdatedBy,GETDATE())

						INSERT INTO AHPF_HN.ASHPF.LINEA_DOC_INV
						(PAQUETE_INVENTARIO,DOCUMENTO_INV,LINEA_DOC_INV,
						 AJUSTE_CONFIG,ARTICULO,BODEGA,LOCALIZACION,
						 LOTE,TIPO,SUBTIPO,SUBSUBTIPO,CANTIDAD,COSTO_TOTAL_LOCAL,COSTO_TOTAL_DOLAR,PRECIO_TOTAL_LOCAL,PRECIO_TOTAL_DOLAR,BODEGA_DESTINO,
						 LOCALIZACION_DEST,NoteExistsFlag,RecordDate,
						 RowPointer,CreatedBy,UpdatedBy,CreateDate)
						VALUES
						('SCON',@DOCUMENTO_INV,1,
						 '~TT~', @Medicamento, @Almacen, NULL,
						  @Lote, 'T','D', 'N', @Cantidad,0,0, 0,0,@Almacen,
						  NULL, 0,GETDATE(),
						  NEWID(),@USUARIO,@USUARIO,GETDATE())
					
			COMMIT TRANSACTION
	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END
			EXECUTE ASHPF.Sp_LogError;

			SELECT @Mensaje=1
			RETURN @Mensaje
	END CATCH;
	 RETURN @Mensaje
END



