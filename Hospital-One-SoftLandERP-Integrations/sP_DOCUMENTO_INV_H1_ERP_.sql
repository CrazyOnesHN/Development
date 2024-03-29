USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_DOCUMENTO_INV_H1_ERP_]    Script Date: 11/9/2022 3:36:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [ASHPF].[sP_DOCUMENTO_INV_H1_ERP_]
	-- Add the parameters for the stored procedure here
	@Id_AD AS	INT
	,@Mensaje	INT OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	DECLARE @PAQUETE_INVENTARIO		VARCHAR(4)
	DECLARE @DOCUMENTO_INV			VARCHAR(50)
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

	DECLARE @BD						VARCHAR(200),@SQL VARCHAR(4000)

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
	

    -- Insert statements for procedure here
						 SELECT @SQL='
						 SELECT '+CONVERT(VARCHAR(100),@PAQUETE_INVENTARIO)+'	 = ''SCON'','+CONVERT(VARCHAR(100),
						 @DOCUMENTO_INV)+'='+CONVERT(VARCHAR(100),@NewAudit)+', '+CONVERT(VARCHAR(100),@CONSECUTIVO)+' =''SOL-H1''
							,'+CONVERT(VARCHAR(100),@REFERENCIA)+' = ''Admision No : '' + CONVERT(VARCHAR(8),Id_AD) + '' '' +  ''Clínica origen: '' + CONVERT(VARCHAR(8),Id_UH)
							,'+CONVERT(VARCHAR(100),@FECHA_HOR_CREACION)+' = Fecha, '+CONVERT(VARCHAR(100),@FECHA_DOCUMENTO)+' = Fecha, '+
							CONVERT(VARCHAR(100),@SELECCIONADO)+' = ''N'','+
							CONVERT(VARCHAR(100),@USUARIO)+' = Usuario_Registro,'+CONVERT(VARCHAR(100),@NoteExistsFlag)+' =0,'+
							CONVERT(VARCHAR(100), @RecordDate)+' = Fecha_Registro,'+
							CONVERT(VARCHAR(100),@RowPointer)+' = NEWID(), '+
							CONVERT(VARCHAR(100),@CreatedBy)+'=Usuario_Registro,'+
							CONVERT(VARCHAR(100),@UpdatedBy)+'=Usuario_Modificacion,'+
							CONVERT(VARCHAR(100),@CreateDate)+' =Fecha
						FROM '+@BD+'.dbo.AD WHERE Id_AD='+CONVERT(VARCHAR(100),@Id_AD)
						EXEC (@SQL)
						--- Insert DocumentInv from H1 to ERP

						INSERT INTO AHPF_HN.ASHPF.DOCUMENTO_INV
							   (PAQUETE_INVENTARIO,DOCUMENTO_INV,CONSECUTIVO,REFERENCIA,FECHA_HOR_CREACION
							   ,FECHA_DOCUMENTO,SELECCIONADO,USUARIO,NoteExistsFlag,RecordDate
							   ,RowPointer,CreatedBy,UpdatedBy,CreateDate)

						VALUES(@PAQUETE_INVENTARIO,@DOCUMENTO_INV, @CONSECUTIVO,@REFERENCIA,@FECHA_HOR_CREACION
							   ,@FECHA_DOCUMENTO,@SELECCIONADO,@USUARIO,@NoteExistsFlag, @RecordDate
							   ,@RowPointer,@CreatedBy,@UpdatedBy,@CreateDate)
					
						-- Insert  LINEA_DOC_INV from H1 to ERP
						
						EXEC AHPF_HN.ASHPF.sP_LINEA_DOC_INV_H1_ERP_ @Id_AD,@PAQUETE_INVENTARIO,@DOCUMENTO_INV

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



