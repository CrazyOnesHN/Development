USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_DOCUMENTO_CC_REC_POS]    Script Date: 11/9/2022 3:36:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER  PROCEDURE [ASHPF].[sP_DOCUMENTO_CC_REC_POS]
	-- Add the parameters for the stored procedure here
	@Id_FC						AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
		DECLARE @DOCUMENTO							AS NVARCHAR(50)
		DECLARE @FACTURA							AS NVARCHAR(50)
		DECLARE @TIPO								AS VARCHAR(3)
		DECLARE @APLICACION							AS VARCHAR(249)
		DECLARE @FECHA_DOCUMENTO					AS DATETIME
		DECLARE @FECHA								AS DATETIME
		DECLARE @MONTO								AS DECIMAL(28,8)
		DECLARE @SALDO								AS DECIMAL(28,8)
		DECLARE @MONTO_LOCAL						AS DECIMAL(28,8)
		DECLARE @SALDO_LOCAL						AS DECIMAL(28,8)
		DECLARE @MONTO_DOLAR						AS DECIMAL(28,8)
		DECLARE @SALDO_DOLAR						AS DECIMAL(28,8)
		DECLARE @MONTO_CLIENTE						AS DECIMAL(28,8)
		DECLARE @SALDO_CLIENTE						AS DECIMAL(28,8)
		DECLARE @TIPO_CAMBIO_MONEDA					AS DECIMAL(28,8)
		DECLARE @TIPO_CAMBIO_DOLAR					AS DECIMAL(28,8)
		DECLARE @TIPO_CAMBIO_CLIENT					AS DECIMAL(28,8)
		DECLARE @TIPO_CAMB_ACT_LOC					AS DECIMAL(28,8)
		DECLARE @TIPO_CAMB_ACT_DOL					AS DECIMAL(28,8)
		DECLARE @TIPO_CAMB_ACT_CLI					AS DECIMAL(28,8)
		DECLARE @SUBTOTAL							AS DECIMAL(28,8)
		DECLARE @DESCUENTO							AS DECIMAL(28,8)
		DECLARE @IMPUESTO1							AS DECIMAL(28,8)
		DECLARE @IMPUESTO2							AS DECIMAL(28,8)
		DECLARE @RUBRO1								AS DECIMAL(28,8)
		DECLARE @RUBRO2								AS DECIMAL(28,8)
		DECLARE @MONTO_RETENCION					AS DECIMAL(28,8)
		DECLARE @SALDO_RETENCION					AS DECIMAL(28,8)
		DECLARE @DEPENDIENTE						AS VARCHAR(1)
		DECLARE @FECHA_ULT_CREDITO					AS DATETIME
		DECLARE @CARGADO_DE_FACT					AS VARCHAR(1)
		DECLARE @APROBADO							AS VARCHAR(1)
		DECLARE @ASIENTO_PENDIENTE					AS VARCHAR(1)
		DECLARE @FECHA_ULT_MOD						AS DATETIME
		DECLARE @NOTAS								AS VARCHAR(MAX)
		DECLARE @CLASE_DOCUMENTO					AS VARCHAR(1)
		DECLARE @FECHA_VENCE						AS DATETIME
		DECLARE @NUM_PARCIALIDADES					AS SMALLINT
		DECLARE @COBRADOR							AS VARCHAR(4)
		DECLARE @USUARIO_ULT_MOD					AS VARCHAR(25)
		DECLARE @CONDICION_PAGO						AS VARCHAR(4)
		DECLARE @MONEDA								AS VARCHAR(4)
		DECLARE @VENDEDOR							AS VARCHAR(4)
		DECLARE @CLIENTE_REPORTE					AS VARCHAR(20)
		DECLARE @CLIENTE_ORIGEN						AS VARCHAR(20)
		DECLARE @CLIENTE							AS VARCHAR(20)
		DECLARE @SUBTIPO							AS SMALLINT
		DECLARE @PORC_INTCTE						AS DECIMAL(28,8)
		DECLARE @NoteExistsFlag						AS TINYINT
		DECLARE @RecordDate							AS DATETIME
		DECLARE @RowPointer							AS UNIQUEIDENTIFIER
		DECLARE @CreatedBy							AS VARCHAR(30)
		DECLARE @UpdatedBy							AS VARCHAR(30)
		DECLARE @CreateDate							AS DATETIME
		DECLARE @ANULADO							AS VARCHAR(1) 		
		DECLARE @TIPO_ASIENTO						AS VARCHAR(4) 	
		DECLARE @PAQUETE							AS VARCHAR(4)
		DECLARE @FACTURADO							AS VARCHAR(1)
		DECLARE @GENERA_DOC_FE						AS VARCHAR(1)
		DECLARE @DIAS_NETO							AS INT
		DECLARE @FECHA_VENCE_T						DATETIME
		DECLARE @Id_Corp							VARCHAR(150)
		
		------------ VARIABLES FCPG --------------------

		
		DECLARE @TEMP_Id_FC						INT
		DECLARE @TEMP_TipoPago					NVARCHAR(20)
		DECLARE @TEMP_Pago						DECIMAL(28,8)
		DECLARE @TEMP_Caja						NVARCHAR(50)
		DECLARE @TEMP_CajaDescripcion			NVARCHAR(120)
		DECLARE @TEMP_Recibo					NVARCHAR(50)
		DECLARE @TEMP_Factura					NVARCHAR(50)
		DECLARE @TEMP_Id_POS					NVARCHAR(50)

		DECLARE @TEMP_Notas						NVARCHAR(MAX)
		DECLARE @TEMP_Aplicacion				VARCHAR(249)
		DECLARE @TEMP_Usuario_Registro			NVARCHAR(256)
		DECLARE @TEMP_Id_PT						NVARCHAR(15)
		DECLARE @TipoPago						NVARCHAR(20)
		DECLARE @TEMP_Paciente					NVARCHAR(250)
		DECLARE @TEMP_Nombre_Corp				VARCHAR(150)


		--- VARIABLES PARA ITERACION DE LINEAS DE FORMA DE PAGO

		DECLARE @I					AS	INT
		SET @I = 1
		DECLARE @Id_FCPG		AS	INT
		
	BEGIN TRY
		BEGIN TRANSACTION

			--- TABLA TEMPORAL CON LAS FORMAS DE PAGO 

			DECLARE @FORMA_FCPG AS TABLE(
			ID INT IDENTITY(1,1) PRIMARY KEY,
			Id_FC					INT,
			Pago					DECIMAL(28,8),
			CajaDescripcion			NVARCHAR(120),
			Caja					NVARCHAR(50),
			Recibo					NVARCHAR(50),
			Factura					NVARCHAR(50),
			Id_POS					NVARCHAR(50),
			Usuario_Registro		NVARCHAR(256),
			Id_PT					NVARCHAR(15),
			TipoPago 				NVARCHAR(20),
			Paciente				NVARCHAR(250)
			)

		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			--- OBTENER REGISTRO DE LA FORMA DE PAGO EN TARJETA PARA REALIZAR EL DEBITO A CREDOMATIC O BANPAIS ---
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		INSERT INTO @FORMA_FCPG
		(Id_FC,Pago,CajaDescripcion,Caja,Recibo,Factura,Id_POS,Usuario_Registro,Id_PT,TipoPago,Paciente)

				SELECT 
			 
				F0.Id_FC,
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
				WHERE F0.Id_FC = @Id_FC AND F0.TipoPago='T'



		-----------------------------------------------
			--- OBTENER NUMERO DE DOCUMENTO ---
		-----------------------------------------------
		
		SELECT @Id_FCPG = COUNT(*) FROM @FORMA_FCPG
		
		WHILE @I <= @Id_FCPG
		BEGIN 
		
				SELECT 
					@TEMP_Id_FC						=	LP.Id_FC,
					@TEMP_Pago						=	LP.Pago, 
					@TEMP_CajaDescripcion		=	UPPER(LP.CajaDescripcion),     
					@TEMP_Caja						=	LP.Caja,
					@TEMP_Recibo					=	LP.Recibo,      
					@TEMP_Factura					=	LP.Factura,
					@TEMP_Id_POS					=	LP.Id_POS,
					@TEMP_Usuario_Registro		=	UPPER(LP.Usuario_Registro),
					@TEMP_Id_PT						=	LP.Id_PT,
					@TipoPago							=	LP.TipoPago,
					@TEMP_Paciente					=	LP.Paciente
		
				FROM @FORMA_FCPG AS LP WHERE LP.ID = @I			

						
	  						SET @DOCUMENTO		= (SELECT ((ULTIMO_VALOR) + 1) FROM AHPF_HN.ASHPF.CONSECUTIVO AS C WITH(UPDLOCK) WHERE c.CONSECUTIVO = 'OD')
							SET @FACTURA		= (SELECT UDF_FACTURA_E FROM  H1_AHPF_HN.dbo.FC  WITH(NOLOCK) WHERE Id_FC=@Id_FC)
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
							PORC_INTCTE,NoteExistsFlag,RecordDate,RowPointer,CreatedBy,UpdatedBy,CreateDate,ANULADO,TIPO_ASIENTO,PAQUETE,FACTURADO,GENERA_DOC_FE,DOC_DOC_ORIGEN)

							VALUES
							(@DOCUMENTO,'O/D',@TEMP_Aplicacion, (SELECT DATEADD(dd, DATEDIFF(dd, 0, CURRENT_TIMESTAMP), 0)),
							(SELECT DATEADD(dd, DATEDIFF(dd, 0, CURRENT_TIMESTAMP), 0)),@TEMP_Pago,@TEMP_Pago,@TEMP_Pago,@TEMP_Pago,0.00000000,0.00000000,
							@TEMP_Pago,@TEMP_Pago,1.00000000,0.00000000,1.00000000,1.00000000,0.00000000,
							1.00000000,@TEMP_Pago,0.00000000,0.00000000,0.00000000,0.00000000,0.00000000,0.00000000,0.00000000,'N',
							'1980-01-01 00:00:00.000','N','N','S',GETDATE(),@TEMP_Notas,'N',GETDATE(),0,
							'ND',@TEMP_Usuario_Registro,'002','LPS','ND',@TEMP_Id_PT,@TEMP_Id_PT,@TEMP_Id_PT,158,
							0.00000000,0,GETDATE(),NEWID(),@TEMP_Usuario_Registro,@TEMP_Usuario_Registro,GETDATE(),'N','PING','CC1','N','N',@TEMP_Factura)

							UPDATE  AHPF_HN.ASHPF.CONSECUTIVO
							SET ULTIMO_VALOR= @DOCUMENTO 
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



				SET @I = @I + 1
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