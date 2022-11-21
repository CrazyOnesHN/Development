DECLARE @Today DATETIME = CAST(CAST(GETDATE() AS DATE) AS DATETIME)
DECLARE @SameDayLastWeek DATETIME = DATEADD(DD, -7,  @Today)
DECLARE @SameDayLastMonth DATETIME = DATEADD(MONTH, -1,  @Today)
DECLARE @SameDayLastQuarter DATETIME = DATEADD(QQ, -1, @Today)
DECLARE @SameDayLastYear DATETIME = DATEADD(YEAR, -1, @Today)
DECLARE @StartOfCurrentMonth DATETIME = DATEADD(MONTH, DATEDIFF(MONTH,0,@Today), 0)
DECLARE @StartOfPreviousMonth DATETIME = DATEADD(MONTH, DATEDIFF(MONTH,0, @Today)-1,0)
DECLARE @StartOfCurrentQuarter DATETIME = DATEADD(QQ, DATEDIFF(QQ,0, @Today),0)
DECLARE @StartOfPreviousQuarter DATETIME = DATEADD(QQ, DATEDIFF(QQ,0, @Today)-1,0)
DECLARE @StartOfCurrentYear DATETIME = CAST(YEAR(@Today) AS NVARCHAR(4))+'0101'
DECLARE @StartOfPreviousYear DATETIME = CAST(YEAR(@Today)-1 AS NVARCHAR(4))+'0101'
DECLARE @EndOfCurrentYear DATETIME = CAST(YEAR(@Today) AS NVARCHAR(4))+'1231'
DECLARE @EndOfPreviousYear DATETIME = CAST(YEAR(@Today)-1 AS NVARCHAR(4))+'1231'
DECLARE @EndOfCurrentMonth DATETIME = DATEADD(S, -1, DATEADD(MONTH, DATEDIFF(MONTH,0,@Today)+1,0))
DECLARE @EndOfPreviousMonth DATETIME = DATEADD(S,-1, DATEADD(MONTH, DATEDIFF(MONTH,0, @Today),0))
DECLARE @EndOfCurrentQuarter DATETIME = DATEADD(S,-1, DATEADD(QQ, DATEDIFF(QQ,0, @Today)+1,0))
DECLARE @EndOfPreviousQuarter DATETIME = DATEADD(S,-1, DATEADD(QQ, DATEDIFF(QQ,0, @Today),0))

DECLARE @CurrentFinanceYear DATETIME = (select MAX(FinancYear) as financYearStart from OACP where FinancYear<= GETDATE())
DECLARE @PreviousFinanceYear DATETIME = (select MAX(FinancYear) as financYearStart from OACP where FinancYear< @CurrentFinanceYear)
DECLARE @StartOfCurrentFinancialYear DATETIME = (SELECT MIN(T1.F_RefDate) FROM OACP T0 JOIN OFPR T1 ON T0.PeriodCat = T1.Category WHERE T0.FinancYear = @CurrentFinanceYear)
DECLARE @StartOfPreviousFinancialYear DATETIME = (SELECT MIN(T1.F_RefDate) FROM OACP T0 JOIN OFPR T1 ON T0.PeriodCat = T1.Category WHERE T0.FinancYear = @PreviousFinanceYear)
DECLARE @EndOFCurrenctFinancialYear DATETIME = (SELECT MAX(T1.T_RefDate) FROM OACP T0 JOIN OFPR T1 ON T0.PeriodCat = T1.Category WHERE T0.FinancYear = @CurrentFinanceYear)
DECLARE @EndOfPreviousFinancialYear DATETIME = (SELECT MAX(T1.T_RefDate) FROM OACP T0 JOIN OFPR T1 ON T0.PeriodCat = T1.Category WHERE T0.FinancYear = @PreviousFinanceYear)

--DECLARE @Start DATETIME = DATEADD(MM,-12,@StartOfCurrentMonth)

DECLARE @Start DATETIME = '2022-02-01 00:00:00'
DECLARE @End DATETIME = '2022-02-28 00:00:00'

SELECT 
'Invoice' AS 'Source',
MAX(T0.DocNum) AS DocNum,
T0.DocDate AS 'Posting Date',
CASE WHEN T0.CANCELED = 'C' THEN -SUM(T0.DocTotal-T0.VatSum+T0.DpmAmnt-T0.TotalExpns-T0.RoundDif) ELSE SUM(T0.DocTotal-T0.VatSum+T0.DpmAmnt-T0.TotalExpns-T0.RoundDif) END AS 'Amount',
CASE WHEN T0.CANCELED = 'C' THEN -SUM(T0.GrosProfit) ELSE SUM(T0.GrosProfit) END AS 'Gross'

FROM OINV T0 WITH (NOLOCK)

WHERE T0.DocDate BETWEEN @Start AND @End

GROUP BY T0.DocDate, T0.DocEntry, T0.CANCELED,T0.DocNum
ORDER BY  T0.DocNum

--UNION ALL

--SELECT 
--'Credit note' AS 'Source',
--MAX(T0.DocNum) AS DocNum,
--T0.DocDate AS 'Posting Date',
--CASE WHEN T0.CANCELED = 'C' THEN SUM(T0.DocTotal-T0.VatSum-T0.TotalExpns-T0.RoundDif) ELSE -SUM(T0.DocTotal-T0.VatSum-T0.TotalExpns-T0.RoundDif) END AS 'Amount',
--CASE WHEN T0.CANCELED = 'C' THEN SUM(T0.GrosProfit) ELSE -SUM(T0.GrosProfit) END AS 'Gross'
--FROM ORIN T0 WITH (NOLOCK)
--WHERE T0.DocDate BETWEEN @Start AND @End
--AND NOT EXISTS (SELECT 1 FROM RIN1 TS1 WHERE TS1.DocEntry = T0.DocEntry AND TS1.BaseType = 203)
--GROUP BY T0.DocDate, T0.DocEntry, T0.CANCELED

