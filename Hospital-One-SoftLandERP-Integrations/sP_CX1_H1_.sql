USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_CX1_H1_]    Script Date: 11/9/2022 3:33:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [ASHPF].[sP_CX1_H1_] 
	-- Add the parameters for the stored procedure here
	@FACTURA					AS NVARCHAR(50), 
	@REC						AS VARCHAR(50),	
	@R_EXITOSO					AS CHAR(1) OUTPUT,
	@ERROR						AS NVARCHAR(MAX) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @USUARIO				AS  VARCHAR(50)
	DECLARE @ASIENTO_CXC			AS  VARCHAR(50) 	
	DECLARE @PAIS_CLIENTE			AS	VARCHAR(50)
	DECLARE @CTA_CONTADO			AS	VARCHAR(25)
	DECLARE @CTA_CXC				AS	VARCHAR(25)
	DECLARE @ROWPOINTER				AS  NVARCHAR(MAX)
	DECLARE @C_EXITOSA				AS  CHAR(1)
	DECLARE @TEMP_COMENTARIO		AS  VARCHAR(40)
	DECLARE @NUM_APERTURA			AS  INT
	DECLARE @Id_UH					AS  VARCHAR(20)
	DECLARE @SALDO					AS  DECIMAL(28,8) 
	DECLARE @SALDO_LOCAL			AS  DECIMAL(28,8) 
	DECLARE @MONTO_REC				AS  DECIMAL(28,8) 
	DECLARE @UDF_Nombre_Paciente	AS  VARCHAR(500)

		BEGIN TRY
			BEGIN TRANSACTION

				/*VARIABLES TEMPORALES PARA CONSTRUIR FORMAS DE PAGO EN FACTURA CANCELA*/
		
				DECLARE @TEMP_FACTURA_CANCELA		AS	VARCHAR(50)
				DECLARE @TEMP_NUMERO_PAGO_FC		AS	INT
				DECLARE @TEMP_TIPO_FC				AS	VARCHAR(1)
				DECLARE @TEMP_MONTO_FC				AS	DECIMAL(28,8)
				DECLARE @TEMP_MONTO_TF				AS	DECIMAL(28,8)

				DECLARE @TEMP_MONTO_FC_E				AS	DECIMAL(28,8)
				DECLARE @TEMP_MONTO_FC_T				AS	DECIMAL(28,8)
				DECLARE @TEMP_MONTO_FC_X				AS	DECIMAL(28,8)
				DECLARE @TEMP_NUMERO_LINEA_FC			AS	INT


				/*VARIABLES TEMPORALES PARA CONSTRUIR LINEAS EN  MAYOR*/

				DECLARE @TEMP_MAYOR_AUDITORIA		AS INT
				DECLARE @TEMP_CLINICA_H1			AS NVARCHAR(MAX) 
				DECLARE @TEMP_CLIENTE				AS NVARCHAR(128)
				DECLARE @TEMP_NOMBRE				AS NVARCHAR(200)
				DECLARE @SUM_DEBITOS				AS DECIMAL(28,8)
				DECLARE @SUM_CREDITOS				AS DECIMAL(28,8)


				/*VARIABLES TEMPORALES CENTRO CUENTA EN MAYOR*/

				DECLARE @TEMP_PAIS					AS VARCHAR(4)
				DECLARE @TEMP_DESCRIPCION			AS VARCHAR(200)
				DECLARE @TEMP_CTA_CXC				AS VARCHAR(25)
				DECLARE @TEMP_CTR_CXC				AS VARCHAR(25)
				DECLARE @TEMP_CENTRO_COSTO			AS VARCHAR(25)
				DECLARE @TEMP_CUENTA_CONTABLE		AS VARCHAR(25)

				/*VARIABLES PARA ITERACION DE LINEAS DE FACTURA CANCELA*/

				DECLARE @E					AS	INT
					SET @E = 1
				DECLARE	@NUMERO_PAGO		AS	INT



				/*TABLA TEMPORAL CON LAS FORMAS DE PAGO DE FACTURA CANCELA*/ 

				DECLARE @FACTURA_CANCELA AS TABLE(

				ID INT IDENTITY(1,1) PRIMARY KEY,
				FACTURA				VARCHAR(50),
				NUMERO_PAGO			INT,
				TIPO				VARCHAR(1),
				MONTO				DECIMAL(28,8),
				NUM_APERTURA		INT
				)

				/*TABLA TEMPORAL PARA CENTRO COSTO, CUENTA CONTABLE POR SUBTIPO EN REGION  */

				DECLARE @PAIS_SUBTIPO AS TABLE(

				ID INT IDENTITY(1,1) PRIMARY KEY,
				PAIS				VARCHAR(4),
				DESCRIPCION			VARCHAR(200),
				CTA_CXC				VARCHAR(25),
				CTR_CXC				VARCHAR(25),
				Id_UH				VARCHAR(20),
				CENTRO_COSTO		VARCHAR(25),
				CUENTA_CONTABLE		VARCHAR(25)
				)

						
											
					/*-----------------------------------------------------------------------------------------------------------------------------*/	
																--- OBTENER FACTURA CANCELA ---
					--------------------------------------------------------------------------------------------------------------------------------	

									INSERT INTO @FACTURA_CANCELA
									(FACTURA, NUMERO_PAGO, TIPO, MONTO,NUM_APERTURA)

									SELECT 
									FC.FACTURA,
									FC.NUMERO_PAGO,
									FC.TIPO,
									FC.MONTO,
									FC.NUM_APERTURA
									

									FROM AHPF_HN.ASHPF.FACTURA_CANCELA AS FC WITH(NOLOCK)
									WHERE FC.FACTURA = @FACTURA 

												



						/*--------------------------------------------------------------------------------------------------------------------------*/
													--- INICIA PROCESO DE GENERACION DE ASIENTO EN EL MAYOR  ---
						/*--------------------------------------------------------------------------------------------------------------------------*/

																	/*VARIABLES DE CONSTRUCCION*/

						SET @USUARIO				= (SELECT UpdatedBy FROM AHPF_HN.ASHPF.FACTURA					WITH(NOLOCK)			WHERE FACTURA =@FACTURA)
						SET @TEMP_CLIENTE			= (SELECT CLIENTE	FROM AHPF_HN.ASHPF.FACTURA					WITH(NOLOCK)			WHERE FACTURA =@FACTURA)
						SET @TEMP_NOMBRE			= (SELECT NOMBRE	FROM AHPF_HN.ASHPF.CLIENTE					WITH(NOLOCK)			WHERE CLIENTE =@TEMP_CLIENTE)
						SET @ASIENTO_CXC			= (SELECT ASIENTO	FROM AHPF_HN.ASHPF.DOCUMENTOS_CC			WITH(NOLOCK)			WHERE DOCUMENTO=@REC)
						SET @Id_UH					= (SELECT Id_UH		FROM H1_AHPF_HN.dbo.FC						WITH(NOLOCK)			WHERE UDF_Factura_E=@FACTURA)
						SET @UDF_Nombre_Paciente	= (SELECT UDF_Nombre_Paciente  FROM  H1_AHPF_HN.dbo.FC			WITH(NOLOCK)			WHERE UDF_Factura_E=@FACTURA)
						SELECT @ROWPOINTER			= NEWID()
						SET @TEMP_MONTO_TF			= (SELECT MONTO FROM AHPF_HN.ASHPF.DOCUMENTOS_CC	WITH(NOLOCK) WHERE DOCUMENTO=@REC)							
						SET @TEMP_CLINICA_H1	  = ('Corporacion :' + ' ' + @TEMP_CLIENTE + ' ' + 'Nombre :' + ' ' + @TEMP_NOMBRE + ' ' + 'Origen :' + ' ' + 
													(SELECT Nombre FROM H1_AHPF_HN.dbo.UH	WITH(NOLOCK) WHERE Id_UH = @Id_UH) + ' ' + 'Paciente:' + ' ' + UPPER(@UDF_Nombre_Paciente))
						SET @TEMP_COMENTARIO	  = (SELECT Nombre FROM H1_AHPF_HN.dbo.UH	WITH(NOLOCK) WHERE Id_UH = @Id_UH)
						SET @TEMP_MAYOR_AUDITORIA = (SELECT (MAX(MAYOR_AUDITORIA) + 1) FROM AHPF_HN.ASHPF.MAYOR_AUDITORIA	WITH(UPDLOCK))

						---------------------------------------
						--- /*REGISTRO DEL PROCESO EN ERP*/ ---
						---- OBTENER NUMERO DE AUDITORIA ------		
						---------------------------------------

						INSERT INTO AHPF_HN.ASHPF.MAYOR_AUDITORIA
						(MAYOR_AUDITORIA,USUARIO,FECHA,COMENTARIO,NoteExistsFlag,RecordDate,RowPointer,CreatedBy,UpdatedBy,CreateDate)								

						VALUES
						(@TEMP_MAYOR_AUDITORIA,@USUARIO,GETDATE(),'INGRESO CLÍNICA:' + ' ' + @TEMP_COMENTARIO ,0,GETDATE(),NEWID(),@USUARIO,@USUARIO,GETDATE())


						/*------------------------------------*/
						----------ENCABEZADO EN MAYOR-----------
						---------------------------------------- 

						DECLARE @FECHA_		AS DATETIME
						SET @FECHA_ =(SELECT DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0))
		
						INSERT INTO AHPF_HN.ASHPF.ASIENTO_MAYORIZADO
						(ASIENTO,MAYOR_AUDITORIA,TIPO_ASIENTO,FECHA,CONTABILIDAD,ORIGEN,CLASE_ASIENTO,ULTIMO_USUARIO,FECHA_ULT_MODIF
						,MONTO_TOTAL_LOCAL,MONTO_TOTAL_DOLAR,NOTAS,USUARIO_CREACION,FECHA_CREACION,EXPORTADO,TIPO_INGRESO_MAYOR
						,NoteExistsFlag,RecordDate,RowPointer,CreatedBy,UpdatedBy,CreateDate)

						VALUES
						(@ASIENTO_CXC,@TEMP_MAYOR_AUDITORIA,'PING',@FECHA_,'A','CXC','N',@USUARIO,GETDATE(),
						ISNULL(@TEMP_MONTO_FC,0),0,@TEMP_CLINICA_H1,@USUARIO,GETDATE(),'N','N',
						0,GETDATE(),NEWID(),@USUARIO,@USUARIO,GETDATE())
			
							
							----- INICIA LA CARGA DE LAS LINEAS DEL RECIBO  EN EL  MAYOR ----
							-----------------------------------------------------------------
							/*----OBTENER CTA'S DESDE TABLA CONFIGURADA EN HOSPITAL ONE----*/	
							----- CENTRO COSTO Y CUENTA CONTABLE PARTIDA DE INGRESO REC -----
							-----------------------------------------------------------------

							INSERT INTO @PAIS_SUBTIPO
							(PAIS, DESCRIPCION,CTA_CXC, CTR_CXC, Id_UH, CENTRO_COSTO, CUENTA_CONTABLE)

							SELECT P0.PAIS, P1.DESCRIPCION, P0.CTA_CXC, P0.CTR_CXC, P0.Id_UH, P1.CENTRO_COSTO, P1.CUENTA_CONTABLE

							FROM H1_AHPF_HN.dbo.UT_PAIS AS P0 WITH(NOLOCK)
								INNER JOIN H1_AHPF_HN.dbo.UT_SUBTIPO_DOC_CC AS P1 ON P0.Id_UH = P1.Id_UH
							WHERE P0.Id_UH = @Id_UH
														
							SELECT 

							@TEMP_PAIS					= PS.PAIS,					
							@TEMP_DESCRIPCION			= PS.DESCRIPCION,			
							@TEMP_CTA_CXC				= PS.CTA_CXC,				
							@TEMP_CTR_CXC				= PS.CTR_CXC,				
							@TEMP_CENTRO_COSTO			= PS.CENTRO_COSTO,			
							@TEMP_CUENTA_CONTABLE		= PS.CUENTA_CONTABLE		

							FROM @PAIS_SUBTIPO AS PS WHERE PS.Id_UH = @Id_UH
		
							/*---------------------------------------------------------------------------------*/
							----- GENERACION DE LINEAS DE ASIENTO INGRESO POR ABONO TIPO RECIBO EN MAYOR -------
							------------------------------------------------------------------------------------ 

							SELECT @NUMERO_PAGO =	COUNT(*) FROM @FACTURA_CANCELA 

							SET @TEMP_NUMERO_LINEA_FC = ISNULL(MAX(ISNULL(@TEMP_NUMERO_LINEA_FC,0)) ,0)+1 
		
							WHILE @E <= @NUMERO_PAGO
							BEGIN 
								SELECT	
									@TEMP_FACTURA_CANCELA		= FC.FACTURA,
									@TEMP_NUMERO_PAGO_FC		= FC.NUMERO_PAGO,
									@TEMP_TIPO_FC				= FC.TIPO,
									@TEMP_MONTO_FC				= FC.MONTO
					
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
														'T',
														@TEMP_MONTO_FC,
														'D',
														'S',
														@ERROR OUTPUT
				
											
														IF @C_EXITOSA = 'N'
														BEGIN
															RAISERROR(@ERROR, 16,1,1)				
														END	

										END



																						
								SET @E = @E + 1
							END
				

							/*---------------------------------------------------*/
							---------- LINEA DE ASIENTO PARA EL CREDITO ----------
							------------------------------------------------------ 	

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
									@TEMP_MONTO_TF,
									'C',
									'S',
									@ERROR OUTPUT
				
											
									IF @C_EXITOSA = 'N'
									BEGIN
										RAISERROR(@ERROR, 16,1,1)				
									END		
									
									
									
									/*-------------------------------------------------------------------*/					
									------------ ACTUALIZAR MONSTOS  TOTALES DE ENCABEZADO --------------
									----------------------------------------------------------------------
										
										SELECT @SUM_DEBITOS		= ROUND(SUM(M.DEBITO_LOCAL), 2),
											   @SUM_CREDITOS	= ROUND(SUM(M.CREDITO_LOCAL), 2)
										FROM   AHPF_HN.ASHPF.MAYOR AS M WHERE  M.ASIENTO = @ASIENTO_CXC
	
										UPDATE AHPF_HN.ASHPF.ASIENTO_MAYORIZADO
										SET    MONTO_TOTAL_LOCAL	 = ISNULL(@SUM_DEBITOS,0.0),
											   MONTO_TOTAL_DOLAR	 = 0
							   
										WHERE  ASIENTO = @ASIENTO_CXC																												

			COMMIT TRANSACTION
		END TRY
	
		BEGIN CATCH
	 		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION
			END
			EXECUTE ASHPF.Sp_LogError;
		
		END CATCH 

	
END
