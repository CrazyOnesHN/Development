SELECT DISTINCT	    T4.SlpName              AS  'Sales Employee',	T1.DocNum				AS	'Invoice',	T0.BaseRef				AS  'OrderNum',	T1.Comments,	T1.DocDate,	T1.CardName,	T1.CardCode,		T6.LineNum,	    T6.ItemCode,	T6.Dscription,	T6.Price,	T1.DiscPrcnt,	CASE		WHEN T3.QryGroup1='Y' THEN (SELECT T0.U_Length FROM INV1 T0 WHERE T0.DocEntry=T1.DocEntry AND T0.LineNum=T6.LineNum AND T0.ItemCode=T6.ItemCode )		WHEN T3.QryGroup1='N' THEN (SELECT T0.SLength1 FROM OITM T0 WHERE T0.ItemCode=T6.ItemCode )	END 'Around',	CASE		WHEN T3.QryGroup1='Y' THEN (SELECT T0.U_Width FROM INV1 T0 WHERE T0.DocEntry=T1.DocEntry AND T0.LineNum=T6.LineNum AND T0.ItemCode=T6.ItemCode )		WHEN T3.QryGroup1='N' THEN (SELECT T0.SWidth1 FROM OITM T0 WHERE T0.ItemCode=T6.ItemCode )	END 'Across',	CASE		WHEN T3.QryGroup1='Y' THEN (SELECT T0.U_Gauge FROM INV1 T0 WHERE T0.DocEntry=T1.DocEntry AND T0.LineNum=T6.LineNum AND T0.ItemCode=T6.ItemCode )		WHEN T3.QryGroup1='N' THEN (SELECT T0.SHeight1 FROM OITM T0 WHERE T0.ItemCode=T6.ItemCode )	END 'Gauge',	T6.Quantity,    T6.LineTotalFROM DLN1 T0    WITH (NOLOCK)	RIGHT OUTER JOIN OINV	T1		ON T1.DocEntry=T0.TrgetEntry  	LEFT  OUTER JOIN ORDR	T2		ON T2.DocNum=T0.BaseRef AND T2.DocEntry=T0.BaseEntry	LEFT  OUTER JOIN OCRD	T3		ON T3.CardCode=T1.CardCode	LEFT  OUTER JOIN OSLP	T4		ON T4.SlpCode=T1.SlpCode	LEFT  OUTER JOIN INV12	T5		ON T5.DocEntry=T1.DocEntry	LEFT  OUTER JOIN INV1	T6		ON T6.DocEntry=T1.DocEntry	LEFT  OUTER JOIN OITM	T7		ON T7.ItemCode=T6.ItemCodeWHERE 	T1.DocDate >='2022-02-01 00:00:00'	AND	T1.DocDate <='2022-03-01 00:00:00'	AND	T1.CANCELED='N'	    AND T3.QryGroup1='N'