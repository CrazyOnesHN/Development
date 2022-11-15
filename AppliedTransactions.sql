
SELECT 

	T1.[TransType], 
	T1.[BaseRef], 
	T1.[TransId], 
	T1.[Line_ID], 
	T2.[ReconType], 	
	T1.[RefDate], 
	T1.[DueDate], 
	T2.[ReconDate], 	
	T1.[CreatedBy], 
	T1.[Ref1], 
	T1.[Ref2], 
	T1.[Ref3Line], 
	T1.[ContraAct], 
	T1.[LineMemo], 
	T0.[CashDisSum], 
	T1.[Debit], 
	T1.[Credit], 
	T1.[BalDueDeb], 
	T1.[BalDueCred], 
	T0.[ReconSum], 
	T1.[SYSCred], 
	T1.[SYSDeb], 
	T1.[BalScDeb], 
	T1.[BalScCred], 
	T0.[ReconSumSC], 
	T1.[FCDebit], 
	T1.[FCCredit], 
	T1.[BalFcDeb], 
	T1.[BalFcCred], 
	T0.[ReconSumFC], 
	T2.[ReconNum], 
	T1.[ShortName], 
	T1.[Account], 	
	T2.[ReconNum], 
	T0.[IsCredit], 
	T2.[OldMatNum]


FROM	[dbo].[ITR1] T0  

	INNER  JOIN [dbo].[JDT1] T1  ON  T0.[TransRowId] = T1.[Line_ID]  AND  T0.[TransId] = T1.[TransId]   
	INNER  JOIN [dbo].[OITR] T2  ON  T0.[ReconNum] = T2.[ReconNum]    
	LEFT OUTER  JOIN [dbo].[ECM2] T3  ON  T2.[ReconNum] = T3.[SrcObjAbs]  AND  T3.[SrcObjType] = '321'  
	
WHERE  

	EXISTS (SELECT U0.[ReconNum] FROM  [dbo].[ITR1] U0  WHERE U0.[TransId] = 613581  AND  U0.[TransRowId] = 0  AND  T2.[ReconNum] = U0.[ReconNum]  )  AND  (T1.[TransId] <> 613581  OR  T1.[Line_ID] <> 0 )  

ORDER BY T2.[CreateDate]

