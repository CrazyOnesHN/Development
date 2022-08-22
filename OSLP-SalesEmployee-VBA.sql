

SELECT 

	T0.SlpCode,
	T0.SlpName

FROM OSLP T0


WHERE

	T0.Active='Y'	AND
	T0.SlpCode IN (17,8,18,7,11,12,20,9,31,33,34,-1)


