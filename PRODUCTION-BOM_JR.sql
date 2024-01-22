
DECLARE	@BeginDate DATETIME='20210101';
DECLARE	@EndDate   DATETIME='20231013';


WITH ProductionHeader 	AS
	(
		SELECT 

		T0.DocEntry,
		T0.DocNum,
		T0.CreateDate,
		T0.U_BATCHNO			'Batch No',
		U_PRODNWHSE				'ProductionWarehouse',
		T0.U_ITEMCODE			'ItemCode',
		T0.U_WHSCODE			'Whs',
		T0.U_DESCRIPTION		'Description',
		T0.U_SONUMBER			'SO No',
		T0.U_CUSTOMERCODE		'CardCode',
		T0.U_TOTALACTUALCOST	'ActualCost',
		--T0.U_FORMULACODE,
		T0.U_SODOCENTRY		'SO DocEntry',
		CASE 

			WHEN T0.U_BATCHTYPE=1	THEN 'Mix'
			WHEN T0.U_BATCHTYPE=2	THEN 'Fill'
			WHEN T0.U_BATCHTYPE=3	THEN 'Assembly'
			WHEN T0.U_BATCHTYPE=4	THEN 'Rework'
			WHEN T0.U_BATCHTYPE=5	THEN 'Repack'
			WHEN T0.U_BATCHTYPE=6	THEN 'Disassembly'	

		END 'Batch Type',

		CASE

			WHEN T0.U_BATCHSTATUS=1	THEN	'Planned'
			WHEN T0.U_BATCHSTATUS=2	THEN	'New'
			WHEN T0.U_BATCHSTATUS=3	THEN	'Firm'
			WHEN T0.U_BATCHSTATUS=4	THEN	'Released'
			WHEN T0.U_BATCHSTATUS=5	THEN	'Hold'
			WHEN T0.U_BATCHSTATUS=6	THEN	'Cancelled'
			WHEN T0.U_BATCHSTATUS=7	THEN	'Completed'
			WHEN T0.U_BATCHSTATUS=8	THEN	'Closed'

		END 'BatchStatus'


		FROM "@BMM_PNMAST" T0

		WITH(NOLOCK) 

		WHERE 

		CONVERT(nvarchar(30), T0.CreateDate, 112)>=CONVERT(NVARCHAR(30),@BeginDate, 112)		AND 
		CONVERT(nvarchar(30), T0.CreateDate, 112)<=CONVERT(NVARCHAR(30),@EndDate, 112)			AND	
		T0.U_SONUMBER <>0																		AND	
		T0.DataSource='O'																		AND
		T0.U_BATCHSTATUS<>6
)

	SELECT   
	I.DocEntry,
	T0.CreateDate,
	I.U_BATCHNO		'Batch No',
	I.U_ITEMCODE	'ItemCode',
	I.U_WHSCODE		'Whs',	
	T3.ItmsGrpCod,
	I.U_ITEMDESC	'Description',
	--I.U_STDQTY		'Qty Required',
	I.U_ISSUEDRECEIVEDQTY	'Qty Produced',
	--I.U_STDQTYDISPUOM,
	I.U_UNITCOST	'Unit Cost',
	T0.ActualCost	'TotalCost',
	I.U_STOCKUOM	'UOM',
	I.U_BOMRECORDID	'LineID',
	I.U_SONUMBER	'SO No',
	I.U_CUSTOMER	'CustomerCode',
	O.CardName		'CustomerName',
	T0.[Batch Type],
	T0.BatchStatus,
	T4.SlpCode,
	T5.SlpName


	FROM "@BMM_PNITEM" I (NOLOCK) 

	LEFT OUTER JOIN "OCRD" O (NOLOCK) ON I.U_CUSTOMER = O."CardCode"  
	LEFT OUTER JOIN "@BMM_ITEM" (nolock) T on T."Code"=I.U_ITEMCODE and I.U_LINETYPE  IN(1,5,6,7,8)   
	LEFT OUTER JOIN ProductionHeader T0 ON T0.DocEntry=I.DocEntry	AND 
	T0.[Batch No]=I.U_BATCHNO		AND T0.ItemCode=I.U_ITEMCODE	AND T0.[SO No]=I.U_SONUMBER
	LEFT OUTER JOIN OITM T2 ON T2.ItemCode=I.U_ITEMCODE
	LEFT OUTER JOIN OITB T3 ON T3.ItmsGrpCod=T2.ItmsGrpCod
	LEFT OUTER JOIN ORDR T4 ON T4.DocNum=I.U_SONUMBER
	LEFT OUTER JOIN OSLP T5 ON T5.SlpCode=T4.SlpCode

	WHERE 
	
		I."DocEntry" = T0.DocEntry	AND
		T3.ItmsGrpCod	IN (110,111,114,112,131,132,130)

	ORDER BY T0.DocEntry,T0.CreateDate