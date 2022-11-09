USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_DOCUMENTO_CC_REC_FA_H1_APLICACION_OPT]    Script Date: 11/9/2022 3:35:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [ASHPF].[sP_DOCUMENTO_CC_REC_FA_H1_APLICACION_OPT]
	-- Add the parameters for the stored procedure here
	@FACTURA			AS NVARCHAR(50),
	@Usuario			AS VARCHAR(30)	
AS
BEGIN

	SET NOCOUNT ON;

		DECLARE @MENSAJE				AS NVARCHAR(500)

		/*VARIABLES PARA DOCUEMENTO REC SEGUNDO ABONO OPTICA*/

		DECLARE @DOCUMENTO								AS NVARCHAR(50)
		DECLARE @TIPO_C									AS VARCHAR(3)
		DECLARE @APLICACION								AS VARCHAR(249)
		DECLARE @FECHA_DOCUMENTO						AS DATETIME
		DECLARE @FECHA									AS DATETIME
		DECLARE @MONTO_C								AS DECIMAL(28,8)
		DECLARE @SALDO									AS DECIMAL(28,8)
		DECLARE @MONTO_LOCAL							AS DECIMAL(28,8)
		DECLARE @SALDO_LOCAL							AS DECIMAL(28,8)
		DECLARE @MONTO_DOLAR							AS DECIMAL(28,8)
		DECLARE @SALDO_DOLAR							AS DECIMAL(28,8)
		DECLARE @MONTO_CLIENTE							AS DECIMAL(28,8)
		DECLARE @SALDO_CLIENTE							AS DECIMAL(28,8)
		DECLARE @TIPO_CAMBIO_MONEDA						AS DECIMAL(28,8)
		DECLARE @TIPO_CAMBIO_DOLAR						AS DECIMAL(28,8)
		DECLARE @TIPO_CAMBIO_CLIENT						AS DECIMAL(28,8)
		DECLARE @TIPO_CAMB_ACT_LOC						AS DECIMAL(28,8)
		DECLARE @TIPO_CAMB_ACT_DOL						AS DECIMAL(28,8)
		DECLARE @TIPO_CAMB_ACT_CLI						AS DECIMAL(28,8)
		DECLARE @SUBTOTAL								AS DECIMAL(28,8)
		DECLARE @DESCUENTO								AS DECIMAL(28,8)
		DECLARE @IMPUESTO1								AS DECIMAL(28,8)
		DECLARE @IMPUESTO2								AS DECIMAL(28,8)
		DECLARE @RUBRO1									AS DECIMAL(28,8)
		DECLARE @RUBRO2									AS DECIMAL(28,8)
		DECLARE @MONTO_RETENCION						AS DECIMAL(28,8)
		DECLARE @SALDO_RETENCION						AS DECIMAL(28,8)
		DECLARE @DEPENDIENTE							AS VARCHAR(1)
		DECLARE @FECHA_ULT_CREDITO						AS DATETIME
		DECLARE @CARGADO_DE_FACT						AS VARCHAR(1)
		DECLARE @APROBADO								AS VARCHAR(1)
		DECLARE @ASIENTO								AS VARCHAR(10)
		DECLARE @ASIENTO_PENDIENTE						AS VARCHAR(1)
		DECLARE @FECHA_ULT_MOD							AS DATETIME
		DECLARE @CLASE_DOCUMENTO						AS VARCHAR(1)
		DECLARE @FECHA_VENCE							AS DATETIME
		DECLARE @NUM_PARCIALIDADES						AS SMALLINT
		DECLARE @USUARIO_ULT_MOD						AS VARCHAR(25)
		DECLARE @CONDICION_PAGO							AS VARCHAR(4)
		DECLARE @MONEDA_C								AS VARCHAR(4)
		DECLARE @CLIENTE_REPORTE						AS VARCHAR(20)
		DECLARE @CLIENTE_ORIGEN							AS VARCHAR(20)
		DECLARE @CLIENTE								AS VARCHAR(20)
		DECLARE @PORC_INTCTE							AS DECIMAL(28,8)
		DECLARE @DEPENDIENTE_GP							AS VARCHAR(1)
		DECLARE @SALDO_TRANS							AS DECIMAL(28,8)
		DECLARE @SALDO_TRANS_LOCAL						AS DECIMAL(28,8)
		DECLARE @SALDO_TRANS_DOLAR						AS DECIMAL(28,8)
		DECLARE @SALDO_TRANS_CLI						AS DECIMAL(28,8)
		DECLARE @TIPO_CAMBIO_FAC						AS DECIMAL(28,8)
		DECLARE @NoteExistsFlag							AS TINYINT
		DECLARE @RecordDate								AS DATETIME
		DECLARE @RowPointer								AS UNIQUEIDENTIFIER
		DECLARE @CreatedBy								AS VARCHAR(30)
		DECLARE @UpdatedBy								AS VARCHAR(30)
		DECLARE @CreateDate								AS DATETIME
		DECLARE @ANULADO								AS VARCHAR(1) 		
		DECLARE @COBRADOR								AS VARCHAR(4)	
		DECLARE @VENDEDOR								AS VARCHAR(4)
		DECLARE @SUBTIPO								AS SMALLINT
		DECLARE @FACTURADO								AS VARCHAR(1)
		DECLARE @GENERA_DOC_FE							AS VARCHAR(1)
		DECLARE @MONTO_E								AS DECIMAL(28,8)
		DECLARE @MONTO_T								AS DECIMAL(28,8)
		DECLARE @UDF_Nombre_Paciente					AS NVARCHAR(500)	
		DECLARE @DIAS_NETO								AS INT
		DECLARE @FECHA_VENCE_T							AS DATETIME

		/*VARIABLES TEMPORALES PARA OBTENER EL ULTIMO ABONO DE FCPG*/

		DECLARE	@TIPO_DOCUMENTO_FC							VARCHAR(1)
		DECLARE @FACTURA_FC									VARCHAR(50)
		DECLARE	@NUMERO_PAGO_FC								INT
		DECLARE	@TIPO_FC									VARCHAR(1)
		DECLARE	@MONTO_FC									DECIMAL(28,8)
		DECLARE @MONEDA_FC									VARCHAR(1)
		DECLARE @NUM_DOCUMENTO_FC							VARCHAR(20)
		DECLARE @ENTIDAD_FINANCIERA_FC						VARCHAR(8)
		DECLARE @TIPO_TARJETA_FC							VARCHAR(12)
		DECLARE @NUM_AUTORIZA_FC							VARCHAR(20)
		DECLARE @USUARIO_FC									VARCHAR(25)
		DECLARE @CAJA_FC									VARCHAR(10)
		DECLARE @FECHA_HORA_FC								DATETIME
		DECLARE @DEVOLUCION_FC								VARCHAR(50)
		DECLARE @NoteExistsFlag_FC							TINYINT
		DECLARE @RecordDate_FC								DATETIME
		DECLARE @RowPointer_FC								UNIQUEIDENTIFIER
		DECLARE @CreatedBy_FC								VARCHAR(30)
		DECLARE @UpdatedBy_FC								VARCHAR(30)
		DECLARE @NUM_APERTURA_FC							INT
		DECLARE @COUNT_LINEA_FC								INT
		DECLARE @Id_FC_FC									INT
		DECLARE @Id_FCPG_FC									INT
		DECLARE @RowPointer_FCPG							UNIQUEIDENTIFIER

		/* TRANSACCION DE SEGUNDO ABONO, OBTENER CAJA Y APERTURA CAJA TRANSACCION*/

		DECLARE	@MONTO_TEMP_									DECIMAL(28,8)
		DECLARE @NUM_APERTURA_TEMP_								INT
		DECLARE @CAJA_TEMP_										VARCHAR(10)
		DECLARE	@TIPO_TEMP_										VARCHAR(1)
		DECLARE @FECHA_HORA_TEMP_								DATETIME
		DECLARE @FECHA_TEMP_									DATETIME
		DECLARE @CreatedBy_TEMP_								VARCHAR(30)


		/*VARIABLES TEMPORALES*/

		DECLARE @Id_UH										AS VARCHAR(20)
		DECLARE @SerieCC									AS NVARCHAR(10) 
		DECLARE @SerieTR									AS INT
		DECLARE @UDF_Cliente								AS NVARCHAR(200)
		DECLARE @ASIENTO_AM_TEMP							AS VARCHAR(10)
		DECLARE	@NUMERO_PAGO_FC_							AS INT
		DECLARE @Id_FC										AS INT
		DECLARE @Id_FCPG									AS INT


		--- VARIABLES PARA ITERACION DE LINEAS FCDT 

		DECLARE @E					AS	INT
		SET @E = 1
		DECLARE	@Id_FCPG_			AS	INT


	BEGIN TRY
		BEGIN TRANSACTION
				
				/*TABLA  TEMPORAL PARA EXTRAER PAGOS FCPG*/

						DECLARE @FACTURA_CANCELA	AS TABLE(
						ID INT IDENTITY(1,1) PRIMARY KEY,
						TIPO_DOCUMENTO						VARCHAR(1),
						FACTURA								VARCHAR(50),
						NUMERO_PAGO							INT,
						TIPO								VARCHAR(1),
						MONTO								DECIMAL(28,8),
						MONEDA								VARCHAR(1),
						NUM_DOCUMENTO						VARCHAR(20),
						ENTIDAD_FINANCIERA					VARCHAR(8),
						TIPO_TARJETA						VARCHAR(12),
						NUM_AUTORIZA						VARCHAR(20),
						USUARIO								VARCHAR(25),
						CAJA								VARCHAR(10),
						FECHA_HORA							DATETIME,
						DEVOLUCION							VARCHAR(50),
						NoteExistsFlag						TINYINT,
						RecordDate							DATETIME,
						RowPointer							UNIQUEIDENTIFIER,
						CreatedBy							VARCHAR(30),
						UpdatedBy							VARCHAR(30),
						NUM_APERTURA						INT,
						Id_FC								INT,
						Id_FCPG								INT,		
										--- CXC ---
						DOCUMENTO							NVARCHAR(50),
						TIPO_C								VARCHAR(3),
						APLICACION							VARCHAR(249),
						FECHA_DOCUMENTO						DATETIME,
						FECHA								DATETIME,
						MONTO_C								DECIMAL(28,8),
						SALDO								DECIMAL(28,8),
						MONTO_LOCAL							DECIMAL(28,8),
						SALDO_LOCAL							DECIMAL(28,8),
						MONTO_DOLAR							DECIMAL(28,8),
						SALDO_DOLAR							DECIMAL(28,8),
						MONTO_CLIENTE						DECIMAL(28,8),
						SALDO_CLIENTE						DECIMAL(28,8),
						TIPO_CAMBIO_MONEDA					DECIMAL(28,8),
						TIPO_CAMBIO_DOLAR					DECIMAL(28,8),
						TIPO_CAMBIO_CLIENT					DECIMAL(28,8),
						TIPO_CAMB_ACT_LOC					DECIMAL(28,8),
						TIPO_CAMB_ACT_DOL					DECIMAL(28,8),
						TIPO_CAMB_ACT_CLI					DECIMAL(28,8),
						SUBTOTAL							DECIMAL(28,8),
						DESCUENTO							DECIMAL(28,8),
						IMPUESTO1							DECIMAL(28,8),
						IMPUESTO2							DECIMAL(28,8),
						RUBRO1								DECIMAL(28,8),
						RUBRO2								DECIMAL(28,8),
						MONTO_RETENCION						DECIMAL(28,8),
						SALDO_RETENCION						DECIMAL(28,8),
						DEPENDIENTE							VARCHAR(1),
						FECHA_ULT_CREDITO					DATETIME,
						CARGADO_DE_FACT						VARCHAR(1),
						APROBADO							VARCHAR(1),
						ASIENTO								VARCHAR(10),
						ASIENTO_PENDIENTE					VARCHAR(1),
						FECHA_ULT_MOD						DATETIME,
						CLASE_DOCUMENTO						VARCHAR(1),
						FECHA_VENCE							DATETIME,
						NUM_PARCIALIDADES					SMALLINT,
						USUARIO_ULT_MOD						VARCHAR(25),
						CONDICION_PAGO						VARCHAR(4),
						MONEDA_C							VARCHAR(4),
						CLIENTE_REPORTE						VARCHAR(20),
						CLIENTE_ORIGEN						VARCHAR(20),
						CLIENTE								VARCHAR(20),
						PORC_INTCTE							DECIMAL(28,8),
						DEPENDIENTE_GP						VARCHAR(1),
						SALDO_TRANS							DECIMAL(28,8),
						SALDO_TRANS_LOCAL					DECIMAL(28,8),
						SALDO_TRANS_DOLAR					DECIMAL(28,8),
						SALDO_TRANS_CLI						DECIMAL(28,8),
						TIPO_CAMBIO_FAC						DECIMAL(28,8),
						ANULADO								VARCHAR(1), 		
						COBRADOR							VARCHAR(4),	
						VENDEDOR							VARCHAR(4),
						SUBTIPO								SMALLINT,
						FACTURADO							VARCHAR(1),
						GENERA_DOC_FE						VARCHAR(1))


						/*----------------------------------------------------------*/			
							--- TABLA TEMPORAL CON LAS FORMAS DE PAGO ---

						DECLARE @FORMA_FCPG AS TABLE(
						ID INT IDENTITY(1,1) PRIMARY KEY,
						Id_FC					INT,
						Id_FCPG					INT,
						Pago					DECIMAL(28,8),
						CajaDescripcion			NVARCHAR(120),
						Caja					NVARCHAR(50),
						Recibo					NVARCHAR(50),
						Factura					NVARCHAR(50),
						Id_POS					NVARCHAR(50),
						Usuario_Registro		NVARCHAR(256),
						Id_PT					NVARCHAR(15),
						TipoPago 				NVARCHAR(20),
						Paciente				NVARCHAR(250))


					/*OBTERNER NUMERO DE ASIENTO CXC*/

						DECLARE @SerieB AS VARCHAR(10)

							EXECUTE AHPF_HN.ASHPF.GET_CXC 'CXC', @SerieB OUTPUT

						SET @ASIENTO_AM_TEMP	= @SerieB

					/*CONTRUCCION DE DATOS PARA  CAMPO APLICACION*/

						SET @Id_UH	= (
							SELECT Id_UH 
							FROM H1_AHPF_HN.dbo.FC 
							WHERE UDF_Factura_E=@FACTURA)

						SET @SerieTR  = (
							SELECT SerieTR 
							FROM H1_AHPF_HN.dbo.UH 
							WHERE Id_UH=@Id_UH)
	

						SET @UDF_Nombre_Paciente = (
							SELECT UDF_Nombre_Paciente 
							FROM H1_AHPF_HN.dbo.FC 
							WHERE UDF_Factura_E=@FACTURA)

						SET @APLICACION = ('Abono cancelacion de factura: ' + @FACTURA + ' - Cliente: ' + UPPER(@UDF_Nombre_Paciente))

					/*OBTENER NUMERO DE RECIBO CAJA*/

					DECLARE @GetSerieRC		AS NVARCHAR(50)
					DECLARE @StringLeft		AS NVARCHAR(50)
					DECLARE @ConvertSerieRC	AS NVARCHAR(50)
					DECLARE @NewSerieRC		AS NVARCHAR(50)

							SELECT @GetSerieRC = 
							C.ULTIMO_VALOR 
							FROM AHPF_HN.ASHPF.CONSECUTIVO C 
							WHERE C.Id_CONSECUTIVO = @SerieTR

							SET @StringLeft		=  LEFT(@GetSerieRC,7) 
							SET @ConvertSerieRC	=  RIGHT(@GetSerieRC,6) + 1
							SET @NewSerieRC		= REPLICATE('0',7-LEN(@ConvertSerieRC))+RTRIM(CONVERT(char(9),@ConvertSerieRC))

							UPDATE  AHPF_HN.ASHPF.CONSECUTIVO 
							SET 
							ULTIMO_VALOR					=LEFT(@StringLeft,7) + @NewSerieRC 
							WHERE Id_CONSECUTIVO			= @SerieTR

							SET @DOCUMENTO					= LEFT(@StringLeft,7) + @NewSerieRC

					/*OBTENER ULTIMO  PAGO OPTICA*/

							SET @Id_FC = (
							SELECT Id_FC FROM H1_AHPF_HN.dbo.FC WHERE UDF_Factura_E=@FACTURA)

							SET @Id_FCPG = 
							(SELECT MAX(Id_FCPG) FROM H1_AHPF_HN.dbo.FCPG WHERE Id_FC=@Id_FC)

							SET @CreatedBy_TEMP_= (
							SELECT Usuario_Registro 
							FROM H1_AHPF_HN.dbo.FCPG 
							WHERE Id_FC=@Id_FC AND Id_FCPG=@Id_FCPG)
							

					/*OBTENER PAGO*/

						INSERT INTO @FACTURA_CANCELA
						(TIPO_DOCUMENTO,FACTURA,NUMERO_PAGO,TIPO,MONTO,MONEDA,NUM_DOCUMENTO,ENTIDAD_FINANCIERA,
						TIPO_TARJETA,NUM_AUTORIZA,USUARIO,CAJA,FECHA_HORA,DEVOLUCION,NoteExistsFlag,RecordDate,
						RowPointer,CreatedBy,UpdatedBy,NUM_APERTURA,Id_FC,Id_FCPG,
						
						DOCUMENTO,TIPO_C,APLICACION,FECHA_DOCUMENTO,
						FECHA,MONTO_C,SALDO,MONTO_LOCAL,SALDO_LOCAL,MONTO_DOLAR,SALDO_DOLAR,MONTO_CLIENTE,SALDO_CLIENTE,
						TIPO_CAMBIO_MONEDA,TIPO_CAMBIO_DOLAR,TIPO_CAMBIO_CLIENT,TIPO_CAMB_ACT_LOC,TIPO_CAMB_ACT_DOL,TIPO_CAMB_ACT_CLI,
						SUBTOTAL,DESCUENTO,IMPUESTO1,IMPUESTO2,RUBRO1,	RUBRO2,MONTO_RETENCION,SALDO_RETENCION,	DEPENDIENTE,FECHA_ULT_CREDITO,
						CARGADO_DE_FACT,APROBADO,ASIENTO,ASIENTO_PENDIENTE,FECHA_ULT_MOD,CLASE_DOCUMENTO,FECHA_VENCE,NUM_PARCIALIDADES,
						USUARIO_ULT_MOD,CONDICION_PAGO,MONEDA_C,CLIENTE_REPORTE,CLIENTE_ORIGEN,CLIENTE,PORC_INTCTE,DEPENDIENTE_GP,
						SALDO_TRANS,SALDO_TRANS_LOCAL,SALDO_TRANS_DOLAR,SALDO_TRANS_CLI,TIPO_CAMBIO_FAC,ANULADO,COBRADOR,VENDEDOR,
						SUBTIPO,FACTURADO,GENERA_DOC_FE)

								SELECT 
								'F' AS TIPO_DOCUMENTO,
								F.UDF_Factura_E AS FACTURA,
								0 AS NUMERO_PAGO,
								(CASE WHEN FP.TipoPago='CC' THEN 'X' ELSE FP.TipoPago END) AS TIPO,
								FP.Pago AS MONTO,
								FP.UDF_MONEDA AS MONEDA,
								(CASE WHEN FP.TipoPago='T' THEN UDF_NUM_DOCUMENTO END) AS NUM_DOCUMENTO,
								FP.EntidadFinanciera AS ENTIDAD_FINANCIERA,
								FP.TC AS TIPO_TARJETA,
								(CASE WHEN FP.TipoPago='T' THEN UDF_Id_POS END) NUM_AUTORIZA,
								FP.Usuario_Registro AS USUARIO,
								[H1_AHPF_HN].[dbo].[Get_Caja](@Usuario) AS CAJA,
								GETDATE() AS FECHA_HORA,
								'0' AS DEVOLUCION,
								0 AS NoteExistsFlag,
								FP.Fecha_Registro AS RecordDate,
								NEWID() AS RowPointer,
								FP.Usuario_Registro AS CreatedBy,
								FP.Usuario_Modificacion AS UpdatedBy,								
								FP.UDF_NUM_APERTURA,
								FP.Id_FC,
								FP.Id_FCPG,

								---- DOCUMENTO CXC REC ----
								@DOCUMENTO,
								'REC' AS TIPO,
								@APLICACION,
								(SELECT DATEADD(dd, DATEDIFF(dd, 0, CURRENT_TIMESTAMP), 0)) AS FECHA_DOCUMENTO, 
								(SELECT DATEADD(dd, DATEDIFF(dd, 0, CURRENT_TIMESTAMP), 0)) AS FECHA,
								FP.Pago AS MONTO_C,
								0.00000000 AS SALDO,
								FP.Pago AS MONTO_LOCAL,
								0.00000000 AS SALDO_LOCAL,
								0.00000000	AS MONTO_DOLAR,
								0.00000000 AS SALDO_DOLAR,	
								FP.Pago AS MONTO_CLIENTE,
								0.00000000 AS SALDO_CLIENTE,
								0.00000000 AS TIPO_CAMBIO_MONEDA,
								0.00000000 AS TIPO_CAMBIO_DOLAR,
								0.00000000 AS TIPO_CAMBIO_CLIENT,
								0.00000000 AS TIPO_CAMB_ACT_LOC,
								0.00000000 AS TIPO_CAMB_ACT_DOL,
								0.00000000 AS TIPO_CAMB_ACT_CLI,
								FP.Pago	 AS SUBTOTAL,
								0.00000000 AS DESCUENTO,
								0.00000000 AS IMPUESTO1,
								0.00000000 AS IMPUESTO2,
								0.00000000 AS RUBRO1 ,
								0.00000000 AS RUBRO2,
								0.00000000 AS MONTO_RETENCION,
								0.00000000 AS SALDO_RETENCION,
								'N' AS DEPENDIENTE,
								FP.Fecha_Registro AS FECHA_ULT_CREDITO,
								'N' AS CARGADO_DE_FACT,
								'S' AS APROBADO,
								@ASIENTO_AM_TEMP AS ASIENTO,
								'N' AS ASIENTO_PENDIENTE,
								FP.Fecha_Registro AS FECHA_ULT_MOD,
								'N' AS CLASE_DOCUMENTO,
								FP.Fecha_Registro AS FECHA_VENCE,
								0 AS NUM_PARCIALIDADES,
								FP.Usuario_Registro USUARIO_ULT_MOD,
								'002' AS CONDICION_PAGO,							
								'LPS',
								F.Id_PT AS CLIENTE_REPORTE,
								F.Id_PT AS CLIENTE_ORIGEN,
								F.Id_PT AS CLIENTE,
								0.00000000 AS PORC_INTCTE,
								'N' AS DEPENDIENTE_GP,															
								0.00000000 AS SALDO_TRANS,
								0.00000000 AS SALDO_TRANS_LOCAL,
								0.00000000 AS SALDO_TRANS_DOLAR,
								0.00000000 AS SALDO_TRANS_CLI,
								0.00000000 AS TIPO_CAMBIO_FAC,
								'N'	 AS ANULADA,
								'ND' AS COBRADOR,
								'ND' AS VENDEDOR,
								0	 AS SUBTIPO,
								'N'  AS FACTURADO,
								'N'	 AS GENERA_DOC_FE 

								FROM H1_AHPF_HN.dbo.FCPG AS FP
								LEFT JOIN H1_AHPF_HN.dbo.FC	AS F
								ON F.Id_FC = FP.Id_FC

								WHERE FP.Id_FC=@Id_FC AND FP.UDF_RowPointer IS NULL AND FP.Usuario_Registro=@CreatedBy_TEMP_
								
								/*---------------------------------------------------------------------------------------------------*/
								--- OBTENER REGISTRO DE LA FORMA DE PAGO EN TARJETA PARA REALIZAR EL DEBITO A CREDOMATIC O BANPAIS ---

									INSERT INTO @FORMA_FCPG
									(Id_FC,Id_FCPG,Pago,CajaDescripcion,Caja,Recibo,Factura,Id_POS,Usuario_Registro,Id_PT,TipoPago,Paciente)

									SELECT 
			 
									F0.Id_FC,
									F0.Id_FCPG,
									F0.Pago, 
									UPPER(F1.Descripcion) AS Caja,     
									F0.UDF_Caja,
									ISNULL(F0.UDF_Num_Recibo,'ND') AS Recibo,
									F3.UDF_Factura_E AS Factura,      
									F0.UDF_Id_POS,
									UPPER(F0.Usuario_Registro),
									F2.Id_PT,
									F0.TipoPago,
									F3.UDF_Nombre_Paciente


									FROM H1_AHPF_HN.dbo.FCPG AS F0  WITH(NOLOCK)
									LEFT JOIN H1_AHPF_HN.dbo.CJ AS F1 ON F1.Caja = F0.UDF_Caja
									LEFT JOIN H1_AHPF_HN.dbo.UT_POS AS F2 ON F2.Id_POS = F0.UDF_Id_POS
									LEFT JOIN H1_AHPF_HN.dbo.FC AS F3 ON F3.Id_FC = F0.Id_FC
									WHERE F0.Id_FC = @Id_FC AND F0.TipoPago='T' AND F0.UDF_RowPointer IS NULL

								/*INICIA EL PROCESO, SE OBTIENEN LOS DATOS REQUERIDOS PARA CONSTRUIR EL REC Y REGISTRAR LA TRANSACCION*/

								DECLARE @MONTO_TEMP_T AS DECIMAL(28,8)

								SET @MONTO_TEMP_T = (SELECT ISNULL(SUM(Pago),0) FROM  H1_AHPF_HN.dbo.FCPG  WHERE Id_FC=@Id_FC AND UDF_RowPointer IS NULL AND TipoPago != 'CC')

								SELECT @NUMERO_PAGO_FC_ = COUNT(*) FROM  AHPF_HN.ASHPF.FACTURA_CANCELA WHERE FACTURA=@FACTURA
								SELECT @Id_FCPG_ = COUNT(*) FROM @FACTURA_CANCELA

								
								
								WHILE @E <= @Id_FCPG_
								BEGIN
									
										SET @NUMERO_PAGO_FC_ = @NUMERO_PAGO_FC_ + 1

										SELECT

										--- FACTURA CANCELA ---

										@TIPO_DOCUMENTO_FC												=FC.TIPO_DOCUMENTO,	
										@FACTURA_FC														=FC.FACTURA,
										@NUMERO_PAGO_FC													=@NUMERO_PAGO_FC_,
										@TIPO_FC														=FC.TIPO,
										@MONTO_FC														=FC.MONTO,
										@MONEDA_FC														=FC.MONEDA,
										@NUM_DOCUMENTO_FC												=FC.NUM_DOCUMENTO,
										@ENTIDAD_FINANCIERA_FC											=FC.ENTIDAD_FINANCIERA,
										@TIPO_TARJETA_FC												=FC.TIPO_TARJETA,
										@NUM_AUTORIZA_FC												=FC.NUM_AUTORIZA,
										@USUARIO_FC														=FC.USUARIO,
										@CAJA_FC														=FC.CAJA,
										@FECHA_HORA_FC													=FC.FECHA_HORA,
										@DEVOLUCION_FC													=FC.DEVOLUCION,
										@NoteExistsFlag_FC												=FC.NoteExistsFlag,
										@RecordDate_FC													=FC.RecordDate,
										@RowPointer_FC													=FC.RowPointer,
										@CreatedBy_FC													=FC.CreatedBy,
										@UpdatedBy_FC													=FC.UpdatedBy,
										@NUM_APERTURA_FC												=FC.NUM_APERTURA,
										@Id_FC															=FC.Id_FC,
										@Id_FCPG														=FC.Id_FCPG,

										--- DOCUMENTO CXC ---

										@DOCUMENTO														=FC.DOCUMENTO,
										@TIPO_C															=FC.TIPO_C,
										@APLICACION														=FC.APLICACION,
										@FECHA_DOCUMENTO												=FC.FECHA_DOCUMENTO,
										@FECHA															=FC.FECHA,
										@MONTO_C														=FC.MONTO_C,
										@SALDO															=FC.SALDO,
										@MONTO_LOCAL													=FC.MONTO_LOCAL,
										@SALDO_LOCAL													=FC.SALDO_LOCAL,
										@MONTO_DOLAR													=FC.MONTO_DOLAR,
										@SALDO_DOLAR													=FC.SALDO_DOLAR,
										@MONTO_CLIENTE													=FC.MONTO_CLIENTE,
										@SALDO_CLIENTE													=FC.SALDO_CLIENTE,
										@TIPO_CAMBIO_MONEDA												=FC.TIPO_CAMBIO_MONEDA,
										@TIPO_CAMBIO_DOLAR												=FC.TIPO_CAMBIO_DOLAR,
										@TIPO_CAMBIO_CLIENT												=FC.TIPO_CAMBIO_CLIENT,
										@TIPO_CAMB_ACT_LOC												=FC.TIPO_CAMB_ACT_LOC,
										@TIPO_CAMB_ACT_DOL												=FC.TIPO_CAMB_ACT_DOL,
										@TIPO_CAMB_ACT_CLI												=FC.TIPO_CAMB_ACT_CLI,
										@SUBTOTAL														=FC.SUBTOTAL,
										@DESCUENTO														=FC.DESCUENTO,
										@IMPUESTO1														=FC.IMPUESTO1,
										@IMPUESTO2														=FC.IMPUESTO2,
										@RUBRO1															=FC.RUBRO1,	
										@RUBRO2															=FC.RUBRO2,
										@MONTO_RETENCION												=FC.MONTO_RETENCION,
										@SALDO_RETENCION												=FC.SALDO_RETENCION,	
										@DEPENDIENTE													=FC.DEPENDIENTE,
										@FECHA_ULT_CREDITO												=FC.FECHA_ULT_CREDITO,
										@CARGADO_DE_FACT												=FC.CARGADO_DE_FACT,
										@APROBADO														=FC.APROBADO,
										@ASIENTO														=FC.ASIENTO,	
										@ASIENTO_PENDIENTE												=FC.ASIENTO_PENDIENTE,
										@FECHA_ULT_MOD													=FC.FECHA_ULT_MOD,
										@CLASE_DOCUMENTO												=FC.CLASE_DOCUMENTO,
										@FECHA_VENCE													=FC.FECHA_VENCE,
										@NUM_PARCIALIDADES												=FC.NUM_PARCIALIDADES,
										@USUARIO_ULT_MOD												=FC.USUARIO_ULT_MOD,
										@CONDICION_PAGO													=FC.CONDICION_PAGO,
										@MONEDA_C														=FC.MONEDA_C,
										@CLIENTE_REPORTE												=FC.CLIENTE_REPORTE,
										@CLIENTE_ORIGEN													=FC.CLIENTE_ORIGEN,
										@CLIENTE														=FC.CLIENTE,
										@PORC_INTCTE													=FC.PORC_INTCTE,
										@DEPENDIENTE_GP													=FC.DEPENDIENTE_GP,
										@SALDO_TRANS													=FC.SALDO_TRANS,
										@SALDO_TRANS_LOCAL												=FC.SALDO_TRANS_LOCAL,
										@SALDO_TRANS_DOLAR												=FC.SALDO_TRANS_DOLAR,
										@SALDO_TRANS_CLI												=FC.SALDO_TRANS_CLI,
										@TIPO_CAMBIO_FAC												=FC.TIPO_CAMBIO_FAC,
										@ANULADO														=FC.ANULADO,
										@COBRADOR														=FC.COBRADOR,
										@VENDEDOR														=FC.VENDEDOR,
										@SUBTIPO														=FC.SUBTIPO,
										@FACTURADO														=FC.FACTURADO,
										@GENERA_DOC_FE													=FC.GENERA_DOC_FE
								

										FROM @FACTURA_CANCELA AS FC WHERE FC.ID=@E
									
										/*REGISTRAR ULTIMO PAGO EN FACTURA CANCELA*/
										
										EXEC erpadmin.LeerUsuarioActual @Usuario
										EXEC erpadmin.GrabarUsuarioActual @Usuario

										
										------------------------------------------------------------------------------------------------------------
										-------------------------------------- FACTURA CANCELA -------------------------------------
										------------------------------------------------------------------------------------------------------------
										
										INSERT INTO AHPF_HN.ASHPF.FACTURA_CANCELA
										(TIPO_DOCUMENTO,FACTURA,NUMERO_PAGO,TIPO,MONTO,					
										MONEDA,NUM_DOCUMENTO,ENTIDAD_FINANCIERA,TIPO_TARJETA,NUM_AUTORIZA,				
										USUARIO,CAJA,FECHA_HORA,DEVOLUCION,NoteExistsFlag,				
										RecordDate,RowPointer,CreatedBy,UpdatedBy,NUM_APERTURA)

										VALUES
										(@TIPO_DOCUMENTO_FC,@FACTURA_FC,@NUMERO_PAGO_FC_,@TIPO_FC,@MONTO_FC,					
										@MONEDA_FC,@NUM_DOCUMENTO_FC,@ENTIDAD_FINANCIERA_FC,@TIPO_TARJETA_FC,@NUM_AUTORIZA_FC,				
										@Usuario,@CAJA_FC,@FECHA_HORA_FC,@DEVOLUCION_FC,@NoteExistsFlag_FC,				
										@RecordDate_FC,@RowPointer_FC,								
										@Usuario,@Usuario,
										@NUM_APERTURA_FC)


												/*---------------------------------------*/
													--- ACTUALIZAR RowPointer FCPG ---
												-------------------------------------------

												UPDATE H1_AHPF_HN.dbo.FCPG

													SET UDF_RowPointer = @RowPointer_FC	

												WHERE Id_FC = @Id_FC AND Id_FCPG = @Id_FCPG

												--------------------------------------------

										SET @E = @E + 1
								END

								/*ACTUALIZAR UDF_Caja de H1*/

								UPDATE H1_AHPF_HN.dbo.FCPG
								SET UDF_Caja=@CAJA_FC, Usuario_Registro=@Usuario, Usuario_Modificacion=@Usuario
								WHERE Id_FC=@Id_FC		AND Id_FCPG=@Id_FCPG

								/*REGISTRO DOCUMENTO  REC SEGUNDO ABONO DE OPTICA*/

								EXEC erpadmin.GrabarUsuarioActual @Usuario
		

										INSERT INTO AHPF_HN.ASHPF.DOCUMENTOS_CC 
										(DOCUMENTO,TIPO,APLICACION,FECHA_DOCUMENTO,FECHA,MONTO,SALDO,MONTO_LOCAL,SALDO_LOCAL,MONTO_DOLAR,SALDO_DOLAR,
										MONTO_CLIENTE,SALDO_CLIENTE,TIPO_CAMBIO_MONEDA,TIPO_CAMBIO_DOLAR,TIPO_CAMBIO_CLIENT,TIPO_CAMB_ACT_LOC,TIPO_CAMB_ACT_DOL,
										TIPO_CAMB_ACT_CLI,SUBTOTAL,DESCUENTO,IMPUESTO1,IMPUESTO2,RUBRO1,RUBRO2,MONTO_RETENCION,SALDO_RETENCION,DEPENDIENTE,
										FECHA_ULT_CREDITO,CARGADO_DE_FACT,APROBADO,ASIENTO,ASIENTO_PENDIENTE,FECHA_ULT_MOD,CLASE_DOCUMENTO,FECHA_VENCE,NUM_PARCIALIDADES,
										COBRADOR,USUARIO_ULT_MOD,CONDICION_PAGO,MONEDA,VENDEDOR,CLIENTE_REPORTE,CLIENTE_ORIGEN,CLIENTE,SUBTIPO,
										PORC_INTCTE,NoteExistsFlag,RecordDate,RowPointer,CreatedBy,UpdatedBy,CreateDate,ANULADO,DEPENDIENTE_GP,SALDO_TRANS,SALDO_TRANS_LOCAL,
										SALDO_TRANS_DOLAR,SALDO_TRANS_CLI,FACTURADO,GENERA_DOC_FE)

										VALUES
										(@DOCUMENTO,@TIPO_C,@APLICACION,@FECHA_DOCUMENTO,@FECHA,@MONTO_TEMP_T,@SALDO,@MONTO_TEMP_T,@SALDO_LOCAL,@MONTO_DOLAR,@SALDO_DOLAR,
										@MONTO_TEMP_T,@SALDO_CLIENTE,@TIPO_CAMBIO_MONEDA,@TIPO_CAMBIO_DOLAR,@TIPO_CAMBIO_CLIENT,@TIPO_CAMB_ACT_LOC,@TIPO_CAMB_ACT_DOL,
										@TIPO_CAMB_ACT_CLI,@MONTO_TEMP_T,@DESCUENTO,@IMPUESTO1,@IMPUESTO2,@RUBRO1,@RUBRO2,@MONTO_RETENCION,@SALDO_RETENCION,@DEPENDIENTE,
										@FECHA_ULT_CREDITO,@CARGADO_DE_FACT,@APROBADO,@ASIENTO,@ASIENTO_PENDIENTE,@FECHA_ULT_MOD,@CLASE_DOCUMENTO,@FECHA_VENCE,@NUM_PARCIALIDADES,
										@COBRADOR,@Usuario,@CONDICION_PAGO,@MONEDA_C,@VENDEDOR,@CLIENTE_REPORTE,@CLIENTE_ORIGEN,@CLIENTE,@SUBTIPO,
										@PORC_INTCTE,@NoteExistsFlag,@RecordDate,NEWID(),@Usuario,@Usuario,@CreateDate,@ANULADO,@DEPENDIENTE_GP,@SALDO_TRANS,@SALDO_TRANS_LOCAL,
										@SALDO_TRANS_DOLAR,@SALDO_TRANS_CLI,@FACTURADO,@GENERA_DOC_FE)


										/*ACTUALIZAR SALDOS CXC*/

												--- ACTUALIZACION DEL SALDO CLIENTE CORPORACION 

												SELECT 
												@SALDO				=	C0.SALDO,
												@SALDO_LOCAL		=	C0.SALDO_LOCAL

												FROM AHPF_HN.ASHPF.CLIENTE AS C0 WHERE C0.CLIENTE	=	@CLIENTE


												UPDATE AHPF_HN.ASHPF.CLIENTE  
												SET SALDO		= ROUND(@SALDO				-  @MONTO_TEMP_T,2),
												SALDO_LOCAL		= ROUND(@SALDO_LOCAL		-  @MONTO_TEMP_T,2)												
												WHERE  CLIENTE = @CLIENTE

												UPDATE AHPF_HN.ASHPF.SALDO_CLIENTE  
												SET  SALDO		= ROUND(@SALDO				-  @MONTO_TEMP_T,2) 
												WHERE  CLIENTE = @CLIENTE  
												AND MONEDA = 'LPS' 

												---  CAMBIAR ESTADO DE ASIENTO 

												UPDATE 	AHPF_HN.ASHPF.DOCUMENTOS_CC  
												SET     ASIENTO_PENDIENTE = 'N'   
												WHERE	TIPO = 'REC'       AND 	DOCUMENTO = @DOCUMENTO

											
												-------- ACTUALIZAR SALDOS DOCUMENTOS TIPO FAC 
																																	
												UPDATE AHPF_HN.ASHPF.DOCUMENTOS_CC 
												SET    
												SALDO		= ROUND(SALDO		- @MONTO_TEMP_T,2),   
												SALDO_LOCAL = ROUND(SALDO_LOCAL - @MONTO_TEMP_T,2)        
								
												WHERE  TIPO = 'FAC'        AND DOCUMENTO = @FACTURA
												

												/*--------------REGISTRO EN AUXILIAR-------------------*/														
													
													/*VARIABLES PARA CONSTRUIR REGISTRO EN AUXILIAR*/

													DECLARE @TIPO_CREDITO			AS VARCHAR(3)
													DECLARE @TIPO_DEBITO			AS VARCHAR(3)
													DECLARE @FECHA_					AS DATETIME
													DECLARE @CREDITO				AS VARCHAR(50)
													DECLARE @MONTO_LOCAL_			AS DECIMAL(28,8)
													DECLARE @MONTO_CLI_CREDITO		AS DECIMAL(28,8)
													DECLARE @MONTO_CLI_DEBITO		AS DECIMAL(28,8)
													DECLARE @ASIENTO_				AS VARCHAR(10)
													DECLARE @MONTO_CREDITO			AS DECIMAL(28,8)
													DECLARE @MONEDA_DEBITO			AS VARCHAR(4)
													DECLARE @CLI_REPORTE_DEBITO		AS VARCHAR(20)
													DECLARE @CLI_DOC_CREDIT			AS VARCHAR(20)
													DECLARE @CLI_DOC_DEBITO			AS VARCHAR(20)
													DECLARE @NoteExistsFlag_		AS TINYINT
													DECLARE @RecordDate_			AS DATETIME
													DECLARE @RowPointer_			AS UNIQUEIDENTIFIER
													DECLARE @UpdatedBy_				AS VARCHAR(30)
													DECLARE @CreateDate_			AS DATETIME
													DECLARE @DEBITO					AS VARCHAR(50)
													DECLARE @MONTO_DEBITO			AS DECIMAL(28,8)
													DECLARE @MONTO_DOLAR_			AS DECIMAL(28,8)
													DECLARE @MONEDA_CREDITO			AS VARCHAR(4)
													DECLARE @CLI_REPORTE_CREDIT		AS VARCHAR(20)
													DECLARE @TIPO_CAMBIO_			AS DECIMAL(28,8)


											
															SELECT @TIPO_CAMBIO_=([AHPF_HN].[ASHPF].[ObtenerTipoCambio] ('DLR',GETDATE()))	
															,@TIPO_CREDITO='REC'								
															,@TIPO_DEBITO='FAC'								
															,@FECHA=GETDATE()							
															,@CREDITO=@DOCUMENTO					
															,@DEBITO=@FACTURA				
															,@MONTO_DEBITO=@MONTO_TEMP_T						
															,@MONTO_CREDITO=@MONTO_TEMP_T							
															,@MONTO_LOCAL=@MONTO_TEMP_T						
															,@MONTO_CLI_CREDITO=@MONTO_TEMP_T						
															,@MONTO_CLI_DEBITO=@MONTO_TEMP_T						
															,@MONEDA_DEBITO='LPS'								
															,@MONEDA_CREDITO='LPS'								
															,@CLI_REPORTE_DEBITO=@CLIENTE				
															,@CLI_REPORTE_CREDIT=@CLIENTE							
															,@CLI_DOC_CREDIT=@CLIENTE						
															,@CLI_DOC_DEBITO=@CLIENTE				
															,@NoteExistsFlag=0									
															,@RecordDate=GETDATE()							
															,@RowPointer=NEWID()							
															,@UpdatedBy=@Usuario					
															,@CreateDate=GETDATE()							
															,@MONTO_DOLAR=0.00000000	

																			
															INSERT INTO AHPF_HN.ASHPF.AUXILIAR_CC
															(TIPO_CREDITO,TIPO_DEBITO,FECHA,CREDITO,DEBITO,MONTO_DEBITO,MONTO_CREDITO,MONTO_LOCAL,MONTO_DOLAR,
															MONTO_CLI_CREDITO,MONTO_CLI_DEBITO,MONEDA_CREDITO,MONEDA_DEBITO,CLI_REPORTE_CREDIT,CLI_REPORTE_DEBITO,
															CLI_DOC_CREDIT,CLI_DOC_DEBITO,NoteExistsFlag,RecordDate,RowPointer,UpdatedBy,CreateDate)
																				
															VALUES 
															(@TIPO_CREDITO,@TIPO_DEBITO,@FECHA,@CREDITO,@DEBITO,@MONTO_DEBITO,@MONTO_CREDITO,@MONTO_LOCAL,@MONTO_DOLAR,
															@MONTO_CLI_CREDITO,@MONTO_CLI_DEBITO,@MONEDA_CREDITO,@MONEDA_DEBITO,@CLI_REPORTE_CREDIT,@CLI_REPORTE_DEBITO,
															@CLI_DOC_CREDIT,@CLI_DOC_DEBITO,@NoteExistsFlag,@RecordDate,@RowPointer,@UpdatedBy,@CreateDate)
								
												/*------------------------------------------------------------------------------------------------------------------*/
												----------------------------------------------------------------------------------------------------------------------


								/*REGISTRO DE ASIENTO EN MAYOR*/

									EXEC AHPF_HN.ASHPF.sP_CX2_H1_   @FACTURA,@DOCUMENTO,@RowPointer_FC,@CreatedBy_FC,'S','ND'
						
									
								/*ACTUALIZAR UDF RECIBO EN H1 */

									SELECT @Id_FC=Id_FC 
									FROM H1_AHPF_HN.dbo.FC 
									WHERE UDF_Factura_E=@FACTURA

									UPDATE H1_AHPF_HN.dbo.FCPG 
									SET UDF_Num_Recibo=@DOCUMENTO 
									WHERE Id_FC=@Id_FC 
									AND UDF_Num_Recibo IS NULL 
									AND TipoPago!='CC'

							
									---- CALCULAR LOS DIAS NETOS Y OBTENER LA FECHA VENCE DEL CREDITO ----

									SET @DIAS_NETO			=( SELECT [AHPF_HN].[ASHPF].[GET_DIASNETOS](@FACTURA))
									SET @FECHA_VENCE_T	=( SELECT[AHPF_HN].[ASHPF].[GET_FECHAVENCE_CC](@DOCUMENTO,@DIAS_NETO))

									UPDATE AHPF_HN.ASHPF.DOCUMENTOS_CC
									SET FECHA_VENCE = @FECHA_VENCE_T
									WHERE DOCUMENTO =@DOCUMENTO

									UPDATE AHPF_HN.ASHPF.MAYOR
									SET FASE=NULL, PROYECTO=NULL
									WHERE ASIENTO=@ASIENTO


									/*----------------------------------------------------------------------*/
									---- ENCAPSULAMIENTO DEL PROCESO PARA REALIZAR CARGO A BAC Y BANPAIS -----
									--------------------------------------------------------------------------

											/*--------------------------------------------------------------*/
																	--- DOCUMENTO CC ---

											DECLARE @TEMP_DOCUMENTO								AS NVARCHAR(50)
											DECLARE @TEMP_FACTURA								AS NVARCHAR(50)
											DECLARE @TEMP_APLICACION							AS VARCHAR(249)
											DECLARE @TEMP_NOTAS									AS VARCHAR(MAX)
											DECLARE @Id_Corp									VARCHAR(150)

											/*------------------------------------------------------------*/
																	--- FCPG POS ---

											DECLARE @TEMP_Id_FC						INT
											DECLARE @TEMP_TipoPago					NVARCHAR(20)
											DECLARE @TEMP_Pago						DECIMAL(28,8)
											DECLARE @TEMP_Caja						NVARCHAR(50)
											DECLARE @TEMP_CajaDescripcion			NVARCHAR(120)
											DECLARE @TEMP_Recibo					NVARCHAR(50)
											DECLARE @TEMP_Factura_					NVARCHAR(50)
											DECLARE @TEMP_Id_POS					NVARCHAR(50)
											DECLARE @TEMP_Notas_					NVARCHAR(MAX)
											DECLARE @TEMP_Aplicacion_				VARCHAR(249)
											DECLARE @TEMP_Usuario_Registro			NVARCHAR(256)
											DECLARE @TEMP_Id_PT						NVARCHAR(15)
											DECLARE @TipoPago						NVARCHAR(20)
											DECLARE @TEMP_Paciente					NVARCHAR(250)
											DECLARE @TEMP_Nombre_Corp				VARCHAR(150)

											/*----------------------------------------------------------*/
																	--- ITERACION ---

											DECLARE @P					AS	INT
												SET @P = 1
											DECLARE @Id_FCPG_POS		AS	INT

														
											/*----------------------------------------------------------*/
														--- CONSTRUIR  DOCUMENTO OD ---
												
		
												SELECT @Id_FCPG_POS = COUNT(*) FROM @FORMA_FCPG
		
												WHILE @P <= @Id_FCPG_POS
												BEGIN 
		
														SELECT 
															@TEMP_Id_FC						=	LP.Id_FC,
															@TEMP_Pago						=	LP.Pago, 
															@TEMP_CajaDescripcion			=	UPPER(LP.CajaDescripcion),     
															@TEMP_Caja						=	LP.Caja,
															@TEMP_Recibo					=	LP.Recibo,      
															@TEMP_Factura					=	LP.Factura,
															@TEMP_Id_POS					=	LP.Id_POS,
															@TEMP_Usuario_Registro			=	UPPER(LP.Usuario_Registro),
															@TEMP_Id_PT						=	LP.Id_PT,
															@TipoPago						=	LP.TipoPago,
															@TEMP_Paciente					=	LP.Paciente
		
														FROM @FORMA_FCPG AS LP WHERE LP.ID = @P			

						
	  																SET @TEMP_DOCUMENTO		= (SELECT ((ULTIMO_VALOR) + 1) FROM AHPF_HN.ASHPF.CONSECUTIVO AS C WITH(UPDLOCK) WHERE c.CONSECUTIVO = 'OD')
																	SET @TEMP_FACTURA		= (SELECT UDF_FACTURA_E FROM  H1_AHPF_HN.dbo.FC  WITH(NOLOCK) WHERE Id_FC=@Id_FC)
																	SET @Id_Corp		= (SELECT Id_PT FROM  H1_AHPF_HN.dbo.FC  WITH(NOLOCK) WHERE Id_FC=@Id_FC)
					
																	SET @TEMP_Nombre_Corp = (SELECT NOMBRE FROM AHPF_HN.ASHPF.CLIENTE  WITH(NOLOCK) WHERE CLIENTE=@Id_Corp)
																	SET @TEMP_Notas		 = @TEMP_CajaDescripcion + '  ' + 'POS :' + '  ' + @TEMP_Id_POS  + '  ' + 'FACTURA :' + '  ' + @TEMP_Factura + '  ' + 'CLIENTE : ' + '  ' + @TEMP_Nombre_Corp + '  ' + 'PACIENTE :' + '  ' + @TEMP_Paciente
																	SET @TEMP_Aplicacion = @TEMP_CajaDescripcion + '  ' + 'POS :' + '  ' + @TEMP_Id_POS  + '  ' + 'FACTURA :' + '  ' + @TEMP_Factura + '  ' + 'CLIENTE : ' + '  ' + @TEMP_Nombre_Corp + '  ' + 'PACIENTE :' + '  ' + @TEMP_Paciente

							
							
																	-----------------------------------------------
																		--- REGISTRO DE DOCUMENTO A CXC ---
																	-----------------------------------------------

																	INSERT INTO AHPF_HN.ASHPF.DOCUMENTOS_CC 
																	(DOCUMENTO,TIPO,APLICACION,FECHA_DOCUMENTO,FECHA,MONTO,SALDO,MONTO_LOCAL,SALDO_LOCAL,MONTO_DOLAR,SALDO_DOLAR,
																	MONTO_CLIENTE,SALDO_CLIENTE,TIPO_CAMBIO_MONEDA,TIPO_CAMBIO_DOLAR,TIPO_CAMBIO_CLIENT,TIPO_CAMB_ACT_LOC,TIPO_CAMB_ACT_DOL,
																	TIPO_CAMB_ACT_CLI,SUBTOTAL,DESCUENTO,IMPUESTO1,IMPUESTO2,RUBRO1,RUBRO2,MONTO_RETENCION,SALDO_RETENCION,DEPENDIENTE,
																	FECHA_ULT_CREDITO,CARGADO_DE_FACT,APROBADO,ASIENTO_PENDIENTE,FECHA_ULT_MOD,NOTAS,CLASE_DOCUMENTO,FECHA_VENCE,NUM_PARCIALIDADES,
																	COBRADOR,USUARIO_ULT_MOD,CONDICION_PAGO,MONEDA,VENDEDOR,CLIENTE_REPORTE,CLIENTE_ORIGEN,CLIENTE,SUBTIPO,
																	PORC_INTCTE,NoteExistsFlag,RecordDate,RowPointer,CreatedBy,UpdatedBy,CreateDate,ANULADO,TIPO_ASIENTO,PAQUETE,FACTURADO,GENERA_DOC_FE)

																	VALUES
																	(@TEMP_DOCUMENTO,'O/D',@TEMP_Aplicacion, (SELECT DATEADD(dd, DATEDIFF(dd, 0, CURRENT_TIMESTAMP), 0)),
																	(SELECT DATEADD(dd, DATEDIFF(dd, 0, CURRENT_TIMESTAMP), 0)),@TEMP_Pago,@TEMP_Pago,@TEMP_Pago,@TEMP_Pago,0.00000000,0.00000000,
																	@TEMP_Pago,@TEMP_Pago,1.00000000,0.00000000,1.00000000,1.00000000,0.00000000,
																	1.00000000,@TEMP_Pago,0.00000000,0.00000000,0.00000000,0.00000000,0.00000000,0.00000000,0.00000000,'N',
																	'1980-01-01 00:00:00.000','N','N','S',GETDATE(),@TEMP_Notas,'N',GETDATE(),0,
																	'ND',@TEMP_Usuario_Registro,'002','LPS','ND',@TEMP_Id_PT,@TEMP_Id_PT,@TEMP_Id_PT,158,
																	0.00000000,0,GETDATE(),NEWID(),@TEMP_Usuario_Registro,@TEMP_Usuario_Registro,GETDATE(),'N','PING','CC1','N','N')

																	UPDATE  AHPF_HN.ASHPF.CONSECUTIVO
																	SET ULTIMO_VALOR= @TEMP_DOCUMENTO 
																	WHERE CONSECUTIVO = 'OD'

							
																	------------------------------------
																	--- ACTUALIZAR SALDO CLIENTE CXC ---
																	------------------------------------
														
																	UPDATE 	AHPF_HN.ASHPF.CLIENTE  
																	SET 	SALDO = SALDO + @TEMP_Pago, 
																	SALDO_LOCAL = SALDO_LOCAL + @TEMP_Pago  	
								       
																	WHERE CLIENTE = @TEMP_Id_PT

																	UPDATE		AHPF_HN.ASHPF.SALDO_CLIENTE  
																	SET	SALDO = SALDO + @TEMP_Pago           
																	WHERE	CLIENTE = @TEMP_Id_PT        
																	AND 	MONEDA = 'LPS'

							
																		-------------------- OBTENER DIAS NETOS PARA CALCULAR FECHA DE VENCIMIENTO DEL DOCUMENTO ---------------------------

																	IF @Id_Corp != 'SIGH000015232'
																	BEGIN

																		SET @DIAS_NETO		=( SELECT [AHPF_HN].[ASHPF].[GET_DIASNETOS](@TEMP_FACTURA))
																		SET @FECHA_VENCE_T	=( SELECT [AHPF_HN].[ASHPF].[GET_FECHAVENCE_CC](@TEMP_FACTURA,@DIAS_NETO))

																		UPDATE AHPF_HN.ASHPF.DOCUMENTOS_CC
																		SET FECHA_VENCE =	@FECHA_VENCE_T
																		WHERE DOCUMENTO =	@TEMP_FACTURA
																	END 

																	IF @Id_Corp = 'SIGH000015232'
																	BEGIN

																		UPDATE AHPF_HN.ASHPF.DOCUMENTOS_CC
																		SET FECHA_VENCE =	(SELECT  DATEADD(DAY,0,GETDATE()))
																		WHERE DOCUMENTO =	@TEMP_DOCUMENTO
																	END 



														SET @P = @P + 1
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
			RETURN
END