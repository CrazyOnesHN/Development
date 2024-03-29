USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_INSERT_SALDO]    Script Date: 11/9/2022 3:43:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Batch submitted through debugger: SALDO_New.sql|7|0|C:\Users\jrivera\Desktop\Analisis_BC_17_02_2018\SALDO_New.sql


ALTER PROCEDURE [ASHPF].[sP_INSERT_SALDO]

	@ASIENTO		AS VARCHAR(10)
	
AS
BEGIN 

	SET NOCOUNT ON;
		
		--- VARIABLES TEMPORALES PARA CARGA DE ASIENTO 

		DECLARE @TEMP_ASIENTO						VARCHAR(10)
		DECLARE @TEMP_CENTRO_COSTO					VARCHAR(25)
		DECLARE @TEMP_CUENTA_CONTABLE				VARCHAR(25)	
		DECLARE @TEMP_SALDO_NORMAL					VARCHAR(1)
		DECLARE @TEMP_DEBITO						DECIMAL(28,8)
		DECLARE @TEMP_CREDITO						DECIMAL(28,8)
		DECLARE @TEMP_DEBITO_DOLAR					DECIMAL(28,8)
		DECLARE @TEMP_CREDITO_DOLAR					DECIMAL(28,8)
		DECLARE @TEMP_DEBITO_UNIDADES				DECIMAL(28,8)
		DECLARE @TEMP_CREDITO_UNIDADES				DECIMAL(28,8)
		DECLARE @TEMP_CONSECUTIVO					INT
		DECLARE @TEMP_FECHA							DATETIME
		DECLARE @TEMP_FECHA_PERIODO					DATETIME
		DECLARE @TEMP_DEBITO_LOCAL					DECIMAL(28,8)
		DECLARE @TEMP_CREDITO_LOCAL					DECIMAL(28,8)
		DECLARE @TEMP_NIT							VARCHAR(20)
		DECLARE @TEMP_CONTABILIDAD					VARCHAR(1)
		DECLARE @TEMP_TIPO							VARCHAR(1)
		DECLARE @TEMP_CreatedBy						VARCHAR(30)
		DECLARE @TEMP_UpdatedBy						VARCHAR(30)
		DECLARE @TEMP_NoteExistsFlag				INT
		DECLARE @TEMP_RecordDate					DATETIME
		DECLARE @TEMP_RowPointer					UNIQUEIDENTIFIER
		DECLARE @TEMP_CreateDate					DATETIME
		DECLARE @PERIODO_ESTADO						INT
		DECLARE @ULTIMO_PERIODO						DATETIME

		--- VARIABLES PARA ITERACION DE LINEAS EN ASIENTO 

		DECLARE @A					AS	INT
			SET @A = 1
		DECLARE	@Id_A				AS	INT

		--- VARIABLES TEMPORALES PARA SALDO POR CUENTAS

		DECLARE @TEMP_CENTRO_COSTO_S				VARCHAR(25)
		DECLARE @TEMP_CUENTA_CONTABLE_S				VARCHAR(25)
		DECLARE @TEMP_FECHA_S						DATETIME
		DECLARE @TEMP_SALDO_FISC_LOCAL_S			DECIMAL(28,8)
		DECLARE @TEMP_SALDO_FISC_DOLAR_S			DECIMAL(28,8)
		DECLARE @TEMP_SALDO_CORP_LOCAL_S			DECIMAL(28,8)
		DECLARE @TEMP_SALDO_CORP_DOLAR_S			DECIMAL(28,8)
		DECLARE @TEMP_DEBITO_FISC_LOCAL_S			DECIMAL(28,8)
		DECLARE @TEMP_CREDITO_FISC_LOCAL_S			DECIMAL(28,8)
		DECLARE @TEMP_DEBITO_CORP_LOCAL_S			DECIMAL(28,8)
		DECLARE @TEMP_CREDITO_CORP_LOCAL_S			DECIMAL(28,8)
		DECLARE @TEMP_DEBITO_FISC_DOLAR_S			DECIMAL(28,8)
		DECLARE @TEMP_CREDITO_FISC_DOLAR_S			DECIMAL(28,8)
		DECLARE @TEMP_DEBITO_CORP_DOLAR_S			DECIMAL(28,8)
		DECLARE @TEMP_CREDITO_CORP_DOLAR_S			DECIMAL(28,8)
		DECLARE @TEMP_SALDO_FISC_UND_S				DECIMAL(28,8)
		DECLARE @TEMP_SALDO_CORP_UND_S				DECIMAL(28,8)
		DECLARE @TEMP_DEBITO_FISC_UND_S				DECIMAL(28,8)
		DECLARE @TEMP_CREDITO_FISC_UND_S			DECIMAL(28,8)
		DECLARE @TEMP_DEBITO_CORP_UND_S				DECIMAL(28,8)
		DECLARE @TEMP_CREDITO_CORP_UND_S			DECIMAL(28,8)


	BEGIN TRY
		BEGIN TRANSACTION;

				--- TABLA PARA CARGA DE LINEAS DE ASIENTO PARA BALANCE  DE COMPROBACION 

				DECLARE @ASIENTO_LINEAS AS TABLE(
				ID INT IDENTITY(1,1) PRIMARY KEY,
				CONSECUTIVO								INT,
				ASIENTO									VARCHAR(10),
				CENTRO_COSTO							VARCHAR(25),
				CUENTA_CONTABLE							VARCHAR(25),
				SALDO_NORMAL							VARCHAR(1),
				TIPO									VARCHAR(1),
				TIPO_DETALLADO							VARCHAR(1),
				FECHA									DATETIME,
				DEBITO_LOCAL							DECIMAL(28,8),
				CREDITO_LOCAL							DECIMAL(28,8),
				DEBITO_DOLAR							DECIMAL(28,8),
				CREDITO_DOLAR							DECIMAL(28,8),
				DEBITO_UNIDADES							DECIMAL(28,8),
				CREDITO_UNIDADES						DECIMAL(28,8),
				NIT										VARCHAR(20),
				CONTABILIDAD							VARCHAR(1),
				TIPO_									VARCHAR(1),
				FECHA_PERIODO							DATETIME,
				CreatedBy								VARCHAR(30),
				UpdatedBy								VARCHAR(30)
				)


				/*CARGA DE LINEAS DE ASIENTO MAYOR A TABLA TEMPORAL*/ 

				INSERT INTO @ASIENTO_LINEAS
				(CONSECUTIVO,ASIENTO,CENTRO_COSTO,CUENTA_CONTABLE,SALDO_NORMAL,TIPO,TIPO_DETALLADO,FECHA,DEBITO_LOCAL,CREDITO_LOCAL,DEBITO_DOLAR,CREDITO_DOLAR,DEBITO_UNIDADES,CREDITO_UNIDADES,NIT,CONTABILIDAD,
				TIPO_,FECHA_PERIODO,CreatedBy,UpdatedBy)

									SELECT 
									M1.CONSECUTIVO, 
									M1.ASIENTO, 
									M1.CENTRO_COSTO, 
									M1.CUENTA_CONTABLE, 
									([AHPF_HN].[ASHPF].[GET_SALDO_NORMAL](M1.CUENTA_CONTABLE)) AS SALDO_NORMAL,
									C0.TIPO,
									C0.TIPO_DETALLADO,
									(SELECT DATEADD(dd, DATEDIFF(dd, 0, M1.FECHA), 0))	AS FECHA,  
									ISNULL(M1.DEBITO_LOCAL,0)							AS DEBITO_LOCAL,
									ISNULL(M1.CREDITO_LOCAL,0)							AS CREDITO_LOCAL,
									ISNULL(M1.DEBITO_DOLAR,0)							AS DEBITO_DOLAR,
									ISNULL(M1.CREDITO_DOLAR,0)							AS CREDITO_DOLAR,
									ISNULL(M1.DEBITO_UNIDADES,0)						AS DEBITO_UNIDADES,
									ISNULL(M1.CREDITO_UNIDADES,0)						AS CREDITO_UNIDADES,
									M1.NIT, 
									M1.CONTABILIDAD,
									([AHPF_HN].[ASHPF].[GET_TIPOSALDO] (M1.ASIENTO,M1.CONSECUTIVO,M1.CENTRO_COSTO,M1.CUENTA_CONTABLE)) AS TIPO_, 
									(SELECT MIN(P.FECHA_FINAL) FROM ASHPF.PERIODO_CONTABLE AS P 
									WHERE P.FECHA_FINAL >= (SELECT DATEADD(dd, DATEDIFF(dd, 0, M1.FECHA), 0))) AS FECHA_PERIODO,  
									M1.CreatedBy, 
									M1.UpdatedBy

									FROM AHPF_HN.ASHPF.MAYOR AS M1
									INNER JOIN ASHPF.CUENTA_CONTABLE AS C0 ON C0.CUENTA_CONTABLE = M1.CUENTA_CONTABLE
									INNER JOIN ASHPF.CENTRO_COSTO AS C1 ON C1.CENTRO_COSTO = M1.CENTRO_COSTO

									WHERE 
									--M1.TIPO_ASIENTO='PING' 
									--AND M1.ORIGEN='FA'									
									M1.ASIENTO=@ASIENTO		--AND
									--M1.CONTABILIDAD IN ('F','A')
									ORDER BY M1.CONSECUTIVO


							
							---------------------------------------------------------------------------------------
							---------------------------------------------------------------------------------------
														--- INICIA EL PROCESO ---
									--- RECORRIDO DE LINEAS POR CUENTA_CONTABLE Y CENTRO DE COSTO---
							---------------------------------------------------------------------------------------
							---------------------------------------------------------------------------------------


							SELECT @Id_A = COUNT(*) FROM  @ASIENTO_LINEAS

							WHILE @A <= @Id_A
											BEGIN

												SELECT 
												@TEMP_CONSECUTIVO						=	L.CONSECUTIVO,
												@TEMP_ASIENTO							=	L.ASIENTO,
												@TEMP_CENTRO_COSTO						=	L.CENTRO_COSTO,
												@TEMP_CUENTA_CONTABLE					=	L.CUENTA_CONTABLE,
												@TEMP_SALDO_NORMAL						=	L.SALDO_NORMAL,
												@TEMP_FECHA								=	L.FECHA,
												@TEMP_DEBITO_LOCAL						=	L.DEBITO_LOCAL,
												@TEMP_CREDITO_LOCAL						=	L.CREDITO_LOCAL,
												@TEMP_DEBITO_DOLAR						=	L.DEBITO_DOLAR,
												@TEMP_CREDITO_DOLAR						=	L.CREDITO_DOLAR,
												@TEMP_DEBITO_UNIDADES					=	L.DEBITO_UNIDADES,
												@TEMP_CREDITO_UNIDADES					=	L.CREDITO_UNIDADES,
												@TEMP_NIT								=	L.NIT,
												@TEMP_CONTABILIDAD						=	L.CONTABILIDAD,
												@TEMP_TIPO								=	L.TIPO_,
												@TEMP_FECHA_PERIODO						=	L.FECHA_PERIODO,
												@TEMP_CreatedBy							=	L.CreatedBy,
												@TEMP_UpdatedBy							=	L.UpdatedBy,
												@TEMP_NoteExistsFlag					=	0,	
												@TEMP_RecordDate						=	GETDATE(),
												@TEMP_RowPointer						=	NEWID(),
												@TEMP_CreateDate						=	GETDATE()

												FROM @ASIENTO_LINEAS AS L	WHERE L.ID = @A

												
												/*VALIDACION PARA DETERMINAR SI PERIODO CONTABLE EXISTE*/ 

												SET @PERIODO_ESTADO	= (SELECT COUNT(*) 	FROM ASHPF.SALDO 
												WHERE 
												FECHA						=@TEMP_FECHA_PERIODO			AND 
												CENTRO_COSTO				=@TEMP_CENTRO_COSTO				AND 
												CUENTA_CONTABLE				=@TEMP_CUENTA_CONTABLE)	

												/*-------------------------------------------------------------------------------------*/
												------------------------- PERIODO CONTABLE NO EXISTE -----------------------------------
												----------------------------------------------------------------------------------------
												
												/*
													MODIFICACION 21 DE FEBRERO 2018
													PARA DETERMINAR SI UNA CUENTA CON DETERMINADO CENTRO DE COSTO NO HA TENIDO MOVIMIENTO NUNCA
													CARLOS IDIAQUEZ
												*/
												DECLARE @NOHAYMOV INT = 0;

												IF @PERIODO_ESTADO = 0
													BEGIN
														/*VALIDACION PARA DETERMINAR SI LA CUENTA Y CENTRO DE COSTOS HAN TENIDO MOVIMIENTO ANTERIORMENTE*/ 
														SET @NOHAYMOV = (SELECT COUNT(*) FROM AHPF_HN.ASHPF.SALDO 
														WHERE  CENTRO_COSTO = @TEMP_CENTRO_COSTO AND    
														CUENTA_CONTABLE = @TEMP_CUENTA_CONTABLE )

														/*INICIALIZA SALDOS EN CERO CUANDO LA CUENTA Y CENTRO DE COSTO NO HAN TENIDO MOVIMIENTO ANTERIORMENTE */
														IF @NOHAYMOV = 0
															BEGIN
																SET @TEMP_CENTRO_COSTO_S				=  @TEMP_CENTRO_COSTO 
																SET @TEMP_CUENTA_CONTABLE_S				=  @TEMP_CUENTA_CONTABLE
																SET @TEMP_FECHA_S						=  @TEMP_FECHA_PERIODO																 
																SET @TEMP_SALDO_FISC_LOCAL_S			=	0 
																SET @TEMP_SALDO_FISC_DOLAR_S			=	0
																SET @TEMP_SALDO_CORP_LOCAL_S			=	0
																SET @TEMP_SALDO_CORP_DOLAR_S			=	0
																SET @TEMP_DEBITO_FISC_LOCAL_S			=	0
																SET @TEMP_CREDITO_FISC_LOCAL_S			=	0
																SET @TEMP_DEBITO_CORP_LOCAL_S			=	0
																SET @TEMP_CREDITO_CORP_LOCAL_S			=	0	
																SET @TEMP_DEBITO_FISC_DOLAR_S			=	0	
																SET @TEMP_CREDITO_FISC_DOLAR_S			=	0
																SET @TEMP_DEBITO_CORP_DOLAR_S			=	0
																SET @TEMP_CREDITO_CORP_DOLAR_S			=	0
																SET @TEMP_SALDO_FISC_UND_S				=	0
																SET @TEMP_SALDO_CORP_UND_S				=	0
																SET @TEMP_DEBITO_FISC_UND_S				=	0
																SET @TEMP_CREDITO_FISC_UND_S			=	0
																SET @TEMP_DEBITO_CORP_UND_S				=	0
																SET @TEMP_CREDITO_CORP_UND_S			=	0
															END														
													END


												IF @PERIODO_ESTADO = 0 

												BEGIN

													/*OBTENER SALDO POR CENTRO COSTO Y CUENTA CONTABLE PARA EL PERIODO EN PROCESO*/
													/*SOLO SI LA CUENTA Y CENTRO DE COSTO HAN TENIDO MOVIMIENTO ANTERIORMENTE */
													IF @NOHAYMOV > 0
													BEGIN
														SELECT 
														@TEMP_CENTRO_COSTO_S				=	S0.CENTRO_COSTO, 
														@TEMP_CUENTA_CONTABLE_S				=	S0.CUENTA_CONTABLE,
														@TEMP_FECHA_S						=	@TEMP_FECHA_PERIODO, 
														@TEMP_SALDO_FISC_LOCAL_S			=	S0.SALDO_FISC_LOCAL, 
														@TEMP_SALDO_FISC_DOLAR_S			=	S0.SALDO_FISC_DOLAR,
														@TEMP_SALDO_CORP_LOCAL_S			=	S0.SALDO_CORP_LOCAL,
														@TEMP_SALDO_CORP_DOLAR_S			=	S0.SALDO_CORP_DOLAR,
														@TEMP_DEBITO_FISC_LOCAL_S			=	S0.DEBITO_FISC_LOCAL,
														@TEMP_CREDITO_FISC_LOCAL_S			=	S0.CREDITO_FISC_LOCAL,
														@TEMP_DEBITO_CORP_LOCAL_S			=	S0.DEBITO_CORP_LOCAL,
														@TEMP_CREDITO_CORP_LOCAL_S			=	S0.CREDITO_CORP_LOCAL,	
														@TEMP_DEBITO_FISC_DOLAR_S			=	S0.DEBITO_FISC_DOLAR,	
														@TEMP_CREDITO_FISC_DOLAR_S			=	S0.CREDITO_FISC_DOLAR,
														@TEMP_DEBITO_CORP_DOLAR_S			=	S0.DEBITO_CORP_DOLAR,
														@TEMP_CREDITO_CORP_DOLAR_S			=	S0.CREDITO_CORP_DOLAR,
														@TEMP_SALDO_FISC_UND_S				=	S0.SALDO_FISC_UND,
														@TEMP_SALDO_CORP_UND_S				=	S0.SALDO_CORP_UND,
														@TEMP_DEBITO_FISC_UND_S				=	S0.DEBITO_FISC_UND,
														@TEMP_CREDITO_FISC_UND_S			=	S0.CREDITO_FISC_UND,
														@TEMP_DEBITO_CORP_UND_S				=	S0.DEBITO_CORP_UND,
														@TEMP_CREDITO_CORP_UND_S			=	S0.CREDITO_CORP_UND
													
														FROM AHPF_HN.ASHPF.SALDO AS S0
														WHERE S0.CENTRO_COSTO	=	@TEMP_CENTRO_COSTO
														AND S0.CUENTA_CONTABLE	=	@TEMP_CUENTA_CONTABLE 
														AND S0.FECHA			=	
														(SELECT MAX( fecha )    FROM AHPF_HN.ASHPF.SALDO 
														WHERE  CENTRO_COSTO = @TEMP_CENTRO_COSTO AND    
														CUENTA_CONTABLE = @TEMP_CUENTA_CONTABLE AND    FECHA <= @TEMP_FECHA_PERIODO)
														ORDER BY FECHA
													END

													/*---------------------------------------------------------------------------*/

												
													/*---------------------------------------------------------------------------*/
															--- INSERCION POR TIPO DE COLUMNA DEBITO O CREIDTO ---
													-------------------------------------------------------------------------------

														/*AFECTAR CREDITO*/

														IF @TEMP_TIPO	=	'C'

															BEGIN
																
																EXEC erpadmin.GrabarUsuarioActual @TEMP_CreatedBy
																EXEC erpadmin.LeerUsuarioActual @TEMP_CreatedBy


																INSERT INTO AHPF_HN.ASHPF.SALDO
																(CENTRO_COSTO,CUENTA_CONTABLE,FECHA,SALDO_FISC_LOCAL,SALDO_FISC_DOLAR,SALDO_CORP_LOCAL
																,SALDO_CORP_DOLAR,DEBITO_FISC_LOCAL,CREDITO_FISC_LOCAL,DEBITO_CORP_LOCAL,CREDITO_CORP_LOCAL
																,DEBITO_FISC_DOLAR,CREDITO_FISC_DOLAR,DEBITO_CORP_DOLAR,CREDITO_CORP_DOLAR,SALDO_FISC_UND
																,SALDO_CORP_UND,DEBITO_FISC_UND,CREDITO_FISC_UND,DEBITO_CORP_UND,CREDITO_CORP_UND,RecordDate,CreatedBy,UpdatedBy,CreateDate)

																VALUES
																(@TEMP_CENTRO_COSTO,@TEMP_CUENTA_CONTABLE,@TEMP_FECHA_PERIODO,@TEMP_SALDO_FISC_LOCAL_S,@TEMP_SALDO_FISC_DOLAR_S,@TEMP_SALDO_CORP_LOCAL_S
																,@TEMP_SALDO_CORP_DOLAR_S,0.00000000,0.00000000,0.00000000,0.00000000
																,@TEMP_DEBITO_FISC_DOLAR_S,@TEMP_CREDITO_FISC_DOLAR_S,@TEMP_DEBITO_CORP_DOLAR_S,@TEMP_CREDITO_CORP_DOLAR_S,@TEMP_SALDO_FISC_UND_S
																,@TEMP_SALDO_CORP_UND_S,@TEMP_DEBITO_FISC_UND_S,@TEMP_CREDITO_FISC_UND_S,@TEMP_DEBITO_CORP_UND_S
																,@TEMP_CREDITO_CORP_UND_S,GETDATE(),@TEMP_CreatedBy,@TEMP_UpdatedBy,GETDATE())

																															

																UPDATE AHPF_HN.ASHPF.SALDO
																SET SALDO_FISC_LOCAL = 
																(
																CASE
																	/* para mantener saldo negativo se resta el credito cuando es acreedora*/ 
																	WHEN @TEMP_SALDO_NORMAL = 'A' THEN SALDO_FISC_LOCAL	- @TEMP_CREDITO_LOCAL
																	WHEN @TEMP_SALDO_NORMAL = 'D' THEN SALDO_FISC_LOCAL	- @TEMP_CREDITO_LOCAL
																END 
																), 
																CREDITO_FISC_LOCAL		=	CREDITO_FISC_LOCAL	+ @TEMP_CREDITO_LOCAL,
																CREDITO_CORP_LOCAL		=	CREDITO_CORP_LOCAL	+ @TEMP_CREDITO_LOCAL	

																WHERE 
																CENTRO_COSTO			=	@TEMP_CENTRO_COSTO		AND
																CUENTA_CONTABLE			=	@TEMP_CUENTA_CONTABLE	AND
																FECHA					=	@TEMP_FECHA_PERIODO
																
															
															END	

														/*AFECTAR DEBITO*/
																		
														IF @TEMP_TIPO	=	'D'

															BEGIN

																EXEC erpadmin.GrabarUsuarioActual @TEMP_CreatedBy
																EXEC erpadmin.LeerUsuarioActual @TEMP_CreatedBy
																														
																INSERT INTO AHPF_HN.ASHPF.SALDO
																(CENTRO_COSTO,CUENTA_CONTABLE,FECHA,SALDO_FISC_LOCAL,SALDO_FISC_DOLAR,SALDO_CORP_LOCAL
																,SALDO_CORP_DOLAR,DEBITO_FISC_LOCAL,CREDITO_FISC_LOCAL,DEBITO_CORP_LOCAL,CREDITO_CORP_LOCAL
																,DEBITO_FISC_DOLAR,CREDITO_FISC_DOLAR,DEBITO_CORP_DOLAR,CREDITO_CORP_DOLAR,SALDO_FISC_UND
																,SALDO_CORP_UND,DEBITO_FISC_UND,CREDITO_FISC_UND,DEBITO_CORP_UND,CREDITO_CORP_UND,RecordDate,CreatedBy,UpdatedBy,CreateDate)

																VALUES
																(@TEMP_CENTRO_COSTO,@TEMP_CUENTA_CONTABLE,@TEMP_FECHA_PERIODO,@TEMP_SALDO_FISC_LOCAL_S,@TEMP_SALDO_FISC_DOLAR_S,@TEMP_SALDO_CORP_LOCAL_S
																,@TEMP_SALDO_CORP_DOLAR_S,0.00000000,0.00000000,0.00000000,0.00000000
																,@TEMP_DEBITO_FISC_DOLAR_S,@TEMP_CREDITO_FISC_DOLAR_S,@TEMP_DEBITO_CORP_DOLAR_S,@TEMP_CREDITO_CORP_DOLAR_S,@TEMP_SALDO_FISC_UND_S
																,@TEMP_SALDO_CORP_UND_S,@TEMP_DEBITO_FISC_UND_S,@TEMP_CREDITO_FISC_UND_S,@TEMP_DEBITO_CORP_UND_S
																,@TEMP_CREDITO_CORP_UND_S,GETDATE(),@TEMP_CreatedBy,@TEMP_UpdatedBy,GETDATE())

															
																UPDATE AHPF_HN.ASHPF.SALDO
																SET SALDO_FISC_LOCAL = 
																(
																CASE 
																	/* para mantener saldo negativo se suma el debito cuando es acreedora*/ 
																	WHEN @TEMP_SALDO_NORMAL = 'A' THEN SALDO_FISC_LOCAL	+ @TEMP_DEBITO_LOCAL
																	WHEN @TEMP_SALDO_NORMAL = 'D' THEN SALDO_FISC_LOCAL	+ @TEMP_DEBITO_LOCAL
																END 
																), 																
																DEBITO_FISC_LOCAL		=	DEBITO_FISC_LOCAL	+ @TEMP_DEBITO_LOCAL,
																DEBITO_CORP_LOCAL			=	DEBITO_CORP_LOCAL	+ @TEMP_DEBITO_LOCAL

																WHERE 
																CENTRO_COSTO			=	@TEMP_CENTRO_COSTO		AND
																CUENTA_CONTABLE			=	@TEMP_CUENTA_CONTABLE	AND
																FECHA					=	@TEMP_FECHA_PERIODO
																
																															
															END	


												END

												/*--------------------------------------------------------------------------------------*/
												------------------------- PERIODO CONTABLE EXISTE	-------------------------------------
												-----------------------------------------------------------------------------------------

												IF @PERIODO_ESTADO > 0

												BEGIN												
																/*AFECTAR CREDITO*/

																IF @TEMP_TIPO	=	'C'
																BEGIN	
																	UPDATE AHPF_HN.ASHPF.SALDO
																	SET SALDO_FISC_LOCAL	=	
																	(
																	CASE 
																		/* para mantener saldo negativo se resta el credito cuando es acreedora*/
																		WHEN @TEMP_SALDO_NORMAL = 'A' THEN SALDO_FISC_LOCAL	- @TEMP_CREDITO_LOCAL
																		WHEN @TEMP_SALDO_NORMAL = 'D' THEN SALDO_FISC_LOCAL	- @TEMP_CREDITO_LOCAL
																	END 
																	), 		
																	CREDITO_FISC_LOCAL		=	CREDITO_FISC_LOCAL	+ @TEMP_CREDITO_LOCAL,
																	CREDITO_CORP_LOCAL			=	CREDITO_CORP_LOCAL	+ @TEMP_CREDITO_LOCAL

																	WHERE 
																	CENTRO_COSTO			=	@TEMP_CENTRO_COSTO		AND
																	CUENTA_CONTABLE			=	@TEMP_CUENTA_CONTABLE	AND
																	FECHA					=	@TEMP_FECHA_PERIODO
																	
																END

																/*AFECTAR DEBITO*/

																IF @TEMP_TIPO	=	'D'
																BEGIN																	
																	UPDATE AHPF_HN.ASHPF.SALDO
																	SET SALDO_FISC_LOCAL	=	
																	(
																	CASE 
																		/* para mantener saldo negativo se suma el debito cuando es acreedora*/ 
																		WHEN @TEMP_SALDO_NORMAL = 'A' THEN SALDO_FISC_LOCAL	+ @TEMP_DEBITO_LOCAL
																		WHEN @TEMP_SALDO_NORMAL = 'D' THEN SALDO_FISC_LOCAL	+ @TEMP_DEBITO_LOCAL
																	END 
																	), 	
																	DEBITO_FISC_LOCAL		=	DEBITO_FISC_LOCAL	+ @TEMP_DEBITO_LOCAL,
																	DEBITO_CORP_LOCAL			=	DEBITO_CORP_LOCAL	+ @TEMP_DEBITO_LOCAL
																

																	WHERE 
																	CENTRO_COSTO			=	@TEMP_CENTRO_COSTO		AND
																	CUENTA_CONTABLE			=	@TEMP_CUENTA_CONTABLE	AND
																	FECHA					=	@TEMP_FECHA_PERIODO															
																	
																END
												END --FIN PERIODO CONTABLE EXISTE

								SET @A = @A + 1
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
	END CATCH;
END
