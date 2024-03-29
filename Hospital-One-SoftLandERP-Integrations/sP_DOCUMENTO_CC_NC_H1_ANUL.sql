USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_DOCUMENTO_CC_NC_H1_ANUL]    Script Date: 11/9/2022 3:35:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [ASHPF].[sP_DOCUMENTO_CC_NC_H1_ANUL]
	@FACTURA			AS VARCHAR(50),
	@USUARIO			AS VARCHAR(30)
AS
BEGIN
	
	SET NOCOUNT ON;

		DECLARE @DOCUMENTO					AS NVARCHAR(50)
		DECLARE @TIPO						AS VARCHAR(3)
		DECLARE @APLICACION					AS VARCHAR(249)
		DECLARE @FECHA_DOCUMENTO			AS DATETIME
		DECLARE @FECHA						AS DATETIME
		DECLARE @MONTO						AS DECIMAL(28,8)
		DECLARE @SALDO						AS DECIMAL(28,8)
		DECLARE @MONTO_LOCAL				AS DECIMAL(28,8)
		DECLARE @SALDO_LOCAL				AS DECIMAL(28,8)
		DECLARE @MONTO_DOLAR				AS DECIMAL(28,8)
		DECLARE @SALDO_DOLAR				AS DECIMAL(28,8)
		DECLARE @MONTO_CLIENTE				AS DECIMAL(28,8)
		DECLARE @SALDO_CLIENTE				AS DECIMAL(28,8)
		DECLARE @SUBTOTAL					AS DECIMAL(28,8)		
		DECLARE @FECHA_ULT_CREDITO			AS DATETIME		
		DECLARE @APROBADO					AS VARCHAR(1)		
		DECLARE @FECHA_ULT_MOD				AS DATETIME		
		DECLARE @CLASE_DOCUMENTO			AS VARCHAR(1)
		DECLARE @FECHA_VENCE				AS DATETIME	
		DECLARE @USUARIO_ULT_MOD			AS VARCHAR(25)		
		DECLARE @CLIENTE					AS VARCHAR(20)
		DECLARE @UpdatedBy					AS VARCHAR(30)		
		DECLARE @ANULADO					AS VARCHAR(1) 		
		DECLARE @DIAS_NETO					AS INT
		DECLARE @FECHA_VENCE_T				DATETIME
		DECLARE	@DOC_DOC_ORIGEN				AS VARCHAR(50)

		/*-----------------------------------------------------------*/
						--- VAIABLES TEMPORALES N/C ---
		---------------------------------------------------------------

		DECLARE	@TEMP_DOCUMENTO				NVARCHAR(50)
		DECLARE	@TEMP_TIPO					VARCHAR(3)
		DECLARE	@TEMP_APLICACION			VARCHAR(3)
		DECLARE	@TEMP_FECHA_DOCUMENTO		DATETIME
		DECLARE	@TEMP_FECHA					DATETIME
		DECLARE	@TEMP_MONTO					DECIMAL(28,8)
		DECLARE	@TEMP_SALDO					DECIMAL(28,8)
		DECLARE	@TEMP_MONTO_LOCAL			DECIMAL(28,8)
		DECLARE	@TEMP_SALDO_LOCAL			DECIMAL(28,8)
		DECLARE	@TEMP_MONTO_DOLAR			DECIMAL(28,8)
		DECLARE	@TEMP_SALDO_DOLAR			DECIMAL(28,8)
		DECLARE	@TEMP_MONTO_CLIENTE			DECIMAL(28,8)
		DECLARE	@TEMP_SALDO_CLIENTE			DECIMAL(28,8)
		DECLARE	@TEMP_SUBTOTAL				DECIMAL(28,8)
		DECLARE	@TEMP_APROBADO				VARCHAR(1)
		DECLARE	@TEMP_USUARIO_ULT_MOD		VARCHAR(25)
		DECLARE	@TEMP_DOC_DOC_ORIGEN		NVARCHAR(50)
		DECLARE	@TEMP_FECHA_ANUL			DATETIME
		DECLARE	@TEMP_AUD_USUARIO_ANUL		VARCHAR(25)
		DECLARE	@TEMP_AUD_FECHA_ANUL		DATETIME
		DECLARE	@TEMP_USUARIO_APROBACION	VARCHAR(25)
		DECLARE	@TEMP_FECHA_APROBACION		DATETIME
		DECLARE	@TEMP_UpdatedBy				VARCHAR(25)
		DECLARE	@TEMP_ANULADO				VARCHAR(1)
		DECLARE @TEMP_CLIENTE				VARCHAR(20)
		DECLARE @TEMP_ASIENTO				VARCHAR(10)
		DECLARE @TEMP_MAYOR_AUDITORIA		INT
		DECLARE @TEMP_NOMBRE_CLIENTE		VARCHAR(150)

		/*--------------------------------------------------------------*/
			--- VARIALES PARA ITERACION EN DOCUMENTOS_CC TIPO N/C ---
		------------------------------------------------------------------

		DECLARE @I					AS	INT
			SET @I = 1
		DECLARE @Id_DOC				AS	INT

		BEGIN TRY
			BEGIN TRANSACTION 

		/*--------------------------------------------------------------*/
				--- TABLA TEMPORAL CON LOS DOCUMENTOS TIPO N/C ---
		------------------------------------------------------------------

				DECLARE @DOCUMENTOS_CC_OD AS TABLE(		
				ID INT IDENTITY(1,1)		PRIMARY KEY,
				DOCUMENTO					NVARCHAR(50),
				TIPO						VARCHAR(3),
				APLICACION					VARCHAR(249),
				FECHA_DOCUMENTO				DATETIME,
				FECHA						DATETIME,
				MONTO						DECIMAL(28,8),
				SALDO						DECIMAL(28,8),
				MONTO_LOCAL					DECIMAL(28,8),
				SALDO_LOCAL					DECIMAL(28,8),
				MONTO_DOLAR					DECIMAL(28,8),
				SALDO_DOLAR					DECIMAL(28,8),
				MONTO_CLIENTE				DECIMAL(28,8),
				SALDO_CLIENTE				DECIMAL(28,8),
				SUBTOTAL					DECIMAL(28,8),
				APROBADO					VARCHAR(1),
				USUARIO_ULT_MOD				VARCHAR(25),
				DOC_DOC_ORIGEN				NVARCHAR(50),
				FECHA_ANUL					DATETIME,
				AUD_USUARIO_ANUL			VARCHAR(25),
				AUD_FECHA_ANUL				DATETIME,
				USUARIO_APROBACION			VARCHAR(25),
				FECHA_APROBACION			DATETIME,
				UpdatedBy					VARCHAR(25),
				ANULADO						VARCHAR(1),
				CLIENTE						VARCHAR(20),
				ASIENTO						VARCHAR(10))
				

		/*----------------------------------------------------------------*/
					--- OBTENER REGISTRO DOCUMENTOS N/C ---
		--------------------------------------------------------------------

		INSERT INTO @DOCUMENTOS_CC_OD
		(DOCUMENTO,TIPO,APLICACION,FECHA_DOCUMENTO,FECHA,MONTO,SALDO,MONTO_LOCAL,
		SALDO_LOCAL,MONTO_DOLAR,SALDO_DOLAR,MONTO_CLIENTE,SALDO_CLIENTE,SUBTOTAL,
		APROBADO,USUARIO_ULT_MOD,DOC_DOC_ORIGEN,FECHA_ANUL,AUD_USUARIO_ANUL,AUD_FECHA_ANUL,
		USUARIO_APROBACION,FECHA_APROBACION,UpdatedBy,ANULADO,CLIENTE,ASIENTO)

				SELECT 

					DOCUMENTO,
					TIPO,
					APLICACION,
					FECHA_DOCUMENTO,
					FECHA,
					MONTO,
					SALDO,
					MONTO_LOCAL,
					SALDO_LOCAL,
					MONTO_DOLAR,
					SALDO_DOLAR,
					MONTO_CLIENTE,
					SALDO_CLIENTE,
					SUBTOTAL,
					APROBADO,
					USUARIO_ULT_MOD,
					DOC_DOC_ORIGEN,
					FECHA_ANUL,
					AUD_USUARIO_ANUL,
					AUD_FECHA_ANUL,
					USUARIO_APROBACION,
					FECHA_APROBACION,
					UpdatedBy,
					ANULADO,
					CLIENTE,
					ASIENTO


				FROM AHPF_HN.ASHPF.DOCUMENTOS_CC 

				WHERE DOC_DOC_ORIGEN=@FACTURA AND TIPO='N/C' AND ANULADO='N'


		/*-----------------------------------------------------------------*/
				--- ITERACION EN DOCUMENTOS CC POR TIPO N/C ---
		---------------------------------------------------------------------

		SELECT @Id_DOC = COUNT(*) FROM @DOCUMENTOS_CC_OD
		
		WHILE @I <= @Id_DOC
		BEGIN


				SELECT 

					@TEMP_DOCUMENTO					=	OD.DOCUMENTO,				
					@TEMP_TIPO						=	OD.TIPO,			
					@TEMP_APLICACION				=	OD.APLICACION,
					@TEMP_FECHA_DOCUMENTO			=	OD.FECHA_DOCUMENTO,
					@TEMP_FECHA						=	OD.FECHA,
					@TEMP_MONTO						=	OD.MONTO,
					@TEMP_SALDO						=	OD.SALDO,
					@TEMP_MONTO_LOCAL				=	OD.MONTO_LOCAL,	
					@TEMP_SALDO_LOCAL				=	OD.SALDO_LOCAL,	
					@TEMP_MONTO_DOLAR				=	OD.MONTO_DOLAR,
					@TEMP_SALDO_DOLAR				=	OD.SALDO_DOLAR,
					@TEMP_MONTO_CLIENTE				=	OD.MONTO_CLIENTE,
					@TEMP_SALDO_CLIENTE				=	OD.SALDO_CLIENTE,
					@TEMP_SUBTOTAL					=	OD.SUBTOTAL,
					@TEMP_APROBADO					=	OD.APROBADO,
					@TEMP_USUARIO_ULT_MOD			=	@USUARIO,
					@TEMP_DOC_DOC_ORIGEN			=	OD.DOC_DOC_ORIGEN,
					@TEMP_FECHA_ANUL				=	OD.FECHA_ANUL,
					@TEMP_AUD_USUARIO_ANUL			=	@USUARIO,
					@TEMP_AUD_FECHA_ANUL			=	GETDATE(),
					@TEMP_USUARIO_APROBACION		=	@USUARIO,
					@TEMP_FECHA_APROBACION			=	GETDATE(),
					@TEMP_UpdatedBy					=	@USUARIO,
					@TEMP_ANULADO					=	OD.ANULADO,
					@TEMP_CLIENTE					=	OD.CLIENTE,
					@TEMP_ASIENTO					=	OD.ASIENTO


				FROM @DOCUMENTOS_CC_OD AS OD WHERE OD.ID = @I


										/*------------------------------------------------------*/
													--- ACTUALIZAR SALDO CLIENTE ---
										----------------------------------------------------------


										UPDATE 	AHPF_HN.ASHPF.CLIENTE  
										SET 	
										SALDO		= SALDO			+ @TEMP_SALDO,  	
										SALDO_LOCAL = SALDO_LOCAL	+ @TEMP_SALDO,
										FECHA_ULT_MOV=GETDATE(),
										UpdatedBy = @USUARIO 
										            
										WHERE CLIENTE =@TEMP_CLIENTE			   

										UPDATE	AHPF_HN.ASHPF.SALDO_CLIENTE  
										SET	
										SALDO = SALDO + @TEMP_SALDO,
										FECHA_ULT_MOV=GETDATE(),
										UpdatedBy = @USUARIO  
										       
										WHERE	CLIENTE =@TEMP_CLIENTE  AND 	MONEDA ='LPS'


										/*-------------------------------------------------------*/
													--- ANULAR DOCUMENTO N/C ---
										-----------------------------------------------------------

										
										UPDATE AHPF_HN.ASHPF.DOCUMENTOS_CC

											SET 
											APLICACION='** ANULADO **',
											MONTO=0.00000000,
											SALDO=0.00000000,
											SALDO_CLIENTE=0.00000000,
											SALDO_LOCAL=0.00000000,
											MONTO_LOCAL=0.00000000, 
											MONTO_DOLAR=0.00000000, 
											MONTO_CLIENTE=0.00000000, 
											SUBTOTAL=0.00000000,
											AUD_USUARIO_ANUL=@USUARIO, 
											AUD_FECHA_ANUL=@TEMP_AUD_FECHA_ANUL, 
											USUARIO_APROBACION=@USUARIO,
											FECHA_APROBACION=@TEMP_FECHA_APROBACION,
											FECHA_ANUL=@TEMP_FECHA_DOCUMENTO,
											ANULADO='S',
											APROBADO='S',
											USUARIO_ULT_MOD=@USUARIO,
											UpdatedBy =@USUARIO

										WHERE DOCUMENTO=@TEMP_DOCUMENTO AND DOC_DOC_ORIGEN=@FACTURA AND TIPO='N/C'

						
			SET @I = @I + 1
		END

		/*--------------------------------------------------------------------------------------------------*/
							--- GENERACION PARTIDA DE REVERSION PARA N/C ---
		------------------------------------------------------------------------------------------------------
		


								/*-------------------------------------------------------------------------*/
												--- REGISTRAR AUDITORIA DE PROCESO ---
								-----------------------------------------------------------------------------

								SELECT 	
								@TEMP_TIPO			=	 TIPO,							
								@TEMP_ASIENTO		=	 ASIENTO

								FROM 	AHPF_HN.ASHPF.DOCUMENTOS_CC                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
								WHERE	TIPO = 'N/C'          AND 	DOCUMENTO = @TEMP_DOCUMENTO AND DOC_DOC_ORIGEN=@FACTURA
					
								INSERT INTO AHPF_HN.ASHPF.AUDITORIA_DE_PROC 
								(ORIGEN,OPCION,USUARIO,FECHA_HORA,NOTAS,ASIENTO )        
								VALUES 
								( 'CC','Modificar estado de aprobación',@USUARIO,ERPADMIN.SF_GETDATE(),'El documento: ' + @TEMP_DOCUMENTO + 'tipo:' + @TEMP_TIPO + 'que pertenece al cliente: ' + @TEMP_CLIENTE + ' ' + 'fue desaprobado.',NULL)
								

								/*-------------------------------------------------------------------------*/
										--- ELIMINANDO  TRANSACCION CONTABLE POR DOCUMENTO REC ---
								-----------------------------------------------------------------------------
								
								DECLARE @ASIENTO_R_OUT			AS VARCHAR(10)
								DECLARE @ASIENTO_R				AS VARCHAR(10)

								EXECUTE AHPF_HN.ASHPF.sP_ASIENTO_REVERSION @TEMP_ASIENTO,@USUARIO,@TEMP_CLIENTE,'CC1',@ASIENTO_R_OUT OUTPUT

								UPDATE AHPF_HN.ASHPF.ASIENTO_MAYORIZADO
								SET NOTAS =NULL
								WHERE ASIENTO=@TEMP_ASIENTO

								SET @ASIENTO_R =(SELECT @ASIENTO_R_OUT)


								/*------------------------------------------------------------------------*/
													--- ACTUALIZAR NOTAS ---
								----------------------------------------------------------------------------

								DECLARE @NewLineChar	AS CHAR(2) = CHAR(13) + CHAR(10)
								DECLARE @NOTAS_AM_  	AS NVARCHAR(MAX)

								SET @TEMP_NOMBRE_CLIENTE	=(SELECT C1.NOMBRE  FROM AHPF_HN.ASHPF.CLIENTE AS C1 WITH(NOLOCK) INNER JOIN ASHPF.FACTURA AS C2  ON C2.CLIENTE = C1.CLIENTE  WHERE C2.FACTURA = @FACTURA)
										
								SET @NOTAS_AM_ =(
								'-------------------------------------------------------' + @NewLineChar +
								'Reversado con partida: ' + ' ' + @ASIENTO_R + @NewLineChar +
								'-------------------------------------------------------' + @NewLineChar +
								'Cliente:' + ' ' + @TEMP_CLIENTE + ' ' + 'Nombre: ' + ' ' + UPPER(@TEMP_NOMBRE_CLIENTE))

								UPDATE AHPF_HN.ASHPF.ASIENTO_MAYORIZADO
								SET NOTAS=@NOTAS_AM_
								WHERE ASIENTO=@TEMP_ASIENTO

											
								  


								
							

			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
	 
			IF @@TRANCOUNT > 0
			BEGIN
				PRINT XACT_STATE();
				ROLLBACK TRANSACTION;
			END
				PRINT ERROR_MESSAGE();
				THROW 50001, 'Ha ocurrido un error, la transacción ha sido cancelada.',0;
				EXECUTE AHPF_HN.ASHPF.Sp_LogError;
		END CATCH 
END
