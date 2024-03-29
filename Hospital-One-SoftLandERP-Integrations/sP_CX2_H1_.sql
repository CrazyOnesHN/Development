USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_CX2_H1_]    Script Date: 11/9/2022 3:33:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [ASHPF].[sP_CX2_H1_]
	-- Add the parameters for the stored procedure here
	@FACTURA					AS NVARCHAR(50), 
	@REC						AS NVARCHAR(50),	
	@RowPointer_FC				UNIQUEIDENTIFIER,
	@TEMP_CreatedBy				AS VARCHAR(30),
	@R_EXITOSO					AS CHAR(1) OUTPUT,
	@ERROR						AS NVARCHAR(MAX) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @USUARIO							AS	VARCHAR(50)
	DECLARE @ASIENTO_CXC						AS	VARCHAR(50) 	
	DECLARE @PAIS_CLIENTE						AS	VARCHAR(50)
	DECLARE @CTA_CONTADO						AS	VARCHAR(25)
	DECLARE @CTA_CXC							AS	VARCHAR(25)
	DECLARE @ROWPOINTER							AS	NVARCHAR(MAX)
	DECLARE @C_EXITOSA							AS	CHAR(1)
	DECLARE @TEMP_COMENTARIO					AS	VARCHAR(40)
	DECLARE @NUM_APERTURA						AS	INT
	DECLARE @Id_UH								AS	VARCHAR(20)
	DECLARE @SALDO								AS	DECIMAL(28,8) 
	DECLARE @SALDO_LOCAL						AS	DECIMAL(28,8) 
	DECLARE @MONTO_REC							AS	DECIMAL(28,8) 
	DECLARE @MONTO_CREDITO_						AS  DECIMAL(28,8)
	DECLARE @UDF_Nombre_Paciente				AS	VARCHAR(500)

	BEGIN TRY
		BEGIN TRANSACTION
					
				/*  VARIABLE TEMPORAL MAYOR */

				DECLARE @TEMP_MAYOR_AUDITORIA				AS INT
				DECLARE @TEMP_CLINICA_H1					AS NVARCHAR(MAX) 
				DECLARE @TEMP_CLIENTE						AS NVARCHAR(128)
				DECLARE @TEMP_NOMBRE						AS NVARCHAR(200)
				DECLARE @SUM_DEBITOS						AS DECIMAL(28,8)
				DECLARE @SUM_CREDITOS						AS DECIMAL(28,8)


			/* VARIABLE TEMPORAL MAYOR */

				DECLARE @TEMP_PAIS							AS VARCHAR(4)
				DECLARE @TEMP_DESCRIPCION					AS VARCHAR(200)
				DECLARE @TEMP_CTA_CXC						AS VARCHAR(25)
				DECLARE @TEMP_CTR_CXC						AS VARCHAR(25)
				DECLARE @TEMP_CENTRO_COSTO					AS VARCHAR(25)
				DECLARE @TEMP_CUENTA_CONTABLE				AS VARCHAR(25)
					
				/* VARIABLES PARA ITERACION DE LINEAS DE FACTURA CANCELA */

				DECLARE @E												AS	INT
					SET @E = 1
				DECLARE	@NUMERO_PAGO						AS	INT

				--- TABLA TEMPORAL CON LAS FORMAS DE PAGO DE FACTURA CANCELA 

				DECLARE @FACTURA_CANCELA AS TABLE(

				ID INT IDENTITY(1,1) PRIMARY KEY,
				FACTURA							VARCHAR(50),
				NUMERO_PAGO						INT,
				TIPO							VARCHAR(1),
				MONTO							DECIMAL(28,8),
				CreatedBy						VARCHAR(50)
				)

				/* TABLA TEMPORAL PARA CENTRO COSTO, CUENTA CONTABLE POR SUBTIPO EN REGION  */

				DECLARE @PAIS_SUBTIPO AS TABLE(

				ID INT IDENTITY(1,1) PRIMARY KEY,
				PAIS							VARCHAR(4),
				DESCRIPCION						VARCHAR(200),
				CTA_CXC							VARCHAR(25),
				CTR_CXC							VARCHAR(25),
				Id_UH							VARCHAR(20),
				CENTRO_COSTO					VARCHAR(25),
				CUENTA_CONTABLE					VARCHAR(25))

				/* VARIABLES TEMPORALES ULTIMO PAGO FACTURA CANCELA */

				DECLARE @TEMP_MONTO_FC				AS	DECIMAL(28,8) 
				DECLARE @TEMP_NUMERO_PAGO_FC		AS	INT
				DECLARE @TEMP_TIPO_FC				AS	VARCHAR(1)
				DECLARE @TEMP_FACTURA_CANCELA		AS	VARCHAR(50)
				DECLARE @TEMP_NUMERO_LINEA_FC		AS	INT

				/*VARIABLES DE CONSTRUCION DE CAMPOS */

							INSERT INTO @FACTURA_CANCELA
							(FACTURA, NUMERO_PAGO, TIPO, MONTO,CreatedBy)

							SELECT 
							FC.FACTURA,
							FC.NUMERO_PAGO,
							FC.TIPO,
							FC.MONTO,
							CreatedBy
									
							FROM AHPF_HN.ASHPF.FACTURA_CANCELA AS FC  WITH(NOLOCK)
							WHERE 
							FC.FACTURA =@FACTURA	AND
							FC.RowPointer=@RowPointer_FC
							

							ORDER BY FC.NUMERO_PAGO
	
							
			 /*CONSTRUCCION DE DATOS*/

							SET @MONTO_CREDITO_				= (SELECT ISNULL(SUM(MONTO),0)	FROM @FACTURA_CANCELA WHERE FACTURA=@FACTURA AND TIPO !='X')
							SET @TEMP_CLIENTE				= (SELECT CLIENTE				FROM AHPF_HN.ASHPF.DOCUMENTOS_CC  WITH(NOLOCK) WHERE DOCUMENTO=@REC)
							SET @TEMP_NOMBRE				= (SELECT NOMBRE				FROM AHPF_HN.ASHPF.CLIENTE  WITH(NOLOCK) WHERE CLIENTE =@TEMP_CLIENTE)
							SET @ASIENTO_CXC				= (SELECT ASIENTO				FROM AHPF_HN.ASHPF.DOCUMENTOS_CC  WITH(NOLOCK) WHERE DOCUMENTO=@REC)
							SET @Id_UH						= (SELECT Id_UH					FROM  H1_AHPF_HN.dbo.FC   WITH(NOLOCK) WHERE UDF_Factura_E=@FACTURA)
							SET @UDF_Nombre_Paciente		= (SELECT UDF_Nombre_Paciente	FROM  H1_AHPF_HN.dbo.FC  WITH(NOLOCK) WHERE UDF_Factura_E=@FACTURA)	
							SET @TEMP_CLINICA_H1			= ('Corporacion :' + ' ' + @TEMP_CLIENTE + ' ' + 'Nombre :' + ' ' + @TEMP_NOMBRE + ' ' + 'Origen :' + ' ' + 
							(SELECT Nombre FROM H1_AHPF_HN.dbo.UH  WITH(NOLOCK) WHERE Id_UH = @Id_UH) + ' ' + 'Paciente:' + ' ' + UPPER(@UDF_Nombre_Paciente))
							SET @TEMP_COMENTARIO			= (SELECT Nombre				FROM H1_AHPF_HN.dbo.UH  WITH(NOLOCK) WHERE Id_UH = @Id_UH)
							SET @TEMP_MAYOR_AUDITORIA		= (SELECT (MAX(MAYOR_AUDITORIA) + 1) FROM AHPF_HN.ASHPF.MAYOR_AUDITORIA WITH(UPDLOCK))
						

			/*OBTENER CENTRO COSTO Y CUENTA CONTABLE POR SUBTIPO*/

							INSERT INTO @PAIS_SUBTIPO
							(PAIS, DESCRIPCION, CTA_CXC, CTR_CXC, Id_UH, CENTRO_COSTO, CUENTA_CONTABLE)
						
									SELECT 
									P0.PAIS, 
									P1.DESCRIPCION, 
									P0.CTA_CXC, 
									P0.CTR_CXC, 
									P0.Id_UH, 								
									P1.CENTRO_COSTO, 
									P1.CUENTA_CONTABLE

									FROM H1_AHPF_HN.dbo.UT_PAIS AS P0  WITH(NOLOCK)
									INNER JOIN H1_AHPF_HN.dbo.UT_SUBTIPO_DOC_CC AS P1 ON P1.Id_UH = P0.Id_UH

									WHERE P0.Id_UH =@Id_UH


			/*REGISTRO DEL PROCESO */

							INSERT INTO AHPF_HN.ASHPF.MAYOR_AUDITORIA
							(MAYOR_AUDITORIA,USUARIO,FECHA,COMENTARIO,NoteExistsFlag,RecordDate,RowPointer,CreatedBy,UpdatedBy,CreateDate)
								

							VALUES
							(@TEMP_MAYOR_AUDITORIA,@TEMP_CreatedBy,GETDATE(),'INGRESO CLÍNICA:' + ' ' + @TEMP_COMENTARIO ,0,GETDATE(),NEWID(),@TEMP_CreatedBy,@TEMP_CreatedBy,GETDATE())
			
			/*REGISTRO EN ENCABEZADO EN MAYOR */

							DECLARE @FECHA_		AS DATETIME
							SET @FECHA_ =(SELECT DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0))
			
							INSERT INTO AHPF_HN.ASHPF.ASIENTO_MAYORIZADO
							(ASIENTO,MAYOR_AUDITORIA,TIPO_ASIENTO,FECHA,CONTABILIDAD,ORIGEN,CLASE_ASIENTO,ULTIMO_USUARIO,FECHA_ULT_MODIF
							,MONTO_TOTAL_LOCAL,MONTO_TOTAL_DOLAR,NOTAS,USUARIO_CREACION,FECHA_CREACION,EXPORTADO,TIPO_INGRESO_MAYOR
							,NoteExistsFlag,RecordDate,RowPointer,CreatedBy,UpdatedBy,CreateDate)

							VALUES
							(@ASIENTO_CXC,@TEMP_MAYOR_AUDITORIA,'PING',@FECHA_,'A','CXC','N',@TEMP_CreatedBy,GETDATE(),
							ISNULL(@TEMP_MONTO_FC,0),0,@TEMP_CLINICA_H1,@TEMP_CreatedBy,GETDATE(),'N','N',
							0,GETDATE(),NEWID(),@TEMP_CreatedBy,@TEMP_CreatedBy,GETDATE()) 

				/* OBTENER CENTRO COSTO Y CUENTA CONTABLE*/

							SELECT 

							@TEMP_PAIS					= PS.PAIS,					
							@TEMP_DESCRIPCION			= PS.DESCRIPCION,			
							@TEMP_CTA_CXC				= PS.CTA_CXC,				
							@TEMP_CTR_CXC				= PS.CTR_CXC,				
							@TEMP_CENTRO_COSTO			= PS.CENTRO_COSTO,			
							@TEMP_CUENTA_CONTABLE		= PS.CUENTA_CONTABLE		

							FROM @PAIS_SUBTIPO AS PS WHERE PS.Id_UH = @Id_UH

				/*REGISTAR LINEAS EN MAYOR*/

				/*GENERACION DE LINEAS PARA PARTIDA DE INGRESO POR ABONO TIPO RECIBO EN MAYOR */


						SELECT @NUMERO_PAGO =	COUNT(*) FROM @FACTURA_CANCELA 

						SET @TEMP_NUMERO_LINEA_FC = ISNULL(MAX(ISNULL(@TEMP_NUMERO_LINEA_FC,0)) ,0)+1 
		
							WHILE @E <= @NUMERO_PAGO
							BEGIN 
									SELECT	
									@TEMP_FACTURA_CANCELA					= FC.FACTURA,
									@TEMP_NUMERO_PAGO_FC					= FC.NUMERO_PAGO,
									@TEMP_TIPO_FC							= FC.TIPO,
									@TEMP_MONTO_FC							= FC.MONTO
					
									FROM	@FACTURA_CANCELA	AS FC	WHERE FC.ID = @E

										IF @TEMP_TIPO_FC = 'E'
										BEGIN
											EXEC AHPF_HN.ASHPF.sP_INSERT_FACTURA_MAYOR_H1_REC
													@ROWPOINTER,
													@ASIENTO_CXC,
													@TEMP_NUMERO_LINEA_FC,
													@TEMP_CUENTA_CONTABLE,
													@TEMP_CENTRO_COSTO,
													@FACTURA,
													@REC,
													 'E',
													@TEMP_MONTO_FC,
													'D',
													'S',
													@ERROR OUTPUT
				
											
													IF @C_EXITOSA = 'N'
													BEGIN
													RAISERROR(@ERROR, 16,1,1)				
													END
										END	
										
										IF @TEMP_TIPO_FC = 'T'		
										BEGIN	
										
										SET @TEMP_NUMERO_LINEA_FC = @TEMP_NUMERO_LINEA_FC +1 	
					
											EXEC AHPF_HN.ASHPF.sP_INSERT_FACTURA_MAYOR_H1_REC
													@ROWPOINTER,
													@ASIENTO_CXC,
													@TEMP_NUMERO_LINEA_FC,
													@TEMP_CTA_CXC,
													@TEMP_CTR_CXC,
													@FACTURA,
													@REC,
													 'T'	,
													@TEMP_MONTO_FC,
													'D',
													'S',
													@ERROR OUTPUT
				
											
													IF @C_EXITOSA = 'N'
													BEGIN
														RAISERROR(@ERROR, 16,1,1)				
													END	
													
										END

										SET @E = @E +1
									END

										/* LINEA DE ASIENTO PARA EL CREDITO */

										SET @TEMP_NUMERO_LINEA_FC = @TEMP_NUMERO_LINEA_FC +1 	

										EXEC AHPF_HN.ASHPF.sP_INSERT_FACTURA_MAYOR_H1_REC
										@ROWPOINTER,
										@ASIENTO_CXC,
										@TEMP_NUMERO_LINEA_FC,
										@TEMP_CTA_CXC,
										@TEMP_CTR_CXC,
										@FACTURA,
										@REC,
										'X',
										@MONTO_CREDITO_,
										'C',
										'S',
										@ERROR OUTPUT
				
											
										IF @C_EXITOSA = 'N'
										BEGIN
											RAISERROR(@ERROR, 16,1,1)				
										END	
							

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	IF @@TRANCOUNT > 0
	BEGIN
		PRINT XACT_STATE();
		ROLLBACK TRANSACTION
	END
		PRINT ERROR_MESSAGE();
		THROW 50001, 'Ha ocurrido un error, la transacción ha sido cancelada.',0;
		EXECUTE AHPF_HN.ASHPF.Sp_LogError;		
	END CATCH


END
