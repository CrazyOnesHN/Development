USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_APERTURA_CAJA_H1_]    Script Date: 11/9/2022 3:29:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [ASHPF].[sP_APERTURA_CAJA_H1_]
	-- Add the parameters for the stored procedure here
	@CAJA					VARCHAR(20),
	@USUARIO				VARCHAR(25),
	@SALDO_INICIAL_LOC		DECIMAL(28,8),
	@Id_UH					VARCHAR(20),
	@MENSAJE					INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

			DECLARE	@NUM_APERTURA			INT
			DECLARE @FCH_HORA_APERTURA		DATETIME
			DECLARE @FCH_HORA_CIERRE		DATETIME
			DECLARE @ESTADO					VARCHAR(1)					
			DECLARE @SALDO_FINAL_LOC		DECIMAL(28,8)	
			DECLARE @SALDO_RECIBO_LOC		DECIMAL(28,8)	
			DECLARE @SALDO_INICIAL_DOL		DECIMAL(28,8)
			DECLARE @SALDO_FINAL_DOL		DECIMAL(28,8)
			DECLARE @SALDO_RECIBO_DOL		DECIMAL(28,8)
			DECLARE @NOTAS					VARCHAR(350)
			DECLARE @NoteExistsFlag			TINYINT			
			DECLARE @RecordDate				DATETIME
			DECLARE @RowPointer				UNIQUEIDENTIFIER
			DECLARE @CreatedBy				VARCHAR(30)
			DECLARE @UpdatedBy				VARCHAR(30)
			DECLARE @CreateDate				DATETIME

			DECLARE @PRIVILEGIOS			VARCHAR(1)
			DECLARE @ERROR					VARCHAR(MAX)
			DECLARE @EXCHANGE_RATE			DECIMAL(28,8)
			DECLARE @Nombre					VARCHAR(128)
			DECLARE @NUM_A_CONTROL			INT


	BEGIN TRY
		BEGIN TRANSACTION
					SET @MENSAJE=0
					DECLARE	 @GetSerie		INT
					DECLARE  @ConvertSerie	INT
					DECLARE	 @NewSerie		VARCHAR(10)
					
					
						SET @GetSerie   = (SELECT  MAX(NUM_APERTURA)  FROM 	AHPF_HN.ASHPF.APERTURA_CAJA WITH (UPDLOCK)  WHERE 	CAJA = @CAJA)
						PRINT @GetSerie 
				
						SET @ConvertSerie =(@GetSerie) + 1
						PRINT @ConvertSerie 
				

						SET @NewSerie = @ConvertSerie
						PRINT @NewSerie

						SET @NUM_APERTURA = @NewSerie 
						PRINT @NUM_APERTURA

											
					----

					SET @PRIVILEGIOS    = (SELECT PRIVILEGIOS 	FROM AHPF_HN.ASHPF.USUARIO_CAJA_FA UC WITH(NOLOCK) 	WHERE	UC.CAJA = @CAJA 	AND	UC.USUARIO = @USUARIO )
					SET @ESTADO			= (SELECT ESTADO FROM AHPF_HN.ASHPF.CAJA WITH(NOLOCK) WHERE CAJA=@CAJA)
					SET @EXCHANGE_RATE  =([AHPF_HN].[ASHPF].[ObtenerTipoCambio] ('DLR',GETDATE()))

					SET @Nombre			= (SELECT Nombre FROM H1_AHPF_HN.dbo.UH WITH(NOLOCK) WHERE Id_UH=@Id_UH)
					
					IF @PRIVILEGIOS = 'T' AND @ESTADO ='C'
					BEGIN 
						UPDATE ASHPF.CAJA 	SET ESTADO = 'A'  WHERE CAJA=@CAJA
								
								SET  @FCH_HORA_APERTURA = GETDATE()
								SET	 @SALDO_FINAL_LOC = 0.00000000
								SET	 @SALDO_RECIBO_LOC = 0.00000000
								SET	 @SALDO_INICIAL_DOL = (@SALDO_INICIAL_LOC / @EXCHANGE_RATE)
								SET	 @SALDO_FINAL_DOL= ISNULL(@SALDO_FINAL_LOC / @EXCHANGE_RATE,0)
								SET	 @SALDO_RECIBO_DOL = ISNULL(@SALDO_RECIBO_LOC / @EXCHANGE_RATE,0)
								SET	 @NOTAS = 'Apertura de caja en Sucursal ' + ' - ' + @Nombre + ' - ' + 'Hospital One'
								SET	 @NoteExistsFlag = 0
								SET	 @RecordDate = GETDATE()
								SET	 @RowPointer = NEWID()
								SET	 @CreatedBy = @USUARIO


									EXEC erpadmin.GrabarUsuarioActual @USUARIO
									EXEC erpadmin.LeerUsuarioActual @USUARIO
		
									 INSERT INTO AHPF_HN.ASHPF.APERTURA_CAJA
									 (CAJA,USUARIO,NUM_APERTURA,FCH_HORA_APERTURA,ESTADO,SALDO_INICIAL_LOC,SALDO_FINAL_LOC,
									 SALDO_RECIBO_LOC,SALDO_INICIAL_DOL,SALDO_FINAL_DOL,SALDO_RECIBO_DOL,
									 NOTAS,NoteExistsFlag,RecordDate,RowPointer,CreatedBy)

									 VALUES
									 (@CAJA,@USUARIO,@NUM_APERTURA,@FCH_HORA_APERTURA,'A',@SALDO_INICIAL_LOC,@SALDO_FINAL_LOC,
									 @SALDO_RECIBO_LOC,@SALDO_INICIAL_DOL,@SALDO_FINAL_DOL,@SALDO_RECIBO_DOL,
									 @NOTAS,@NoteExistsFlag,@RecordDate,@RowPointer,@CreatedBy)
						SELECT @MENSAJE=0
						
					END
					ELSE
					BEGIN		
						
						SET	@ERROR = 'EL ' + @USUARIO + ' NO TIENE PRIVILEGIO DE PERTURA EN CAJA NO:' + @CAJA + ' PRIVILEGIO ' +  @PRIVILEGIOS + ' ESTADO ' + @ESTADO
					 SET @Mensaje = 'Ocurrio un Error: '+ERROR_MESSAGE()+' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
					END

	
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	 SET @Mensaje = 'Ocurrio un Error: '+ERROR_MESSAGE()+' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
		END
		
		EXECUTE ASHPF.Sp_LogError;
		
	END CATCH 

   RETURN @MENSAJE
 END



