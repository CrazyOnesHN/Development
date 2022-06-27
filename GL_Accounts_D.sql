
DECLARE @BeginDate	DATETIME ='20220501'
DECLARE @EndDate	DATETIME ='20220531'

SELECT 

	T0.AcctCode,
	T0.Levels,
	T0.FatherNum,
	T0.FatherNum + ' - ' + [dbo].[GET_ACCTNAME] (T0.FatherNum)	'AcctName',
	T0.Segment_0 + ' - ' + T0.AcctName 'Name',
	--T1.RefDate,
	SUM(T1.Credit) 'Credit',
	SUM(T1.Debit) 'Debit'




FROM	dbo.[OACT] T0 

	LEFT OUTER JOIN JDT1 T1 ON T1.Account=T0.AcctCode


WHERE 

	T0.[GrpLine] <> 0					   AND
	T1.[RefDate] >=@BeginDate  AND  
	T1.[RefDate] <=@EndDate  AND  
	T1.[TransType] <> -3  
	
GROUP BY
	T0.AcctCode,
	T0.AcctName,
	T0.GroupMask,
	T0.GrpLine,
	T0.AccntntCod,
	T1.RefDate,
	T0.FatherNum,
	T0.Segment_0,
	T0.Levels

	
ORDER BY 

	T0.[GroupMask],
	T0.[GrpLine]
	