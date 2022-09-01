

SELECT 

	T0.CardCode,
	T0.ItemCode,
	T0.Substitute,
	T0.U_BPItemDesc,
	T0.U_Press,
	T0.U_Around,
	T0.U_Across,
	T0.U_Bar1,
	T0.U_Bar2,
	T0.U_Spec1,
	T0.U_Spec2,
	T2.U_ItemGrpDesc

FROM OSCN T0

	LEFT JOIN OITM T1 ON T1.ItemCode = T0.ItemCode
	LEFT JOIN OITB T2 ON T2.ItmsGrpCod=T1.ItmsGrpCod


WHERE 

	T2.ItmsGrpCod IN (110,111,112,114,130,131,132)

ORDER BY 

	T0.CardCode
	