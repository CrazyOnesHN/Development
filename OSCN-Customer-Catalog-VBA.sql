

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
	T0.U_Spec2		

FROM OSCN T0

	INNER JOIN OCRD T1 ON T1.CardCode=T0.CardCode

ORDER BY 

	T0.CardCode
	