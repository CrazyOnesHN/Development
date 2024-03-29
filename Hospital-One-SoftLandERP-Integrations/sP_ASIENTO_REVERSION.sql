USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_ASIENTO_REVERSION]    Script Date: 11/9/2022 3:30:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [ASHPF].[sP_ASIENTO_REVERSION]
	-- Add the parameters for the stored procedure here
	@ASIENTO					AS VARCHAR(10),
	@USUARIO					AS VARCHAR(30),
	@TEMP_CLIENTE_CORP			AS VARCHAR(20),
	@PAQUETE					AS VARCHAR(4),
	@ASIENTO_R					AS VARCHAR(10) OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	--- VARIABLES PARA ITERACION EN MAYOR

	DECLARE @M						AS	INT
	SET @M = 1
	DECLARE	@Id_M					AS	INT

	--- VARIABLES TEMPORALES PARA GENERAR LA PARTIDA DE REVERSION

	/*VARIABLES ASIENTO_MAYORIZADO*/

	DECLARE @ASIENTO_AM								AS VARCHAR(10)
	DECLARE @MAYOR_AUDITORIA_AM						AS INT
	DECLARE @TIPO_ASIENTO_AM						AS VARCHAR(4)
	DECLARE @FECHA_AM								AS DATETIME
	DECLARE @CONTABILIDAD_AM						AS VARCHAR(1)
	DECLARE @ORIGEN_AM								AS VARCHAR(4)
	DECLARE @CLASE_ASIENTO_AM						AS VARCHAR(1)
	DECLARE @CONSECUTIVO_AM							AS INT
	DECLARE @MONTO_TOTAL_LOCAL_AM					AS DECIMAL(28,8)
	DECLARE @MONTO_TOTAL_DOLAR_AM					AS DECIMAL(28,8)
	DECLARE @NOTAS_AM								AS NVARCHAR(MAX)
	DECLARE @USUARIO_CREACION_AM					AS VARCHAR(25)
	DECLARE @EXPORTADO_AM							AS VARCHAR(1)
	DECLARE @TIPO_INGRESO_MAYOR_AM					AS VARCHAR(1)
	DECLARE @FECHA_CREACION_AM						AS DATETIME
	DECLARE @FECHA_ULT_MODIF_AM						AS DATETIME
	DECLARE @RowPointer_AM							AS UNIQUEIDENTIFIER
	DECLARE @RecordDate_AM							AS DATETIME
	DECLARE @NOTAS_AM_								AS NVARCHAR(MAX)
	DECLARE @NoteExistsFlag_AM						AS TINYINT

	DECLARE @ASIENTO_AM_TEMP						AS VARCHAR(10)
	DECLARE @TEMP_NOMBRE_CLIENTE					AS VARCHAR(150)


	/*VARIABLES MAYOR */

	DECLARE @ASIENTO_M								AS VARCHAR(10)
	DECLARE @CONSECUTIVO_M							AS INT
	DECLARE @NIT_M									AS VARCHAR(20)
	DECLARE @CENTRO_COSTO_M							AS VARCHAR(25)
	DECLARE @CUENTA_CONTABLE_M						AS VARCHAR(25)
	DECLARE @FECHA_M								AS DATETIME
	DECLARE @TIPO_ASIENTO_M							AS VARCHAR(4)
	DECLARE @FUENTE_M								AS VARCHAR(40)
	DECLARE @REFERENCIA_M							AS VARCHAR(249)
	DECLARE @ORIGEN_M								AS VARCHAR(4)
	DECLARE @DEBITO_LOCAL_M							AS DECIMAL(28,8)
	DECLARE @CREDITO_LOCAL_M						AS DECIMAL(28,8)
	DECLARE @CONTABILIDAD_M							AS VARCHAR(1)
	DECLARE @CLASE_ASIENTO_M						AS VARCHAR(1)
	DECLARE @ESTADO_CONS_FISC_M						AS VARCHAR(1)
	DECLARE @ESTADO_CONS_CORP_M						AS VARCHAR(1)
	DECLARE @NoteExistsFlag_M						AS TINYINT
	DECLARE @RecordDate_M							AS DATETIME
	DECLARE @RowPointer_M							AS UNIQUEIDENTIFIER
	DECLARE @CreatedBy_M							AS VARCHAR(30)
	DECLARE @UpdatedBy_M							AS VARCHAR(30)
	DECLARE @CreateDate_M							AS DATETIME
	DECLARE @PROYECTO_M								AS VARCHAR(25)
	DECLARE @FASE_M									AS VARCHAR(25)
	DECLARE @TIPO									AS VARCHAR(1)

    BEGIN TRY
		BEGIN TRANSACTION

					/*TABLA TEMPORAL PARA EXTRAER LINEAS DE ASIENTO PARA GENERAR PARTIDA DE REVERSION*/

							DECLARE @MAYOR AS TABLE(
							ID INT IDENTITY(1,1) PRIMARY KEY,
							ASIENTO_TEMP								 VARCHAR(10),
							CONSECUTIVO_TEMP							 INT,
							NIT_TEMP									 VARCHAR(20),
							CENTRO_COSTO_TEMP							 VARCHAR(25),
							CUENTA_CONTABLE_TEMP						 VARCHAR(25),
							FECHA_TEMP									 DATETIME,
							TIPO_ASIENTO_TEMP							 VARCHAR(4),
							FUENTE_TEMP									 VARCHAR(40),
							REFERENCIA_TEMP						         VARCHAR(249),
							ORIGEN_TEMP									 VARCHAR(4),
							DEBITO_LOCAL_TEMP							 DECIMAL(28,8),
							CREDITO_LOCAL_TEMP							 DECIMAL(28,8),
							CONTABILIDAD_TEMP							 VARCHAR(1),
							CLASE_ASIENTO_TEMP							 VARCHAR(1),
							ESTADO_CONS_FISC_TEMP						 VARCHAR(1),
							ESTADO_CONS_CORP_TEMP						 VARCHAR(1),
							NoteExistsFlag_TEMP							 TINYINT,
							RecordDate_TEMP								 DATETIME,
							RowPointer_TEMP								 UNIQUEIDENTIFIER,
							CreatedBy_TEMP								 VARCHAR(30),
							UpdatedBy_TEMP								 VARCHAR(30),
							CreateDate_TEMP								 DATETIME,
							PROYECTO_TEMP								 VARCHAR(25),
							FASE_TEMP									 VARCHAR(25),
							TIPO_TEMP									 VARCHAR(1))
					---------------------------------------------------------------------------------------------

				/*REGISTRO DEL PROCESO*/

					SET @MAYOR_AUDITORIA_AM		= (SELECT (MAX(MAYOR_AUDITORIA) + 1) FROM AHPF_HN.ASHPF.MAYOR_AUDITORIA)

					INSERT INTO AHPF_HN.ASHPF.MAYOR_AUDITORIA
					(MAYOR_AUDITORIA,USUARIO,FECHA,COMENTARIO,NoteExistsFlag,RecordDate,RowPointer,CreatedBy,UpdatedBy,CreateDate)
							
					VALUES
					(@MAYOR_AUDITORIA_AM,@USUARIO,GETDATE(),'Aprobado desde Cuentas por Cobrar',0,GETDATE(),NEWID(),@USUARIO,@USUARIO,GETDATE())


				/*INSERTAR ENCABEZADO EN MAYOR*/

				IF @PAQUETE = 'CC1'
				BEGIN
					DECLARE @SerieB AS VARCHAR(10)

					EXECUTE AHPF_HN.ASHPF.GET_CXC 'CC1', @SerieB OUTPUT

					SET @ASIENTO_AM_TEMP	= @SerieB
				END	

				IF @PAQUETE = 'F1'
				BEGIN
					
					EXECUTE AHPF_HN.ASHPF.GET_F1 'F1', @SerieB OUTPUT

					SET @ASIENTO_AM_TEMP	= @SerieB
				END



				/*--------------------------------------------------------------------------------------------*/
										--- OBTENER ENCABEZADO DE ASIENTO ---
				------------------------------------------------------------------------------------------------

	
								SELECT
								@ASIENTO_AM									=@ASIENTO_AM_TEMP,
								@MAYOR_AUDITORIA_AM							= MAYOR_AUDITORIA,
								@TIPO_ASIENTO_AM							=TIPO_ASIENTO,
								@FECHA_AM									=(SELECT DATEADD(dd, DATEDIFF(dd, 0, CURRENT_TIMESTAMP), 0)),
								@CONTABILIDAD_AM							=CONTABILIDAD,
								@ORIGEN_AM									=ORIGEN,
								@CLASE_ASIENTO_AM							=CLASE_ASIENTO,
								@USUARIO									=ULTIMO_USUARIO,
								@FECHA_ULT_MODIF_AM							=GETDATE(),
								@MONTO_TOTAL_LOCAL_AM						=MONTO_TOTAL_LOCAL,
								@MONTO_TOTAL_DOLAR_AM						=MONTO_TOTAL_DOLAR,
								@NOTAS_AM									=@NOTAS_AM_,
								@USUARIO									=USUARIO_CREACION,
								@FECHA_CREACION_AM							=GETDATE(),
								@EXPORTADO_AM								=EXPORTADO,
								@TIPO_INGRESO_MAYOR_AM						=TIPO_INGRESO_MAYOR,
								@NoteExistsFlag_AM							=NoteExistsFlag,
								@RowPointer_AM								=NEWID(),
								@FECHA_CREACION_AM							=GETDATE(),
								@USUARIO									=CreatedBy,
								@RecordDate_AM								=GETDATE()

								FROM AHPF_HN.ASHPF.ASIENTO_MAYORIZADO WHERE ASIENTO = @ASIENTO
					

						INSERT INTO AHPF_HN.ASHPF.ASIENTO_MAYORIZADO
						(ASIENTO,MAYOR_AUDITORIA,TIPO_ASIENTO,FECHA,CONTABILIDAD,ORIGEN,CLASE_ASIENTO,ULTIMO_USUARIO,FECHA_ULT_MODIF
						,MONTO_TOTAL_LOCAL,MONTO_TOTAL_DOLAR,NOTAS,USUARIO_CREACION,FECHA_CREACION,EXPORTADO,TIPO_INGRESO_MAYOR
						,NoteExistsFlag,RecordDate,RowPointer,CreatedBy,UpdatedBy,CreateDate)

						VALUES
						(@ASIENTO_AM,@MAYOR_AUDITORIA_AM,@TIPO_ASIENTO_AM,@FECHA_AM,@CONTABILIDAD_AM,@ORIGEN_AM,@CLASE_ASIENTO_AM,@USUARIO,@FECHA_CREACION_AM,
						ISNULL(@MONTO_TOTAL_LOCAL_AM,0),0,@NOTAS_AM,@USUARIO,@FECHA_CREACION_AM,@EXPORTADO_AM,@TIPO_INGRESO_MAYOR_AM	,
						@NoteExistsFlag_AM,@FECHA_CREACION_AM,@RowPointer_AM,@USUARIO,@USUARIO,@RecordDate_AM)

				
					/*--------------------------------------------------------------------------------------------------*/
													--- OBTENER LINEAS DE ASIENTO ---
					------------------------------------------------------------------------------------------------------


									INSERT INTO @MAYOR
									(ASIENTO_TEMP,CONSECUTIVO_TEMP,NIT_TEMP,CENTRO_COSTO_TEMP,CUENTA_CONTABLE_TEMP,
									FECHA_TEMP,TIPO_ASIENTO_TEMP,FUENTE_TEMP,REFERENCIA_TEMP,ORIGEN_TEMP,DEBITO_LOCAL_TEMP,
									CREDITO_LOCAL_TEMP,CONTABILIDAD_TEMP,CLASE_ASIENTO_TEMP,ESTADO_CONS_FISC_TEMP,	ESTADO_CONS_CORP_TEMP,
									NoteExistsFlag_TEMP,RecordDate_TEMP,RowPointer_TEMP,CreatedBy_TEMP,UpdatedBy_TEMP,CreateDate_TEMP,PROYECTO_TEMP,	FASE_TEMP,TIPO_TEMP)
								
										SELECT 
												ASIENTO,
												CONSECUTIVO,
												NIT,
												CENTRO_COSTO,
												CUENTA_CONTABLE,
												FECHA,
												TIPO_ASIENTO,
												FUENTE,
												REFERENCIA,
												ORIGEN,
												ISNULL(DEBITO_LOCAL,0),
												ISNULL(CREDITO_LOCAL,0),
												CONTABILIDAD,
												CLASE_ASIENTO,
												ESTADO_CONS_FISC,
												ESTADO_CONS_CORP,
												NoteExistsFlag,
												RecordDate,
												RowPointer,
												CreatedBy,
												UpdatedBy,
												CreateDate,
												PROYECTO,
												FASE,
												[AHPF_HN].[ASHPF].[GET_TIPOSALDO_REVERSION](ASIENTO,CONSECUTIVO,CENTRO_COSTO,CUENTA_CONTABLE)

										FROM AHPF_HN.ASHPF.MAYOR WHERE ASIENTO=@ASIENTO

										------------------------------------------------------------------------------

										SELECT @Id_M = COUNT(*) FROM @MAYOR

										WHILE @M <= @Id_M
											BEGIN

												SELECT 
												@ASIENTO_M							=@ASIENTO_AM_TEMP,
												@CONSECUTIVO_M						=M0.CONSECUTIVO_TEMP,
												@NIT_M								=M0.NIT_TEMP,
												@CENTRO_COSTO_M						=M0.CENTRO_COSTO_TEMP,
												@CUENTA_CONTABLE_M					=M0.CUENTA_CONTABLE_TEMP,
												@FECHA_M							=(SELECT DATEADD(dd, DATEDIFF(dd, 0, CURRENT_TIMESTAMP), 0)),
												@TIPO_ASIENTO_M						=M0.TIPO_ASIENTO_TEMP,
												@FUENTE_M							=M0.FUENTE_TEMP,
												@REFERENCIA_M						=M0.REFERENCIA_TEMP,
												@ORIGEN_M							=M0.ORIGEN_TEMP,
												@DEBITO_LOCAL_M						=ISNULL(M0.DEBITO_LOCAL_TEMP,0),
												@CREDITO_LOCAL_M					=ISNULL(M0.CREDITO_LOCAL_TEMP,0),
												@CONTABILIDAD_M						=M0.CONTABILIDAD_TEMP,
												@CLASE_ASIENTO_M					=M0.CLASE_ASIENTO_TEMP,
												@ESTADO_CONS_FISC_M					=M0.ESTADO_CONS_FISC_TEMP,
												@ESTADO_CONS_CORP_M					=M0.ESTADO_CONS_CORP_TEMP,
												@NoteExistsFlag_M					=0,
												@RecordDate_M						=GETDATE(),
												@RowPointer_M						=NEWID(),
												@CreatedBy_M						=M0.CreatedBy_TEMP,
												@UpdatedBy_M						=M0.UpdatedBy_TEMP,
												@CreateDate_M						=GETDATE(),
												@PROYECTO_M							=NULL,
												@FASE_M								=NULL,
												@TIPO								=M0.TIPO_TEMP
										

												FROM @MAYOR AS M0  WHERE M0.ID = @M


												IF @TIPO = 'D'
												BEGIN

													INSERT INTO AHPF_HN.ASHPF.MAYOR
													(ASIENTO,CONSECUTIVO,NIT,CENTRO_COSTO,CUENTA_CONTABLE,FECHA,TIPO_ASIENTO,FUENTE
													,REFERENCIA,ORIGEN,DEBITO_LOCAL,CREDITO_LOCAL,CONTABILIDAD,CLASE_ASIENTO
													,ESTADO_CONS_FISC,ESTADO_CONS_CORP,NoteExistsFlag,RecordDate,RowPointer
													,CreateDate,PROYECTO,FASE)

													VALUES
													(@ASIENTO_M,@CONSECUTIVO_M,@NIT_M,@CENTRO_COSTO_M,@CUENTA_CONTABLE_M,@FECHA_M,@TIPO_ASIENTO_M,@FUENTE_M
													,@REFERENCIA_M,@ORIGEN_M,@CREDITO_LOCAL_M,0.00000000,@CONTABILIDAD_M,@CLASE_ASIENTO_M
													,@ESTADO_CONS_FISC_M,@ESTADO_CONS_CORP_M,@NoteExistsFlag_M,@RecordDate_M,@RowPointer_M
													,@CreateDate_M,@PROYECTO_M,@FASE_M)
													
												END

												IF @TIPO ='C'
												BEGIN

													INSERT INTO AHPF_HN.ASHPF.MAYOR
													(ASIENTO,CONSECUTIVO,NIT,CENTRO_COSTO,CUENTA_CONTABLE,FECHA,TIPO_ASIENTO,FUENTE
													,REFERENCIA,ORIGEN,DEBITO_LOCAL,CREDITO_LOCAL,CONTABILIDAD,CLASE_ASIENTO
													,ESTADO_CONS_FISC,ESTADO_CONS_CORP,NoteExistsFlag,RecordDate,RowPointer
													,CreateDate,PROYECTO,FASE)

													VALUES
													(@ASIENTO_M,@CONSECUTIVO_M,@NIT_M,@CENTRO_COSTO_M,@CUENTA_CONTABLE_M,@FECHA_M,@TIPO_ASIENTO_M,@FUENTE_M
													,@REFERENCIA_M,@ORIGEN_M,0.00000000,@DEBITO_LOCAL_M,@CONTABILIDAD_M,@CLASE_ASIENTO_M
													,@ESTADO_CONS_FISC_M,@ESTADO_CONS_CORP_M,@NoteExistsFlag_M,@RecordDate_M,@RowPointer_M
													,@CreateDate_M,@PROYECTO_M,@FASE_M)

												END


												SET @M = @M + 1
											END
											DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10)

											SET @TEMP_NOMBRE_CLIENTE=(SELECT NOMBRE FROM AHPF_HN.ASHPF.CLIENTE WHERE CLIENTE=@TEMP_CLIENTE_CORP)

											SET @NOTAS_AM_=( 
											
											'-------------------------------------------------------' + @NewLineChar +
											'Partida de Reversión'+ @NewLineChar +
											'Se reversa la partida:' + ' ' + @ASIENTO + @NewLineChar +
											'-------------------------------------------------------' + @NewLineChar +
											'Cliente:' + ' ' + @TEMP_CLIENTE_CORP + ' ' + 'Nombre: ' + ' ' + UPPER(@TEMP_NOMBRE_CLIENTE))

											UPDATE AHPF_HN.ASHPF.ASIENTO_MAYORIZADO
											SET NOTAS=@NOTAS_AM_
											WHERE ASIENTO=@ASIENTO_M

											
											SET @ASIENTO_R =(SELECT @ASIENTO_AM)



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
