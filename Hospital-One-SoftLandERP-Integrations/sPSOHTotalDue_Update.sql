USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sPSOHTotalDue_Update]    Script Date: 11/9/2022 3:49:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jose Rivera
-- Create date: 09/11/2016
-- Description:	Update total due Sales Order Header Softland
-- =============================================
ALTER PROCEDURE [ASHPF].[sPSOHTotalDue_Update]
	-- Add the parameters for the stored procedure here
	@PEDIDO		AS VARCHAR(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @TOTAL_MERCADERIA		AS DECIMAL(28,8)
	DECLARE	@TOTAL_A_FACTURAR			AS DECIMAL(28,8)
	DECLARE @TOTAL_UNIDADES				AS DECIMAL(28,8)

    -- Insert statements for procedure here

	BEGIN TRY
		BEGIN TRANSACTION;

					-------------------------------------------------------------------------------------------------------------------------------------
													--- OBTENER MONTO TOTAL PEDIDO ---
					-------------------------------------------------------------------------------------------------------------------------------------

					SET 
					@TOTAL_MERCADERIA =(SELECT [AHPF_HN].[ASHPF].[GET_TOTALPEDIDO](@PEDIDO))

					UPDATE AHPF_HN.ASHPF.PEDIDO 
					SET 
					TOTAL_MERCADERIA = @TOTAL_MERCADERIA 
					WHERE PEDIDO = @PEDIDO

					SET 
					@TOTAL_A_FACTURAR =(SELECT [AHPF_HN].[ASHPF].[GET_TOTALPEDIDO](@PEDIDO))

					UPDATE AHPF_HN.ASHPF.PEDIDO 
					SET 
					TOTAL_A_FACTURAR =@TOTAL_A_FACTURAR 
					WHERE PEDIDO = @PEDIDO

					-------------------------------------------------------------------------------------------------------------------------------------
													--- OBTENER TOTAL UNIDADES PEDIDO ---
					-------------------------------------------------------------------------------------------------------------------------------------

					SET @TOTAL_UNIDADES = (SELECT  SUM(FL.CANTIDAD_FACTURADA) FROM AHPF_HN.ASHPF.PEDIDO_LINEA AS FL WITH(NOLOCK) WHERE FL.PEDIDO = @PEDIDO)

					UPDATE AHPF_HN.ASHPF.PEDIDO 
					SET 
					TOTAL_UNIDADES = @TOTAL_UNIDADES 
					WHERE PEDIDO = @PEDIDO


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





