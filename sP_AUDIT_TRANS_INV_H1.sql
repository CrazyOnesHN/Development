USE [PRUEBA]
GO

/****** Object:  StoredProcedure [ASHPF].[sP_AUDIT_TRANS_INV_H1]    Script Date: 22/11/2016 10:44:46 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jose rivera	
-- Create date: 17/11/2016
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ASHPF].[sP_AUDIT_TRANS_INV_H1]
	-- Add the parameters for the stored procedure here

	--@Id_AD				AS INT,
	@USUARIO			AS VARCHAR(25),
	@FECHA_HORA			AS DATE,
	@FECHA_PEDIDO		AS DATE,
	@CLIENTE			AS VARCHAR(20),
	@PEDIDO				AS VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	DECLARE @MAX_AUDITORIA		INT

	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;
					DECLARE	 @GetSerie		VARCHAR(10)
					DECLARE  @ConvertSerie	VARCHAR(10)
					DECLARE	 @NewSerie		VARCHAR(10)
					DECLARE	 @NewAudit		VARCHAR(10)
					
					SET @GetSerie   = (SELECT SIGUIENTE_CONSEC FROM ASHPF.CONSECUTIVO_CI c WHERE c.CONSECUTIVO = 'SOLICITUD9')
					SET @ConvertSerie =  RIGHT(@GetSerie,7) + 1
					SET @NewSerie = REPLICATE('0',7-LEN(@ConvertSerie))+RTRIM(CONVERT(char(9),@ConvertSerie))
		
					UPDATE  ASHPF.CONSECUTIVO_CI Set SIGUIENTE_CONSEC=LEFT(@GetSerie,2) + @NewSerie WHERE CONSECUTIVO = 'SOLICITUD9'
					SET @NewAudit = (SELECT LEFT(@GetSerie,3) + @NewSerie)
		 
    -- Insert statements for procedure here

							--- Insert Header on AUDIT_TRANS_INV

							INSERT INTO ASHPF.AUDIT_TRANS_INV
									   (USUARIO,FECHA_HORA,MODULO_ORIGEN,APLICACION,REFERENCIA
									   ,NoteExistsFlag,RecordDate,RowPointer,CreatedBy,UpdatedBy,CreateDate)

							VALUES 
							(@USUARIO,@FECHA_HORA,'FA',@NewAudit,@CLIENTE,0,@FECHA_PEDIDO,NEWID(),@USUARIO,@USUARIO,@FECHA_PEDIDO)

							--- Insert Details on TRANSACCION_INV
							
							SET @MAX_AUDITORIA = @@IDENTITY 


							EXEC ASHPF.sP_AUDIT_TRANS_INV_DETAILS_H1 @MAX_AUDITORIA,@PEDIDO


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

GO


