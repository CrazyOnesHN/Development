DECLARE	@BeginDate DATETIME='20230101'
DECLARE @EndDate   DATETIME='20231231'
DECLARE @SlpCode   INT=7;
	
	
WITH InternalReconciliation	AS
(
	SELECT 

		T1.[TransType], 
		T1.[BaseRef], 
		T3.DocEntry		'DocEntryFac',
		T3.TransId		'TransIDFac',
		T1.[TransId], 		
		ISNULL(T3.ReceiptNum,0)		'ReconcInitiatorInternalID',
		[dbo].[PromptPaymentDiscount] (T3.ReceiptNum,24,T3.DocEntry) 'PPDiscountDebitAmount',
		[dbo].[Get_PymntGroup](T1.[ShortName]) 	'PaymentTerms',
		ISNULL([dbo].[Get_PymntDiscount](T1.[ShortName]),0) 'Discount',
		T1.[Line_ID], 
		CASE 
			WHEN T2.[ReconType]=0 THEN 'Manual'
			WHEN T2.[ReconType]=1 THEN 'Automatic' 
			WHEN T2.[ReconType]=2 THEN 'Semi-Automatic'
			WHEN T2.[ReconType]=3 THEN 'Payment'
			WHEN T2.[ReconType]=4 THEN 'Credit Memo'
			WHEN T2.[ReconType]=6 THEN 'Zero Value'
			WHEN T2.[ReconType]=7 THEN 'Cancellation'
			WHEN T2.[ReconType]=8 THEN 'BoE'
			WHEN T2.[ReconType]=9 THEN 'Deposit'
			WHEN T2.[ReconType]=10 THEN 'Bank Statement Processing'
			WHEN T2.[ReconType]=11 THEN 'Period Closing'
			WHEN T2.[ReconType]=12 THEN 'Correction Invoice'
			WHEN T2.[ReconType]=13 THEN 'Inventory/Expense Allocation'
			WHEN T2.[ReconType]=14 THEN 'WIP'
			WHEN T2.[ReconType]=15 THEN 'Deferred Tax Interim Account'
			WHEN T2.[ReconType]=16 THEN 'Down Payment Allocation'
			WHEN T2.[ReconType]=17 THEN 'Auto. Conversion Difference'
			WHEN T2.[ReconType]=18 THEN 'Interim Document'
			WHEN T2.[ReconType]=19 THEN 'Withholding Tax Interim Account'
		END ReconType,
		T1.[RefDate]		'PostingDate', 
		T1.[DueDate]		'DueDate', 
		T2.[ReconDate]		'DateClosed', 	
		T1.[LineMemo], 	
		T0.[ReconSum], 	
		T1.BalDueDeb,
		T2.[ReconNum], 
		T1.[ShortName],
		T2.Canceled,
		T3.SlpCode,
		CASE
			WHEN T3.DocStatus='O' THEN 'Open'
			WHEN T3.DocStatus='C' THEN 'Closed'
		END 'DocStatus'
	   
	FROM ITR1 T0

			INNER JOIN JDT1 T1 ON T1.Line_ID=T0.TransRowId AND T1.TransId=T0.TransId
			INNER JOIN OITR T2 ON T2.ReconNum=T0.ReconNum
			LEFT JOIN OINV T3 ON T3.DocNum=T1.BaseRef


	WHERE 

		CONVERT(nvarchar(30), T2.[ReconDate], 112)>=CONVERT(NVARCHAR(30),@BeginDate, 112)	AND 
		CONVERT(nvarchar(30), T2.[ReconDate], 112)<=CONVERT(NVARCHAR(30),@EndDate, 112)		AND
		T3.SlpCode=@SlpCode									AND
		T2.Canceled='N'										
		--AND T2.[ReconType]=3 
		AND T2.[ReconType]<>6	
		AND T0.IsCredit='D'
		AND	T2.ReconNum =(SELECT MAX(TA.ReconNum) FROM ITR1 TA
							INNER JOIN JDT1 TB ON TB.Line_ID=TA.TransRowId AND TB.TransId=TA.TransId
							WHERE TB.BaseRef=T1.BaseRef AND TB.TransId=T1.TransId)			AND
		T3.DocStatus='C'


)
	
