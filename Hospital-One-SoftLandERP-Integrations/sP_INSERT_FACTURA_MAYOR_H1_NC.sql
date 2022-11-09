USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_INSERT_FACTURA_MAYOR_H1_NC]    Script Date: 11/9/2022 3:40:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [ASHPF].[sP_INSERT_FACTURA_MAYOR_H1_NC]
	-- Add the parameters for the stored procedure here
	@ROWPOINTER								NVARCHAR(MAX),
	@ASIENTO								VARCHAR(10),
	@LINEA_AUXILIAR							INT,
	@CTA_CONTABLE							VARCHAR(25),
	@CTO_COSTO								VARCHAR(25),
	@FACTURA								VARCHAR(50),
	@NC										VARCHAR(50),
	@TIPO									VARCHAR(1),
	@MONTO									DECIMAL(28, 8),
	@L_REGISTRO								CHAR(1),
	@R_EXITOSO								CHAR(1) OUTPUT,
	@ERROR									VARCHAR(400) OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		DECLARE @UID UNIQUEIDENTIFIER

		SET @UID = NEWID()

		BEGIN TRY
			BEGIN TRANSACTION 

				INSERT INTO AHPF_HN.ASHPF.CG_AUX(GUID_ORIGEN,TABLA_ORIGEN,ASIENTO,LINEA,COMENTARIO)
					VALUES(NEWID(),'FACTURA',@ASIENTO,@LINEA_AUXILIAR,'GUID - Origen') 

				--- MAYOR

					INSERT INTO AHPF_HN.ASHPF.MAYOR
						(ASIENTO,CONSECUTIVO,NIT,CENTRO_COSTO,CUENTA_CONTABLE,FECHA,TIPO_ASIENTO,FUENTE
						,REFERENCIA,ORIGEN,DEBITO_LOCAL,CREDITO_LOCAL,CONTABILIDAD,CLASE_ASIENTO
						,ESTADO_CONS_FISC,ESTADO_CONS_CORP,NoteExistsFlag,RecordDate,RowPointer
						,CreateDate,PROYECTO,FASE)

					SELECT @ASIENTO,@LINEA_AUXILIAR,'ND',@CTO_COSTO,@CTA_CONTABLE,(SELECT DATEADD(dd, DATEDIFF(dd, 0, CURRENT_TIMESTAMP), 0)),'PING',					
					'N/C#' + @NC +  (SELECT '/' + F.CLIENTE	FROM   AHPF_HN.ASHPF.FACTURA F WHERE  F.FACTURA = @FACTURA),
					'FAC#' + @FACTURA +  (SELECT ' - CLIENTE: ' + F.CLIENTE + ' - ' + F.NOMBRE_CLIENTE  FROM   AHPF_HN.ASHPF.FACTURA F WHERE  F.FACTURA = @FACTURA),'CXC',
					CASE @L_REGISTRO
						WHEN 'D' THEN ROUND(@MONTO, 2)
						ELSE NULL
					END,
					CASE @L_REGISTRO
						WHEN 'C' THEN ROUND(@MONTO, 2)
						ELSE NULL
					END,
					'A','N','P','P',0,GETDATE(),@UID,GETDATE(),' ',' '

							
						SET @R_EXITOSO	= 'S'
						SET @ERROR		= 'ND'

						EXECUTE AHPF_HN.ASHPF.sP_ACTUALIZAR_REFERENCIA @UID,@TIPO


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
				SET @R_EXITOSO = 'N'
				SET @ERROR = ERROR_MESSAGE()
		END CATCH
  
END



