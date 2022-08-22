

SELECT

	T0.ItemCode,
	T0.ItemName,
	T0.FrgnName,
	T0.ItmsGrpCod,
	T1.U_ItemGrpDesc
	
FROM OITM T0

	LEFT JOIN OITB T1 ON T1.ItmsGrpCod=T0.ItmsGrpCod


WHERE

	T0.ItemType='I'	AND
	T0.validFor='Y'



ORDER BY 

	T0.ItemCode