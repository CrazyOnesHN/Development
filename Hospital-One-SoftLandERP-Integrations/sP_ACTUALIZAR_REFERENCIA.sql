USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_ACTUALIZAR_REFERENCIA]    Script Date: 11/9/2022 3:29:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [ASHPF].[sP_ACTUALIZAR_REFERENCIA]
	-- Add the parameters for the stored procedure here
	@UID									VARCHAR(MAX),
	@TIPO									VARCHAR(1)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		BEGIN TRY
			BEGIN TRANSACTION 
			
			----------- AGREGAR FORMA DE PAGO A REFERENCIA --------------

						DECLARE @TEMP_REFERENCIA		AS VARCHAR(249)

						SELECT @TEMP_REFERENCIA = REFERENCIA FROM AHPF_HN.ASHPF.MAYOR WITH(NOLOCK) WHERE  RowPointer=@UID

								IF @TIPO = 'E'
								BEGIN  
									UPDATE  AHPF_HN.ASHPF.MAYOR
									SET REFERENCIA =  'EFVO :' + ' - ' + @TEMP_REFERENCIA 
									WHERE  RowPointer=@UID
								END

								IF @TIPO = 'T'
								BEGIN  
									UPDATE  AHPF_HN.ASHPF.MAYOR
									SET REFERENCIA =  'T/C :' + ' -  ' + @TEMP_REFERENCIA 
									WHERE  RowPointer=@UID
								END

								IF @TIPO = 'X'
								BEGIN  
									UPDATE  AHPF_HN.ASHPF.MAYOR
									SET REFERENCIA =  'CRED :' + ' -  ' + @TEMP_REFERENCIA 
									WHERE  RowPointer=@UID
								END

								IF @TIPO = 'N'
								BEGIN  
									UPDATE  AHPF_HN.ASHPF.MAYOR
									SET REFERENCIA =  'ND :' + ' -  ' + @TEMP_REFERENCIA 
									WHERE  RowPointer=@UID
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
		END CATCH
END
