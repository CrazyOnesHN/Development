declare	@BeginDate DATETIME='20220901' 
declare @EndDate   DATETIME='20220930'
declare	@SlpCode   INT=17


SELECT 

	T1.[TransType], 
	T1.[BaseRef], 
	T1.[TransId], 
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
	T1.[RefDate]		'Posting Date', 
	T1.[DueDate]		'Due Date', 
	T2.[ReconDate]		'Date Closed', 	
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

	T2.[ReconDate]>=CONVERT(DATETIME,@BeginDate, 112)	AND 
	T2.[ReconDate]<=CONVERT(DATETIME,@EndDate, 112)		AND
	T3.SlpCode=@SlpCode									AND
	T2.Canceled='N'										
	AND T2.[ReconType]=3 

ORDER BY 
	T1.[BaseRef]




--SELECT * FROM ITR1 WHERE ShortName='C010023'