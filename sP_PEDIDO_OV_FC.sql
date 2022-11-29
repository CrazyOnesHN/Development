USE [PRUEBA]
GO

/****** Object:  StoredProcedure [ASHPF].[sP_PEDIDO_OV_FC]    Script Date: 22/11/2016 10:46:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jose Rivera
-- Create date: 09/11/2016
-- Description:	Extract and load Sales Order Header to FC
-- =============================================
CREATE PROCEDURE [ASHPF].[sP_PEDIDO_OV_FC]
	-- Add the parameters for the stored procedure here
	@Id_OV	AS	INT,
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
					BEGIN	TRANSACTION;


					-- Get Record to Insert FC --
							

							
							SELECT		@Id_UH					=	CO.Id_UH
										,@Id_DC					=	0
										,@TipoDocumento			=	'FC'
										,@Serie					=	RH.SerieFC
										,@Id_PT_FC				=	P.Id_PT
										,@Fecha					=	P.Fecha_Registro
										,@MetodoPago			=	C1.CONDICION_PAGO
										,@Estatus				=	'RE'
										,@Usuario_Registro		=	P.Usuario_Registro
										,@Fecha_Registro		=	P.Fecha_Registro
										,@Id_LP					=	P.Id_LP
										,@Id_PR					=	P.Id_PR
										,@UDF_Cliente			=	P.Id_PC
										,@UDF_Nombre_Paciente	=	PC1.NombreCompleto
																					
							FROM H1_ASHONPLAFA_385.dbo.OV AS P
		
											INNER JOIN PRUEBA.ASHPF.CLIENTE			AS C1	ON	C1.CLIENTE = P.Id_PT COLLATE SQL_Latin1_General_CP850_CI_AS
											LEFT JOIN H1_ASHONPLAFA_385.dbo.US		AS CO	ON	CO.Id_US = P.Id_US
											LEFT JOIN H1_ASHONPLAFA_385.dbo.UH		AS RH	ON	RH.Id_UH = CO.Id_UH
											LEFT JOIN H1_ASHONPLAFA_385.dbo.PC		AS PC1	ON	PC1.Id_PC = P.Id_PC
											LEFT JOIN PRUEBA.ASHPF.NIVEL_PRECIO		AS NP	ON	NP.Id_NIVEL_PRECIO = P.Id_LP
											LEFT JOIN PRUEBA.ASHPF.ARTICULO_PRECIO	AS AP	ON	AP.ARTICULO = P.Id_AR COLLATE SQL_Latin1_General_CP850_CI_AS AND AP.NIVEL_PRECIO = NP.NIVEL_PRECIO
											LEFT JOIN H1_ASHONPLAFA_385.dbo.PR		AS C	ON		C.Id_PR = P.Id_PR
											LEFT JOIN PRUEBA.ASHPF.DIRECC_EMBARQUE	AS DE	ON	DE.CLIENTE = P.Id_PT COLLATE SQL_Latin1_General_CP850_CI_AS

							WHERE   P.Id_PT = @Id_PT AND P.Id_OV = @Id_OV

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


