USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_DOCUMENTO_CC_REC_FA_H1]    Script Date: 11/9/2022 3:35:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [ASHPF].[sP_DOCUMENTO_CC_REC_FA_H1]
	-- Add the parameters for the stored procedure here
	@FACTURA			AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		DECLARE @DOCUMENTO				AS NVARCHAR(50)
		DECLARE @TIPO					AS VARCHAR(3)
		DECLARE @APLICACION				AS VARCHAR(249)
		DECLARE @FECHA_DOCUMENTO		AS DATETIME
		DECLARE @FECHA					AS DATETIME
		DECLARE @MONTO					AS DECIMAL(28,8)
		DECLARE @SALDO					AS DECIMAL(28,8)
		DECLARE @MONTO_LOCAL			AS DECIMAL(28,8)
		DECLARE @SALDO_LOCAL			AS DECIMAL(28,8)
		DECLARE @MONTO_DOLAR			AS DECIMAL(28,8)
		DECLARE @SALDO_DOLAR			AS DECIMAL(28,8)
		DECLARE @MONTO_CLIENTE			AS DECIMAL(28,8)
		DECLARE @SALDO_CLIENTE			AS DECIMAL(28,8)
		DECLARE @TIPO_CAMBIO_MONEDA		AS DECIMAL(28,8)
		DECLARE @TIPO_CAMBIO_DOLAR		AS DECIMAL(28,8)
		DECLARE @TIPO_CAMBIO_CLIENT		AS DECIMAL(28,8)
		DECLARE @TIPO_CAMB_ACT_LOC		AS DECIMAL(28,8)
		DECLARE @TIPO_CAMB_ACT_DOL		AS DECIMAL(28,8)
		DECLARE @TIPO_CAMB_ACT_CLI		AS DECIMAL(28,8)
		DECLARE @SUBTOTAL				AS DECIMAL(28,8)
		DECLARE @DESCUENTO				AS DECIMAL(28,8)
		DECLARE @IMPUESTO1				AS DECIMAL(28,8)
		DECLARE @IMPUESTO2				AS DECIMAL(28,8)
		DECLARE @RUBRO1					AS DECIMAL(28,8)
		DECLARE @RUBRO2					AS DECIMAL(28,8)
		DECLARE @MONTO_RETENCION		AS DECIMAL(28,8)
		DECLARE @SALDO_RETENCION		AS DECIMAL(28,8)
		DECLARE @DEPENDIENTE			AS VARCHAR(1)
		DECLARE @FECHA_ULT_CREDITO		AS DATETIME
		DECLARE @CARGADO_DE_FACT		AS VARCHAR(1)
		DECLARE @APROBADO				AS VARCHAR(1)
		DECLARE @ASIENTO				AS VARCHAR(10)
		DECLARE @ASIENTO_PENDIENTE		AS VARCHAR(1)
		DECLARE @FECHA_ULT_MOD			AS DATETIME
		DECLARE @CLASE_DOCUMENTO		AS VARCHAR(1)
		DECLARE @FECHA_VENCE			AS DATETIME
		DECLARE @NUM_PARCIALIDADES		AS SMALLINT
		DECLARE @USUARIO_ULT_MOD		AS VARCHAR(25)
		DECLARE @CONDICION_PAGO			AS VARCHAR(4)
		DECLARE @MONEDA					AS VARCHAR(4)
		DECLARE @CLIENTE_REPORTE		AS VARCHAR(20)
		DECLARE @CLIENTE_ORIGEN			AS VARCHAR(20)
		DECLARE @CLIENTE				AS VARCHAR(20)
		DECLARE @PORC_INTCTE			AS DECIMAL(28,8)
		DECLARE @DEPENDIENTE_GP			AS VARCHAR(1)
		DECLARE @SALDO_TRANS			AS DECIMAL(28,8)
		DECLARE @SALDO_TRANS_LOCAL		AS DECIMAL(28,8)
		DECLARE @SALDO_TRANS_DOLAR		AS DECIMAL(28,8)
		DECLARE @SALDO_TRANS_CLI		AS DECIMAL(28,8)
		DECLARE @TIPO_CAMBIO_FAC		AS DECIMAL(28,8)
		DECLARE @NoteExistsFlag			AS TINYINT
		DECLARE @RecordDate				AS DATETIME
		DECLARE @RowPointer				AS UNIQUEIDENTIFIER
		DECLARE @CreatedBy				AS VARCHAR(30)
		DECLARE @UpdatedBy				AS VARCHAR(30)
		DECLARE @CreateDate				AS DATETIME
		DECLARE @ANULADO				AS VARCHAR(1) 		
		DECLARE @COBRADOR				AS VARCHAR(4)	
		DECLARE @VENDEDOR				AS VARCHAR(4)
		DECLARE @SUBTIPO				AS SMALLINT
		DECLARE @FACTURADO				AS VARCHAR(1)
		DECLARE @GENERA_DOC_FE			AS VARCHAR(1)
		DECLARE @MONTO_E				AS DECIMAL(28,8)
		DECLARE @MONTO_T				AS DECIMAL(28,8)
		DECLARE @UDF_Nombre_Paciente	AS NVARCHAR(500)	
		DECLARE @SerieTR				AS INT	
		DECLARE @Serie					AS INT	
		DECLARE @Id_UH					AS VARCHAR(20)
		DECLARE @SerieCC				AS NVARCHAR(10) 
		DECLARE @UDF_Cliente			AS NVARCHAR(200)
		DECLARE @OPTICA					INT
		DECLARE @Caja					AS VARCHAR(20)
		DECLARE @DIAS_NETO				AS INT
		DECLARE @FECHA_VENCE_T			DATETIME

  declare @Mensaje as nvarchar(500)
	BEGIN TRY
		BEGIN TRANSACTION
    -- Insert statements for procedure here
		
		SET @Caja					= (SELECT Caja					FROM H1_AHPF_HN.dbo.FC WITH(NOLOCK) WHERE UDF_Factura_E=@FACTURA)
		SET @Id_UH					= (SELECT Id_UH					FROM H1_AHPF_HN.dbo.FC WITH(NOLOCK) WHERE UDF_Factura_E=@FACTURA)
		SET @SerieTR				= (SELECT UDF_Recibo			FROM H1_AHPF_HN.dbo.CJ WITH(NOLOCK) WHERE Id_UH=@Id_UH AND Caja=@Caja)
		SET @UDF_Nombre_Paciente	= (SELECT UDF_Nombre_Paciente	FROM H1_AHPF_HN.dbo.FC WITH(NOLOCK) WHERE UDF_Factura_E=@FACTURA)

		
		/*---------------------------------------------------------------*/
					--- OBTENER NUMERO DE ASIENTO CXC ---
		-------------------------------------------------------------------

		DECLARE @SerieA AS VARCHAR(50)
		DECLARE @SerieB AS VARCHAR(10)
		
		EXECUTE AHPF_HN.ASHPF.sP_GET_SERIAL_CXC @SerieTR, @SerieOUT = @SerieA OUTPUT, @SerieCC = @SerieB OUTPUT
		
				
		SET @TIPO_CAMBIO_FAC		= (SELECT TIPO_CAMBIO					FROM AHPF_HN.ASHPF.FACTURA			WITH(NOLOCK) WHERE FACTURA=@FACTURA)
		SET @MONTO_E				= ISNULL((SELECT ISNULL(MONTO,0.0)		FROM AHPF_HN.ASHPF.FACTURA_CANCELA	WITH(NOLOCK) WHERE FACTURA=@FACTURA AND TIPO='E'),0.0)	
		SET @MONTO_T				= ISNULL((SELECT ISNULL(SUM(MONTO),0.0) FROM AHPF_HN.ASHPF.FACTURA_CANCELA	WITH(NOLOCK) WHERE FACTURA=@FACTURA AND TIPO='T'),0.0)	
		SET @UDF_Nombre_Paciente	= (SELECT UDF_Nombre_Paciente			FROM H1_AHPF_HN.dbo.FC		WITH(NOLOCK) WHERE UDF_Factura_E=@FACTURA)
		SET @UDF_Cliente			= (SELECT UDF_Cliente					FROM H1_AHPF_HN.dbo.FC		WITH(NOLOCK) WHERE UDF_Factura_E=@FACTURA)
		

						/*----------------------------------------------------------------------------------------*/
									 

			
						SELECT DISTINCT 
					 
							@DOCUMENTO =(SELECT  @SerieA),
							@TIPO ='REC',	
							@APLICACION = ('Abono cancelacion de factura: ' + @FACTURA + ' - Cliente: ' + UPPER(@UDF_Nombre_Paciente)),
							@FECHA_DOCUMENTO =(SELECT DATEADD(dd, DATEDIFF(dd, 0, CURRENT_TIMESTAMP), 0)), 
							@FECHA =(SELECT DATEADD(dd, DATEDIFF(dd, 0, CURRENT_TIMESTAMP), 0)),
							@MONTO = (@MONTO_E + @MONTO_T), 
							@SALDO = 0.00000000,
							@MONTO_LOCAL = (@MONTO_E + @MONTO_T),
							@SALDO_LOCAL = 0.00000000,
							@MONTO_DOLAR = ((@MONTO_E + @MONTO_T) / FAC.TIPO_CAMBIO),
							@SALDO_DOLAR = 0.00000000,	
							@MONTO_CLIENTE= (@MONTO_E + @MONTO_T),
							@SALDO_CLIENTE = 0.00000000,
							@TIPO_CAMBIO_MONEDA = FAC.TIPO_CAMBIO,
							@TIPO_CAMBIO_DOLAR = FAC.TIPO_CAMBIO,
							@TIPO_CAMBIO_CLIENT = FAC.TIPO_CAMBIO,
							@TIPO_CAMB_ACT_LOC = FAC.TIPO_CAMBIO,
							@TIPO_CAMB_ACT_DOL = FAC.TIPO_CAMBIO,
							@TIPO_CAMB_ACT_CLI = FAC.TIPO_CAMBIO,
							@SUBTOTAL = (@MONTO_E + @MONTO_T),
							@DESCUENTO =0.00000000,
							@IMPUESTO1 =0.00000000,
							@IMPUESTO2 =0.00000000,
							@RUBRO1 =0.00000000,
							@RUBRO2 =0.00000000,
							@MONTO_RETENCION =0.00000000,
							@SALDO_RETENCION =0.00000000,
							@DEPENDIENTE = 'N',
							@FECHA_ULT_CREDITO = FAC.FECHA,
							@CARGADO_DE_FACT = 'N',
							@APROBADO = 'S',
							@ASIENTO =(SELECT  @SerieB),
							@ASIENTO_PENDIENTE = 'N',
							@FECHA_ULT_MOD = FAC.FECHA,
							@CLASE_DOCUMENTO = 'N',
							@FECHA_VENCE = FAC.FECHA,
							@NUM_PARCIALIDADES = 0,
							@COBRADOR = FAC.COBRADOR,
							@USUARIO_ULT_MOD = FAC.USUARIO,
							@CONDICION_PAGO = FAC.CONDICION_PAGO,
							@MONEDA = (CASE WHEN FAC.MONEDA='L' THEN 'LPS' END),
							@VENDEDOR = FAC.VENDEDOR,
							@CLIENTE_REPORTE = FAC.CLIENTE,
							@CLIENTE_ORIGEN =FAC.CLIENTE,
							@CLIENTE = FAC.CLIENTE,
							@SUBTIPO = 0,
							@PORC_INTCTE = 0.00000000,
							@NoteExistsFlag =0,
							@RecordDate = FAC.RecordDate,
							@RowPointer = NEWID(),
							@CreatedBy = FAC.CreatedBy,
							@UpdatedBy = FAC.UpdatedBy,
							@CreateDate = FAC.CreateDate,
							@ANULADO = FAC.ANULADA,
							@DEPENDIENTE_GP = 'N',
							@SALDO_TRANS =0.00000000,
							@SALDO_TRANS_LOCAL =0.00000000,
							@SALDO_TRANS_DOLAR=0.00000000,
							@SALDO_TRANS_CLI =0.00000000,
							@FACTURADO	= 'N',
							@GENERA_DOC_FE = 'N'	
					
						FROM AHPF_HN.ASHPF.FACTURA AS FAC WITH(NOLOCK)
						INNER JOIN AHPF_HN.ASHPF.FACTURA_CANCELA AS FC ON FC.FACTURA = FAC.FACTURA	WHERE FAC.FACTURA =@FACTURA  


						/*------------------------------------------------------*/
							--- INSERT DOCUMENTO CREDITO DOCUMENTOS_CC ---
						----------------------------------------------------------

						INSERT INTO AHPF_HN.ASHPF.DOCUMENTOS_CC 
						(DOCUMENTO,TIPO,APLICACION,FECHA_DOCUMENTO,FECHA,MONTO,SALDO,MONTO_LOCAL,SALDO_LOCAL,MONTO_DOLAR,SALDO_DOLAR,
						MONTO_CLIENTE,SALDO_CLIENTE,TIPO_CAMBIO_MONEDA,TIPO_CAMBIO_DOLAR,TIPO_CAMBIO_CLIENT,TIPO_CAMB_ACT_LOC,TIPO_CAMB_ACT_DOL,
						TIPO_CAMB_ACT_CLI,SUBTOTAL,DESCUENTO,IMPUESTO1,IMPUESTO2,RUBRO1,RUBRO2,MONTO_RETENCION,SALDO_RETENCION,DEPENDIENTE,
						FECHA_ULT_CREDITO,CARGADO_DE_FACT,APROBADO,ASIENTO,ASIENTO_PENDIENTE,FECHA_ULT_MOD,CLASE_DOCUMENTO,FECHA_VENCE,NUM_PARCIALIDADES,
						COBRADOR,USUARIO_ULT_MOD,CONDICION_PAGO,MONEDA,VENDEDOR,CLIENTE_REPORTE,CLIENTE_ORIGEN,CLIENTE,SUBTIPO,
						PORC_INTCTE,NoteExistsFlag,RecordDate,RowPointer,CreatedBy,UpdatedBy,CreateDate,ANULADO,DEPENDIENTE_GP,SALDO_TRANS,SALDO_TRANS_LOCAL,
						SALDO_TRANS_DOLAR,SALDO_TRANS_CLI,FACTURADO,GENERA_DOC_FE)

						VALUES
						(@DOCUMENTO,@TIPO,@APLICACION,@FECHA_DOCUMENTO,@FECHA,@MONTO,@SALDO,@MONTO_LOCAL,@SALDO_LOCAL,@MONTO_DOLAR,@SALDO_DOLAR,
						@MONTO_CLIENTE,@SALDO_CLIENTE,@TIPO_CAMBIO_MONEDA,@TIPO_CAMBIO_DOLAR,@TIPO_CAMBIO_CLIENT,@TIPO_CAMB_ACT_LOC,@TIPO_CAMB_ACT_DOL,
						@TIPO_CAMB_ACT_CLI,@SUBTOTAL,@DESCUENTO,@IMPUESTO1,@IMPUESTO2,@RUBRO1,@RUBRO2,@MONTO_RETENCION,@SALDO_RETENCION,@DEPENDIENTE,
						@FECHA_ULT_CREDITO,@CARGADO_DE_FACT,@APROBADO,@ASIENTO,@ASIENTO_PENDIENTE,@FECHA_ULT_MOD,@CLASE_DOCUMENTO,@FECHA_VENCE,@NUM_PARCIALIDADES,
						@COBRADOR,@USUARIO_ULT_MOD,@CONDICION_PAGO,@MONEDA,@VENDEDOR,@CLIENTE_REPORTE,@CLIENTE_ORIGEN,@CLIENTE,@SUBTIPO,
						@PORC_INTCTE,@NoteExistsFlag,@RecordDate,@RowPointer,@USUARIO_ULT_MOD,@USUARIO_ULT_MOD,@CreateDate,@ANULADO,@DEPENDIENTE_GP,@SALDO_TRANS,
						@SALDO_TRANS_LOCAL,@SALDO_TRANS_DOLAR,@SALDO_TRANS_CLI,@FACTURADO,@GENERA_DOC_FE)

						/*--------------------------------------------------------------*/
										--- REGISTRO EN  AUXILIAR_CC ---
						------------------------------------------------------------------
						EXEC AHPF_HN.ASHPF.sP_AUXILIAR_CC_FA_H1 @DOCUMENTO,@FACTURA

					    DECLARE @Id_FC INT
                        SELECT @Id_FC=Id_FC FROM H1_AHPF_HN.dbo.FC WITH(NOLOCK) WHERE UDF_Factura_E=@FACTURA
						
                        UPDATE H1_AHPF_HN.dbo.FCPG 
						SET UDF_Num_Recibo=@DOCUMENTO 
						WHERE Id_FC=@Id_FC AND UDF_Num_Recibo IS NULL AND TipoPago!='CC'


						/*--------------------------------------------------------------*/
							--- GENERACION PARTIDA DE INGRESO POR ABONO CXC ---
						------------------------------------------------------------------
												
						EXEC AHPF_HN.ASHPF.sP_CX1_H1_  @FACTURA,@DOCUMENTO,'S','ND'
						

						/*-----------------------------------------------------------------------------------------------------------------*/
						-------------------- OBTENER DIAS NETOS PARA CALCULAR FECHA DE VENCIMIENTO DEL DOCUMENTO ---------------------------
						--------------------------------------------------------------------------------------------------------------------

						SET @DIAS_NETO =( SELECT [AHPF_HN].[ASHPF].[GET_DIASNETOS](@FACTURA))
						SET @FECHA_VENCE_T	=( SELECT [AHPF_HN].[ASHPF].[GET_FECHAVENCE] (@DOCUMENTO,@DIAS_NETO))

						UPDATE AHPF_HN.ASHPF.DOCUMENTOS_CC
						SET FECHA_VENCE = @FECHA_VENCE_T
						WHERE DOCUMENTO =@DOCUMENTO

						UPDATE AHPF_HN.ASHPF.MAYOR
						SET FASE=NULL, PROYECTO=NULL
						WHERE ASIENTO=@ASIENTO


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
	return @Mensaje
END

