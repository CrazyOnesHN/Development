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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose rivera
-- Create date: 22/11/2016
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE ASHPF.sP_PEDIDO_AD_FC
	-- Add the parameters for the stored procedure here
	@Id_AD	AS	INT,
	@Id_PT	AS	NVARCHAR(15)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		DECLARE	@Id_UH						AS NVARCHAR(20)
		DECLARE @Id_DC						AS INT
		DECLARE	@TipoDocumento				AS NVARCHAR(32)
		DECLARE	@Serie						AS INT
		DECLARE	@Id_PT_FC					AS NVARCHAR(15)
		DECLARE @Id_OV_FC					AS INT
		DECLARE	@Fecha						AS DATETIME
		DECLARE	@MetodoPago					AS NVARCHAR(20)
		DECLARE	@Estatus					AS NVARCHAR(32)
		DECLARE	@Usuario_Registro			AS NVARCHAR(256)
		DECLARE	@Fecha_Registro				AS DATETIME
		DECLARE	@Id_LP						AS INT
		DECLARE	@Id_PR						AS INT
		DECLARE	@UDF_Cliente				AS NVARCHAR(200)
		DECLARE	@UDF_Nombre_Paciente		AS NVARCHAR(500)

	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		BEGIN TRANSACTION;

		-- Fetch data to Insert FC from AD --

						SELECT 
						@Id_UH					=	A.Id_UH
						,@Id_DC					=	0
						,@TipoDocumento			=	'FC'
						,@Serie					=	H.SerieFC
						,@Id_PT_FC				=	A.Id_PT
						,@Fecha					=	A.Fecha_Registro
						,@MetodoPago			=	C1.CONDICION_PAGO
						,@Estatus				=	'RE'
						,@Usuario_Registro		=	A.Usuario_Registro
						,@Fecha_Registro		=	A.Fecha_Registro
						,@Id_LP					=	A.Id_LP
						,@Id_PR					=	A.Medico
						,@UDF_Cliente			=	A.Id_PC
						,@UDF_Nombre_Paciente	=	P1.NombreCompleto



						FROM H1_ASHONPLAFA_385.dbo.AD AS A
							INNER JOIN PRUEBA.ASHPF.CLIENTE				AS C1	ON	C1.CLIENTE = A.Id_PT COLLATE SQL_Latin1_General_CP850_CI_AS
							INNER JOIN H1_ASHONPLAFA_385.dbo.PC			AS P1	ON	P1.Id_PC = A.Id_PC
							LEFT JOIN H1_ASHONPLAFA_385.dbo.UH			AS H	ON  H.Id_UH = A.Id_UH
							LEFT JOIN H1_ASHONPLAFA_385.dbo.ADHB		AS HB	ON  HB.Id_AD = A.Id_AD
	

						WHERE A.Id_AD=@Id_AD AND A.Id_PT=@Id_PT



		--- INSERT Extract And Load Sales Oder Header to FC ---
									
									INSERT INTO H1_ASHONPLAFA_385.dbo.FC
									(Id_UH,Id_DC,TipoDocumento,Serie,Id_PT,Fecha
									,MetodoPago,Estatus,Usuario_Registro,Fecha_Registro
									,Id_LP,Id_PR,UDF_Cliente,UDF_Nombre_Paciente)
									VALUES
									(@Id_UH,@Id_DC,@TipoDocumento,@Serie,@Id_PT_FC,@Fecha,
									@MetodoPago,@Estatus,@Usuario_Registro,@Fecha_Registro,
									@Id_LP,@Id_PR,@UDF_Cliente,@UDF_Nombre_Paciente)	
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
