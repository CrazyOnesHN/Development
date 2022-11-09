USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_ENCABEZADO_FACTURA_RAPIDA_]    Script Date: 11/9/2022 3:37:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [ASHPF].[sP_ENCABEZADO_FACTURA_RAPIDA_]
	-- Add the parameters for the stored procedure here
	@Id_FC					INT,
	@Serie					INT,
	@Mensaje				INT OUTPUT

	AS
BEGIN
	
	-------------------------------------
	-- VARIABLES ENCABEZADO DE FACTURA --
	-------------------------------------
	
						DECLARE	@TIPO_DOCUMENTO			VARCHAR(1)
						DECLARE	@FACTURA				VARCHAR(50)
						DECLARE	@AUDIT_TRANS_INV		INT
						DECLARE	@ESTA_DESPACHADO		VARCHAR(1)
						DECLARE	@EN_INVESTIGACION		VARCHAR(1)
						DECLARE	@TRANS_ADICIONALES		VARCHAR(1)
						DECLARE	@ESTADO_REMISION		VARCHAR(1)
						DECLARE	@ASIENTO_DOCUMENTO		VARCHAR(10)
						DECLARE	@DESCUENTO_VOLUMEN		DECIMAL(28,8)
						DECLARE	@MONEDA_FACTURA			VARCHAR(1)
						DECLARE	@FECHA_DESPACHO			DATETIME
						DECLARE	@CLASE_DOCUMENTO		VARCHAR(1)
						DECLARE	@FECHA_RECIBIDO			DATETIME
						DECLARE	@COMISION_COBRADOR		DECIMAL(28,8)
						DECLARE	@TOTAL_VOLUMEN			DECIMAL(28,8)
						DECLARE	@TOTAL_PESO				DECIMAL(28,8)
						DECLARE	@MONTO_COBRADO			DECIMAL(28,8)
						DECLARE	@TOTAL_IMPUESTO1		DECIMAL(28,8)
						DECLARE	@FECHA					DATETIME
						DECLARE	@FECHA_ENTREGA			DATETIME
						DECLARE	@TOTAL_IMPUESTO2		DECIMAL(28,8)
						DECLARE	@PORC_DESCUENTO2		DECIMAL(28,8)
						DECLARE	@MONTO_FLETE			DECIMAL(28,8)
						DECLARE	@MONTO_SEGURO			DECIMAL(28,8)
						DECLARE	@MONTO_DOCUMENTACIO		DECIMAL(28,8)
						DECLARE	@TIPO_DESCUENTO1		VARCHAR(1)
						DECLARE	@TIPO_DESCUENTO2		VARCHAR(1)
						DECLARE @MONTO_DESCUENTO1		DECIMAL(28,8)
						DECLARE @MONTO_DESCUENTO2		DECIMAL(28,8)
						DECLARE	@PORC_DESCUENTO1		DECIMAL(28,8)
						DECLARE	@TOTAL_FACTURA			DECIMAL(28,8)
						DECLARE	@FECHA_PEDIDO			DATETIME
						DECLARE	@FECHA_ORDEN			DATETIME
						DECLARE	@TOTAL_MERCADERIA		DECIMAL(28,8)
						DECLARE	@COMISION_VENDEDOR		DECIMAL(28,8)
						DECLARE	@FECHA_HORA				DATETIME
						DECLARE	@TOTAL_UNIDADES			DECIMAL(28,8)
						DECLARE	@NUMERO_PAGINAS			SMALLINT
						DECLARE	@TIPO_CAMBIO			DECIMAL(28,8)
						DECLARE @ANULADA				VARCHAR(1)
						DECLARE	@MODULO					VARCHAR(4)
						DECLARE	@CARGADO_CG				VARCHAR(1)
						DECLARE	@CARGADO_CXC			VARCHAR(1)
						DECLARE	@EMBARCAR_A				VARCHAR(80)
						DECLARE	@DIREC_EMBARQUE			VARCHAR(8)
						DECLARE	@MULTIPLICADOR_EV		SMALLINT
						DECLARE	@VERSION_NP				INT
						DECLARE	@MONEDA					VARCHAR(1)
						DECLARE	@NIVEL_PRECIO			VARCHAR(12)
						DECLARE	@COBRADA				VARCHAR(1)
						DECLARE	@RUTA					VARCHAR(4)
						DECLARE	@USUARIO				VARCHAR(25)
						DECLARE	@CONDICION_PAGO			VARCHAR(4)
						DECLARE	@ZONA					VARCHAR(4)
						DECLARE	@VENDEDOR				VARCHAR(4)
						DECLARE	@DOC_CREDITO_CXC		VARCHAR(50)
						DECLARE	@CLIENTE_DIRECCION		VARCHAR(20)
						DECLARE	@CLIENTE_CORPORAC		VARCHAR(20)
						DECLARE	@CLIENTE_ORIGEN			VARCHAR(20)
						DECLARE	@CLIENTE				VARCHAR(20)
						DECLARE	@PAIS					VARCHAR(4)
						DECLARE	@SUBTIPO_DOC_CXC		SMALLINT
						DECLARE	@TIPO_CREDITO_CXC		VARCHAR(3)
						DECLARE	@TIPO_DOC_CXC			VARCHAR(3)
						DECLARE	@FECHA_RIGE				DATETIME
						DECLARE	@USA_DESPACHOS			VARCHAR(1)
						DECLARE	@COBRADOR				VARCHAR(4)
						DECLARE	@DESCUENTO_CASCADA		VARCHAR(1)
						DECLARE	@NoteExistsFlag			TINYINT
						DECLARE	@RecordDate				DATETIME
						DECLARE	@RowPointer				UNIQUEIDENTIFIER
						DECLARE	@CreatedBy				VARCHAR(30)
						DECLARE	@UpdatedBy				VARCHAR(30)
						DECLARE	@CreateDate				DATETIME
						DECLARE	@NOMBRE_CLIENTE			VARCHAR(150)
						DECLARE	@REIMPRESO				INT
						DECLARE	@GENERA_DOC_FE			VARCHAR(1)
						DECLARE @NOMBREMAQUINA			VARCHAR(20)
						DECLARE @DIRECCION_FACTURA		VARCHAR(4000)
						DECLARE @CONSECUTIVO			VARCHAR(10)
						DECLARE @Id_UH					NVARCHAR(20)
						DECLARE	@SerieFC				INT 


	SET NOCOUNT ON;

    -- Insert statements for procedure here

	BEGIN TRY
		BEGIN TRANSACTION

							SET @SerieFC		= (SELECT  Id_CONSECUTIVO				FROM AHPF_HN.ASHPF.CONSECUTIVO_FA  WITH(NOLOCK) WHERE Id_CONSECUTIVO =@Serie)
							SET @CONSECUTIVO	= (SELECT  CODIGO_CONSECUTIVO	FROM AHPF_HN.ASHPF.CONSECUTIVO_FA  WITH(NOLOCK) WHERE Id_CONSECUTIVO =@Serie)
						
							--------------------------------------------
							--- OBTENER MASCARA DE FACTURA Y ASIENTO ---
							-------------------------------------------- 

							DECLARE @SerieA AS VARCHAR(50)
							DECLARE @SerieB AS VARCHAR(10)

								EXECUTE AHPF_HN.ASHPF.sP_GET_Journal_Number @SerieFC, @SerieOUT = @SerieA OUTPUT, @SerieFA = @SerieB OUTPUT

							SET @FACTURA				=(SELECT  @SerieA)
							SET @ASIENTO_DOCUMENTO		=(SELECT  @SerieB)

							----------------------------------------------
							----------------------------------------------

							------------------------------------------------------
							--- INICA EL PROCESO DE COSNTRUCCION DE ENCABEZADO ---
							------------------------------------------------------

									SELECT 
											@Id_UH=F0.Id_UH																				
											,@TIPO_DOCUMENTO='F'																								
											,@ESTA_DESPACHADO='N'																							
											,@EN_INVESTIGACION='N'																							
											,@TRANS_ADICIONALES='N'																							
											,@ESTADO_REMISION='N'																							
											,@DESCUENTO_VOLUMEN=0.00000000																						
											,@MONEDA_FACTURA='L'																						
											,@FECHA=F0.Fecha_Registro																			
											,@FECHA_ENTREGA=F0.Fecha_Registro																			
											,@FECHA_DESPACHO=F0.Fecha_Registro																					
											,@FECHA_RECIBIDO=F0.Fecha_Registro																					
											,@FECHA_PEDIDO=F0.Fecha_Registro																					
											,@FECHA_HORA=F0.Fecha_Registro																				
											,@FECHA_RIGE=F0.Fecha_Registro																					
											,@USUARIO=F0.Usuario_Registro																			
											,@CONDICION_PAGO=F0.MetodoPago																				
											,@CLASE_DOCUMENTO='N'																							
											,@COMISION_COBRADOR=0.00000000																						
											,@TOTAL_VOLUMEN=0.00000000																					
											,@TOTAL_PESO=0.00000000																					
											,@MONTO_COBRADO=0.00000000																					
											,@TOTAL_IMPUESTO1=0.00000000																					
											,@TOTAL_IMPUESTO2=0.00000000																						
											,@PORC_DESCUENTO1=0.00000000																						
											,@PORC_DESCUENTO2=0.00000000																						
											,@MONTO_FLETE=0.00000000																							
											,@MONTO_SEGURO=0.00000000																							
											,@MONTO_DOCUMENTACIO=0.00000000																						
											,@TIPO_DESCUENTO1='P'																							
											,@TIPO_DESCUENTO2='P'																							
											,@MONTO_DESCUENTO1=0.00000000																						
											,@MONTO_DESCUENTO2=0.00000000																						
											,@TOTAL_FACTURA=([H1_AHPF_HN].[dbo].[GETSUBTOTAL](F0.Id_FC))												
											,@TOTAL_MERCADERIA=([H1_AHPF_HN].[dbo].[GETSUBTOTAL](F0.Id_FC))												
											,@COMISION_VENDEDOR=0.00000000																						
											,@TOTAL_UNIDADES=([H1_AHPF_HN].[dbo].[GETTOTALUNIDADES](F0.Id_FC))												
											,@NUMERO_PAGINAS=1																							
											,@TIPO_CAMBIO=([AHPF_HN].[ASHPF].[ObtenerTipoCambio] ('DLR',F0.Fecha_Registro))							
											,@ANULADA='N'																									
											,@MODULO='FA'																							
											,@CARGADO_CG='S'																									
											,@CARGADO_CXC='N'																							
											,@EMBARCAR_A=([H1_AHPF_HN].[dbo].[GETEMBARCAR_A](F0.Id_PT))												 	
											,@DIRECCION_FACTURA=([H1_AHPF_HN].[dbo].[GETDIRECCION_FACTURA](F0.Id_PT))									
											,@MULTIPLICADOR_EV=1																							
											,@NIVEL_PRECIO=([H1_AHPF_HN].[dbo].[GETNIVELPRECIO](F0.Id_LP))											
											,@VERSION_NP=([H1_AHPF_HN].[dbo].[GETVERSION_NP]([H1_AHPF_HN].[dbo].[GETNIVELPRECIO](F0.Id_LP)))		
											,@MONEDA='L'																						
											,@COBRADOR=([H1_AHPF_HN].[dbo].[GETCOBRADOR](F0.Id_PR))												
											,@PAIS=([H1_AHPF_HN].[dbo].[GETPAIS](F0.Id_UH))													
											,@RUTA=([H1_AHPF_HN].[dbo].[GETRUTA](F0.Id_PT))												
											,@ZONA=([H1_AHPF_HN].[dbo].[GETZONA](F0.Id_PT))													
											,@VENDEDOR='ND'																						
											,@CLIENTE_DIRECCION=F0.Id_PT																					
											,@CLIENTE_CORPORAC=F0.Id_PT																						
											,@CLIENTE_ORIGEN=F0.Id_PT																							
											,@CLIENTE=F0.Id_PT																								
											,@USA_DESPACHOS='N'																					  		
											,@COBRADA='S'																									
											,@DESCUENTO_CASCADA='N'																							
											,@REIMPRESO=0																													
											,@GENERA_DOC_FE='N'																										
											,@SUBTIPO_DOC_CXC=0																								
											,@TIPO_DOC_CXC='FAC'																								 
											,@NoteExistsFlag=0																								
											,@RecordDate=F0.Fecha_Registro																			
											,@RowPointer=NEWID()																					
											,@CreatedBy=F0.Usuario_Registro																		
											,@UpdatedBy=F0.Usuario_Modificacion																	
											,@CreateDate=F0.Fecha																						
											,@NOMBREMAQUINA=HOST_NAME()																			

									FROM H1_AHPF_HN.dbo.FC AS F0   WITH(NOLOCK)
									INNER JOIN H1_AHPF_HN.dbo.FCDT AS F1
									ON F1.Id_FC = F0.Id_FC
									
									WHERE F0.Id_FC=@Id_FC 

									--------------------------------------------------------------------------------------------
													--- INICIA PROCESO DE INSERCION DE ENCABEZADO EN ERP ---
									--------------------------------------------------------------------------------------------

											EXEC erpadmin.GrabarUsuarioActual @USUARIO
											EXEC erpadmin.LeerUsuarioActual @USUARIO

											INSERT INTO AHPF_HN.ASHPF.FACTURA
												(TIPO_DOCUMENTO,FACTURA,ESTA_DESPACHADO,EN_INVESTIGACION,TRANS_ADICIONALES,ESTADO_REMISION,ASIENTO_DOCUMENTO
												,DESCUENTO_VOLUMEN,MONEDA_FACTURA,FECHA_DESPACHO,CLASE_DOCUMENTO,FECHA_RECIBIDO,COMISION_COBRADOR,TOTAL_VOLUMEN
												,TOTAL_PESO,MONTO_COBRADO,TOTAL_IMPUESTO1,FECHA,FECHA_ENTREGA,TOTAL_IMPUESTO2,PORC_DESCUENTO2,MONTO_FLETE
												,MONTO_SEGURO,MONTO_DOCUMENTACIO,TIPO_DESCUENTO1,TIPO_DESCUENTO2,MONTO_DESCUENTO1,MONTO_DESCUENTO2
												,PORC_DESCUENTO1,TOTAL_FACTURA,FECHA_PEDIDO,TOTAL_MERCADERIA,COMISION_VENDEDOR,FECHA_HORA,TOTAL_UNIDADES
												,NUMERO_PAGINAS,TIPO_CAMBIO,ANULADA,MODULO,CARGADO_CG,CARGADO_CXC,EMBARCAR_A,MULTIPLICADOR_EV,VERSION_NP
												,MONEDA,NIVEL_PRECIO,COBRADOR,RUTA,USUARIO,CONDICION_PAGO,ZONA,VENDEDOR,CLIENTE_DIRECCION,CLIENTE_CORPORAC
												,CLIENTE_ORIGEN,CLIENTE,PAIS,FECHA_RIGE,USA_DESPACHOS,COBRADA,DESCUENTO_CASCADA,NoteExistsFlag,RecordDate,RowPointer,
												CreatedBy,UpdatedBy,CreateDate,DIRECCION_FACTURA,CONSECUTIVO,REIMPRESO,GENERA_DOC_FE,SUBTIPO_DOC_CXC,TIPO_DOC_CXC,NOMBREMAQUINA)

											VALUES
												(@TIPO_DOCUMENTO,@FACTURA,@ESTA_DESPACHADO,@EN_INVESTIGACION,@TRANS_ADICIONALES,@ESTADO_REMISION,@ASIENTO_DOCUMENTO
												,@DESCUENTO_VOLUMEN,@MONEDA_FACTURA,@FECHA_DESPACHO,@CLASE_DOCUMENTO,@FECHA_RECIBIDO,@COMISION_COBRADOR,@TOTAL_VOLUMEN
												,@TOTAL_PESO,@MONTO_COBRADO,@TOTAL_IMPUESTO1,@FECHA,@FECHA_ENTREGA,@TOTAL_IMPUESTO2,@PORC_DESCUENTO2,@MONTO_FLETE
												,@MONTO_SEGURO,@MONTO_DOCUMENTACIO,@TIPO_DESCUENTO1,@TIPO_DESCUENTO2,@MONTO_DESCUENTO1,@MONTO_DESCUENTO2
												,@PORC_DESCUENTO1,@TOTAL_FACTURA,@FECHA_PEDIDO,@TOTAL_MERCADERIA,@COMISION_VENDEDOR,@FECHA_HORA,@TOTAL_UNIDADES
												,@NUMERO_PAGINAS,@TIPO_CAMBIO,@ANULADA,@MODULO,@CARGADO_CG,@CARGADO_CXC,@EMBARCAR_A,@MULTIPLICADOR_EV,@VERSION_NP
												,@MONEDA,@NIVEL_PRECIO,@COBRADOR,@RUTA,@USUARIO,@CONDICION_PAGO,@ZONA,@VENDEDOR,@CLIENTE_DIRECCION,@CLIENTE_CORPORAC
												,@CLIENTE_ORIGEN,@CLIENTE,@PAIS,@FECHA_RIGE,@USA_DESPACHOS,@COBRADA,@DESCUENTO_CASCADA,@NoteExistsFlag,@RecordDate,@RowPointer,
												@CreatedBy,@UpdatedBy,@CreateDate,@DIRECCION_FACTURA,@CONSECUTIVO,@REIMPRESO,@GENERA_DOC_FE,@SUBTIPO_DOC_CXC,@TIPO_DOC_CXC,@NOMBREMAQUINA)


								

															---------------------------------------------------------------------------------------
																			--- INICIA PROCESO DE INSERCION DE LINEAS EN ERP ---
															---------------------------------------------------------------------------------------

															EXECUTE  AHPF_HN.ASHPF.sP_DETALLE_FACTURA_RAPIDA @Id_FC, @FACTURA
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
																WHERE Id_FC=@Id_FC

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

															------------------------------------------------------------------------------------------------------

															----------------------------------------------------------------------------------------
																							--- REGISTRO EN MAYOR ---
															----------------------------------------------------------------------------------------

																DECLARE	@return_value int,
																		@ASIENTO varchar(50),
																		@CLINICA varchar(20),
																		@R_EXITOSO char(1),
																		@ERROR nvarchar(max)

																SELECT	@ASIENTO = @SerieB
																SELECT  @CLINICA = @Id_UH

																EXEC	@return_value = [ASHPF].[sP_CARGA_CONTABLE_MAYOR_FACTURA_H1]
																		@FACTURA = @SerieA,
																		@USUARIO = @USUARIO,
																		@PAQUETE = N'F1',
																		@TIPO_ASIENTO = N'PING',
																		@ASIENTO = @ASIENTO OUTPUT,
																		@Id_UH = @CLINICA,
																		@R_EXITOSO = @R_EXITOSO OUTPUT,
																		@ERROR = @ERROR OUTPUT

																SELECT	@ASIENTO as N'@ASIENTO',
																		@R_EXITOSO as N'@R_EXITOSO',
																		@ERROR as N'@ERROR'

																SELECT	'Return Value' = @return_value

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
