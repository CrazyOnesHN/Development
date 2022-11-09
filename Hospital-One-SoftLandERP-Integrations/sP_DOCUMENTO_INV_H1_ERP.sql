USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [dbo].[sP_DOCUMENTO_INV_H1_ERP]    Script Date: 11/9/2022 3:49:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[sP_DOCUMENTO_INV_H1_ERP]
	-- Add the parameters for the stored procedure here
	@Id_AD AS INT

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





	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;
					DECLARE	 @GetSerie		VARCHAR(10)
					DECLARE  @ConvertSerie	VARCHAR(10)
					DECLARE	 @NewSerie		VARCHAR(10)
					DECLARE	 @NewAudit		VARCHAR(10)
					
					SET @GetSerie   = (SELECT SIGUIENTE_CONSEC FROM ASHPF.CONSECUTIVO_CI c WHERE c.CONSECUTIVO = 'SOLICITUD9')
					SET @ConvertSerie =  RIGHT(@GetSerie,7) + 1
					SET @NewSerie = REPLICATE('0',7-LEN(@ConvertSerie))+RTRIM(CONVERT(char(9),@ConvertSerie))
		
					UPDATE  ASHPF.CONSECUTIVO_CI Set SIGUIENTE_CONSEC=LEFT(@GetSerie,2) + @NewSerie WHERE CONSECUTIVO = 'SOLICITUD9'
					SET @NewAudit = (SELECT LEFT(@GetSerie,3) + @NewSerie)
	

    -- Insert statements for procedure here
						 SELECT @PAQUETE_INVENTARIO	 = 'SCON', @DOCUMENTO_INV=@NewAudit, @CONSECUTIVO ='SOLICITUD9'
							,@REFERENCIA = 'Admision No : ' + CONVERT(VARCHAR(8),Id_AD) + ' ' +  'Clínica origen: ' + CONVERT(VARCHAR(8),Id_UH)
							,@FECHA_HOR_CREACION = Fecha, @FECHA_DOCUMENTO = Fecha, @SELECCIONADO = 'N'
							,@USUARIO = Usuario_Registro,@NoteExistsFlag =0, @RecordDate = Fecha_Registro
							,@RowPointer = NEWID(), @CreatedBy=Usuario_Registro,@UpdatedBy =Usuario_Modificacion, @CreateDate =Fecha
 
						FROM H1_ASHONPLAFA_387.dbo.AD WHERE Id_AD=@Id_AD

						--- Insert DocumentInv from H1 to ERP

						INSERT INTO ASHPF.DOCUMENTO_INV
							   (PAQUETE_INVENTARIO,DOCUMENTO_INV,CONSECUTIVO,REFERENCIA,FECHA_HOR_CREACION
							   ,FECHA_DOCUMENTO,SELECCIONADO,USUARIO,NoteExistsFlag,RecordDate
							   ,RowPointer,CreatedBy,UpdatedBy,CreateDate)

						VALUES(@PAQUETE_INVENTARIO,@DOCUMENTO_INV, @CONSECUTIVO,@REFERENCIA,@FECHA_HOR_CREACION
							   ,@FECHA_DOCUMENTO,@SELECCIONADO,@USUARIO,@NoteExistsFlag, @RecordDate
							   ,@RowPointer,@CreatedBy,@UpdatedBy,@CreateDate)


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

