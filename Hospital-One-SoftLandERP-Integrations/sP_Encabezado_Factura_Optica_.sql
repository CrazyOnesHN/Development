USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_Encabezado_Factura_Optica_]    Script Date: 11/9/2022 3:37:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [ASHPF].[sP_Encabezado_Factura_Optica_]
-- Add the parameters for the stored procedure here
	@PEDIDO				VARCHAR(20),
	@Serie					INT,
	@Id_FC					INT,	
	@Mensaje				INT OUTPUT

AS
BEGIN

	-------------------------------------
	-- VARIABLES ENCABEZADO DE FACTURA --
	-------------------------------------

		DECLARE	@TIPO_DOCUMENTO							VARCHAR(1)
		DECLARE	@FACTURA								VARCHAR(50)
		DECLARE	@AUDIT_TRANS_INV						INT
		DECLARE	@ESTA_DESPACHADO						VARCHAR(1)
		DECLARE	@EN_INVESTIGACION						VARCHAR(1)
		DECLARE	@TRANS_ADICIONALES						VARCHAR(1)
		DECLARE	@ESTADO_REMISION						VARCHAR(1)
		DECLARE	@ASIENTO_DOCUMENTO						VARCHAR(10)
		DECLARE	@DESCUENTO_VOLUMEN						DECIMAL(28,8)
		DECLARE	@MONEDA_FACTURA							VARCHAR(1)
		DECLARE	@FECHA_DESPACHO							DATETIME
		DECLARE	@CLASE_DOCUMENTO						VARCHAR(1)
		DECLARE	@FECHA_RECIBIDO							DATETIME
		DECLARE	@COMISION_COBRADOR						DECIMAL(28,8)
		DECLARE	@TOTAL_VOLUMEN							DECIMAL(28,8)
		DECLARE	@TOTAL_PESO								DECIMAL(28,8)
		DECLARE	@MONTO_COBRADO							DECIMAL(28,8)
		DECLARE	@TOTAL_IMPUESTO1						DECIMAL(28,8)
		DECLARE	@FECHA									DATETIME
		DECLARE	@FECHA_ENTREGA							DATETIME
		DECLARE	@TOTAL_IMPUESTO2						DECIMAL(28,8)
		DECLARE	@PORC_DESCUENTO2						DECIMAL(28,8)
		DECLARE	@MONTO_FLETE							DECIMAL(28,8)
		DECLARE	@MONTO_SEGURO							DECIMAL(28,8)
		DECLARE	@MONTO_DOCUMENTACIO						DECIMAL(28,8)
		DECLARE	@TIPO_DESCUENTO1						VARCHAR(1)
		DECLARE	@TIPO_DESCUENTO2						VARCHAR(1)
		DECLARE @MONTO_DESCUENTO1						DECIMAL(28,8)
		DECLARE @MONTO_DESCUENTO2						DECIMAL(28,8)
		DECLARE	@PORC_DESCUENTO1						DECIMAL(28,8)
		DECLARE	@TOTAL_FACTURA							DECIMAL(28,8)
		DECLARE	@FECHA_PEDIDO							DATETIME
		DECLARE	@FECHA_ORDEN							DATETIME
		DECLARE	@TOTAL_MERCADERIA						DECIMAL(28,8)
		DECLARE	@COMISION_VENDEDOR						DECIMAL(28,8)
		DECLARE	@FECHA_HORA								DATETIME
		DECLARE	@TOTAL_UNIDADES							DECIMAL(28,8)
		DECLARE	@NUMERO_PAGINAS							SMALLINT
		DECLARE	@TIPO_CAMBIO							DECIMAL(28,8)
		DECLARE @ANULADA								VARCHAR(1)
		DECLARE	@MODULO									VARCHAR(4)
		DECLARE	@CARGADO_CG								VARCHAR(1)
		DECLARE	@CARGADO_CXC							VARCHAR(1)
		DECLARE	@EMBARCAR_A								VARCHAR(80)
		DECLARE	@DIREC_EMBARQUE							VARCHAR(8)
		DECLARE	@MULTIPLICADOR_EV						SMALLINT
		DECLARE	@VERSION_NP								INT
		DECLARE	@MONEDA									VARCHAR(1)
		DECLARE	@NIVEL_PRECIO							VARCHAR(12)
		DECLARE	@COBRADA								VARCHAR(1)
		DECLARE	@RUTA									VARCHAR(4)
		DECLARE	@USUARIO								VARCHAR(25)
		DECLARE	@CONDICION_PAGO							VARCHAR(4)
		DECLARE	@ZONA									VARCHAR(4)
		DECLARE	@VENDEDOR								VARCHAR(4)
		DECLARE	@DOC_CREDITO_CXC						VARCHAR(50)
		DECLARE	@CLIENTE_DIRECCION						VARCHAR(20)
		DECLARE	@CLIENTE_CORPORAC						VARCHAR(20)
		DECLARE	@CLIENTE_ORIGEN							VARCHAR(20)
		DECLARE	@CLIENTE								VARCHAR(20)
		DECLARE	@PAIS									VARCHAR(4)
		DECLARE	@SUBTIPO_DOC_CXC						SMALLINT
		DECLARE	@TIPO_CREDITO_CXC						VARCHAR(3)
		DECLARE	@TIPO_DOC_CXC							VARCHAR(3)
		DECLARE	@FECHA_RIGE								DATETIME
		DECLARE	@USA_DESPACHOS							VARCHAR(1)
		DECLARE	@COBRADOR								VARCHAR(4)
		DECLARE	@DESCUENTO_CASCADA						VARCHAR(1)
		DECLARE	@NoteExistsFlag							TINYINT
		DECLARE	@RecordDate								DATETIME
		DECLARE	@RowPointer								UNIQUEIDENTIFIER
		DECLARE	@CreatedBy								VARCHAR(30)
		DECLARE	@UpdatedBy								VARCHAR(30)
		DECLARE	@CreateDate								DATETIME
		DECLARE	@NOMBRE_CLIENTE							VARCHAR(150)
		DECLARE	@REIMPRESO								INT
		DECLARE	@GENERA_DOC_FE							VARCHAR(1)
		DECLARE	@SerieFC								INT
		DECLARE @Id_UH									NVARCHAR(20)
		DECLARE @CONSECUTIVO							VARCHAR(10)
		DECLARE @FACTURA_ID								INT
		DECLARE @NUMERO_PAGO							INT

