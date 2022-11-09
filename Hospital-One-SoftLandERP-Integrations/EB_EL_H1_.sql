USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[EB_EL_H1_]    Script Date: 11/9/2022 3:27:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [ASHPF].[EB_EL_H1_]
	-- Add the parameters for the stored procedure here
	@ARTICULO			AS VARCHAR(20),
	@CANTIDAD			AS DECIMAL(28,8),
	@BODEGA				AS VARCHAR(4),
	@LOCALIZACION		AS VARCHAR(8),
	@LOTE				AS VARCHAR(15)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

		DECLARE @CANT_DISPONIBLE_BODEGA	AS DECIMAL(28,8)
		DECLARE @CANT_DISPONIBLE_LOTE	AS DECIMAL(28,8)
		DECLARE @ARTICULO_HIJO			AS VARCHAR(20)

		---  VARIABLES DE VALIDACION PARA ACTULIZAR EXISTENCIA SEGUNTO TIPO, TERMINADO O SERVICIO 

		DECLARE @TIPO					AS VARCHAR(1)
		DECLARE @USA_LOTE				AS VARCHAR(1)

		--- VARIABLES PARA OBTENER EL COSTO DE LOS ARTICULOS TERMINADOS

		DECLARE @COSTO_PROM_LOC					AS DECIMAL(28,8)	
		DECLARE @COSTO_PROM_DOL					AS DECIMAL(28,8)
		DECLARE @COSTO_ULT_LOC					AS DECIMAL(28,8)
		DECLARE @COSTO_ULT_DOL					AS DECIMAL(28,8)
		DECLARE @TEMP_CANT_DISPONIBLE			AS DECIMAL(28,8)

		--- VARIABLES PARA ARTICULO TIPO KIT 

		DECLARE @LOCALIZACION_ENSAMBLE				AS VARCHAR(8)
		DECLARE @LOTE_ENSAMBLE						AS VARCHAR(15)
		DECLARE @CANT_DISPONIBLE_BODEGA_ENSAMBLE	AS DECIMAL(28,8)
		DECLARE @CANT_DISPONIBLE_LOTE_ENSAMBLE		AS DECIMAL(28,8)
		


	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

						--- OBTENER EXISTENCIA TOTAL PARA CALCULAR COSTO 

						SET @TEMP_CANT_DISPONIBLE = 
								(SELECT 
								SUM(CANT_DISPONIBLE)	+
								SUM(CANT_RESERVADA)		+
								SUM(CANT_NO_APROBADA)	+
								SUM(CANT_VENCIDA)		+ 
								SUM(CANT_REMITIDA) 
  
								FROM AHPF_HN.ASHPF.EXISTENCIA_BODEGA WHERE  ARTICULO=@ARTICULO)

						--- OBTENER ULTIMO COSTO DEL ARTICULO

						SELECT 
						@COSTO_PROM_LOC		= A.COSTO_PROM_LOC,
						@COSTO_PROM_DOL		= A.COSTO_PROM_DOL,
						@COSTO_ULT_LOC		= A.COSTO_ULT_LOC,
						@COSTO_ULT_DOL		= A.COSTO_ULT_DOL 

						FROM AHPF_HN.ASHPF.ARTICULO AS A WHERE A.ARTICULO=@ARTICULO
						
						--- INICIA PROCESO PARA ACTUALIZAR EXISTENCIAS ---

						--- OBTENER EL TIPO ---

						SET @TIPO = (SELECT TIPO FROM AHPF_HN.ASHPF.ARTICULO WHERE ARTICULO = @ARTICULO)

						--- SI ES TERMINADO VALIDAR SI UTILIZA LOTES

						SET @USA_LOTE = (SELECT USA_LOTES FROM AHPF_HN.ASHPF.ARTICULO WHERE ARTICULO = @ARTICULO)


						--- ARTICULO TIPO TERMINADO  UTILIZA LOTES Y LOCALIZACION

						IF @TIPO = 'T' AND @USA_LOTE = 'S'
						BEGIN

						--- OBTENER EXISTENCIA ACTUAL												
							SET @CANT_DISPONIBLE_BODEGA =(SELECT CANT_DISPONIBLE 
							FROM AHPF_HN.ASHPF.EXISTENCIA_BODEGA WHERE ARTICULO=@ARTICULO AND BODEGA=@BODEGA)

						--- ACTUALIZAR EXISTENCIA DE BODEGA
							UPDATE AHPF_HN.ASHPF.EXISTENCIA_BODEGA  
							SET CANT_DISPONIBLE = @CANT_DISPONIBLE_BODEGA + @CANTIDAD 
							WHERE ARTICULO=@ARTICULO AND BODEGA=@BODEGA
						
						--- ACTUALIZAR EXISTENCIA LOTES
							SELECT 
							@LOTE_ENSAMBLE					=	EB.LOTE,        
							@LOCALIZACION_ENSAMBLE			=	EB.LOCALIZACION,        
							@CANT_DISPONIBLE_LOTE_ENSAMBLE	=	EB.CANT_DISPONIBLE 

							FROM   AHPF_HN.ASHPF.EXISTENCIA_LOTE AS EB,        ASHPF.LOTE LOT 
							WHERE  EB.ARTICULO = @ARTICULO      
							AND EB.LOTE = LOT.LOTE        
							AND EB.ARTICULO = LOT.ARTICULO        
							AND LOT.FECHA_VENCIMIENTO > '1980-1-1 00:00:00:000'        
							AND EB.BODEGA = @BODEGA        
							--AND EB.LOTE != 'ND'        
							AND EB.LOCALIZACION != 'ND'
							AND EB.CANT_DISPONIBLE >0 ORDER BY        LOT.FECHA_VENCIMIENTO

							UPDATE AHPF_HN.ASHPF.EXISTENCIA_LOTE  
							SET CANT_DISPONIBLE = @CANT_DISPONIBLE_LOTE_ENSAMBLE + @CANTIDAD 
							WHERE ARTICULO=@ARTICULO AND BODEGA=@BODEGA AND LOCALIZACION=@LOCALIZACION_ENSAMBLE AND LOTE=@LOTE_ENSAMBLE

						--- ACTUALIZAR COSTO DE ARTICULO

							UPDATE AHPF_HN.ASHPF.ARTICULO  
							SET 
							COSTO_PROM_LOC = ROUND(  ( COSTO_PROM_LOC * @TEMP_CANT_DISPONIBLE + @COSTO_PROM_LOC * @CANTIDAD)   / (@TEMP_CANT_DISPONIBLE  + @CANTIDAD), 7 ),  
							COSTO_PROM_DOL = ROUND(  ( COSTO_PROM_DOL * @TEMP_CANT_DISPONIBLE + 0  * @CANTIDAD)   / ( @TEMP_CANT_DISPONIBLE + @CANTIDAD), 7 ),  
							COSTO_ULT_LOC = @COSTO_ULT_LOC , COSTO_ULT_DOL = 0            
							WHERE ARTICULO =@ARTICULO

						
							
						END 

						--- ARTICULO TIPO TERMINADO NO UTILIZA LOTES Y LOCALIZACION

						IF @TIPO = 'T' AND @USA_LOTE = 'N'
						BEGIN

						--- OBTENER EXISTENCIA ACTUAL												
							SET @CANT_DISPONIBLE_BODEGA =(SELECT CANT_DISPONIBLE 
							FROM AHPF_HN.ASHPF.EXISTENCIA_BODEGA WHERE ARTICULO=@ARTICULO AND BODEGA=@BODEGA)

						--- ACTUALIZAR EXISTENCIA DE BODEGA
							UPDATE AHPF_HN.ASHPF.EXISTENCIA_BODEGA  
							SET CANT_DISPONIBLE = @CANT_DISPONIBLE_BODEGA + @CANTIDAD 
							WHERE ARTICULO=@ARTICULO AND BODEGA=@BODEGA

						--- ACTUALIZAR EXISTENCIA LOTES
							SELECT 
							@LOTE_ENSAMBLE					=	EB.LOTE,        
							@LOCALIZACION_ENSAMBLE			=	EB.LOCALIZACION,        
							@CANT_DISPONIBLE_LOTE_ENSAMBLE	=	EB.CANT_DISPONIBLE 

							FROM   AHPF_HN.ASHPF.EXISTENCIA_LOTE AS EB,        ASHPF.LOTE LOT 
							WHERE  EB.ARTICULO = @ARTICULO      
							AND EB.LOTE = LOT.LOTE        
							AND EB.ARTICULO = LOT.ARTICULO        
							AND LOT.FECHA_VENCIMIENTO > '1980-1-1 00:00:00:000'        
							AND EB.BODEGA = @BODEGA        
							--AND EB.LOTE != 'ND'        
							AND EB.LOCALIZACION != 'ND'
							AND EB.CANT_DISPONIBLE >0 ORDER BY        LOT.FECHA_VENCIMIENTO

							UPDATE AHPF_HN.ASHPF.EXISTENCIA_LOTE  
							SET CANT_DISPONIBLE = @CANT_DISPONIBLE_LOTE_ENSAMBLE + @CANTIDAD 
							WHERE ARTICULO=@ARTICULO AND BODEGA=@BODEGA AND LOCALIZACION=@LOCALIZACION_ENSAMBLE AND LOTE=@LOTE_ENSAMBLE

						--- ACTUALIZAR COSTO DE ARTICULO

							UPDATE AHPF_HN.ASHPF.ARTICULO  
							SET 
							COSTO_PROM_LOC = ROUND(  ( COSTO_PROM_LOC * @TEMP_CANT_DISPONIBLE + @COSTO_PROM_LOC * @CANTIDAD)   / (@TEMP_CANT_DISPONIBLE  + @CANTIDAD), 7 ),  
							COSTO_PROM_DOL = ROUND(  ( COSTO_PROM_DOL * @TEMP_CANT_DISPONIBLE + 0  * @CANTIDAD)   / ( @TEMP_CANT_DISPONIBLE + @CANTIDAD), 7 ),  
							COSTO_ULT_LOC = @COSTO_ULT_LOC , COSTO_ULT_DOL = 0            
							WHERE ARTICULO =@ARTICULO

						END 

									--- ARTICULO TIPO COMSUMO  UTILIZA LOTES Y LOCALIZACION

						IF @TIPO = 'U' AND @USA_LOTE = 'S'
						BEGIN

						--- OBTENER EXISTENCIA ACTUAL												
							SET @CANT_DISPONIBLE_BODEGA =(SELECT CANT_DISPONIBLE 
							FROM AHPF_HN.ASHPF.EXISTENCIA_BODEGA WHERE ARTICULO=@ARTICULO AND BODEGA=@BODEGA)

						--- ACTUALIZAR EXISTENCIA DE BODEGA
							UPDATE AHPF_HN.ASHPF.EXISTENCIA_BODEGA  
							SET CANT_DISPONIBLE = @CANT_DISPONIBLE_BODEGA + @CANTIDAD 
							WHERE ARTICULO=@ARTICULO AND BODEGA=@BODEGA
												
						--- ACTUALIZAR EXISTENCIA LOTES
							SELECT 
							@LOTE_ENSAMBLE					=	EB.LOTE,        
							@LOCALIZACION_ENSAMBLE			=	EB.LOCALIZACION,        
							@CANT_DISPONIBLE_LOTE_ENSAMBLE	=	EB.CANT_DISPONIBLE 

							FROM   AHPF_HN.ASHPF.EXISTENCIA_LOTE AS EB,        ASHPF.LOTE LOT 
							WHERE  EB.ARTICULO = @ARTICULO      
							AND EB.LOTE = LOT.LOTE        
							AND EB.ARTICULO = LOT.ARTICULO        
							AND LOT.FECHA_VENCIMIENTO > '1980-1-1 00:00:00:000'       
							AND EB.BODEGA = @BODEGA        
							--AND EB.LOTE != 'ND'        
							AND EB.LOCALIZACION != 'ND'
							AND EB.CANT_DISPONIBLE >0 ORDER BY        LOT.FECHA_VENCIMIENTO

							UPDATE AHPF_HN.ASHPF.EXISTENCIA_LOTE  
							SET CANT_DISPONIBLE = @CANT_DISPONIBLE_LOTE_ENSAMBLE + @CANTIDAD 
							WHERE ARTICULO=@ARTICULO AND BODEGA=@BODEGA AND LOCALIZACION=@LOCALIZACION_ENSAMBLE AND LOTE=@LOTE_ENSAMBLE

							--- ACTUALIZAR COSTO DE ARTICULO

							UPDATE AHPF_HN.ASHPF.ARTICULO  
							SET 
							COSTO_PROM_LOC = ROUND(  ( COSTO_PROM_LOC * @TEMP_CANT_DISPONIBLE + @COSTO_PROM_LOC * @CANTIDAD)   / (@TEMP_CANT_DISPONIBLE  + @CANTIDAD), 7 ),  
							COSTO_PROM_DOL = ROUND(  ( COSTO_PROM_DOL * @TEMP_CANT_DISPONIBLE + 0  * @CANTIDAD)   / ( @TEMP_CANT_DISPONIBLE + @CANTIDAD), 7 ),  
							COSTO_ULT_LOC = @COSTO_ULT_LOC , COSTO_ULT_DOL = 0            
							WHERE ARTICULO =@ARTICULO

							UPDATE AHPF_HN.ASHPF.ARTICULO		   
							SET ULTIMA_SALIDA = GETDATE() WHERE  ARTICULO = @ARTICULO
	

						END 

						--- ARTICULO TIPO COMSUMO  UTILIZA LOTES Y LOCALIZACION

						IF @TIPO = 'U' AND @USA_LOTE = 'N'
						BEGIN

						--- OBTENER EXISTENCIA ACTUAL												
							SET @CANT_DISPONIBLE_BODEGA =(SELECT CANT_DISPONIBLE 
							FROM AHPF_HN.ASHPF.EXISTENCIA_BODEGA WHERE ARTICULO=@ARTICULO AND BODEGA=@BODEGA)

						--- ACTUALIZAR EXISTENCIA DE BODEGA
							UPDATE AHPF_HN.ASHPF.EXISTENCIA_BODEGA  
							SET CANT_DISPONIBLE = @CANT_DISPONIBLE_BODEGA + @CANTIDAD 
							WHERE ARTICULO=@ARTICULO AND BODEGA=@BODEGA
									
							--- ACTUALIZAR COSTO DE ARTICULO

							UPDATE AHPF_HN.ASHPF.ARTICULO  
							SET 
							COSTO_PROM_LOC = ROUND(  ( COSTO_PROM_LOC * @TEMP_CANT_DISPONIBLE + @COSTO_PROM_LOC * @CANTIDAD)   / (@TEMP_CANT_DISPONIBLE  + @CANTIDAD), 7 ),  
							COSTO_PROM_DOL = ROUND(  ( COSTO_PROM_DOL * @TEMP_CANT_DISPONIBLE + 0  * @CANTIDAD)   / ( @TEMP_CANT_DISPONIBLE + @CANTIDAD), 7 ),  
							COSTO_ULT_LOC = @COSTO_ULT_LOC , COSTO_ULT_DOL = 0            
							WHERE ARTICULO =@ARTICULO

							UPDATE AHPF_HN.ASHPF.ARTICULO		   
							SET ULTIMA_SALIDA = GETDATE() WHERE  ARTICULO = @ARTICULO


						END 

						
						--- ACTUALIZAR TIPO TERMINADO KIT UTILIZA LOTES Y LOCALIZACION

						IF @TIPO = 'K' AND @USA_LOTE = 'N'

						BEGIN
						--- ACTUALIZAR EXISTENCIA DE BODEGA ENSAMBLE

								UPDATE AHPF_HN.ASHPF.EXISTENCIA_BODEGA  
								SET CANT_DISPONIBLE = 1.00000000
								WHERE ARTICULO=@ARTICULO_HIJO AND BODEGA=@BODEGA

								UPDATE AHPF_HN.ASHPF.ARTICULO		   
								SET ULTIMA_SALIDA = GETDATE() WHERE  ARTICULO = @ARTICULO_HIJO
							
						END 

						

						--- ARTICULO SERVICIO		

						IF @TIPO = 'V'
						BEGIN
						
						--- ACTUALIZAR EXISTENCIA DE BODEGA
							UPDATE AHPF_HN.ASHPF.EXISTENCIA_BODEGA  
							SET CANT_DISPONIBLE = 0.00000000
							WHERE ARTICULO=@ARTICULO AND BODEGA=@BODEGA


						END
		



	COMMIT TRANSACTION 
	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END
			EXECUTE ASHPF.Sp_LogError;
	END CATCH;
END









