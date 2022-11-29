USE [PRUEBA]
GO

/****** Object:  StoredProcedure [ASHPF].[sP_GET_Journal_Number]    Script Date: 27/01/2017 6:51:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ASHPF].[sP_GET_Journal_Number]
	-- Add the parameters for the stored procedure here
	@SerieFC		AS INT,
	@SerieOUT		AS NVARCHAR(19)	OUTPUT,
	@SerieFA		AS NVARCHAR(10) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    BEGIN TRY
		BEGIN TRANSACTION;

				DECLARE @GetSerieFC		AS NVARCHAR(19)
				DECLARE @GetAsientoFA	AS NVARCHAR(10)
				DECLARE @ConvertSerieFC	AS NVARCHAR(19)
				DECLARE @ConvertSerieFA	AS NVARCHAR(19)
				DECLARE @NewSerieFC		AS NVARCHAR(19)
				DECLARE @NewSerieFA		AS NVARCHAR(19)
				DECLARE @StringLeft		AS NVARCHAR(19)
				DECLARE @StringLeft_FA	AS NVARCHAR(10)
				
				

				IF EXISTS(SELECT * FROM ASHPF.CONSECUTIVO_FA WHERE Id_CONSECUTIVO = @SerieFC )
					BEGIN 

						-- FETCH Last Bill Number
						SELECT @GetSerieFC = c.VALOR_CONSECUTIVO FROM ASHPF.CONSECUTIVO_FA c WHERE c.Id_CONSECUTIVO = @SerieFC
						PRINT @GetSerieFC

						--- FETCH Last Journal Number 
							SELECT @GetAsientoFA = ULTIMO_ASIENTO FROM ASHPF.PAQUETE WHERE PAQUETE='FA'
							PRINT @GetAsientoFA
					END
					ELSE
					BEGIN
							SELECT @GetSerieFC = c.VALOR_CONSECUTIVO FROM ASHPF.CONSECUTIVO_FA c WHERE c.Id_CONSECUTIVO = @SerieFC
							PRINT @GetSerieFC
					END

					SET @StringLeft =  LEFT(@GetSerieFC,11) 
					SET @StringLeft_FA =  LEFT(@GetAsientoFA,2) 
				
					SET @ConvertSerieFC =  RIGHT(@GetSerieFC,8) + 1
					SET @ConvertSerieFA =  RIGHT(@GetAsientoFA,8) + 1
					

					SET @NewSerieFC = REPLICATE('0',8-LEN(@ConvertSerieFC))+RTRIM(CONVERT(char(9),@ConvertSerieFC))
					SET @NewSerieFA = REPLICATE('0',8-LEN(@ConvertSerieFA))+RTRIM(CONVERT(char(9),@ConvertSerieFA))
				
		
					IF EXISTS(SELECT * FROM ASHPF.CONSECUTIVO_FA AS c WHERE c.Id_CONSECUTIVO =@SerieFC )
						BEGIN
							UPDATE  ASHPF.CONSECUTIVO_FA SET VALOR_CONSECUTIVO=LEFT(@StringLeft,11) + @NewSerieFC WHERE Id_CONSECUTIVO = @SerieFC
							SET @SerieOUT = LEFT(@StringLeft,11) + @NewSerieFC
							
							UPDATE  ASHPF.PAQUETE SET ULTIMO_ASIENTO=LEFT(@StringLeft_FA,2) + @NewSerieFA WHERE PAQUETE='FA'
							SET @SerieFA = LEFT(@StringLeft_FA,2) + @NewSerieFA

					
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


GO

