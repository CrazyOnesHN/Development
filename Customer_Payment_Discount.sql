


SELECT 

	PT.GroupNum,
	PT.PymntGroup,
	PT.DiscCode,
	T0.Code,
	T0.ByDate,
	CASE	
		WHEN T0.BaseDate='P' THEN 'Posting Date'
		WHEN T0.BaseDate='S' THEN 'System Date'
		WHEN T0.BaseDate='T' THEN 'Document Date'
		WHEN T0.BaseDate='C' THEN 'Closing Date'
	END 'CashDiscountBasedOn',
	T1.LineId,
	T1.NumOfDays,
	PT.ExtraDays,
	T1.Discount

FROM OCTG PT

	INNER JOIN OCDC T0 ON T0.Code=PT.DiscCode
	LEFT OUTER JOIN CDC1 T1 ON T1.CdcCode=T0.Code