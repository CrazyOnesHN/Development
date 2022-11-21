--exec sp_executesql 

--N'

SELECT 
T0.[TransType], 
T0.[BaseRef], 
T0.[TransId], 
T0.[Line_ID], 
MIN(T2.[ReconType]), 
MIN(T2.[ReconRule1]), 
MIN(T2.[ReconRule2]), 
MIN(T2.[ReconRule3]), 
T0.[RefDate], 
T0.[DueDate], 
MAX(T2.[ReconDate]), 
T0.[BatchNum], 
T0.[CreatedBy], 
T0.[Ref1], 
T0.[Ref2], 
T0.[Ref3Line], 
T0.[ContraAct], 
T0.[LineMemo], 
SUM(T1.[CashDisSum]), 
T0.[Debit], 
T0.[Credit],
T0.[BalDueDeb], 
T0.[BalDueCred], 
SUM(T1.[ReconSum]), 
T0.[SYSCred], 
T0.[SYSDeb], 
T0.[BalScDeb], 
T0.[BalScCred], 
SUM(T1.[ReconSumSC]), 
T0.[FCDebit], 
T0.[FCCredit], 
T0.[BalFcDeb], 
T0.[BalFcCred], 
SUM(T1.[ReconSumFC]), 
MAX(T2.[ReconNum]), 
T0.[ShortName], 
COUNT(T2.[ReconNum]), 
T1.[IsCredit]


FROM  [dbo].[JDT1] T0   

LEFT OUTER  JOIN [dbo].[ITR1] T1  ON  T0.[Line_ID] = T1.[TransRowId]  AND  T0.[TransId] = T1.[TransId]    
LEFT OUTER  JOIN [dbo].[OITR] T2  ON  T1.[ReconNum] = T2.[ReconNum]    
LEFT OUTER  JOIN [dbo].[ECM2] T3  ON  T0.[TransType] = T3.[SrcObjType]  AND  T0.[CreatedBy] = T3.[SrcObjAbs]   

WHERE (T0.[TransId] = 608281 ) AND  T0.[ShortName] <> T0.[Account]   

GROUP BY 

T0.[TransType], 
T0.[BaseRef], 
T0.[TransId], 
T0.[Line_ID], 
T0.[RefDate], 
T0.[DueDate], 
T0.[BatchNum], 
T0.[CreatedBy], 
T0.[Ref1], 
T0.[Ref2], 
T0.[Ref3Line], 
T0.[ContraAct], 
T0.[LineMemo], 
T0.[Debit], 
T0.[Credit], 
T0.[BalDueDeb], 
T0.[BalDueCred], 
T0.[SYSCred], 
T0.[SYSDeb], 
T0.[BalScDeb], 
T0.[BalScCred], 
T0.[FCDebit], 
T0.[FCCredit], 
T0.[BalFcDeb], 
T0.[BalFcCred], 
T0.[ShortName], 
T0.[Account], 
T0.[FCCurrency], 
T2.[ReconCurr], 
T1.[IsCredit] 

ORDER BY 

T0.[TransId],
T0.[Line_ID]

--',N'@P1 int',608281