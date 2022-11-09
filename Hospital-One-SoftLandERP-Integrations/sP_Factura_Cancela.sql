USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_Factura_Cancela]    Script Date: 11/9/2022 3:38:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [ASHPF].[sP_Factura_Cancela]
	-- Add the parameters for the stored procedure here
	@Id_FC			INT
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE	@TIPO_DOCUMENTO				VARCHAR(1)
	DECLARE @FACTURA					VARCHAR(50)
	DECLARE	@NUMERO_PAGO				INT
	DECLARE	@TIPO						VARCHAR(1)
	DECLARE	@MONTO						DECIMAL(28,8)
	DECLARE @MONEDA						VARCHAR(1)
	DECLARE @NUM_DOCUMENTO				VARCHAR(20)
	DECLARE @ENTIDAD_FINANCIERA			VARCHAR(8)
	DECLARE @TIPO_TARJETA				VARCHAR(12)
	DECLARE @NUM_AUTORIZA				VARCHAR(20)
	DECLARE @USUARIO					VARCHAR(25)
	DECLARE @CAJA						VARCHAR(10)
	DECLARE @FECHA_HORA					DATETIME
	DECLARE @DEVOLUCION					VARCHAR(50)
	DECLARE @NoteExistsFlag				TINYINT
	DECLARE @RecordDate					DATETIME
	DECLARE @RowPointer					UNIQUEIDENTIFIER
	DECLARE @CreatedBy					VARCHAR(30)
	DECLARE @UpdatedBy					VARCHAR(30)
	DECLARE @NUM_APERTURA				INT
	DECLARE @N_PAGO                     INT
	DECLARE @RowPointer_FCPG			UNIQUEIDENTIFIER
	DECLARE @LINEA_C					INT		
	DECLARE @Id_FCPG					INT
	
	/*-----------------------------------------------------*/
		--- VARIABLES PARA ITERACION DE LINEAS FCPG ---
	---------------------------------------------------------

	DECLARE @E					AS	INT
		SET @E = 1
	DECLARE	@Id_FCPG_			AS	INT

	BEGIN TRY
		BEGIN TRANSACTION;


				/*----------------------------------------------------------------------*/
								--- CARGA DE LINEAS DETALLE LINEAS FCPG ---
				-------------------------------------------------------------------------

					DECLARE @FACTURA_CANCELA AS TABLE(
					ID INT IDENTITY(1,1) PRIMARY KEY,
					TIPO_DOCUMENTO				VARCHAR(1),
					FACTURA						VARCHAR(50),
					NUMERO_PAGO					INT,
					TIPO						VARCHAR(1),
					MONTO						DECIMAL(28,8),
					MONEDA						VARCHAR(1),
					NUM_DOCUMENTO				VARCHAR(20),
					ENTIDAD_FINANCIERA			VARCHAR(8),
					TIPO_TARJETA				VARCHAR(12),
					NUM_AUTORIZA				VARCHAR(20),
					USUARIO						VARCHAR(25),
					CAJA						VARCHAR(10),
					FECHA_HORA					DATETIME,
					DEVOLUCION					VARCHAR(50),
					NoteExistsFlag				TINYINT,
					RecordDate					DATETIME,
					RowPointer					UNIQUEIDENTIFIER,
					CreatedBy					VARCHAR(30),
					UpdatedBy					VARCHAR(30),
					NUM_APERTURA				INT,					
					N_PAGO						INT,
					Id_FCPG						INT
					)


			/*------------------------------------------------------------------------*/
			----------------------------------------------------------------------------

			INSERT INTO @FACTURA_CANCELA
			(TIPO_DOCUMENTO,FACTURA,NUMERO_PAGO,TIPO,MONTO,					
			MONEDA,NUM_DOCUMENTO,ENTIDAD_FINANCIERA,TIPO_TARJETA,NUM_AUTORIZA,				
			USUARIO,CAJA,FECHA_HORA,DEVOLUCION,NoteExistsFlag,				
			RecordDate,RowPointer,CreatedBy,UpdatedBy,NUM_APERTURA,N_PAGO,Id_FCPG)


						SELECT	'F' AS TIPO_DOCUMENTO,
								F.UDF_Factura_E AS FACTURA,
								0 AS NUMERO_PAGO,
								CASE WHEN FP.TipoPago='CC' THEN 'X' ELSE FP.TipoPago END AS TIPO,
								FP.Pago AS MONTO,
								FP.UDF_MONEDA AS MONEDA,
								CASE WHEN FP.TipoPago='T' THEN UDF_NUM_DOCUMENTO END AS NUM_DOCUMENTO,
								FP.EntidadFinanciera AS ENTIDAD_FINANCIERA,
								FP.TC AS TIPO_TARJETA,
								CASE WHEN FP.TipoPago='T' THEN UDF_Id_POS END NUM_AUTORIZA,
								FP.Usuario_Registro AS USUARIO,
								F.Caja AS CAJA,
								FP.Fecha_Registro AS FECHA_HORA,
								'0' AS DEVOLUCION,
								0 AS NoteExistsFlag,
								FP.Fecha_Registro AS RecordDate,
								NEWID() AS RowPointer,
								FP.Usuario_Registro AS CreatedBy,
								FP.Usuario_Modificacion AS UpdatedBy,
								F.UDF_NUM_APERTURA AS NUM_APERTURA,
								FP.UDF_N_PAGO AS PAGO,
								FP.Id_FCPG

						FROM H1_AHPF_HN.dbo.FCPG AS FP WITH(NOLOCK)
							INNER JOIN H1_AHPF_HN.dbo.FC	AS F ON F.Id_FC = FP.Id_FC
						WHERE FP.Id_FC=@Id_FC AND FP.UDF_N_PAGO IS NULL

						UNION

						SELECT 'F' AS TIPO_DOCUMENTO,
								F.UDF_Factura_E AS FACTURA,
								0 AS NUMERO_PAGO,
								'D',
								FP.UDF_VUELTOS AS MONTO,
								FP.UDF_MONEDA AS MONEDA,								
								CASE WHEN FP.TipoPago='T' THEN UDF_NUM_DOCUMENTO 
								END AS NUM_DOCUMENTO,
								FP.EntidadFinanciera AS ENTIDAD_FINANCIERA,
								FP.TC AS TIPO_TARJETA,								
								CASE WHEN FP.TipoPago='T' THEN UDF_Id_POS END NUM_AUTORIZA,
								FP.Usuario_Registro AS USUARIO,
								F.Caja AS CAJA,
								FP.Fecha_Registro AS FECHA_HORA,
								'0' AS DEVOLUCION,
								0 AS NoteExistsFlag,
								FP.Fecha_Registro AS RecordDate,
								NEWID() AS RowPointer,
								FP.Usuario_Registro AS CreatedBy,
								FP.Usuario_Modificacion AS UpdatedBy,								
								F.UDF_NUM_APERTURA AS NUM_APERTURA,
								FP.UDF_N_PAGO AS PAGO,
								FP.Id_FCPG

						FROM H1_AHPF_HN.dbo.FCPG AS FP WITH(NOLOCK)
							INNER JOIN H1_AHPF_HN.dbo.FC	AS F ON F.Id_FC = FP.Id_FC
						WHERE FP.Id_FC=@Id_FC AND FP.UDF_VUELTOS>0 AND FP.UDF_N_PAGO IS NULL

						/*---------------------------------------------------------------*/
							--- INICIA EL PROCESO DE INSERCION LINEA FACTURA CANCELA ---
						-------------------------------------------------------------------
	
						SELECT @Id_FCPG_ = COUNT(*) FROM @FACTURA_CANCELA

						WHILE @E <= @Id_FCPG_
						

								BEGIN															
									
									SET  @LINEA_C	= ISNULL(MAX(ISNULL(@LINEA_C, 0)),0)+1
									SELECT 

										@TIPO_DOCUMENTO					= FC.TIPO_DOCUMENTO,			
										@FACTURA						= FC.FACTURA,				
										@NUMERO_PAGO					= @LINEA_C,
										@TIPO							= FC.TIPO,						
										@MONTO							= FC.MONTO,
										@MONEDA							= FC.MONEDA,
										@NUM_DOCUMENTO					= FC.NUM_DOCUMENTO,
										@ENTIDAD_FINANCIERA				= FC.ENTIDAD_FINANCIERA,
										@TIPO_TARJETA					= FC.TIPO_TARJETA,
										@NUM_AUTORIZA					= FC.NUM_AUTORIZA,
										@USUARIO						= FC.CreatedBy,
										@CAJA							= FC.CAJA,
										@FECHA_HORA						= FC.FECHA_HORA,
										@DEVOLUCION						= FC.DEVOLUCION,
										@NoteExistsFlag					= FC.NoteExistsFlag,
										@RecordDate						= FC.RecordDate,
										@RowPointer						= FC.RowPointer,
										@CreatedBy						= FC.CreatedBy,
										@UpdatedBy						= FC.UpdatedBy,
										@NUM_APERTURA					= FC.NUM_APERTURA,
										@N_PAGO							= FC.N_PAGO,
										@Id_FCPG						= FC.Id_FCPG


									FROM @FACTURA_CANCELA AS FC WHERE FC.ID = @E

									EXEC erpadmin.GrabarUsuarioActual @CreatedBy
									EXEC erpadmin.LeerUsuarioActual @CreatedBy


									INSERT INTO AHPF_HN.ASHPF.FACTURA_CANCELA
									(TIPO_DOCUMENTO,FACTURA,NUMERO_PAGO,TIPO,MONTO,					
									MONEDA,NUM_DOCUMENTO,ENTIDAD_FINANCIERA,TIPO_TARJETA,NUM_AUTORIZA,				
									USUARIO,CAJA,FECHA_HORA,DEVOLUCION,NoteExistsFlag,				
									RecordDate,RowPointer,CreatedBy,UpdatedBy,NUM_APERTURA)

									VALUES
									(@TIPO_DOCUMENTO,@FACTURA,@LINEA_C,@TIPO,@MONTO,					
									@MONEDA,@NUM_DOCUMENTO,@ENTIDAD_FINANCIERA,@TIPO_TARJETA,@NUM_AUTORIZA,				
									@USUARIO,@CAJA,@FECHA_HORA,@DEVOLUCION,@NoteExistsFlag,				
									@RecordDate,@RowPointer,@USUARIO,@USUARIO,@NUM_APERTURA)

											/*---------------------------------------*/
												--- ACTUALIZAR RowPointer FCPG ---
											------------------------------------------																			

											UPDATE H1_AHPF_HN.dbo.FCPG

												SET UDF_RowPointer = @RowPointer

											WHERE Id_FC = @Id_FC AND Id_FCPG = @Id_FCPG

											--------------------------------------------

														
								SET @E = @E + 1
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