SELECT 

	IR.ReconNum,	
	T2.DocNum,
	IR.DocEntryFac,
	IR.TransIDFac,
	IR.ReconcInitiatorInternalID,
	IR.PPDiscountDebitAmount,		
	IR.PaymentTerms,
	IR.Discount,
	T2.DocStatus,
	T2.SlpCode,		
	T2.DocDate																AS 'InvDate',
	IR.DueDate,
	IR.DateClosed,			
	(SELECT TA.SlpName FROM OSLP TA WHERE TA.SlpCode=T2.SlpCode)			AS 'PrimarySlp',
	T7.ItmsGrpCod,

	-- FETCH ITEMS GROUP - COMMISIONS TYPE --
	CASE
		WHEN T7.ItmsGrpCod IN (110,111,114,112)		THEN 'Blanket'
		WHEN T7.ItmsGrpCod IN (131,132)				THEN 'Non KVI Blanket'
		WHEN T7.ItmsGrpCod IN (130)					THEN 'Chemicals'
		WHEN (SUBSTRING(T6.FrgnName,6,2)) = 'CW'	THEN 'Rapid Wash'
		WHEN T6.FrgnName=NULL						THEN 'All'
		ELSE 'Non Commissionable'
	END																		AS 'CommisionsType',		

	-- END LINE --			
	   	 			
	T2.CANCELED,
	T3.LineNum,
	T3.ItemCode				'Finished Goods',
	UPPER(T3.Dscription)	'Description',
	T3.GrossBuyPr			'Item Cost',
	T3.OpenQty				'Qty',
	T3.StockValue			'Total COGS',
	T3.Price				'Base Price',		
	T3.LineTotal,		
	T2.TotalExpns			'Freight',
	T2.VatSum				'Tax',
	T2.DocTotal				'Total',
	T3.GrssProfit			'Gross Profit',
				
	ISNULL(T8.U_commPerc,0)													AS 'CommissionsPerc',

	-- FETCH COMMISSIONS PERC --			
	CASE 

		WHEN IR.PPDiscountDebitAmount = 0 THEN ISNULL((T8.U_commPerc/100*T3.LineTotal),0)		
		WHEN IR.PPDiscountDebitAmount <> 0 THEN (T8.U_commPerc/100*[dbo].[Get_TempLineTotal] (IR.DocEntryFac,T3.LineNum,IR.Discount))

	END 'Commissions'

	-- END LINE --

	
	   
FROM OINV T2 

	INNER JOIN INV1 T3		 ON T3.DocEntry=T2.DocEntry
	LEFT  OUTER JOIN OSLP T4 ON T4.SlpCode=T2.SlpCode
	INNER JOIN OCRD T5		 ON T5.CardCode=T2.CardCode
	LEFT  OUTER JOIN OITM T6 ON T6.ItemCode=T3.ItemCode
	LEFT  OUTER JOIN OITB T7 ON T7.ItmsGrpCod=T6.ItmsGrpCod
	LEFT  OUTER JOIN [dbo].[@COMMPRIMARY] T8 ON T8.U_slpCode_P=T2.SlpCode AND T8.U_itmsGrpCod=CAST(T7.ItmsGrpCod AS VARCHAR)
	LEFT  OUTER JOIN InternalReconciliation AS IR ON IR.BaseRef=T2.DocNum	AND IR.SlpCode=T2.SlpCode 
	

WHERE 

	T2.CANCELED='N'		AND
	CONVERT(nvarchar(30),IR.DateClosed, 112)>=CONVERT(NVARCHAR(30),@BeginDate, 112)	AND
	CONVERT(nvarchar(30),IR.DateClosed, 112)<=CONVERT(NVARCHAR(30),@EndDate, 112)	AND	
	T2.DocType <> 'S'	
	--AND T2.DocStatus='C'	
	AND T2.SlpCode=@SlpCode
	

ORDER BY
	T2.DocNum,
	T3.LineNum


