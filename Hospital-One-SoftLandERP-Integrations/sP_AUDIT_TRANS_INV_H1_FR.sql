USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_AUDIT_TRANS_INV_H1_FR]    Script Date: 11/9/2022 3:31:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
ALTER PROCEDURE [ASHPF].[sP_AUDIT_TRANS_INV_H1_FR]

	@USUARIO					AS VARCHAR(25),
	@FECHA_HORA			AS DATE,
	@FECHA_PEDIDO		AS DATE,
	@CLIENTE					AS VARCHAR(20),
	@Id_FC							AS INT

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
					
					SET @GetSerie   = (SELECT SIGUIENTE_CONSEC FROM AHPF_HN.ASHPF.CONSECUTIVO_CI c WHERE c.CONSECUTIVO = 'SOL-H1')
					SET @ConvertSerie =  RIGHT(@GetSerie,7) + 1
					SET @NewSerie = REPLICATE('0',7-LEN(@ConvertSerie))+RTRIM(CONVERT(char(9),@ConvertSerie))
		
					UPDATE  AHPF_HN.ASHPF.CONSECUTIVO_CI 
					SET SIGUIENTE_CONSEC=LEFT(@GetSerie,2) + @NewSerie 
					WHERE CONSECUTIVO = 'SOL-H1'

					SET @NewAudit = (SELECT LEFT(@GetSerie,3) + @NewSerie)
		 
							-----------------------------------------------------------------------------------------------------------------
							-------- INSERTAR ENCABEZADO DE AUDITORIA DE INVENTARIO ---------------
							----------------------------------------------------------------------------------------------------------------

							INSERT INTO AHPF_HN.ASHPF.AUDIT_TRANS_INV
									   (USUARIO,FECHA_HORA,MODULO_ORIGEN,APLICACION,REFERENCIA
									   ,NoteExistsFlag,RecordDate,RowPointer,CreatedBy,UpdatedBy,CreateDate)

							VALUES 
							(@USUARIO,@FECHA_HORA,'FA',@NewAudit,@CLIENTE,0,@FECHA_PEDIDO,NEWID(),@USUARIO,@USUARIO,@FECHA_PEDIDO)

							------------------------------------------------------------------------------------------------------------------
							------------ GENERAR LINEAS DE AUDITORIA DE INVENTARIO -----------------------
							------------------------------------------------------------------------------------------------------------------
							
							SET @MAX_AUDITORIA = @@IDENTITY 


							--EXEC AHPF_HN.ASHPF.sP_AUDIT_TRANS_INV_DETAILS_H1_FR @MAX_AUDITORIA,@Id_FC

							EXECUTE AHPF_HN.ASHPF.sP_REGISTRO_INV_LN @MAX_AUDITORIA,@Id_FC


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

