USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_GET_SERIAL_CXC]    Script Date: 11/9/2022 3:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [ASHPF].[sP_GET_SERIAL_CXC] 
	-- Add the parameters for the stored procedure here
	@SerieTR		AS INT,
	@SerieOUT		AS NVARCHAR(50)	OUTPUT,
	@SerieCC		AS NVARCHAR(10) OUTPUT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

     BEGIN TRY
		BEGIN TRANSACTION;

				DECLARE @GetSerieRC		AS NVARCHAR(50)
				DECLARE @GetAsientoCC	AS NVARCHAR(10)

				DECLARE @ConvertSerieRC	AS NVARCHAR(50)
				DECLARE @ConvertSerieCC	AS NVARCHAR(10)

				DECLARE @NewSerieRC		AS NVARCHAR(50)
				DECLARE @NewSerieCC		AS NVARCHAR(10)

				DECLARE @StringLeft		AS NVARCHAR(50)
				DECLARE @StringLeft_CC	AS NVARCHAR(10)
				
				

				IF EXISTS(SELECT * FROM AHPF_HN.ASHPF.CONSECUTIVO WITH (UPDLOCK) WHERE Id_CONSECUTIVO = @SerieTR )
					BEGIN 

						-- FETCH Last REC Number
						SELECT @GetSerieRC = ULTIMO_VALOR FROM AHPF_HN.ASHPF.CONSECUTIVO WITH (UPDLOCK) WHERE Id_CONSECUTIVO = @SerieTR
						PRINT @GetSerieRC

						--- FETCH Last CXC Number 
							SELECT @GetAsientoCC = ULTIMO_ASIENTO FROM AHPF_HN.ASHPF.PAQUETE WITH (UPDLOCK) WHERE PAQUETE='CC1'
							PRINT @GetAsientoCC
					END
					ELSE
					BEGIN
							SELECT @GetSerieRC = ULTIMO_VALOR FROM AHPF_HN.ASHPF.CONSECUTIVO WITH (UPDLOCK) WHERE Id_CONSECUTIVO = @SerieTR
							PRINT @GetSerieRC
					END

					SET @StringLeft =  LEFT(@GetSerieRC,7) 
					SET @StringLeft_CC =  LEFT(@GetAsientoCC,3) 
				
					SET @ConvertSerieRC =  RIGHT(@GetSerieRC,6) + 1
					SET @ConvertSerieCC =  RIGHT(@GetAsientoCC,6) + 1
					

					SET @NewSerieRC = REPLICATE('0',7-LEN(@ConvertSerieRC))+RTRIM(CONVERT(char(9),@ConvertSerieRC))
					SET @NewSerieCC = REPLICATE('0',7-LEN(@ConvertSerieCC))+RTRIM(CONVERT(char(9),@ConvertSerieCC))
				
		
					IF EXISTS(SELECT * FROM AHPF_HN.ASHPF.CONSECUTIVO WITH (UPDLOCK) WHERE Id_CONSECUTIVO =@SerieTR )
						BEGIN
							UPDATE  AHPF_HN.ASHPF.CONSECUTIVO SET ULTIMO_VALOR=LEFT(@StringLeft,7) + @NewSerieRC WHERE Id_CONSECUTIVO = @SerieTR
							SET @SerieOUT = LEFT(@StringLeft,7) + @NewSerieRC
							
							UPDATE  AHPF_HN.ASHPF.PAQUETE SET ULTIMO_ASIENTO=LEFT(@StringLeft_CC,3) + @NewSerieCC WHERE PAQUETE='CC1'
							SET @SerieCC = LEFT(@StringLeft_CC,3) + @NewSerieCC

					
						END

				


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
	END CATCH
	
END


