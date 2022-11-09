USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_ST_H1_AD_ERP_]    Script Date: 11/9/2022 3:47:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [ASHPF].[sP_ST_H1_AD_ERP_]
	-- Add the parameters for the stored procedure here
	@Id_AD	INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Id_ADHB	AS INT
	DECLARE @Controller AS NVARCHAR(128)
	DECLARE @Id			AS NVARCHAR(128)
	DECLARE @Status		AS NVARCHAR(16)
	DECLARE @Usuario	AS NVARCHAR(256)

	BEGIN TRY
		BEGIN TRANSACTION;

    -- Insert statements for procedure here

	SET @Id_ADHB =(SELECT Id_ADHB FROM H1_AHPF_HN.dbo.ADHB WITH(NOLOCK) where id_ad=@Id_AD)

			DECLARE SELECT_SA CURSOR LOCAL
			FOR 

					SELECT 	Controller,Id_SA,Status,SA.Usuario

					FROM H1_AHPF_HN.dbo.V_SA AS SA WITH(NOLOCK)
						 INNER JOIN H1_AHPF_HN.dbo.V__ST AS ST ON ST.Id = SA.Id_SA
					WHERE ST.Status='PR' AND SA.Id_ADHB=@Id_ADHB
	
			OPEN SELECT_SA

			FETCH SELECT_SA INTO @Controller, @Id,@Status,@Usuario

			WHILE (@@FETCH_STATUS = 0 )
			BEGIN;

				UPDATE [H1_AHPF_HN].[dbo].[_ST] 
				   SET Date = GETDATE()
					  ,@Controller =Controller  
					  ,@Id =Id 
					  ,Status = 'RC'
					  , @Usuario =User

				  WHERE Status='PR' AND Id=@Id

				  FETCH SELECT_SA INTO  @Controller, @Id,@Status,@Usuario
			END;
			CLOSE SELECT_SA
			DEALLOCATE SELECT_SA


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



