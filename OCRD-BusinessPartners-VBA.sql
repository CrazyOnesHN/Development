

SELECT

	T0.CardCode,
	T0.CardName,
	T0.Phone1			'Tel1',
	T0.Phone2			'Tel2',
	T0.E_Mail,
	T0.CntctPrsn		'ContactPerson',
	T1.SlpCode,
	T1.SlpName,
	T0.GroupNum,
	T2.PymntGroup



FROM OCRD T0

	LEFT JOIN OSLP T1 ON T1.SlpCode=T0.SlpCode
	LEFT JOIN OCTG T2 ON T2.GroupNum=T0.GroupNum

WHERE 
	
	T0.CardType='C'	AND
	T0.validFor='Y'	AND
	T0.CardName IS NOT NULL

ORDER BY

	T0.CardCode


	--SELECT * FROM OCPR
	--SELECT * FROM OCTG