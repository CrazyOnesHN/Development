USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[GET_F1]    Script Date: 11/9/2022 3:28:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER PROCEDURE [ASHPF].[GET_F1] 

	-- Add the parameters for the function here
	@PAQUETE							AS VARCHAR(4),
	@ULTIMO_ASIENTO						AS NVARCHAR(10)	OUTPUT

AS
BEGIN
	
	SET NOCOUNT ON; 


	
	DECLARE @GetAsientoF1		AS NVARCHAR(10)
	DECLARE @ConvertSerieF1		AS NVARCHAR(10)
	DECLARE @StringLeft_F1		AS NVARCHAR(10)
	DECLARE @NewSerieF1			AS NVARCHAR(10)
	DECLARE @SerieF1			AS NVARCHAR(10)

	BEGIN TRY
		BEGIN TRANSACTION
			
			--- OBTENER ULTIMO CONSECUTIVO ---

			SELECT @GetAsientoF1 = 
			ULTIMO_ASIENTO FROM AHPF_HN.ASHPF.PAQUETE WHERE PAQUETE=@PAQUETE

				SET @StringLeft_F1		=  LEFT(@GetAsientoF1,2) 
				SET @ConvertSerieF1		=  RIGHT(@GetAsientoF1,8) + 1
				SET @NewSerieF1			= REPLICATE('0',8-LEN(@ConvertSerieF1))+RTRIM(CONVERT(char(9),@ConvertSerieF1))

				UPDATE  AHPF_HN.ASHPF.PAQUETE 
				SET ULTIMO_ASIENTO=LEFT(@StringLeft_F1,2) + @NewSerieF1 
				WHERE PAQUETE=@PAQUETE

				SET @SerieF1 = LEFT(@StringLeft_F1,2) + @NewSerieF1
				SET @ULTIMO_ASIENTO = @SerieF1


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
	END CATCH;

END

