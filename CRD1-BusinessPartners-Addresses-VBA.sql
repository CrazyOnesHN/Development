

SELECT 

	T0.CardCode,
	T0.Address,
	T0.Street,
	T0.City,
	T0.State,
	T0.ZipCode,
	T0.AdresType

FROM CRD1 T0

	INNER JOIN OCRD T1 ON T1.CardCode=T0.CardCode

WHERE
	
	T0.Country='US'	AND
	T1.CardType='C'	AND t0.CardCode NOT IN ('company')

ORDER BY

	T0.CardCode