SET NOCOUNT ON;

BEGIN TRY
	BEGIN TRANSACTION

				SET @SerieFC		= (SELECT  Id_CONSECUTIVO		FROM AHPF_HN.ASHPF.CONSECUTIVO_FA  WITH(NOLOCK)  WHERE Id_CONSECUTIVO =@Serie)
				SET @CONSECUTIVO	= (SELECT  CODIGO_CONSECUTIVO	FROM AHPF_HN.ASHPF.CONSECUTIVO_FA  WITH(NOLOCK)  WHERE Id_CONSECUTIVO =@Serie)
				SET @Id_UH			= (SELECT Id_UH					FROM H1_AHPF_HN.dbo.FC  WITH(NOLOCK) WHERE Id_FC=@Id_FC)

							-------------------------------------------------------------------------------
							--- OBTENER MASCARA DE FACTURA Y ASIENTO ---
							------------------------------------------------------------------------------- 

							DECLARE @SerieA AS VARCHAR(50)
							DECLARE @SerieB AS VARCHAR(10)

								EXECUTE AHPF_HN.ASHPF.sP_GET_Journal_Number @SerieFC, @SerieOUT = @SerieA OUTPUT, @SerieFA = @SerieB OUTPUT

							SET @FACTURA				=(SELECT  @SerieA)
							SET @ASIENTO_DOCUMENTO		=(SELECT  @SerieB)

							---------------------------------------------------------------------------------------
									--- VALIDAR QUE NO EXISTE UN CARGO ---
							---------------------------------------------------------------------------------------

							DECLARE @CONTADOR_C INT
							SELECT @CONTADOR_C= COUNT(Id_FC) FROM H1_AHPF_HN.dbo.FCPG  WITH(NOLOCK) WHERE Id_FC=@Id_FC AND TipoPago='CC'

							IF ISNULL(@CONTADOR_C,0)=0
								UPDATE AHPF_HN.ASHPF.PEDIDO 
								SET 
								CONDICION_PAGO=0 WHERE PEDIDO=@PEDIDO
							
							----------------------------------------------------------
							---	ACTUALIZAR FECHA DE PEDIDO ---
							----------------------------------------------------------

							UPDATE  AHPF_HN.ASHPF.PEDIDO 
							SET 
								FECHA_PEDIDO=GETDATE(),
								FECHA_PROMETIDA=GETDATE(),
								FECHA_PROX_EMBARQU=GETDATE(),
								FECHA_ULT_EMBARQUE=GETDATE(),
								FECHA_ULT_CANCELAC=GETDATE(),
								FECHA_ORDEN=GETDATE(),
								FECHA_HORA=GETDATE(),
								RECORDDATE=GETDATE(),
								CREATEDATE=GETDATE(),
								FECHA_PROYECTADA=GETDATE() 
							WHERE PEDIDO=@PEDIDO

							UPDATE  AHPF_HN.ASHPF.PEDIDO_LINEA 
							SET 
								FECHA_ENTREGA=GETDATE(),
								FECHA_PROMETIDA=GETDATE(),
								RECORDDATE=GETDATE(),
								CREATEDATE=GETDATE() 
							WHERE PEDIDO=@PEDIDO

							------------------------------------------------------
							--- INICA EL PROCESO DE COSNTRUCCION DE ENCABEZADO ---
							------------------------------------------------------

										SELECT 
										@TIPO_DOCUMENTO = 'F',
										@ESTA_DESPACHADO='N',
										@EN_INVESTIGACION='N',
										@TRANS_ADICIONALES ='N',
										@ESTADO_REMISION ='N',
										@DESCUENTO_VOLUMEN =DESCUENTO_VOLUMEN,
										@MONEDA_FACTURA ='L',
										@FECHA_DESPACHO =GETDATE(),
										@CLASE_DOCUMENTO =TIPO_PEDIDO,
										@FECHA_RECIBIDO =GETDATE(),
										@PEDIDO =PEDIDO,
										@COMISION_COBRADOR =PORC_COMI_COBRADOR,
										@TOTAL_VOLUMEN =0.00000000,
										@TOTAL_PESO =0.00000000,
										@MONTO_COBRADO=0.00000000,
										@TOTAL_IMPUESTO1 =TOTAL_IMPUESTO1,
										@FECHA =FECHA_PEDIDO,
										@FECHA_ENTREGA =GETDATE(),
										@TOTAL_IMPUESTO2 =TOTAL_IMPUESTO2,
										@PORC_DESCUENTO2 = PORC_DESCUENTO2,
										@MONTO_FLETE =MONTO_FLETE,
										@MONTO_SEGURO = MONTO_SEGURO,
										@MONTO_DOCUMENTACIO = MONTO_DOCUMENTACIO,
										@TIPO_DESCUENTO1 =TIPO_DESCUENTO1,
										@TIPO_DESCUENTO2 =TIPO_DESCUENTO2,
										@MONTO_DESCUENTO1 =MONTO_DESCUENTO1,
										@MONTO_DESCUENTO2 =MONTO_DESCUENTO2,
										@PORC_DESCUENTO1 =PORC_DESCUENTO1,
										@TOTAL_FACTURA =TOTAL_A_FACTURAR,
										@FECHA_PEDIDO =FECHA_PEDIDO,
										@TOTAL_MERCADERIA =TOTAL_MERCADERIA,
										@COMISION_VENDEDOR = PORC_COMI_VENDEDOR,
										@FECHA_HORA =GETDATE(),
										@TOTAL_UNIDADES =TOTAL_UNIDADES,
										@NUMERO_PAGINAS=1,
										@TIPO_CAMBIO =([AHPF_HN].[ASHPF].[ObtenerTipoCambio] ('DLR',FECHA_PEDIDO))	,
										@ANULADA = ESTADO,
										@MODULO ='FA',
										@CARGADO_CG ='S',
										@CARGADO_CXC ='S',
										@EMBARCAR_A = EMBARCAR_A,
										@MULTIPLICADOR_EV =1,
										@VERSION_NP =VERSION_NP,
										@MONEDA = MONEDA,
										@NIVEL_PRECIO =NIVEL_PRECIO,
										@COBRADOR =COBRADOR,
										@RUTA =RUTA,
										@USUARIO =Usuario,
										@CONDICION_PAGO =CONDICION_PAGO,
										@ZONA =ZONA,
										@VENDEDOR =VENDEDOR,
										@CLIENTE_DIRECCION =CLIENTE_DIRECCION,
										@CLIENTE_CORPORAC =CLIENTE_CORPORAC,
										@CLIENTE_ORIGEN =CLIENTE_ORIGEN,
										@CLIENTE =CLIENTE,
										@PAIS =PAIS,
										@FECHA_RIGE =GETDATE(),
										@USA_DESPACHOS ='N',
										@COBRADA='S',
										@DESCUENTO_CASCADA ='N',
										@REIMPRESO=0,
										@GENERA_DOC_FE ='N',
										@SUBTIPO_DOC_CXC =0,
										@TIPO_DOC_CXC='FAC'
										FROM AHPF_HN.ASHPF.PEDIDO  WITH(NOLOCK)  WHERE PEDIDO=@PEDIDO


										--------------------------------------------------------------------------------------------
									--- INICIA PROCESO DE INSERCION DE ENCABEZADO EN ERP ---
										--------------------------------------------------------------------------------------------

										EXEC erpadmin.GrabarUsuarioActual @USUARIO
										EXEC erpadmin.LeerUsuarioActual @USUARIO

										INSERT INTO AHPF_HN.ASHPF.FACTURA
										(TIPO_DOCUMENTO,FACTURA,ESTA_DESPACHADO,EN_INVESTIGACION,TRANS_ADICIONALES,ESTADO_REMISION,ASIENTO_DOCUMENTO
										,DESCUENTO_VOLUMEN,MONEDA_FACTURA,FECHA_DESPACHO,CLASE_DOCUMENTO,FECHA_RECIBIDO,PEDIDO,COMISION_COBRADOR,TOTAL_VOLUMEN
										,TOTAL_PESO,MONTO_COBRADO,TOTAL_IMPUESTO1,FECHA,FECHA_ENTREGA,TOTAL_IMPUESTO2,PORC_DESCUENTO2,MONTO_FLETE
										,MONTO_SEGURO,MONTO_DOCUMENTACIO,TIPO_DESCUENTO1,TIPO_DESCUENTO2,MONTO_DESCUENTO1,MONTO_DESCUENTO2
										,PORC_DESCUENTO1,TOTAL_FACTURA,FECHA_PEDIDO,TOTAL_MERCADERIA,COMISION_VENDEDOR,FECHA_HORA,TOTAL_UNIDADES
										,NUMERO_PAGINAS,TIPO_CAMBIO,ANULADA,MODULO,CARGADO_CG,CARGADO_CXC,EMBARCAR_A,MULTIPLICADOR_EV,VERSION_NP
										,MONEDA,NIVEL_PRECIO,COBRADOR,RUTA,USUARIO,CONDICION_PAGO,ZONA,VENDEDOR,CLIENTE_DIRECCION,CLIENTE_CORPORAC
										,CLIENTE_ORIGEN,CLIENTE,PAIS,FECHA_RIGE,USA_DESPACHOS,COBRADA,DESCUENTO_CASCADA,REIMPRESO,GENERA_DOC_FE,SUBTIPO_DOC_CXC,TIPO_DOC_CXC)
										VALUES
										(@TIPO_DOCUMENTO,@FACTURA,@ESTA_DESPACHADO,@EN_INVESTIGACION,@TRANS_ADICIONALES,@ESTADO_REMISION,@ASIENTO_DOCUMENTO
										,@DESCUENTO_VOLUMEN,@MONEDA_FACTURA,@FECHA_DESPACHO,@CLASE_DOCUMENTO,@FECHA_RECIBIDO,@PEDIDO,@COMISION_COBRADOR,@TOTAL_VOLUMEN
										,@TOTAL_PESO,@MONTO_COBRADO,@TOTAL_IMPUESTO1,@FECHA,@FECHA_ENTREGA,@TOTAL_IMPUESTO2,@PORC_DESCUENTO2,@MONTO_FLETE
										,@MONTO_SEGURO,@MONTO_DOCUMENTACIO,@TIPO_DESCUENTO1,@TIPO_DESCUENTO2,@MONTO_DESCUENTO1,@MONTO_DESCUENTO2
										,@PORC_DESCUENTO1,@TOTAL_FACTURA,@FECHA_PEDIDO,@TOTAL_MERCADERIA,@COMISION_VENDEDOR,@FECHA_HORA,@TOTAL_UNIDADES
										,@NUMERO_PAGINAS,@TIPO_CAMBIO,@ANULADA,@MODULO,@CARGADO_CG,@CARGADO_CXC,@EMBARCAR_A,@MULTIPLICADOR_EV,@VERSION_NP
										,@MONEDA,@NIVEL_PRECIO,@COBRADOR,@RUTA,@USUARIO,@CONDICION_PAGO,@ZONA,@VENDEDOR,@CLIENTE_DIRECCION,@CLIENTE_CORPORAC
										,@CLIENTE_ORIGEN,@CLIENTE,@PAIS,@FECHA_RIGE,@USA_DESPACHOS,@COBRADA,@DESCUENTO_CASCADA,@REIMPRESO,@GENERA_DOC_FE,@SUBTIPO_DOC_CXC,@TIPO_DOC_CXC)




															---------------------------------------------------------------------------------------
																			--- INICIA PROCESO DE INSERCION DE LINEAS EN ERP ---
															---------------------------------------------------------------------------------------

															EXECUTE  AHPF_HN.ASHPF.sP_Detalle_Factura_Optica @PEDIDO,@FACTURA
															---------------------------------------------------------------------------------------
														
															---------------------------------------------------------------------------------------
																				--- REGISTRO TRANSACCION DE INVENTARIO ---
															---------------------------------------------------------------------------------------

															EXECUTE  AHPF_HN.ASHPF.sP_AUDIT_TRANS_INV_H1_FR @USUARIO, @FECHA, @FECHA, @CLIENTE, @Id_FC
															----------------------------------------------------------------------------------------


															----------------------------------------------------------------------------------------
																					--- OBTENER VARIABLES PARA PROCESOS ---
															----------------------------------------------------------------------------------------

															SET @AUDIT_TRANS_INV	=(SELECT MAX(AUDIT_TRANS_INV) FROM ASHPF.AUDIT_TRANS_INV)

															-----------------------------------------------------------------------------------------
																							--- ACTUALIZAR UDF ---
															-----------------------------------------------------------------------------------------

												
																UPDATE H1_AHPF_HN.dbo.FC 
																SET 
																	UDF_Factura_E=@FACTURA,
																	UDF_Asiento=@ASIENTO_DOCUMENTO,
																	UDF_Audit_Trans_Inv=@AUDIT_TRANS_INV
																WHERE UDF_Pedido=@PEDIDO

																UPDATE AHPF_HN.ASHPF.PEDIDO
																SET 
																	ESTADO='F'
																WHERE PEDIDO=@PEDIDO



															---------------------------------------------------------------------------------------
																	--- REGISTRO DE LAS FORMAS DE PAGO ---
															---------------------------------------------------------------------------------------
											
															EXECUTE AHPF_HN.ASHPF.sP_Factura_Cancela @Id_FC
															---------------------------------------------------------------------------------------
															---------------------------------------------------------------------------------------------------
																	--- REGISTRAR DEBITO EN CREDOMATIC O BANPAIS ---
															---------------------------------------------------------------------------------------------------
												

															DECLARE @CONT	AS INT
															
															SELECT @CONT= COUNT(Id_FC) 
															FROM H1_AHPF_HN.dbo.FCPG 
															WHERE Id_FC=@Id_FC AND TipoPago='T'

															IF @CONT > 0
															BEGIN
																EXECUTE AHPF_HN.ASHPF.sP_DOCUMENTO_CC_REC_POS @Id_FC
															END 
															

															---------------------------------------------------------------------------------------
																SELECT @NUMERO_PAGO= NUMERO_PAGO FROM AHPF_HN.ASHPF.Factura_Cancela WHERE FACTURA=@FACTURA
																UPDATE H1_AHPF_HN.dbo.FCPG 
																SET 
																	UDF_N_Pago=@NUMERO_PAGO 
																WHERE Id_FC=@Id_FC

															----------------------------------------------------------------------------------------
																				--- REGISTRO EN MAYOR ---
															----------------------------------------------------------------------------------------

																DECLARE	@return_value int,
																		@ASIENTO varchar(50),
																		@CLINICA varchar(20),
																		@R_EXITOSO char(1),
																		@ERROR nvarchar(max)

																SELECT	@ASIENTO	= @SerieB
																SELECT	@CLINICA		= @Id_UH

																EXEC	@return_value = [ASHPF].[sP_CARGA_CONTABLE_MAYOR_FACTURA_H1]
																		@FACTURA				= @SerieA,
																		@USUARIO				= @USUARIO,
																		@PAQUETE				= N'F1',
																		@TIPO_ASIENTO		= N'PING',
																		@ASIENTO = @ASIENTO OUTPUT,
																		@Id_UH					= @CLINICA,
																		@R_EXITOSO			= @R_EXITOSO OUTPUT,
																		@ERROR					= @ERROR OUTPUT

																SELECT	@ASIENTO as N'@ASIENTO',
																		@R_EXITOSO as N'@R_EXITOSO',
																		@ERROR as N'@ERROR'

																SELECT	'Return Value' = @return_value

															-----------------------------------------------------------------------------------------
																		--- GENERACION DE RECIBO ---
																					--- CREDITO CXC ---
															----------------------------------------------------------------------------------------

															DECLARE @NumeroRecibo	AS NVARCHAR(80)
															DECLARE @SerieTR				AS INT	
															SET @SerieTR  
															= (SELECT SerieTR FROM H1_AHPF_HN.dbo.UH WHERE Id_UH=@Id_UH)
															DECLARE @SerieAN				AS VARCHAR(50)
															DECLARE @SerieBN				AS VARCHAR(10)
															DECLARE @TPAGO				AS VARCHAR(50)
															EXECUTE AHPF_HN.ASHPF.sP_GET_SERIAL_CXC 189, @SerieOUT = @SerieAN OUTPUT, @SerieCC = @SerieBN OUTPUT 
															SELECT @NumeroRecibo=@SerieAN
															
															-----------------------------------------------------------------------------------------
															-----------------------------------------------------------------------------------------
																--- REGISTRO EN BALANCE DE COMPROBACION ---
															-----------------------------------------------------------------------------------------

																	--EXEC AHPF_HN.ASHPF.sP_INSERT_SALDO @ASIENTO
															----------------------------------------------------------------------------------------


																	--- ACTUALIZAR  APLICACION Y REFERENCIA DE TRANSACCION DE INVENTARIO ---
									
																UPDATE AHPF_HN.ASHPF.AUDIT_TRANS_INV 
																SET 
																	APLICACION = 'FAC#'+@FACTURA, 
																	REFERENCIA ='Cliente:' +@CLIENTE, 
																	ASIENTO=@ASIENTO_DOCUMENTO
																WHERE AUDIT_TRANS_INV=@AUDIT_TRANS_INV

																UPDATE AHPF_HN.ASHPF.FACTURA
																SET 
																	AUDIT_TRANS_INV=@AUDIT_TRANS_INV
																WHERE FACTURA=@FACTURA



																--------------------------------------------------------------------------
																		--- VALIDAR QUE LA TRANSACCION NO TIENE CARGOS A CXC  ---
																		--- APLICA PARA CONSUMIDOR FINAL Y COORPORACION ---
																--------------------------------------------------------------------------

																DECLARE	@C_CXC				INT

																SET  @C_CXC = (SELECT  [AHPF_HN].[ASHPF].[GET_VALIDARCXC] (@FACTURA))

																IF @C_CXC = 0
																BEGIN
																UPDATE AHPF_HN.ASHPF.FACTURA
																SET CARGADO_CXC='N'
																WHERE FACTURA=@FACTURA
																END
																
																-----------------------------------------------------------------------------
																		--- OBTENER NUMERO DE PAGO ---


																SELECT  @NUMERO_PAGO = NUMERO_PAGO 
																FROM AHPF_HN.ASHPF.FACTURA_CANCELA 
																WHERE FACTURA=@FACTURA

																UPDATE H1_AHPF_HN.dbo.FCPG 
																SET 
																UDF_N_Pago		=@NUMERO_PAGO 
																WHERE Id_FC	=@Id_FC


																--------------------------------------------------------------------------
																	--- VALIDAR QUE ESTA TRANSACCION PERTENECE A UNA COORPORACION ---
																				--- QUE SUS FORMAS DE PAGO AFECTAN CXC ---
																--------------------------------------------------------------------------
								
																DECLARE @CONTADOR INT
		
																SELECT @CONTADOR= COUNT(Id_FC) FROM H1_AHPF_HN.dbo.FCPG WHERE Id_FC=@Id_FC AND TipoPago='CC'

																IF @CONTADOR>0

																----------------------------------------------------------------------------
																--							--- AFECTAR CXC ---
																----------------------------------------------------------------------------

																EXECUTE AHPF_HN.ASHPF.sP_DOCUMENTO_CC_FA_H1 @FACTURA

																--------------------------------------------------------------------------
											


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
END CATCH;
	RETURN @Mensaje		
END
