
SELECT

	T0.CardCode,
	T0.CntctCode,
	T0.Name,
	T0.Position,
	T0.Tel1,
	T0.Tel2,
	T0.Cellolar,
	T0.Fax,
	T0.E_MailL


FROM OCPR T0

	INNER JOIN OCRD T1 ON T1.CardCode=T0.CardCode

WHERE 

	T1.CardType='C'	AND
	T0.CardCode NOT IN ('company')


ORDER BY

	T0.CardCode