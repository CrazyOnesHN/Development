USE [PRUEBA]
GO

/****** Object:  StoredProcedure [ASHPF].[sP_PEDIDO_LINEA_OV_FCDT]    Script Date: 22/11/2016 10:46:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jose Rivera
-- Create date: 09/11/2016
-- Description:	Insert Sales Order Details Softland ERP
-- =============================================
CREATE PROCEDURE [ASHPF].[sP_PEDIDO_LINEA_OV_FCDT]
	-- Add the parameters for the stored procedure here
	@Id_OV				AS INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

		DECLARE @Linea				AS INT 
		DECLARE @Id_FC				AS INT
		DECLARE @Id_UH				AS NVARCHAR(20)
		DECLARE @Id_US				AS NVARCHAR(20)
		DECLARE @Id_LP				AS INT
		DECLARE @Id_AR				AS NVARCHAR(20)
		DECLARE @Descripcion		AS NVARCHAR(120)
		DECLARE	@Cantidad			AS DECIMAL(19,5)
		DECLARE	@PrecioUnitario		AS DECIMAL(19,5)
		DECLARE	@Impuesto			AS NVARCHAR(15)
		DECLARE	@Id_AL				AS NVARCHAR(8)
		DECLARE @Subtotal			AS DECIMAL(19,5)		
		DECLARE @Usuario_Registro	AS NVARCHAR(256)
		DECLARE @Fecha_Registro		AS DATETIME
		DECLARE @Saldo				AS DECIMAL(19,5)
		DECLARE @FLAG				AS INT 
		DECLARE @FLAG_FC			AS INT 
	
		
	
	SET NOCOUNT ON;

				BEGIN TRY
					BEGIN	TRANSACTION;

    -- Insert statements for procedure here
				SET @FLAG =(SELECT Id_OV FROM H1_ASHONPLAFA_385.dbo.OV WHERE Id_OV = @Id_OV)  
				SET @FLAG_FC = (SELECT MAX(Id_FC) FROM H1_ASHONPLAFA_385.dbo.FC)	
				
				DECLARE SELECT_OVAR CURSOR LOCAL
				FOR 

								SELECT @FLAG_FC,V1.Id_OV,V4.Id_UH,V1.Id_US,V1.Id_LP,V1.Id_AR,V3.ItemName, V1.Cantidad,V3.UnitPrice,'ND',V4.Almacen,(V1.Cantidad * V3.UnitPrice) AS Subtotal,
									   v1.Usuario_Registro, v1.Fecha_Registro,(V1.Cantidad * V3.UnitPrice) AS Saldo

			
								FROM H1_ASHONPLAFA_385.dbo.OV AS V1 
									LEFT JOIN H1_ASHONPLAFA_385.dbo.V_ITPR AS V3 ON
										V3.PriceList = V1.Id_LP AND V3.ItemCode = V1.Id_AR
									LEFT JOIN H1_ASHONPLAFA_385.dbo.US AS V4 ON
										V4.Id_US = V1.Id_US
							

								WHERE V1.Id_OV=@Id_OV

								UNION

								SELECT	@FLAG_FC,V2.Id_OV,V4.Id_UH,V1.Id_US,V1.Id_LP,V2.Id_AR,V3.ItemName, V2.Cantidad,V3.UnitPrice,'ND',V4.Almacen,(V2.Cantidad * V3.UnitPrice) AS Subtotal,
										V2.Usuario_Registro, V2.Fecha_Registro,(V1.Cantidad * V3.UnitPrice) AS Saldo

								FROM H1_ASHONPLAFA_385.dbo.OVAR AS V2 
									LEFT JOIN H1_ASHONPLAFA_385.dbo.OV AS V1 ON V1.Id_OV = V2.Id_OV
									LEFT JOIN H1_ASHONPLAFA_385.dbo.V_ITPR AS V3 ON V3.PriceList = V1.Id_LP AND V3.ItemCode = V2.Id_AR
									LEFT JOIN H1_ASHONPLAFA_385.dbo.US AS V4 ON	V4.Id_US = V1.Id_US
						
								
								WHERE V2.Id_OV =@Id_OV
					

				OPEN SELECT_OVAR

				FETCH SELECT_OVAR INTO @Id_FC,@Linea,@Id_UH,@Id_US,@Id_LP,@Id_AR,@Descripcion,@Cantidad, 
									   @PrecioUnitario,@Impuesto,@Id_AL,@Subtotal,@Usuario_Registro,@Fecha_Registro, 
									   @Saldo


				WHILE (@@FETCH_STATUS = 0)
				BEGIN;

					SELECT @Linea = ISNULL(MAX(ISNULL(Linea ,0)) ,0)+1 
					FROM   H1_ASHONPLAFA_385.dbo.FCDT
					WHERE  Id_FCDT =  (SELECT MAX(Id_FCDT) FROM H1_ASHONPLAFA_385.dbo.FCDT)

					INSERT INTO H1_ASHONPLAFA_385.dbo.FCDT
						(Id_FC,Linea,Id_UH,Id_US,Id_LP,Id_AR,Descripcion,Cantidad
						 ,PrecioUnitario,Impuesto,Id_AL,Subtotal,Usuario_Registro,Fecha_Registro,
						 Saldo)

					VALUES(@FLAG_FC,@Linea,@Id_UH,@Id_US,@Id_LP,@Id_AR,@Descripcion,@Cantidad, 
							@PrecioUnitario,@Impuesto,@Id_AL,@Subtotal,@Usuario_Registro,@Fecha_Registro, 
							@Saldo)

					FETCH SELECT_OVAR INTO  @Id_FC,@Linea,@Id_UH,@Id_US,@Id_LP,@Id_AR,@Descripcion,@Cantidad, 
									   @PrecioUnitario,@Impuesto,@Id_AL,@Subtotal,@Usuario_Registro,@Fecha_Registro, 
									   @Saldo;
				END;
				CLOSE SELECT_OVAR
				DEALLOCATE SELECT_OVAR		
				
				COMMIT TRANSACTION
				END TRY 
				BEGIN CATCH

					IF @@TRANCOUNT > 0
					BEGIN 
						ROLLBACK TRANSACTION;
					END
						EXECUTE ASHPF.Sp_LogError;
				END CATCH	
				
END

GO


