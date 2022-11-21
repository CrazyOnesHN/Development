

SELECT 

T0.DocEntry,
T0.LineNum,
T0.ItemCode,
T1.U_Punch,
T1.U_Bar1,
T1.U_Bar2,
T1.U_Press,
([dbo].[C_MM_INCH] (T1.SLength1))								'Length(in)',
([dbo].[C_MM_INCH] (T1.SWidth1))								'Width(in)',
T1.SHeight1														'Gauge',
T0.Quantity,
T1.U_Spec1

FROM DRF1 T0

	INNER JOIN OITM T1 ON T1.ItemCode=T0.ItemCode

WHERE 

T0.DocEntry=5763






SELECT * FROM ODRF WHERE DocEntry=5763