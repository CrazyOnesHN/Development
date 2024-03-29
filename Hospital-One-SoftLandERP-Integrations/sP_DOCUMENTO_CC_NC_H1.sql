USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_DOCUMENTO_CC_NC_H1]    Script Date: 11/9/2022 3:35:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER  PROCEDURE [ASHPF].[sP_DOCUMENTO_CC_NC_H1]
	-- Add the parameters for the stored procedure here
	@FACTURA						AS NVARCHAR(50),
	@Id_UH							AS NVARCHAR(20)

	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
		DECLARE @DOCUMENTO						AS NVARCHAR(50)		
		DECLARE @TIPO							AS VARCHAR(3)
		DECLARE @APLICACION						AS VARCHAR(249)
		DECLARE @FECHA_DOCUMENTO				AS DATETIME
		DECLARE @FECHA							AS DATETIME
		DECLARE @MONTO							AS DECIMAL(28,8)
		DECLARE @SALDO							AS DECIMAL(28,8)
		DECLARE @MONTO_LOCAL					AS DECIMAL(28,8)
		DECLARE @SALDO_LOCAL					AS DECIMAL(28,8)
		DECLARE @MONTO_DOLAR					AS DECIMAL(28,8)
		DECLARE @SALDO_DOLAR					AS DECIMAL(28,8)
		DECLARE @MONTO_CLIENTE					AS DECIMAL(28,8)
		DECLARE @SALDO_CLIENTE					AS DECIMAL(28,8)
		DECLARE @TIPO_CAMBIO_MONEDA				AS DECIMAL(28,8)
		DECLARE @TIPO_CAMBIO_DOLAR				AS DECIMAL(28,8)
		DECLARE @TIPO_CAMBIO_CLIENT				AS DECIMAL(28,8)
		DECLARE @TIPO_CAMB_ACT_LOC				AS DECIMAL(28,8)
		DECLARE @TIPO_CAMB_ACT_DOL				AS DECIMAL(28,8)
		DECLARE @TIPO_CAMB_ACT_CLI				AS DECIMAL(28,8)
		DECLARE @SUBTOTAL						AS DECIMAL(28,8)
		DECLARE @DESCUENTO						AS DECIMAL(28,8)
		DECLARE @IMPUESTO1						AS DECIMAL(28,8)
		DECLARE @IMPUESTO2						AS DECIMAL(28,8)
		DECLARE @RUBRO1							AS DECIMAL(28,8)
		DECLARE @RUBRO2							AS DECIMAL(28,8)
		DECLARE @MONTO_RETENCION				AS DECIMAL(28,8)
		DECLARE @SALDO_RETENCION				AS DECIMAL(28,8)
		DECLARE @DEPENDIENTE					AS VARCHAR(1)
		DECLARE @FECHA_ULT_CREDITO				AS DATETIME
		DECLARE @CARGADO_DE_FACT				AS VARCHAR(1)
		DECLARE @APROBADO						AS VARCHAR(1)
		DECLARE @ASIENTO_PENDIENTE				AS VARCHAR(1)
		DECLARE @FECHA_ULT_MOD					AS DATETIME
		DECLARE @NOTAS							AS VARCHAR(MAX)
		DECLARE @CLASE_DOCUMENTO				AS VARCHAR(1)
		DECLARE @FECHA_VENCE					AS DATETIME
		DECLARE @NUM_PARCIALIDADES				AS SMALLINT
		DECLARE @COBRADOR						AS VARCHAR(4)
		DECLARE @USUARIO_ULT_MOD				AS VARCHAR(25)
		DECLARE @CONDICION_PAGO					AS VARCHAR(4)
		DECLARE @MONEDA							AS VARCHAR(4)
		DECLARE @VENDEDOR						AS VARCHAR(4)
		DECLARE @CLIENTE_REPORTE				AS VARCHAR(20)
		DECLARE @CLIENTE_ORIGEN					AS VARCHAR(20)
		DECLARE @CLIENTE						AS VARCHAR(20)
		DECLARE @SUBTIPO						AS SMALLINT
		DECLARE @PORC_INTCTE					AS DECIMAL(28,8)
		DECLARE @NoteExistsFlag					AS TINYINT
		DECLARE @RecordDate						AS DATETIME
		DECLARE @RowPointer						AS UNIQUEIDENTIFIER
		DECLARE @CreatedBy						AS VARCHAR(30)
		DECLARE @CreateDate						AS DATETIME
		DECLARE @ANULADO						AS VARCHAR(1) 		
		DECLARE @TIPO_ASIENTO					AS VARCHAR(4) 	
		DECLARE @PAQUETE						AS VARCHAR(4)
		DECLARE @FACTURADO						AS VARCHAR(1)
		DECLARE @GENERA_DOC_FE					AS VARCHAR(1)
		DECLARE @DIAS_NETO						AS INT
		DECLARE @FECHA_VENCE_T					DATETIME
		

		DECLARE @TEMP_Notas						NVARCHAR(MAX)
		DECLARE @TEMP_Aplicacion				VARCHAR(249)
		DECLARE @TEMP_Nombre_Corp				VARCHAR(150)
		DECLARE @TEMP_Paciente					NVARCHAR(250)
		DECLARE @TEMP_Pago						DECIMAL(28,8)
		DECLARE @TEMP_Id_PT						NVARCHAR(15)
		DECLARE @TEMP_Usuario_Registro			NVARCHAR(256)
		DECLARE @Id_Corp						VARCHAR(150)
		DECLARE @Id_FC							INT


		DECLARE @TEMP_FACTURA					VARCHAR(50)
		DECLARE @TEMP_CLIENTE					VARCHAR(20)
		DECLARE @TEMP_ARTICULO					VARCHAR(20)
		DECLARE @TEMP_CANTIDAD					DECIMAL(28,8)
		DECLARE @TEMP_PRECIO_UNITARIO			DECIMAL(28,8)
		DECLARE @TEMP_PORC						DECIMAL(28,8)
		DECLARE @CENTRO_COSTO					VARCHAR(25)
		DECLARE @CUENTA_CONTABLE				VARCHAR(25)

		DECLARE @TEMP_MAYOR_AUDITORIA			INT
		DECLARE @TEMP_COMENTARIO				VARCHAR(40)
		DECLARE @TEMP_CLINICA_H1				NVARCHAR(MAX)
		DECLARE @TEMP_NOMBRE					NVARCHAR(200)
		DECLARE @ASIENTO_CXC					VARCHAR(50)
		DECLARE @TEMP_NUMERO_LINEA_FC			INT
		DECLARE @C_EXITOSA						CHAR(1)
		DECLARE @ERROR							NVARCHAR(MAX) 

		
		/* VARIABLE TEMPORAL MAYOR */

		DECLARE @TEMP_CTA_CXC						AS VARCHAR(25)
		DECLARE @TEMP_CTR_CXC						AS VARCHAR(25)
		DECLARE @TEMP_CENTRO_COSTO					AS VARCHAR(25)
		DECLARE @TEMP_CUENTA_CONTABLE				AS VARCHAR(25)
		DECLARE @TEMP_C_COSTO_VENTA					AS VARCHAR(25)
		DECLARE @TEMP_CTA_DESC_LINEA_LOC			AS VARCHAR(25)
		DECLARE @TEMP_C_COSTO_CONTADO_CREDITO		AS VARCHAR(25)
		DECLARE @TEMP_CTA_CONTADO					AS VARCHAR(25)
		


		--- VARIABLES PARA ITERACION DE LINEAS DE FORMA DE PAGO

		DECLARE @I					AS	INT
		SET @I = 1
		DECLARE @Id_NC				AS	INT
		
	BEGIN TRY
		BEGIN TRANSACTION


			/*---------------------------------------------*/
			 --- TABLA TEMPORAL PARA CONSTRUIR DESCUENTO ---
			------------------------------------------------ 

			DECLARE @FACTURA_DESCUENTO AS TABLE(
			ID INT IDENTITY(1,1)	PRIMARY KEY,			
			FACTURA					VARCHAR(50),
			CLIENTE					VARCHAR(20),
			ARTICULO				VARCHAR(20),
			CANTIDAD				DECIMAL(28,8),
			PRECIO_UNITARIO			DECIMAL(28,8),
			PORC					DECIMAL(28,8),
			MONTO					DECIMAL(28,8),
			Id_UH					VARCHAR(20),
			C_COSTO_VENTAS			VARCHAR(25),
			C_COSTO_DESC_TOT_LINEA	VARCHAR(25),
			C_COSTO_CONTADO_CREDITO	VARCHAR(25),
			CTA_CONTADO				VARCHAR(25),
			CTA_CXC					VARCHAR(25))
		
			
					INSERT INTO @FACTURA_DESCUENTO
					
						(FACTURA,
						CLIENTE,
						ARTICULO,
						CANTIDAD,
						PRECIO_UNITARIO,
						PORC,
						MONTO,
						Id_UH,
						C_COSTO_VENTAS,
						C_COSTO_DESC_TOT_LINEA,
						C_COSTO_CONTADO_CREDITO,CTA_CONTADO,CTA_CXC)

						SELECT 
							F.FACTURA,
							F.CLIENTE, 
							FL.ARTICULO,
							FL.CANTIDAD,
							FL.PRECIO_UNITARIO, 
							ISNULL(ED.PORC,0), 
							ROUND(ISNULL(CONVERT(DECIMAL(28,8),(((FL.CANTIDAD * FL.PRECIO_UNITARIO)* ED.PORC)/100)),0),2) AS MONTO,
							ED.Id_UH,
							CC.C_COSTO_VENTA,
							CT.CTA_DESC_LINEA_LOC,
							CC.C_COSTO_CONTADO_CREDITO,
							P0.CTA_CONTADO,
							P0.CTA_CXC

						FROM AHPF_HN.ASHPF.FACTURA_LINEA AS FL

						INNER JOIN AHPF_HN.ASHPF.FACTURA	AS F ON F.FACTURA = FL.FACTURA
						LEFT JOIN 	H1_AHPF_HN.dbo.UT_ESQUEMA_DESCUENTOS AS ED ON 
						CONVERT(VARCHAR(20),ED.ARTICULO) COLLATE SQL_Latin1_General_CP850_CI_AS= FL.ARTICULO AND 
						CONVERT(VARCHAR(20),ED.CLIENTE) = F.CLIENTE COLLATE SQL_Latin1_General_CP850_CI_AS
						LEFT JOIN AHPF_HN.ASHPF.ARTICULO AS A ON A.ARTICULO  = FL.ARTICULO
						INNER JOIN	H1_AHPF_HN.dbo.UT_CC AS CC ON CC.ARTICULO_CUENTA COLLATE SQL_Latin1_General_CP850_CI_AS = A.ARTICULO_CUENTA AND CC.Id_UH= ED.Id_UH
						INNER JOIN	H1_AHPF_HN.dbo.UT_CCA AS CT ON CT.ARTICULO_CUENTA = CC.ARTICULO_CUENTA
						INNER JOIN AHPF_HN.ASHPF.PAIS AS P0 ON P0.PAIS = F.PAIS

						WHERE FL.FACTURA =@FACTURA AND ED.Id_UH=@Id_UH

						ORDER BY F.FACTURA



					SET @TEMP_Pago = (SELECT SUM(ISNULL(MONTO,0)) FROM @FACTURA_DESCUENTO)

					IF @TEMP_Pago > 0
					BEGIN

							/*--------------------------------------------------------------------------------------------*/
							 -- CONSTRUCCION DE NOTA DE CREDITO PARA LA APLICACION AUTOMATICA A DE CXC A LA ASEGURADORA  --
							-----------------------------------------------------------------------------------------------
	
						
	  						SET @DOCUMENTO			= (SELECT ((ULTIMO_VALOR) + 1)			FROM AHPF_HN.ASHPF.CONSECUTIVO AS C	WITH(UPDLOCK)	WHERE C.CONSECUTIVO = 'NC')							
							SET @Id_Corp			= (SELECT Id_PT							FROM H1_AHPF_HN.dbo.FC		WITH(NOLOCK)	WHERE UDF_Factura_E=@FACTURA)					
							SET @TEMP_Nombre_Corp	= (SELECT UPPER(NOMBRE)					FROM AHPF_HN.ASHPF.CLIENTE			WITH(NOLOCK)	WHERE CLIENTE=@Id_Corp)
							SET @TEMP_Paciente		= (SELECT UPPER(UDF_Nombre_Paciente)	FROM H1_AHPF_HN.dbo.FC		WITH(NOLOCK)	WHERE UDF_Factura_E = @FACTURA)
							SET @Id_FC				= (SELECT Id_FC							FROM H1_AHPF_HN.dbo.FC		WITH(NOLOCK)	WHERE UDF_Factura_E=@FACTURA)
							SET @TEMP_Usuario_Registro	= (SELECT Usuario_Registro			FROM H1_AHPF_HN.dbo.FC		WITH(NOLOCK)	WHERE UDF_Factura_E=@FACTURA)


									SET @TEMP_Notas		 = 
									'CARGO POR DESCUENTO ASEGURADORA SEGÚN CONVENIO, CÓDIGO: ' + '  ' + @Id_Corp  + '  ' + 
									'NOMBRE:' + '  ' + @TEMP_Nombre_Corp + '  ' + 
									'PACIENTE :' + '  ' + @TEMP_Paciente + '  ' + 'FAC#:' + '  ' + @FACTURA

									SET @TEMP_Aplicacion = 
									'CARGO POR DESCUENTO ASEGURADORA SEGÚN CONVENIO, CÓDIGO: ' + '  ' + @Id_Corp  + '  ' + 
									'NOMBRE:' + '  ' + @TEMP_Nombre_Corp + '  ' + 
									'PACIENTE :' + '  ' + @TEMP_Paciente + '  ' + 'FAC#:' + '  ' + @FACTURA

									SET @FECHA = (SELECT DATEADD(dd, DATEDIFF(dd, 0, CURRENT_TIMESTAMP), 0))					


							
							/*---------------------------------------------*/
								  --- REGISTRO DE DOCUMENTO A CXC ---
							-------------------------------------------------

							

							INSERT INTO AHPF_HN.ASHPF.DOCUMENTOS_CC 
							(DOCUMENTO,TIPO,APLICACION,FECHA_DOCUMENTO,FECHA,MONTO,SALDO,MONTO_LOCAL,SALDO_LOCAL,MONTO_DOLAR,SALDO_DOLAR,
							MONTO_CLIENTE,SALDO_CLIENTE,TIPO_CAMBIO_MONEDA,TIPO_CAMBIO_DOLAR,TIPO_CAMBIO_CLIENT,TIPO_CAMB_ACT_LOC,TIPO_CAMB_ACT_DOL,
							TIPO_CAMB_ACT_CLI,SUBTOTAL,DESCUENTO,IMPUESTO1,IMPUESTO2,RUBRO1,RUBRO2,MONTO_RETENCION,SALDO_RETENCION,DEPENDIENTE,
							FECHA_ULT_CREDITO,CARGADO_DE_FACT,APROBADO,ASIENTO_PENDIENTE,FECHA_ULT_MOD,NOTAS,CLASE_DOCUMENTO,FECHA_VENCE,NUM_PARCIALIDADES,
							COBRADOR,USUARIO_ULT_MOD,CONDICION_PAGO,MONEDA,VENDEDOR,CLIENTE_REPORTE,CLIENTE_ORIGEN,CLIENTE,SUBTIPO,
							PORC_INTCTE,NoteExistsFlag,RecordDate,RowPointer,CreatedBy,UpdatedBy,CreateDate,ANULADO,TIPO_ASIENTO,PAQUETE,FACTURADO,GENERA_DOC_FE,DOC_DOC_ORIGEN)

							VALUES
							(@DOCUMENTO,'N/C',@TEMP_Aplicacion,@FECHA,@FECHA,@TEMP_Pago,@TEMP_Pago,@TEMP_Pago,@TEMP_Pago,0.00000000,0.00000000,
							@TEMP_Pago,@TEMP_Pago,1.00000000,0.00000000,1.00000000,1.00000000,0.00000000,
							1.00000000,@TEMP_Pago,0.00000000,0.00000000,0.00000000,0.00000000,0.00000000,0.00000000,0.00000000,'N',
							GETDATE(),'N','S','N',GETDATE(),@TEMP_Notas,'N',GETDATE(),0,
							'ND',@TEMP_Usuario_Registro,'002','LPS','ND',@Id_Corp,@Id_Corp,@Id_Corp,0,
							0.00000000,0,GETDATE(),NEWID(),@TEMP_Usuario_Registro,@TEMP_Usuario_Registro,GETDATE(),'N','NCRE','CC1','N','N',@FACTURA)
		

									UPDATE  AHPF_HN.ASHPF.CONSECUTIVO
									SET ULTIMO_VALOR= @DOCUMENTO 
									WHERE CONSECUTIVO = 'NC'

							
									/*---------------------------------*/
									--- ACTUALIZAR SALDO CLIENTE CXC ---
									------------------------------------

									UPDATE 	 AHPF_HN.ASHPF.CLIENTE 
									SET 	
									SALDO			=	SALDO			-	@TEMP_Pago, 
									SALDO_LOCAL		=	SALDO_LOCAL		-	@TEMP_Pago
									WHERE CLIENTE=@Id_Corp

									UPDATE	AHPF_HN.ASHPF.SALDO_CLIENTE  
									SET	
									SALDO = SALDO - @TEMP_Pago,
									FECHA_ULT_MOV=GETDATE()          
									WHERE	CLIENTE = @Id_Corp       
									AND 	MONEDA = 'LPS'
									
									
							/*-----------------------------------------------------------------------------------------------------------------*/
							-------------------- OBTENER DIAS NETOS PARA CALCULAR FECHA DE VENCIMIENTO DEL DOCUMENTO ---------------------------
							--------------------------------------------------------------------------------------------------------------------


							IF @Id_Corp != 'SIGH000015232'
							BEGIN

								SET @DIAS_NETO		=( SELECT [AHPF_HN].[ASHPF].[GET_DIASNETOS](@FACTURA))
								SET @FECHA_VENCE_T	=( SELECT [AHPF_HN].[ASHPF].[GET_FECHAVENCE_CC](@FACTURA,@DIAS_NETO))

								UPDATE AHPF_HN.ASHPF.DOCUMENTOS_CC
								SET FECHA_VENCE =	@FECHA_VENCE_T
								WHERE DOCUMENTO =	@FACTURA
							END 

							IF @Id_Corp = 'SIGH000015232'
							BEGIN

								UPDATE AHPF_HN.ASHPF.DOCUMENTOS_CC
								SET FECHA_VENCE =	(SELECT  DATEADD(DAY,0,GETDATE()))
								WHERE DOCUMENTO =	@DOCUMENTO
							END 
											
					END


							/*-----------------------------------------------------------------------------------------------------------------*/
																	--- REGISTRO ASIENTO PARA N/C ---
							---------------------------------------------------------------------------------------------------------------------
		
							
									/*---------------------------------------------------------------*/
														--- REGISTRO DEL PROCESO ---
									-------------------------------------------------------------------

									SET @TEMP_MAYOR_AUDITORIA		= (SELECT (MAX(MAYOR_AUDITORIA) + 1)	FROM AHPF_HN.ASHPF.MAYOR_AUDITORIA WITH(UPDLOCK))
									SET @TEMP_NOMBRE				= (SELECT NOMBRE						FROM AHPF_HN.ASHPF.CLIENTE WHERE CLIENTE =@Id_Corp)
									SET @TEMP_COMENTARIO			= (SELECT Nombre						FROM H1_AHPF_HN.dbo.UH WITH(UPDLOCK) WHERE Id_UH = @Id_UH)
									SET @TEMP_CLINICA_H1			= ('Corporacion :' + ' ' + @Id_Corp + ' ' + 'Nombre :' + ' ' + @TEMP_Nombre_Corp + ' ' + 'Origen :' + ' ' + 
									(SELECT Nombre FROM H1_AHPF_HN.dbo.UH WHERE Id_UH = @Id_UH) + ' ' + 'Paciente:' + ' ' + UPPER(@TEMP_Paciente) + ' ' + 'Factura :' + ' ' + @FACTURA)
									SET @TEMP_Usuario_Registro	= (SELECT Usuario_Registro			FROM H1_AHPF_HN.dbo.FC		WITH(NOLOCK)	WHERE UDF_Factura_E=@FACTURA)

									INSERT INTO AHPF_HN.ASHPF.MAYOR_AUDITORIA
									(MAYOR_AUDITORIA,USUARIO,FECHA,COMENTARIO,NoteExistsFlag,RecordDate,RowPointer,CreatedBy,UpdatedBy,CreateDate)
								

									VALUES
									(@TEMP_MAYOR_AUDITORIA,@TEMP_Usuario_Registro,GETDATE(),'INGRESO CLÍNICA:' + ' ' + @TEMP_COMENTARIO ,0,GETDATE(),NEWID(),@TEMP_Usuario_Registro,@TEMP_Usuario_Registro,GETDATE())


									/*------------------------------------------------------------------------*/
									--- ---
									----------------------------------------------------------------------------

									DECLARE @DOC_DOC_O AS INT

									SET @DOC_DOC_O =(SELECT ISNULL(COUNT(*),0)  FROM ASHPF.DOCUMENTOS_CC WHERE DOC_DOC_ORIGEN=@FACTURA)

									IF @DOC_DOC_O > 0

									BEGIN
							
											/*----------------------------------------------------------------*/
														--- OBTERNER NUMERO DE ASIENTO CXC ---
											--------------------------------------------------------------------

												DECLARE @SerieB AS VARCHAR(10)

												EXECUTE AHPF_HN.ASHPF.GET_CXC 'CC1', @SerieB OUTPUT

												SET @ASIENTO_CXC	= @SerieB
			
							
											/*----------------------------------------------------------------*/
														--- REGISTRO  ENCABEZADO  MAYOR ---
											--------------------------------------------------------------------
			
												INSERT INTO AHPF_HN.ASHPF.ASIENTO_MAYORIZADO
												(ASIENTO,MAYOR_AUDITORIA,TIPO_ASIENTO,FECHA,CONTABILIDAD,ORIGEN,CLASE_ASIENTO,ULTIMO_USUARIO,FECHA_ULT_MODIF
												,MONTO_TOTAL_LOCAL,MONTO_TOTAL_DOLAR,NOTAS,USUARIO_CREACION,FECHA_CREACION,EXPORTADO,TIPO_INGRESO_MAYOR
												,NoteExistsFlag,RecordDate,RowPointer,CreatedBy,UpdatedBy,CreateDate)

												VALUES
												(@ASIENTO_CXC,@TEMP_MAYOR_AUDITORIA,'PING',(SELECT DATEADD(dd, DATEDIFF(dd, 0, CURRENT_TIMESTAMP), 0)),'A','CXC','N',@TEMP_Usuario_Registro,GETDATE(),
												ISNULL(@TEMP_Pago,0),0,@TEMP_CLINICA_H1,@TEMP_Usuario_Registro,GETDATE(),'N','N',
												0,GETDATE(),NEWID(),@TEMP_Usuario_Registro,@TEMP_Usuario_Registro,GETDATE()) 

									END

												/*---------------------------------------------------------------*/
														--- ACTUALIZAR CAMPO ASIENTO EN DOCUMENTO N/C ---
												-------------------------------------------------------------------

												UPDATE AHPF_HN.ASHPF.DOCUMENTOS_CC
												SET ASIENTO=@ASIENTO_CXC
												WHERE DOC_DOC_ORIGEN=@FACTURA AND DOCUMENTO=@DOCUMENTO


												/*---------------------------------------------------------------*/
															--- REGISTRAR LINEAS DE ASIENTO ---
												-------------------------------------------------------------------
												

												SELECT @Id_NC= COUNT(*) FROM @FACTURA_DESCUENTO
												SET @RowPointer=NEWID()
									

												/*-----------------------------------------------------------*/
																--- ITERACION LINEAS  ---
												---------------------------------------------------------------

												WHILE @I <= @Id_NC
												BEGIN 

													SELECT 

														@TEMP_Pago						=NC.MONTO,
														@TEMP_CENTRO_COSTO				=NC.C_COSTO_VENTAS,
														@TEMP_CTA_DESC_LINEA_LOC		=NC.C_COSTO_DESC_TOT_LINEA,
														@TEMP_C_COSTO_CONTADO_CREDITO	=NC.C_COSTO_CONTADO_CREDITO,
														@TEMP_CTA_CONTADO				=NC.CTA_CONTADO,
														@TEMP_CTA_CXC					=NC.CTA_CXC
														

													FROM @FACTURA_DESCUENTO AS NC WHERE NC.ID = @I
																	
													/*---------------------------------------------------*/
														--- LINEA DE ASIENTO PARA EL DESCUENTO ---
													------------------------------------------------------ 									
														SET @TEMP_NUMERO_LINEA_FC = ISNULL(MAX(ISNULL(@TEMP_NUMERO_LINEA_FC,0)) ,0)+1 

														EXEC AHPF_HN.ASHPF.sP_INSERT_FACTURA_MAYOR_H1_NC
															@RowPointer,
															@ASIENTO_CXC,
															@TEMP_NUMERO_LINEA_FC,
															@TEMP_CTA_DESC_LINEA_LOC,
															@TEMP_CENTRO_COSTO,
															@FACTURA,
															@DOCUMENTO,
															'N',
															@TEMP_Pago,
															'D',
															'S',
															@ERROR OUTPUT
				
											
															IF @C_EXITOSA = 'N'
															BEGIN
																RAISERROR(@ERROR, 16,1,1)				
															END



													SET @I = @I + 1
											   END


											   /*---------------------------------------------------*/
													--- LINEA DE ASIENTO PARA EL CREDITO ---
												------------------------------------------------------ 	

														
														SET @TEMP_Pago = (SELECT SUM(ISNULL(MONTO,0)) FROM @FACTURA_DESCUENTO)

														SET @TEMP_NUMERO_LINEA_FC = @TEMP_NUMERO_LINEA_FC +1 

											   			EXEC AHPF_HN.ASHPF.sP_INSERT_FACTURA_MAYOR_H1_NC
															@RowPointer,
															@ASIENTO_CXC,
															@TEMP_NUMERO_LINEA_FC,
															@TEMP_CTA_CXC,
															@TEMP_C_COSTO_CONTADO_CREDITO,
															@FACTURA,
															@DOCUMENTO,
															'N',
															@TEMP_Pago,
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
			ROLLBACK TRANSACTION;
		END
			PRINT ERROR_MESSAGE();
			THROW 50001, 'Ha ocurrido un error, la transacción ha sido cancelada.',0;
			EXECUTE AHPF_HN.ASHPF.Sp_LogError;
			
	
	END CATCH 

END