
DECLARE	@BeginDate DATETIME='20220101'
DECLARE	@EndDate   DATETIME='20230531'

SELECT DISTINCT

T0.DocEntry,
T0.Status,
T0.CreateDate,
T0.U_BATCHNO,
T0.U_REVISIONNO,
T0.U_ITEMCODE,
T0.U_WHSCODE,
T0.U_DESCRIPTION,
T0.U_SONUMBER,
T0.U_CUSTOMERCODE,
ISNULL(T1.U_BOMCOST,0)	'BOMCost'

FROM "@BMM_PNMAST" T0 

	LEFT OUTER JOIN "@BMM_BOM" T1 ON T1.U_FGCODE=T0.U_ITEMCODE AND T1.U_FGWHSE=T0.U_WHSCODE AND T1.U_REVISIONNO = '0000000001'

	

WHERE 

	T0.U_DEMANDSOURCE='17'	--AND
	--CONVERT(nvarchar(30), T0.CreateDate, 112)>=CONVERT(NVARCHAR(30),@BeginDate, 112)		AND 
	--CONVERT(nvarchar(30), T0.CreateDate, 112)<=CONVERT(NVARCHAR(30),@EndDate, 112)			--AND	T0.U_BATCHSTATUS in(4,8,9,10,11,12,6) 

	

ORDER BY
	T0.DocEntry

--SELECT *

--FROM "@BMM_PNITEM" I (NOLOCK)

--WHERE I."DocEntry" = 123821	AND U_LINETYPE=7