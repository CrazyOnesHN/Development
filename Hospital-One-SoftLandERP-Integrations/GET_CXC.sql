USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[GET_CXC]    Script Date: 11/9/2022 3:27:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER PROCEDURE [ASHPF].[GET_CXC] 

	-- Add the parameters for the function here
	@PAQUETE							AS VARCHAR(4),
	@ULTIMO_ASIENTO				AS NVARCHAR(10)	OUTPUT

AS
BEGIN
	
	SET NOCOUNT ON; 
	
	DECLARE @GetAsientoCC		AS NVARCHAR(10)
	DECLARE @ConvertSerieCC		AS NVARCHAR(10)
	DECLARE @StringLeft_CC			AS NVARCHAR(10)
	DECLARE @NewSerieCC			AS NVARCHAR(10)
	DECLARE @SerieCC					AS NVARCHAR(10)

	BEGIN TRY
		BEGIN TRANSACTION
			
			--- OBTENER ULTIMO CONSECUTIVO ---

			SELECT @GetAsientoCC = 
			ULTIMO_ASIENTO FROM AHPF_HN.ASHPF.PAQUETE WITH (UPDLOCK) WHERE PAQUETE=@PAQUETE

				SET @StringLeft_CC			=  LEFT(@GetAsientoCC,3) 
				SET @ConvertSerieCC		=  RIGHT(@GetAsientoCC,6) + 1
				SET @NewSerieCC			= REPLICATE('0',7-LEN(@ConvertSerieCC))+RTRIM(CONVERT(char(9),@ConvertSerieCC))

				UPDATE  AHPF_HN.ASHPF.PAQUETE 
				SET ULTIMO_ASIENTO=LEFT(@StringLeft_CC,3) + @NewSerieCC 
				WHERE PAQUETE=@PAQUETE

				SET @SerieCC = LEFT(@StringLeft_CC,3) + @NewSerieCC
				SET @ULTIMO_ASIENTO = @SerieCC


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

