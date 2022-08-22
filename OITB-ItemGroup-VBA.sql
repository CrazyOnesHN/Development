



SELECT 

	T0.ItmsGrpCod,
	T0.ItmsGrpNam,
	T0.U_ItemGrpDesc



FROM OITB T0

WHERE 

	T0.ItmsGrpCod IN (110,111,114,112,131,132,130)

ORDER BY

	T0.ItmsGrpCod