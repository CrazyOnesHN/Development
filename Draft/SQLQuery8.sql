
SELECT 

T2.DocNum			AS  'OrderNum'

FROM DLN1 T0    WITH (NOLOCK)

	RIGHT OUTER JOIN OINV  T1	ON T1.DocEntry=T0.TrgetEntry  



WHERE
	T0.[DocDate] BETWEEN '2022-02-01' AND '2022-02-28'	AND
	T0.[CANCELED] = 'N'				  AND T1.QryGroup1='N'


-- Delivery
--SELECT * FROM ODLN WHERE DocNum=607924
--SELECT * FROM DLN1 WHERE DocEntry=10973

--Invoice
--SELECT * FROM OINV WHERE DocNum=709307
--SELECT * FROM INV1 WHERE DocEntry=13881

-- Credit Memo
--SELECT * FROM ORIN T0 WHERE T0.DocNum=645
--SELECT * FROM RIN1 T0 WHERE T0.DocEntry=645