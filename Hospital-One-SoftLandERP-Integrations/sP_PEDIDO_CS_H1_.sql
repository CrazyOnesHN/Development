USE [AHPF_HN]
GO
/****** Object:  StoredProcedure [ASHPF].[sP_PEDIDO_CS_H1_]    Script Date: 11/9/2022 3:45:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [ASHPF].[sP_PEDIDO_CS_H1_] 
	-- Add the parameters for the stored procedure here
	 @Id_PRCSHO AS INT
	 ,@Id_ADRX AS INT
	 ,@Id_UH	 AS VARCHAR(50)
	 ,@Mensaje	INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	------ SalesOrder Header

		DECLARE	@PEDIDO				AS VARCHAR(20) 
		DECLARE @ESTADO				AS VARCHAR(1)		='N'
		DECLARE @FECHA_PEDIDO		AS DATE				
		DECLARE @FECHA_PROMETIDA	AS DATE				
		DECLARE @FECHA_PROX_EMBARQU	AS DATE				
		DECLARE @EMBARCAR_A			AS VARCHAR(80)
		DECLARE @DIREC_EMBARQUE		AS VARCHAR(8)
		DECLARE @TOTAL_MERCADERIA	AS DECIMAL(28,8)    =0.00000000
		DECLARE @MONTO_ANTICIPO		AS DECIMAL(28,8)	=0
		DECLARE @MONTO_FLETE		AS DECIMAL(28,8)	=0
		DECLARE @MONTO_SEGURO		AS DECIMAL(28,8)	=0
		DECLARE @MONTO_DOCUMENTACIO	AS DECIMAL(28,8)	=0
		DECLARE @TIPO_DESCUENTO1	AS VARCHAR(1)		='P'
		DECLARE @TIPO_DESCUENTO2	AS VARCHAR(1)		='P'
		DECLARE @MONTO_DESCUENTO1	AS DECIMAL(28,8)	=0
		DECLARE @MONTO_DESCUENTO2	AS DECIMAL(28,8)	=0
		DECLARE @PORC_DESCUENTO1	AS DECIMAL(28,8)	=0
		DECLARE @PORC_DESCUENTO2	AS DECIMAL(28,8)	=0
		DECLARE @TOTAL_IMPUESTO1	AS DECIMAL(28,8)	=0
		DECLARE @TOTAL_IMPUESTO2	AS DECIMAL(28,8)	=0
		DECLARE	@TOTAL_A_FACTURAR	AS DECIMAL(28,8)    =0.00000000
		DECLARE @PORC_COMI_VENDEDOR	AS DECIMAL(28,8)	=0
		DECLARE @PORC_COMI_COBRADOR	AS DECIMAL(28,8)	=0
		DECLARE @TOTAL_CANCELADO	AS DECIMAL(28,8)	=0
		DECLARE @TOTAL_UNIDADES		AS DECIMAL(28,8)    =0
		DECLARE	@IMPRESO			AS VARCHAR(1)		='N'
		DECLARE	@FECHA_HORA			AS DATE
		DECLARE @DESCUENTO_VOLUMEN	AS DECIMAL(28,8)	=0
		DECLARE @TIPO_PEDIDO		AS VARCHAR(1)		='N'
		DECLARE	@MONEDA_PEDIDO		AS VARCHAR(1)       ='L'
		DECLARE @VERSION_NP			AS INT	
		DECLARE	@AUTORIZADO			AS VARCHAR(1)		='N'
		DECLARE	@DOC_A_GENERAR		AS VARCHAR(1)		='F'
		DECLARE	@CLASE_PEDIDO		AS VARCHAR(1)		='N'
		DECLARE @MONEDA				AS VARCHAR(1)       ='L' 
		DECLARE	@NIVEL_PRECIO		AS VARCHAR(12)
		DECLARE	@COBRADOR			AS VARCHAR(4)
		DECLARE	@RUTA				AS VARCHAR(4)
		DECLARE	@USUARIO			AS VARCHAR(25)
		DECLARE	@CONDICION_PAGO		AS VARCHAR(4)
		DECLARE	@BODEGA				AS VARCHAR(4)
		DECLARE	@ZONA				AS VARCHAR(4)
		DECLARE	@VENDEDOR			AS VARCHAR(4)		='ND'
		DECLARE	@CLIENTE			AS VARCHAR(20)
		DECLARE	@CLIENTE_DIRECCION	AS VARCHAR(20)
		DECLARE	@CLIENTE_CORPORAC	AS VARCHAR(20)
		DECLARE	@CLIENTE_ORIGEN		AS VARCHAR(20)
		DECLARE	@PAIS				AS VARCHAR(4)
		DECLARE	@BACKORDER			AS VARCHAR(1)		='N'
		DECLARE	@DESCUENTO_CASCADA	AS VARCHAR(1)		='N'
		DECLARE	@DIRECCION_FACTURA	AS VARCHAR(4000) 
		DECLARE	@FIJAR_TIPO_CAMBIO	AS VARCHAR(1)		='N'
		DECLARE	@ORIGEN_PEDIDO		AS VARCHAR(1)		='F'
		DECLARE	@TIPO_DOCUMENTO		AS VARCHAR(1)		='P'
		DECLARE @SUBTIPO_DOC_CXC	AS SMALLINT			=0
		DECLARE @TIPO_DOC_CXC		AS VARCHAR(3)		='FAC'
		DECLARE @NoteExistsFlag		AS TINYINT
		DECLARE @RecordDate			AS DATETIME
		DECLARE @RowPointer			AS UNIQUEIDENTIFIER 
		DECLARE @CreatedBy			AS VARCHAR(30)
		DECLARE @UpdatedBy			AS VARCHAR(30)
		DECLARE @CreateDate			AS DATETIME
		----------- END ------------
		DECLARE @FLAG				AS INT
		DECLARE @Id_PT				AS	VARCHAR(20)
		DECLARE @SerieOV			INT
		DECLARE @FLAG_PEDIDO		AS VARCHAR(30)
		DECLARE @Id_US				AS NVARCHAR(16)
		DECLARE @Referencia1		AS NVARCHAR(32)
		DECLARE @Id_PR				AS INT
		DECLARE @Almacen			AS NVARCHAR(8)
		DECLARE @Nombre				AS VARCHAR(20)
		DECLARE @VERSION_NP_H1		AS INT =1
		--DECLARE @Id_ADRX			AS INT
		
		SELECT @Mensaje=0

	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;
		----------- Fetch New Sales Order ID ----------
				SET @SerieOV= (SELECT SerieOV  FROM H1_AHPF_HN.dbo.UH WHERE Id_UH =@Id_UH)
		--- Call sP ASHPF.sPGetSerieOVERP ---
		DECLARE @SerieO AS NVARCHAR(10);
		EXECUTE  AHPF_HN.ASHPF.sPGetSerieOVERP @SerieOV, @SerieOUT = @SerieO OUTPUT;

		SELECT @SerieOV,@SerieO
		--------- END ---------------			
		----------- Fetch Id_OV and Id_PT  ----------
		SET @FLAG_PEDIDO	=@SerieO
		SET @Id_PT			=(SELECT top 1 UDF_Id_PT FROM H1_AHPF_HN.dbo.ADRX  WITH(NOLOCK) WHERE Id_ADRX=@Id_ADRX)	
		SET @Id_PR			=(SELECT top 1 Id_PR FROM H1_AHPF_HN.dbo.ADRX  WITH(NOLOCK) WHERE Id_PRCSHO=@Id_PRCSHO)
		SET @Referencia1	=(SELECT TOP 1 PR.Referencia1 FROM H1_AHPF_HN.dbo.PR AS PR  WITH(NOLOCK)  INNER JOIN H1_AHPF_HN.dbo.ADRX AS ADRX ON ADRX.Id_PR = PR.Id_PR  WHERE PR.Id_PR=@Id_PR AND ADRX.Id_PRCSHO=@Id_PRCSHO)
		SET @Almacen        =(SELECT DISTINCT TOP 1 UDF_Id_AL FROM H1_AHPF_HN.dbo.ADRXAR  WITH(NOLOCK) WHERE Id_ADRX=@Id_ADRX)
		SET @Nombre			=(SELECT NP.PriceListName FROM H1_AHPF_HN.dbo.PRCSHO AS PRCSHO  WITH(NOLOCK)
								INNER JOIN H1_AHPF_HN.dbo.V_PL AS NP ON NP.PriceList = PRCSHO.Id_LP WHERE PRCSHO.Id_PRCSHO = @Id_PRCSHO)
		SET	@VERSION_NP_H1	=1
        SELECT 
		@PEDIDO =(SELECT  @FLAG_PEDIDO),@ESTADO='N',@FECHA_PEDIDO =P.Fecha,@FECHA_PROMETIDA =P.Fecha 
		,@FECHA_PROX_EMBARQU =P.Fecha,@EMBARCAR_A =C1.NOMBRE,@DIREC_EMBARQUE =DE.DIRECCION,@TOTAL_MERCADERIA =0.00000000
		,@MONTO_ANTICIPO =0,@MONTO_FLETE =0,@MONTO_SEGURO =0,@MONTO_DOCUMENTACIO =0,@TIPO_DESCUENTO1 ='P',@TIPO_DESCUENTO2 ='P'
		,@MONTO_DESCUENTO1 =0,@MONTO_DESCUENTO2 =0,@PORC_DESCUENTO1 =0,@PORC_DESCUENTO2 =0,@TOTAL_IMPUESTO1 =0,@TOTAL_IMPUESTO2 =0
		,@TOTAL_A_FACTURAR =0.00000000,@PORC_COMI_VENDEDOR =0,@PORC_COMI_COBRADOR =0,@TOTAL_CANCELADO =0
		,@TOTAL_UNIDADES =0,@IMPRESO ='N',@FECHA_HORA =P.Fecha,@DESCUENTO_VOLUMEN =0,@TIPO_PEDIDO ='N',@MONEDA_PEDIDO ='L'
		,@VERSION_NP =@VERSION_NP_H1,@AUTORIZADO ='N',@DOC_A_GENERAR ='F',@CLASE_PEDIDO ='N',@MONEDA ='L' 
		,@NIVEL_PRECIO =@Nombre,
		@COBRADOR = @Referencia1,
		@RUTA =C1.RUTA,@USUARIO =P.Usuario_Registro,@CONDICION_PAGO =C1.CONDICION_PAGO,
		@BODEGA =@Almacen,
		@ZONA =C1.ZONA,@VENDEDOR ='ND',@CLIENTE =Q.UDF_Id_PT,@CLIENTE_DIRECCION =Q.UDF_Id_PT,@CLIENTE_CORPORAC =Q.UDF_Id_PT 
		,@CLIENTE_ORIGEN =Q.UDF_Id_PT,@PAIS =C1.PAIS,@SUBTIPO_DOC_CXC =0,@TIPO_DOC_CXC ='FAC',@BACKORDER ='N',@DESCUENTO_CASCADA ='N' 
		,@DIRECCION_FACTURA =DE.DIRECCION,@FIJAR_TIPO_CAMBIO ='N',@ORIGEN_PEDIDO ='F',@TIPO_DOCUMENTO ='P',@NoteExistsFlag =0
		,@RecordDate =P.Fecha_Registro,@RowPointer =NEWID(),@CreatedBy =P.Usuario_Registro ,@UpdatedBy =P.Usuario_Registro ,@CreateDate =P.Fecha_Registro 										
		FROM H1_AHPF_HN.dbo.PRCSHO AS P  WITH(NOLOCK)
		INNER JOIN H1_AHPF_HN.dbo.ADRX AS Q ON P.Id_PRCSHO=Q.Id_PRCSHO
		INNER JOIN AHPF_HN.ASHPF.CLIENTE AS C1 ON C1.CLIENTE = Q.UDF_Id_PT COLLATE SQL_Latin1_General_CP850_CI_AS
		INNER JOIN AHPF_HN.ASHPF.DIRECC_EMBARQUE AS DE ON DE.CLIENTE = Q.UDF_Id_PT COLLATE SQL_Latin1_General_CP850_CI_AS
		WHERE  Q.UDF_Id_PT = @Id_PT AND P.Id_PRCSHO =@Id_PRCSHO AND Q.Id_ADRX=@Id_ADRX
		
		EXEC erpadmin.GrabarUsuarioActual @USUARIO
		---------- INSERT Sales Orde Header in ERP --------
		INSERT INTO AHPF_HN.ASHPF.PEDIDO
		(PEDIDO,ESTADO,FECHA_PEDIDO,FECHA_PROMETIDA,FECHA_PROX_EMBARQU,EMBARCAR_A,DIREC_EMBARQUE,TOTAL_MERCADERIA,MONTO_ANTICIPO,MONTO_FLETE,
		MONTO_SEGURO,MONTO_DOCUMENTACIO,TIPO_DESCUENTO1,TIPO_DESCUENTO2,MONTO_DESCUENTO1,MONTO_DESCUENTO2,PORC_DESCUENTO1,PORC_DESCUENTO2,TOTAL_IMPUESTO1,TOTAL_IMPUESTO2,
		TOTAL_A_FACTURAR,PORC_COMI_VENDEDOR,PORC_COMI_COBRADOR,TOTAL_CANCELADO,TOTAL_UNIDADES,IMPRESO,FECHA_HORA,DESCUENTO_VOLUMEN,TIPO_PEDIDO,MONEDA_PEDIDO,VERSION_NP,
		AUTORIZADO,DOC_A_GENERAR,CLASE_PEDIDO,MONEDA,NIVEL_PRECIO,COBRADOR,RUTA,USUARIO,CONDICION_PAGO,
		BODEGA,
		ZONA,VENDEDOR,CLIENTE,CLIENTE_DIRECCION,CLIENTE_CORPORAC,CLIENTE_ORIGEN,PAIS,SUBTIPO_DOC_CXC,TIPO_DOC_CXC,BACKORDER,DESCUENTO_CASCADA,NoteExistsFlag,RecordDate,RowPointer, 
		CreatedBy,UpdatedBy,CreateDate,DIRECCION_FACTURA,FIJAR_TIPO_CAMBIO,ORIGEN_PEDIDO,TIPO_DOCUMENTO)
		VALUES
		(@PEDIDO,@ESTADO,GETDATE(),GETDATE(),GETDATE(),@EMBARCAR_A,@DIREC_EMBARQUE,@TOTAL_MERCADERIA,@MONTO_ANTICIPO,@MONTO_FLETE,
		@MONTO_SEGURO,@MONTO_DOCUMENTACIO,@TIPO_DESCUENTO1,@TIPO_DESCUENTO2,@MONTO_DESCUENTO1,@MONTO_DESCUENTO2,@PORC_DESCUENTO1,@PORC_DESCUENTO2,@TOTAL_IMPUESTO1,@TOTAL_IMPUESTO2,
		@TOTAL_A_FACTURAR,@PORC_COMI_VENDEDOR,@PORC_COMI_COBRADOR,@TOTAL_CANCELADO,@TOTAL_UNIDADES,@IMPRESO,@FECHA_HORA,@DESCUENTO_VOLUMEN,@TIPO_PEDIDO,@MONEDA_PEDIDO,@VERSION_NP,
		@AUTORIZADO,@DOC_A_GENERAR,@CLASE_PEDIDO,@MONEDA,@NIVEL_PRECIO,@COBRADOR,@RUTA,ISNULL((SELECT USUARIO FROM erpadmin.USUARIO WHERE usuario=@USUARIO),'SA'),@CONDICION_PAGO,
		@BODEGA,
		@ZONA,@VENDEDOR,@CLIENTE,@CLIENTE_DIRECCION,@CLIENTE_CORPORAC,@CLIENTE_ORIGEN,@PAIS,@SUBTIPO_DOC_CXC,@TIPO_DOC_CXC,@BACKORDER,@DESCUENTO_CASCADA,@NoteExistsFlag,@RecordDate,@RowPointer, 
		@USUARIO,@USUARIO,@CreateDate,@DIRECCION_FACTURA,@FIJAR_TIPO_CAMBIO,@ORIGEN_PEDIDO,@TIPO_DOCUMENTO)

		-- Scannig Sales Order Lines --
		EXEC  AHPF_HN.ASHPF.sP_PEDIDO_LINEA_CS_H1_ @Id_ADRX, @PEDIDO
		
		---- Update Total Due SalesOrderHeader --
		EXEC  AHPF_HN.ASHPF.sPSOHTotalDue_Update @PEDIDO		
		EXEC erpadmin.LeerUsuarioActual @USUARIO
		
		UPDATE AHPF_HN.ASHPF.PEDIDO SET CreatedBy=@USUARIO,UpdatedBy=@USUARIO WHERE PEDIDO=@PEDIDO
		UPDATE AHPF_HN.ASHPF.PEDIDO_LINEA SET CreatedBy=@USUARIO,UpdatedBy=@USUARIO WHERE PEDIDO=@PEDIDO
		COMMIT TRANSACTION
		END TRY 
		BEGIN CATCH
          
			IF @@TRANCOUNT > 0
			BEGIN 
				ROLLBACK TRANSACTION;
			END
				EXECUTE ASHPF.Sp_LogError;
			
			SELECT @Mensaje=1
			RETURN @Mensaje
		END CATCH;

		IF @Mensaje=0
			UPDATE H1_AHPF_HN.dbo.ADRX  SET UDF_Pedido=@PEDIDO WHERE Id_ADRX=@Id_ADRX
		RETURN @Mensaje
END
