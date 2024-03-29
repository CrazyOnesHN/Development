USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_PROCESO_ANULACION_DOCUMENTO_H1]    Script Date: 11/9/2022 3:46:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [ASHPF].[sP_PROCESO_ANULACION_DOCUMENTO_H1]
 	
	@FACTURA			AS VARCHAR(50),
	@USUARIO			AS VARCHAR(30),
	@OBSERVACIONES		AS VARCHAR(MAX),
	@FECHA_HORA_ANULA	AS DATETIME
AS
BEGIN

	SET NOCOUNT ON;

				DECLARE @TEMP_MAYOR_AUDITORIA	AS INT
				DECLARE @TEMP_MONTO				AS DECIMAL(28,8)
				DECLARE @TEMP_MONTO_LOCAL		AS DECIMAL(28,8)
				DECLARE @TEMP_MONTO_CLIENTE		AS DECIMAL(28,8)
				DECLARE @TEMP_MONTO_DOLAR		AS DECIMAL(28,8)
				DECLARE @TEMP_CLIENTE_CORP		AS VARCHAR(20)
				DECLARE @TEMP_APLICACION		AS VARCHAR(249)
				DECLARE @TEMP_TIPO				AS VARCHAR(3)
 				DECLARE @TEMP_ASIENTO_CXC		AS VARCHAR(10)
				DECLARE @TEMP_ASIENTO_FA		AS VARCHAR(10)
				DECLARE @TEMP_ASIENTO_DOCUMENTO	AS VARCHAR(10)
				DECLARE @TEMP_NOMBRE_CLIENTE	AS VARCHAR(150)
				DECLARE @TEMP_AUDIT_TRANS_INV	AS INT
				DECLARE @TEMP_CANT_DISPONIBLE	AS DECIMAL(28,8)
				DECLARE @TEMP_SALDO				AS DECIMAL(28,8)
				DECLARE @TEMP_SALDO_LOCAL 		AS DECIMAL(28,8)
				DECLARE @TEMP_SALDO_CLIENTE		AS DECIMAL(28,8)
				DECLARE @TEMP_SALDO_DOLAR		AS DECIMAL(28,8)
				
				DECLARE @Id_FC					AS INT
				DECLARE @FLAG_FAC				AS INT
				DECLARE @FLAG_REC				AS INT
				DECLARE @MAX_AUDITORIA			AS INT
				DECLARE @REC		 			AS VARCHAR(50)


				--- VARIABLES TEMPORALES TRANSACCION DE INVENTARIO
	  
				DECLARE @AUDIT_TRANS_INV	AS INT
				DECLARE @CONSECUTIVO		AS INT
				DECLARE @ARTICULO			AS VARCHAR(20)
				DECLARE @BODEGA				AS VARCHAR(4)
				DECLARE @LOCALIZACION		AS VARCHAR(8)
				DECLARE @LOTE				AS VARCHAR(15)     
				DECLARE @TIPO				AS VARCHAR(1)
				DECLARE @SUBTIPO			AS VARCHAR(1)
				DECLARE @SUBSUBTIPO			AS VARCHAR(1)
				DECLARE @NATURALEZA			AS VARCHAR(1)
				DECLARE @CANTIDAD			AS DECIMAL(28,8)    
				DECLARE @COSTO_TOT_FISC_LOC	AS DECIMAL(28,8)  
				DECLARE @COSTO_TOT_FISC_DOL AS DECIMAL(28,8)      
				DECLARE @COSTO_TOT_COMP_LOC	AS DECIMAL(28,8)  
				DECLARE @COSTO_TOT_COMP_DOL	AS DECIMAL(28,8)       
				DECLARE @PRECIO_TOTAL_LOCAL	AS DECIMAL(28,8)  
				DECLARE @PRECIO_TOTAL_DOLAR	AS DECIMAL(28,8)  
				DECLARE @CONTABILIZADA		AS VARCHAR(1)
				DECLARE @FECHA				AS DATETIME       
				DECLARE @CENTRO_COSTO		AS VARCHAR(25)
				DECLARE @AJUSTE_CONFIG		AS VARCHAR(4)
				DECLARE @NIT				AS VARCHAR(20)
				DECLARE @CUENTA_CONTABLE	AS VARCHAR(25)
				DECLARE @FECHA_HORA_TRANSAC	AS DATETIME 
				DECLARE @ROWPOINTER			AS UNIQUEIDENTIFIER  

				--- VARIABLES TEMPORALES AUXILIAR_CC

				DECLARE @TIPO_CREDITO		AS VARCHAR(3)
				DECLARE @CREDITO			AS VARCHAR(50)
				DECLARE @DEBITO				AS VARCHAR(50)

				----------------------------------------------

				--- VARIABLES PARA ITERACION DE LINEAS 

				DECLARE @E					AS	INT
					SET @E = 1
				DECLARE	@Id_INV				AS	INT

				--- VARIABLES PARA ITERACION DE LINEAS 

				DECLARE @F					AS	INT
					SET @F = 1
				DECLARE	@Id_F				AS	INT


				--- VARIABLES PARA ITERACION EN AUXILIAR_CC 

				DECLARE @A					AS	INT
					SET @A = 1
				DECLARE	@Id_AUX				AS	INT

	

	BEGIN TRY
		BEGIN TRANSACTION 

				/*--------------------------------------------------------*/
					--- CARGA DE LINEAS DE TRANSACCION DE INVENTARIO ---
				------------------------------------------------------------
		
				DECLARE @TRANSACCION_INV AS TABLE(
				ID INT IDENTITY(1,1) PRIMARY KEY,
				AUDIT_TRANS_INV		INT,
				CONSECUTIVO			INT,
				ARTICULO			VARCHAR(20),
				BODEGA				VARCHAR(4),
				LOCALIZACION		VARCHAR(8),
				LOTE				VARCHAR(15),     
				TIPO				VARCHAR(1),
				SUBTIPO			    VARCHAR(1),
				SUBSUBTIPO			VARCHAR(1),
				NATURALEZA			VARCHAR(1),
				CANTIDAD			DECIMAL(28,8),  
				COSTO_TOT_FISC_LOC	DECIMAL(28,8),  
				COSTO_TOT_FISC_DOL  DECIMAL(28,8),      
				COSTO_TOT_COMP_LOC	DECIMAL(28,8), 
				COSTO_TOT_COMP_DOL	DECIMAL(28,8),       
				PRECIO_TOTAL_LOCAL	DECIMAL(28,8),  
				PRECIO_TOTAL_DOLAR	DECIMAL(28,8),  
				CONTABILIZADA		VARCHAR(1),
				FECHA				DATETIME,      
				CENTRO_COSTO		VARCHAR(25),
				AJUSTE_CONFIG		VARCHAR(4),
				NIT					VARCHAR(20),
				CUENTA_CONTABLE		VARCHAR(25),
				FECHA_HORA_TRANSAC	DATETIME, 
				ROWPOINTER			UNIQUEIDENTIFIER  
			)
		
				/*----------------------------------*/
						--- AUXILIA_CC ---
				--------------------------------------

				DECLARE @AUXILIAR_CC	AS TABLE(
				ID INT IDENTITY(1,1) PRIMARY KEY,
				TIPO_CREDITO			VARCHAR(3),
				CREDITO					VARCHAR(50),
				DEBITO					VARCHAR(50))

		/*----------------------------------------------------------------------------------------------------------*/
									--- OBTENER LAS TRANSACCION DE INVENTARIO ---
		--------------------------------------------------------------------------------------------------------------

		SET @TEMP_AUDIT_TRANS_INV = (SELECT AUDIT_TRANS_INV FROM AHPF_HN.ASHPF.FACTURA WITH(NOLOCK) WHERE FACTURA = @FACTURA)

		INSERT INTO @TRANSACCION_INV
		(AUDIT_TRANS_INV,CONSECUTIVO,ARTICULO,BODEGA,LOCALIZACION,LOTE,TIPO,SUBTIPO,SUBSUBTIPO,NATURALEZA,CANTIDAD,COSTO_TOT_FISC_LOC,
		COSTO_TOT_FISC_DOL,COSTO_TOT_COMP_LOC,COSTO_TOT_COMP_DOL,PRECIO_TOTAL_LOCAL,PRECIO_TOTAL_DOLAR,CONTABILIZADA,FECHA,CENTRO_COSTO,
		AJUSTE_CONFIG,NIT,CUENTA_CONTABLE,FECHA_HORA_TRANSAC,ROWPOINTER)

		SELECT  
			AUDIT_TRANS_INV, 
			CONSECUTIVO, 
			ARTICULO, 
			BODEGA, 
			LOCALIZACION, 
			LOTE,        
			TIPO, 
			SUBTIPO, 
			SUBSUBTIPO, 
			NATURALEZA, 
			CANTIDAD,        
			COSTO_TOT_FISC_LOC, 
			COSTO_TOT_FISC_DOL,        
			COSTO_TOT_COMP_LOC, 
			COSTO_TOT_COMP_DOL,        
			PRECIO_TOTAL_LOCAL, 
			PRECIO_TOTAL_DOLAR, 
			CONTABILIZADA, FECHA,        
			CENTRO_COSTO, AJUSTE_CONFIG,NIT,CUENTA_CONTABLE, FECHA_HORA_TRANSAC ,ROWPOINTER  

		FROM AHPF_HN.ASHPF.TRANSACCION_INV WITH(NOLOCK) WHERE AUDIT_TRANS_INV = @TEMP_AUDIT_TRANS_INV 
		
		/*--------------------------------------------------------------------------------*/
							--- OBTENER CREDITOS EN AUXILIAR_CC ---
		-----------------------------------------------------------------------------------

		INSERT INTO @AUXILIAR_CC
		(TIPO_CREDITO,CREDITO,DEBITO)
		
		SELECT
			TCC.TIPO_CREDITO,
			TCC.CREDITO,
			TCC.DEBITO

		FROM AHPF_HN.ASHPF.AUXILIAR_CC AS TCC WITH(NOLOCK) WHERE TCC.DEBITO = @FACTURA  
		        	
		/*------------------------------------------------------------------------------*/		
					--- INICIA EL PROCESO DE ANULACION RECIBO Y PARTIDA CC1 ---
		----------------------------------------------------------------------------------

			SELECT @Id_AUX = COUNT(*) FROM @AUXILIAR_CC
			SET  @FLAG_FAC = (SELECT COUNT(*) FROM AHPF_HN.ASHPF.DOCUMENTOS_CC WITH(NOLOCK) WHERE DOCUMENTO=@FACTURA)

			/*-----------------------------------------------------*/
					--- AFECTO CUENTAS POR COBRAR ---
			---------------------------------------------------------

			IF @Id_AUX > 0			
			WHILE @E <= @Id_AUX
			BEGIN
				SELECT 
					@TIPO_CREDITO		= CC.TIPO_CREDITO,
					@CREDITO			= CC.CREDITO,
					@DEBITO				= CC.DEBITO

				FROM @AUXILIAR_CC AS CC  WHERE CC.ID = @E


				/*-------------------------------------------------------*/
						--- DESAPROBAR DOCUMENTO TIPO REC ---
				----------------------------------------------------------

				DELETE 	FROM AHPF_HN.ASHPF.AUXILIAR_CC WHERE TIPO_CREDITO = 'REC'  AND 	DEBITO = @FACTURA

				/*-------------------------------------------------------*/

					SET @REC					=(SELECT CREDITO FROM @AUXILIAR_CC WHERE  DEBITO=@FACTURA)
					SET @TEMP_NOMBRE_CLIENTE	=(SELECT C1.NOMBRE  FROM AHPF_HN.ASHPF.CLIENTE AS C1 WITH(NOLOCK) INNER JOIN ASHPF.FACTURA AS C2  ON C2.CLIENTE = C1.CLIENTE  WHERE C2.FACTURA = @FACTURA)
					SET @TEMP_CLIENTE_CORP		=(SELECT CLIENTE  FROM AHPF_HN.ASHPF.FACTURA WITH(NOLOCK) WHERE FACTURA = @FACTURA)
					SET @TEMP_APLICACION		
					=('Aplicación: Abono a cancelación de factura' + ' ' + @FACTURA + ' - ' + 'Cliente:' + ' - ' + 
					(SELECT UDF_Nombre_Paciente FROM H1_AHPF_HN.dbo.FC  WITH(NOLOCK) 
					WHERE UDF_Factura_E=@FACTURA) + ' ' + '__________________________________________________________' + ' ' + 'Notas:')


					/*--------------------------------------------------*/
									--- OBTENER MONTO ---
					------------------------------------------------------

					SELECT 
					@TEMP_MONTO			=	CC1.MONTO,
					@TEMP_MONTO_LOCAL 	=	CC1.MONTO_CLIENTE,
					@TEMP_MONTO_CLIENTE	=	CC1.MONTO_LOCAL,
					@TEMP_MONTO_DOLAR	=	CC1.MONTO_DOLAR

					FROM AHPF_HN.ASHPF.DOCUMENTOS_CC AS CC1 WITH(NOLOCK) WHERE CC1.DOCUMENTO = @REC

								EXEC erpadmin.GrabarUsuarioActual @USUARIO
								EXEC erpadmin.LeerUsuarioActual @USUARIO


								/*--------------------------------------------------------------------------*/
									--- ACTUALIZAR SALDOS DESPUES DE HABER REVERSADO EL DOCUMENTO ---
								------------------------------------------------------------------------------

								UPDATE 	AHPF_HN.ASHPF.DOCUMENTOS_CC  
								SET SALDO		=  ROUND(SALDO			+ @TEMP_MONTO, 2), 
								SALDO_CLIENTE	=  ROUND(SALDO_CLIENTE	+ @TEMP_MONTO_LOCAL, 2), 
								SALDO_LOCAL		=  ROUND(SALDO_LOCAL	+ @TEMP_MONTO_CLIENTE, 2), 
								SALDO_DOLAR		=  ROUND(SALDO_DOLAR	+ @TEMP_MONTO_DOLAR, 2),UpdatedBy = @USUARIO   
								WHERE  TIPO		= 'REC'  AND	DOCUMENTO = @REC

								/*--------------------------------------------------------------------------*/
												--- ACTUALIZAR SALDOS DOCUMENTO FAC ---
								------------------------------------------------------------------------------

								UPDATE 	AHPF_HN.ASHPF.DOCUMENTOS_CC  
								SET SALDO		=  ROUND(SALDO			+ @TEMP_MONTO, 2), 
								SALDO_CLIENTE	=  ROUND(SALDO_CLIENTE	+ @TEMP_MONTO_LOCAL, 2), 
								SALDO_LOCAL		=  ROUND(SALDO_LOCAL	+ @TEMP_MONTO_CLIENTE, 2), 
								SALDO_DOLAR		=  ROUND(SALDO_DOLAR	+ @TEMP_MONTO_DOLAR, 2),UpdatedBy = @USUARIO  
								WHERE  TIPO		= 'FAC'  AND	DOCUMENTO = @FACTURA																	

								/*--------------------------------------------------------------------------*/
											--- ACTUALIZAR POSTERIOR A LA ANULACION  REC ---
								------------------------------------------------------------------------------

								UPDATE 	AHPF_HN.ASHPF.CLIENTE 
								SET SALDO	= SALDO			+ @TEMP_MONTO,  	
								SALDO_LOCAL = SALDO_LOCAL	+ @TEMP_MONTO_CLIENTE,  	
								SALDO_DOLAR = SALDO_DOLAR	+ @TEMP_MONTO_DOLAR,
								FECHA_ULT_MOV = GETDATE(),UpdatedBy = @USUARIO          
								WHERE CLIENTE = @TEMP_CLIENTE_CORP
								
								
								/*--------------------------------------------------------------------------*/							
												--- ANULAR  REC EN  DOCUMENTOS CC ---
								------------------------------------------------------------------------------

								UPDATE AHPF_HN.ASHPF.DOCUMENTOS_CC
								SET APLICACION='** ANULADO **',
								MONTO=0.00000000,SALDO=0.00000000,SALDO_CLIENTE=0.00000000,SALDO_LOCAL=0.00000000,MONTO_LOCAL=0.00000000, MONTO_DOLAR=0.00000000, MONTO_CLIENTE=0.00000000, SUBTOTAL=0.00000000,
								NOTAS=@TEMP_APLICACION, 
								AUD_USUARIO_ANUL=@USUARIO, AUD_FECHA_ANUL=GETDATE(), USUARIO_APROBACION=@USUARIO,FECHA_APROBACION=GETDATE(),ANULADO='S',UpdatedBy = @USUARIO
								WHERE DOCUMENTO=@REC

								UPDATE 	AHPF_HN.ASHPF.DOCUMENTOS_CC  
								SET 	APROBADO	= 'N', 
								USUARIO_APROBACION	= NULL, 
								FECHA_APROBACION	= NULL,UpdatedBy = @USUARIO                 
								WHERE 	TIPO ='REC'  AND 	DOCUMENTO = @REC

								
								/*-------------------------------------------------------------------------*/
												--- ANULAR O/D EN DOCUMENTOS CC ---
								-----------------------------------------------------------------------------

								DECLARE @TIPO_FC AS INT

								SELECT @TIPO_FC =COUNT(*) FROM ASHPF.FACTURA_CANCELA WHERE FACTURA=@FACTURA AND TIPO='T'

								IF @TIPO_FC > 0
								BEGIN
									EXECUTE AHPF_HN.ASHPF.sP_DOCUMENTO_CC_REC_POS_ANUL @FACTURA,@USUARIO
								END 
								

								/*-------------------------------------------------------------------------*/
												--- REGISTRAR AUDITORIA DE PROCESO ---
								-----------------------------------------------------------------------------

								SELECT 	
								@TEMP_TIPO			=	 TIPO,							
								@TEMP_ASIENTO_CXC	=	 ASIENTO

								FROM 	AHPF_HN.ASHPF.DOCUMENTOS_CC                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
								WHERE	TIPO = 'REC'          AND 	DOCUMENTO = @REC
					
								INSERT INTO AHPF_HN.ASHPF.AUDITORIA_DE_PROC 
								(ORIGEN,OPCION,USUARIO,FECHA_HORA,NOTAS,ASIENTO )        
								VALUES 
								( 'CC','Modificar estado de aprobación',@USUARIO,ERPADMIN.SF_GETDATE(),'El documento: ' + @REC + 'tipo:' + @TEMP_TIPO + 'que pertenece al cliente: ' + @TEMP_CLIENTE_CORP + ' ' + 'fue desaprobado.',NULL)
								

								/*-------------------------------------------------------------------------*/
										--- ELIMINANDO  TRANSACCION CONTABLE POR DOCUMENTO REC ---
								-----------------------------------------------------------------------------
								
								DECLARE @ASIENTO_R_OUT			AS VARCHAR(10)
								DECLARE @ASIENTO_R				AS VARCHAR(10)

								EXECUTE AHPF_HN.ASHPF.sP_ASIENTO_REVERSION @TEMP_ASIENTO_CXC,@USUARIO,@TEMP_CLIENTE_CORP,'CC1',@ASIENTO_R_OUT OUTPUT

								UPDATE AHPF_HN.ASHPF.ASIENTO_MAYORIZADO
								SET NOTAS =NULL
								WHERE ASIENTO=@TEMP_ASIENTO_CXC

								SET @ASIENTO_R =(SELECT @ASIENTO_R_OUT)


								/*------------------------------------------------------------------------*/
													--- ACTUALIZAR NOTAS ---
								----------------------------------------------------------------------------

								DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10)
								DECLARE @NOTAS  	AS NVARCHAR(MAX)
								
								  
								SET @NOTAS =(
								'-------------------------------------------------------' + @NewLineChar +
								'Reversado con partida: ' + ' ' + @ASIENTO_R + @NewLineChar +
								'-------------------------------------------------------' + @NewLineChar +
								'Cliente:' + ' ' + @TEMP_CLIENTE_CORP + ' ' + 'Nombre: ' + ' ' + UPPER(@TEMP_NOMBRE_CLIENTE))
								
								
								UPDATE AHPF_HN.ASHPF.ASIENTO_MAYORIZADO
								SET NOTAS =@NOTAS
								WHERE ASIENTO=@TEMP_ASIENTO_CXC

								
								SET @TEMP_MAYOR_AUDITORIA = (SELECT (MAX(MAYOR_AUDITORIA) + 1) FROM AHPF_HN.ASHPF.MAYOR_AUDITORIA WITH(UPDLOCK))
																
								INSERT INTO AHPF_HN.ASHPF.MAYOR_AUDITORIA (COMENTARIO,FECHA,MAYOR_AUDITORIA,USUARIO)          
								VALUES ('Anulación de la partida:' + ' ' + @TEMP_ASIENTO_CXC, ERPADMIN.SF_GETDATE(),@TEMP_MAYOR_AUDITORIA,@USUARIO)
								



			SET @E = @E + 1

			END	


			/*-------------------------------------------------------------------------*/
							--- INICIA PROCESO DE ANULACION ---
							--- FACTURA Y PARTIDA DE INGRESO F1 ---
			-----------------------------------------------------------------------------
			

			IF   @FLAG_FAC > 0
			BEGIN

									SELECT 
									@TEMP_SALDO			=	CC1.SALDO,
									@TEMP_SALDO_LOCAL 	=	CC1.SALDO_LOCAL,
									@TEMP_SALDO_CLIENTE	=	CC1.SALDO_CLIENTE,
									@TEMP_SALDO_DOLAR	=	CC1.SALDO_DOLAR

									FROM AHPF_HN.ASHPF.DOCUMENTOS_CC AS CC1 WITH(NOLOCK) WHERE CC1.DOCUMENTO = @FACTURA

									SET @TEMP_MAYOR_AUDITORIA = (SELECT (MAX(MAYOR_AUDITORIA) + 1) FROM AHPF_HN.ASHPF.MAYOR_AUDITORIA WITH(UPDLOCK))
									SET @TEMP_NOMBRE_CLIENTE	=(SELECT C1.NOMBRE  FROM AHPF_HN.ASHPF.CLIENTE AS C1 WITH(NOLOCK) INNER JOIN ASHPF.FACTURA AS C2  ON C2.CLIENTE = C1.CLIENTE  WHERE C2.FACTURA = @FACTURA)
									SET @TEMP_CLIENTE_CORP		=(SELECT CLIENTE  FROM AHPF_HN.ASHPF.FACTURA WITH(NOLOCK) WHERE FACTURA = @FACTURA)


									/*-------------------------------------------------------------*/
											--- GENERACION ASIENTO DE REVERSION F1 ---
									-----------------------------------------------------------------

									SELECT 	
									@TEMP_TIPO			=	 TIPO,							
									@TEMP_ASIENTO_FA	=	 ASIENTO

									FROM 	AHPF_HN.ASHPF.DOCUMENTOS_CC  WITH(NOLOCK)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
									WHERE	TIPO = 'FAC'          AND 	DOCUMENTO = @FACTURA									

									DECLARE @ASIENTO_F1_R_OUT			AS VARCHAR(10)
									DECLARE @ASIENTO_R_F1				AS VARCHAR(10)

									EXECUTE AHPF_HN.ASHPF.sP_ASIENTO_REVERSION @TEMP_ASIENTO_FA,@USUARIO,@TEMP_CLIENTE_CORP,'F1',@ASIENTO_F1_R_OUT OUTPUT

									UPDATE AHPF_HN.ASHPF.ASIENTO_MAYORIZADO
									SET NOTAS =NULL
									WHERE ASIENTO=@TEMP_ASIENTO_FA

									SET @ASIENTO_R_F1 =(SELECT @ASIENTO_F1_R_OUT)

									/*-------------------------------------------------------------*/
													--- ACTUALIZAR NOTAS ---
									-----------------------------------------------------------------
														
									SET @NewLineChar = CHAR(13) + CHAR(10)
																  
									SET @NOTAS =(
									'-------------------------------------------------------' + @NewLineChar +
									'Reversado con partida: ' + ' ' + @ASIENTO_R_F1 + @NewLineChar +
									'-------------------------------------------------------' + @NewLineChar +
									'Cliente:' + ' ' + @TEMP_CLIENTE_CORP + ' ' + 'Nombre: ' + ' ' + UPPER(@TEMP_NOMBRE_CLIENTE))
								
								
									UPDATE AHPF_HN.ASHPF.ASIENTO_MAYORIZADO
									SET NOTAS =@NOTAS
									WHERE ASIENTO=@TEMP_ASIENTO_FA


									/*---------------------------------------------------------------*/
									 			--- REGISTRAR AUDITORIA DE PROCESO ---
									-------------------------------------------------------------------


									SET @TEMP_MAYOR_AUDITORIA = (SELECT (MAX(MAYOR_AUDITORIA) + 1) FROM AHPF_HN.ASHPF.MAYOR_AUDITORIA WITH(UPDLOCK))
																
								
									INSERT INTO AHPF_HN.ASHPF.MAYOR_AUDITORIA
									(COMENTARIO,FECHA,MAYOR_AUDITORIA,USUARIO )        
									VALUES 
									('Anulación de la partida:' + ' ' + @TEMP_ASIENTO_FA,ERPADMIN.SF_GETDATE(),@TEMP_MAYOR_AUDITORIA,@USUARIO)



									/*------------------------------------------------------------*/
													--- DEVOLUCION A INVENTARIO ---
									---------------------------------------------------------------
									
									INSERT INTO AHPF_HN.ASHPF.AUDIT_TRANS_INV
									(USUARIO,FECHA_HORA,MODULO_ORIGEN,CONSECUTIVO,APLICACION,REFERENCIA,ASIENTO,PAQUETE_INVENTARIO,ROWPOINTER)  
									VALUES (@USUARIO, ERPADMIN.SF_GETDATE(),'FA',NULL,'ANU-FAC#'+@FACTURA,@TEMP_CLIENTE_CORP,NULL,NULL,NEWID())

									SET @MAX_AUDITORIA = @@IDENTITY 

									/*-----------------------------------------------------------*/
															--- ITERACION ---
									---------------------------------------------------------------


									SELECT @Id_F = COUNT(*) FROM @TRANSACCION_INV

									WHILE @F <= @Id_F
										BEGIN
											SELECT 
												@AUDIT_TRANS_INV		= TI.AUDIT_TRANS_INV,	
												@CONSECUTIVO			= TI.CONSECUTIVO,		
												@ARTICULO				= TI.ARTICULO,			
												@BODEGA					= TI.BODEGA,	
												@LOCALIZACION			= TI.LOCALIZACION,		
												@LOTE					= TI.LOTE,				     
												@TIPO					= TI.TIPO,
												@SUBTIPO				= TI.SUBTIPO,
												@SUBSUBTIPO				= TI.SUBSUBTIPO,
												@NATURALEZA				= TI.NATURALEZA,
												@CANTIDAD			    = TI.CANTIDAD,
												@COSTO_TOT_FISC_LOC		= TI.COSTO_TOT_FISC_LOC,
												@COSTO_TOT_FISC_DOL     = TI.COSTO_TOT_FISC_DOL,
												@COSTO_TOT_COMP_LOC		= TI.COSTO_TOT_COMP_LOC,	  
												@COSTO_TOT_COMP_DOL		= TI.COSTO_TOT_COMP_DOL,       
												@PRECIO_TOTAL_LOCAL		= TI.PRECIO_TOTAL_LOCAL,  
												@PRECIO_TOTAL_DOLAR		= TI.PRECIO_TOTAL_DOLAR, 
												@CONTABILIZADA			= TI.CONTABILIZADA,	
												@FECHA					= TI.FECHA,		      
												@CENTRO_COSTO			= TI.CENTRO_COSTO,	
												@AJUSTE_CONFIG			= TI.AJUSTE_CONFIG,		
												@NIT					= TI.NIT,		
												@CUENTA_CONTABLE		= TI.CUENTA_CONTABLE,
												@FECHA_HORA_TRANSAC		= TI.FECHA_HORA_TRANSAC,	 
												@ROWPOINTER				= NEWID()

											FROM @TRANSACCION_INV AS TI WHERE TI.ID = @F


											/*----------------------------------------------------------*/
													--- ACTUALIZAR EXISTENCIAS EN BODEGA ---
											--------------------------------------------------------------

																																				
											EXEC AHPF_HN.ASHPF.EB_EL_H1_ @ARTICULO,@CANTIDAD,@BODEGA,@LOCALIZACION,@LOTE


											/*------------------------------------------------------------------*/
												--- REGISTRO DE AUDITORIA DE INVENTARIO POR LA DEVOLUCION ---
											----------------------------------------------------------------------

											INSERT INTO AHPF_HN.ASHPF.TRANSACCION_INV 
											(AUDIT_TRANS_INV,CONSECUTIVO,ARTICULO,BODEGA,LOCALIZACION,LOTE,TIPO,SUBTIPO,SUBSUBTIPO,NATURALEZA,CANTIDAD,
											COSTO_TOT_FISC_LOC,COSTO_TOT_FISC_DOL,COSTO_TOT_COMP_LOC,COSTO_TOT_COMP_DOL,PRECIO_TOTAL_LOCAL,PRECIO_TOTAL_DOLAR, 
											CONTABILIZADA, FECHA,CENTRO_COSTO,AJUSTE_CONFIG, SERIE_CADENA,NIT,UNIDAD_DISTRIBUCIO,CUENTA_CONTABLE,FECHA_HORA_TRANSAC,ROWPOINTER)

											VALUES
											(@MAX_AUDITORIA,@CONSECUTIVO,@ARTICULO,@BODEGA,@LOCALIZACION,@LOTE,@TIPO,@SUBTIPO,@SUBSUBTIPO,'E',-@CANTIDAD,
											@COSTO_TOT_FISC_LOC,@COSTO_TOT_FISC_DOL,@COSTO_TOT_COMP_LOC,@COSTO_TOT_COMP_DOL,@PRECIO_TOTAL_LOCAL,@PRECIO_TOTAL_DOLAR, 
											'N',GETDATE(),NULL,'~VV~',NULL,@NIT,NULL,NULL,GETDATE(),@ROWPOINTER)

										
											SET @F = @F + 1
										END

										EXEC erpadmin.GrabarUsuarioActual @USUARIO
										EXEC erpadmin.LeerUsuarioActual @USUARIO


										/*------------------------------------------------------*/
												--- CAMBIAR ESTADO  DE FACTURA 	---
										----------------------------------------------------------										
									
										UPDATE	AHPF_HN.ASHPF.FACTURA   
										SET 	ANULADA ='S',
										MULTIPLICADOR_EV = 0,
										USUARIO_ANULA =@USUARIO,
										FECHA_HORA_ANULA =GETDATE(),
										OBSERVACIONES = @OBSERVACIONES                    
										WHERE 	FACTURA =@FACTURA AND TIPO_DOCUMENTO ='F'

										UPDATE AHPF_HN.ASHPF.FACTURA_LINEA  
										SET ANULADA = 'S', 
										MULTIPLICADOR_EV = 0, UpdatedBy = @USUARIO  
										WHERE FACTURA =@FACTURA  AND TIPO_DOCUMENTO = 'F'


										/*------------------------------------------------------*/
												--- ACTUALIZAR SALDO CLIENTE EN CXC ---
										----------------------------------------------------------

										UPDATE 	AHPF_HN.ASHPF.CLIENTE  
										SET 	
										SALDO		= SALDO			- @TEMP_SALDO,  	
										SALDO_LOCAL = SALDO_LOCAL	- @TEMP_SALDO_LOCAL,
										UpdatedBy = @USUARIO 
										            
										WHERE CLIENTE =@TEMP_CLIENTE_CORP			   

										UPDATE	AHPF_HN.ASHPF.SALDO_CLIENTE  
										SET	SALDO = SALDO - @TEMP_SALDO,
										UpdatedBy = @USUARIO         
										WHERE	CLIENTE =@TEMP_CLIENTE_CORP  AND 	MONEDA ='LPS'
																 													
										UPDATE 	AHPF_HN.ASHPF.DOCUMENTOS_CC  
										SET 	APROBADO = 'S', 
										USUARIO_APROBACION =@USUARIO, 
										FECHA_APROBACION =GETDATE(), UpdatedBy = @USUARIO               
										WHERE 	TIPO ='FAC'  AND 	DOCUMENTO =@FACTURA

										/*-------------------------------------------------------*/
													--- Anulacion del FAC en CC ---
										-----------------------------------------------------------

										UPDATE AHPF_HN.ASHPF.DOCUMENTOS_CC
										SET APLICACION='** ANULADO **',
										MONTO=0.00000000,SALDO=0.00000000,SALDO_LOCAL=0.00000000,SALDO_CLIENTE=0.00000000, MONTO_LOCAL=0.00000000, MONTO_DOLAR=0.00000000, MONTO_CLIENTE=0.00000000, SUBTOTAL=0.00000000,
										NOTAS=@TEMP_APLICACION, 
										AUD_USUARIO_ANUL=@USUARIO, AUD_FECHA_ANUL=GETDATE(), USUARIO_APROBACION=@USUARIO,FECHA_APROBACION=GETDATE(),ANULADO='S'
										WHERE DOCUMENTO=@FACTURA

										UPDATE AHPF_HN.ASHPF.FACTURA_LINEA  
										SET PEDIDO		= NULL,
										PEDIDO_LINEA	= NULL, UpdatedBy = @USUARIO         
										WHERE FACTURA	= @FACTURA AND TIPO_DOCUMENTO ='F'

			END

			/*------------------------------------------*/
				--- NO AFECTO CUENTAS POR COBRAR ---
			----------------------------------------------
			
			IF @FLAG_FAC =0			
			BEGIN

									
									SET @TEMP_MAYOR_AUDITORIA = (SELECT (MAX(MAYOR_AUDITORIA) + 1) FROM AHPF_HN.ASHPF.MAYOR_AUDITORIA WITH(UPDLOCK))
									SET @TEMP_NOMBRE_CLIENTE	=(SELECT C1.NOMBRE  FROM AHPF_HN.ASHPF.CLIENTE AS C1 WITH(NOLOCK) INNER JOIN ASHPF.FACTURA AS C2  ON C2.CLIENTE = C1.CLIENTE  WHERE C2.FACTURA = @FACTURA)
									SET @TEMP_CLIENTE_CORP		=(SELECT CLIENTE  FROM AHPF_HN.ASHPF.FACTURA WITH(NOLOCK) WHERE FACTURA = @FACTURA)
									
									
									/*------------------------------------------------------------*/									
												--- GENERACION ASIENTO DE REVERSION ---
									----------------------------------------------------------------

									SELECT 	
												
									@TEMP_ASIENTO_FA	=	 ASIENTO_DOCUMENTO

									FROM 	AHPF_HN.ASHPF.FACTURA  WITH(NOLOCK)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
									WHERE	FACTURA = @FACTURA									
														

									EXECUTE AHPF_HN.ASHPF.sP_ASIENTO_REVERSION @TEMP_ASIENTO_FA,@USUARIO,@TEMP_CLIENTE_CORP,'F1',@ASIENTO_F1_R_OUT OUTPUT

									UPDATE AHPF_HN.ASHPF.ASIENTO_MAYORIZADO
									SET NOTAS =NULL
									WHERE ASIENTO=@TEMP_ASIENTO_FA

									SET @ASIENTO_R_F1 =(SELECT @ASIENTO_F1_R_OUT)


									/*-------------------------------------------------------------*/
														--- ACTUALIZAR NOTAS ---
									-----------------------------------------------------------------
									
									SET @NewLineChar = CHAR(13) + CHAR(10)						  
									SET @NOTAS =(
									'-------------------------------------------------------' + @NewLineChar +
									'Reversado con partida: ' + ' ' + @ASIENTO_R_F1 + @NewLineChar +
									'-------------------------------------------------------' + @NewLineChar +
									'Cliente:' + ' ' + @TEMP_CLIENTE_CORP + ' ' + 'Nombre: ' + ' ' + UPPER(@TEMP_NOMBRE_CLIENTE))
								
								
									UPDATE AHPF_HN.ASHPF.ASIENTO_MAYORIZADO
									SET NOTAS =@NOTAS
									WHERE ASIENTO=@TEMP_ASIENTO_FA


									/*-----------------------------------------------------------------------------------------------------------*/				
																	--- REGISTRAR AUDITORIA DE PROCESO ---		
									---------------------------------------------------------------------------------------------------------------
					
									SET @TEMP_MAYOR_AUDITORIA = (SELECT (MAX(MAYOR_AUDITORIA) + 1) FROM AHPF_HN.ASHPF.MAYOR_AUDITORIA WITH(UPDLOCK))

									INSERT INTO AHPF_HN.ASHPF.MAYOR_AUDITORIA
									(COMENTARIO,FECHA,MAYOR_AUDITORIA,USUARIO )        
									VALUES 
									('Anulación de la partida:' + ' ' + @TEMP_ASIENTO_FA,ERPADMIN.SF_GETDATE(),@TEMP_MAYOR_AUDITORIA,@USUARIO)


									/*-------------------------------------------------------------*/
													--- DEVOLUCION A INVENTARIO ---
									-----------------------------------------------------------------
									
									INSERT INTO AHPF_HN.ASHPF.AUDIT_TRANS_INV
									(USUARIO,FECHA_HORA,MODULO_ORIGEN,CONSECUTIVO,APLICACION,REFERENCIA,ASIENTO,PAQUETE_INVENTARIO,ROWPOINTER)  
									VALUES (@USUARIO, ERPADMIN.SF_GETDATE(),'FA',NULL,'ANU-FAC#'+@FACTURA,@TEMP_CLIENTE_CORP,NULL,NULL,NEWID())

									SET @MAX_AUDITORIA = @@IDENTITY 

									/*------------------------------------*/
											--- ITERACION ---
									----------------------------------------

									SELECT @Id_F = COUNT(*) FROM @TRANSACCION_INV

									WHILE @F <= @Id_F
										BEGIN
											SELECT 
												@AUDIT_TRANS_INV		= TI.AUDIT_TRANS_INV,	
												@CONSECUTIVO			= TI.CONSECUTIVO,		
												@ARTICULO				= TI.ARTICULO,			
												@BODEGA					= TI.BODEGA,	
												@LOCALIZACION			= TI.LOCALIZACION,		
												@LOTE					= TI.LOTE,				     
												@TIPO					= TI.TIPO,
												@SUBTIPO				= TI.SUBTIPO,
												@SUBSUBTIPO				= TI.SUBSUBTIPO,
												@NATURALEZA				= TI.NATURALEZA,
												@CANTIDAD			    = TI.CANTIDAD,
												@COSTO_TOT_FISC_LOC		= TI.COSTO_TOT_FISC_LOC,
												@COSTO_TOT_FISC_DOL     = TI.COSTO_TOT_FISC_DOL,
												@COSTO_TOT_COMP_LOC		= TI.COSTO_TOT_COMP_LOC,	  
												@COSTO_TOT_COMP_DOL		= TI.COSTO_TOT_COMP_DOL,       
												@PRECIO_TOTAL_LOCAL		= TI.PRECIO_TOTAL_LOCAL,  
												@PRECIO_TOTAL_DOLAR		= TI.PRECIO_TOTAL_DOLAR, 
												@CONTABILIZADA			= TI.CONTABILIZADA,	
												@FECHA					= TI.FECHA,		      
												@CENTRO_COSTO			= TI.CENTRO_COSTO,	
												@AJUSTE_CONFIG			= TI.AJUSTE_CONFIG,		
												@NIT					= TI.NIT,		
												@CUENTA_CONTABLE		= TI.CUENTA_CONTABLE,
												@FECHA_HORA_TRANSAC		= TI.FECHA_HORA_TRANSAC,	 
												@ROWPOINTER				= NEWID()

											FROM @TRANSACCION_INV AS TI WHERE TI.ID = @F


											/*-------------------------------------------------------*/
													--- ACTUALIZAR EXISTENCIAS EN BODEGA ---
											-----------------------------------------------------------
																																				
											EXEC AHPF_HN.ASHPF.EB_EL_H1_ @ARTICULO,@CANTIDAD,@BODEGA,@LOCALIZACION,@LOTE

											/*----------------------------------------------------------------------------*/
													--- REGISTRO DE AUDITORIA DE INVENTARIO POR LA DEVOLUCION ---
											--------------------------------------------------------------------------------

											INSERT INTO AHPF_HN.ASHPF.TRANSACCION_INV 
											(AUDIT_TRANS_INV,CONSECUTIVO,ARTICULO,BODEGA,LOCALIZACION,LOTE,TIPO,SUBTIPO,SUBSUBTIPO,NATURALEZA,CANTIDAD,
											COSTO_TOT_FISC_LOC,COSTO_TOT_FISC_DOL,COSTO_TOT_COMP_LOC,COSTO_TOT_COMP_DOL,PRECIO_TOTAL_LOCAL,PRECIO_TOTAL_DOLAR, 
											CONTABILIZADA, FECHA,CENTRO_COSTO,AJUSTE_CONFIG, SERIE_CADENA,NIT,UNIDAD_DISTRIBUCIO,CUENTA_CONTABLE,FECHA_HORA_TRANSAC,ROWPOINTER)

											VALUES
											(@MAX_AUDITORIA,@CONSECUTIVO,@ARTICULO,@BODEGA,@LOCALIZACION,@LOTE,@TIPO,@SUBTIPO,@SUBSUBTIPO,'E',-@CANTIDAD,
											@COSTO_TOT_FISC_LOC,@COSTO_TOT_FISC_DOL,@COSTO_TOT_COMP_LOC,@COSTO_TOT_COMP_DOL,@PRECIO_TOTAL_LOCAL,@PRECIO_TOTAL_DOLAR, 
											'N',GETDATE(),NULL,'~VV~',NULL,@NIT,NULL,NULL,GETDATE(),@ROWPOINTER)

										
											SET @F = @F + 1
										END


										/*-----------------------------------*/
										--- CAMBIAR ESTADO  DE FACTURA ERP --- 											
										---------------------------------------						
										
										EXEC erpadmin.GrabarUsuarioActual @USUARIO
										EXEC erpadmin.LeerUsuarioActual @USUARIO			
									
										UPDATE	AHPF_HN.ASHPF.FACTURA   
										SET 	ANULADA ='S',
										MULTIPLICADOR_EV = 0,
										USUARIO_ANULA =@USUARIO,
										FECHA_HORA_ANULA =GETDATE(),
										OBSERVACIONES = @OBSERVACIONES                    
										WHERE 	FACTURA =@FACTURA AND TIPO_DOCUMENTO ='F'

										UPDATE AHPF_HN.ASHPF.FACTURA_LINEA  
										SET ANULADA = 'S', 
										MULTIPLICADOR_EV = 0, UpdatedBy = @USUARIO  
										WHERE FACTURA =@FACTURA  AND TIPO_DOCUMENTO = 'F'

										/*-------------------------------------------------------------------------*/
															--- ANULAR O/D EN DOCUMENTOS CC ---
										-----------------------------------------------------------------------------

										SELECT @TIPO_FC =COUNT(*) FROM AHPF_HN.ASHPF.FACTURA_CANCELA WHERE FACTURA=@FACTURA AND TIPO='T'

										IF @TIPO_FC > 0
										BEGIN
											EXECUTE AHPF_HN.ASHPF.sP_DOCUMENTO_CC_REC_POS_ANUL @FACTURA,@USUARIO
										END 
			END

			/*-----------------------------------*/
			--- CAMBIAR ESTADO  DE FACTURA H1 --- 											
			---------------------------------------

			SET @Id_FC =(SELECT Id_FC FROM H1_AHPF_HN.dbo.FC WHERE UDF_Factura_E=@FACTURA)

			UPDATE H1_AHPF_HN.dbo.FC
			SET UDF_Anulada='S'
			WHERE Id_FC=@Id_FC

			UPDATE H1_AHPF_HN.dbo.FCDT
			SET UDF_Anulada='S'
			WHERE Id_FC=@Id_FC

			/*-----------------------------------------------------------------------------------------------*/
				--- CAMBIAR ESTADO PARA QUE PEDIDO OPTICA NO SEA VISIBLE EN LAS FACTURAS A PROCESAR ---
				--- PARA EFECTOS DE ANULACION CUANDO EL PEDIDO NO SE HA CANCELADO EN SU TOTALIDAD ---
			---------------------------------------------------------------------------------------------------

			DECLARE @Opt	AS INT

			SET @Opt = (SELECT ISNULL(UDF_Optica,0) FROM H1_AHPF_HN.dbo.FC WHERE Id_FC=@Id_FC)
										
			IF @Opt = 1
			BEGIN
				UPDATE H1_AHPF_HN.dbo.FC
					SET UDF_Adeudo=0.0, UDF_Pagada1=1
				WHERE Id_FC=@Id_FC 
			END	


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