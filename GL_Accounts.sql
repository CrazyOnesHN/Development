--exec sp_executesql N'

SELECT 

	T0.[Account], 
	SUM(T0.[Credit]), 
	SUM(T0.[Debit]), 
	SUM(T0.[SYSCred]), 
	SUM(T0.[SYSDeb]), 
	SUM(T0.[FCCredit]), 
	SUM(T0.[FCDebit]), 
	SUM(T0.[BalDueCred]), 
	SUM(T0.[BalDueDeb]), 
	SUM(T0.[BalFcCred]), 
	SUM(T0.[BalFcDeb]) 

FROM  [dbo].[JDT1] T0 

WHERE 

T0.[RefDate] >= '2022-06-01 00:00:00'  AND  
T0.[RefDate] <= '2022-06-30 00:00:00'  AND  
T0.[TransType] <> -3  

GROUP BY T0.[Account]



--',N'@P1 datetime2,@P2 datetime2,@P3 nvarchar(254)','2022-01-01 00:00:00','2022-06-30 00:00:00',N'-3'




