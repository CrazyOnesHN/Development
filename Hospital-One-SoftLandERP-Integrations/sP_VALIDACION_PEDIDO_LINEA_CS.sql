USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_VALIDACION_PEDIDO_LINEA_CS]    Script Date: 11/9/2022 3:48:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [ASHPF].[sP_VALIDACION_PEDIDO_LINEA_CS]
	-- Add the parameters for the stored procedure here
	@Id_AR		   VARCHAR(20),
	@Id_LP			INT,
	@C_EXITOSA		   CHAR(1) OUTPUT,
	@ERROR			   VARCHAR(MAX) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @NIVEL_PRECIO		AS VARCHAR(20)
	DECLARE @ACTIVO				AS VARCHAR(1)
	

    -- Insert statements for procedure here
	BEGIN TRY
		BEGIN TRANSACTION

		SET @NIVEL_PRECIO = (SELECT TOP(1)N1.NIVEL_PRECIO FROM AHPF_HN.ASHPF.NIVEL_PRECIO AS N1
								INNER JOIN AHPF_HN.ASHPF.VERSION_NIVEL AS N2 ON N2.NIVEL_PRECIO = N1.NIVEL_PRECIO
								WHERE N1.Id_NIVEL_PRECIO=@Id_LP AND N2.ESTADO='A')

		SET @ACTIVO = (SELECT A1.ACTIVO FROM AHPF_HN.ASHPF.ARTICULO A1 WHERE A1.ARTICULO=@Id_AR)

		SET @ERROR = 'ND'
		SET @C_EXITOSA = 'S'
	
		-- VALIDAR SI EL ARTÍCULO SE ENCUENTRA ACTIVO 

			IF @ACTIVO = 'N'
			BEGIN
				SET @ERROR='ARTÍCULO SE ENCUENTRA INACTIVO, NO ES POSIBLE GENERAR LA ORDEN DE SERVICIO: ' + @Id_AR + '.'
				RAISERROR(@ERROR,16,1,1)
			END


		COMMIT TRANSACTION
	END TRY

		BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END
			EXECUTE ASHPF.Sp_LogError;
			SET @ERROR = ERROR_MESSAGE()
			SET @C_EXITOSA = 'N'
	END CATCH

END
