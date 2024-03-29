SELECT 
T1.[TransType], 
T1.[BaseRef], 
T1.[TransId], 
T1.[Line_ID], 
T2.[ReconType], 
T1.[RefDate], 
T1.[DueDate], 
T2.[ReconDate], 
T1.[LineMemo],
T1.[BalDueDeb],
T0.[ReconSum], 
T1.[ShortName], 
T2.[ReconNum], T0.[IsCredit]

FROM  [dbo].[ITR1] T0  

INNER  JOIN [dbo].[JDT1] T1  ON  T0.[TransRowId] = T1.[Line_ID]  AND  T0.[TransId] = T1.[TransId]   
INNER  JOIN [dbo].[OITR] T2  ON  T0.[ReconNum] = T2.[ReconNum]    
--LEFT OUTER  JOIN [dbo].[ECM2] T3  ON  T2.[ReconNum] = T3.[SrcObjAbs]  AND  T3.[SrcObjType] ='321'  

WHERE  

EXISTS (SELECT U0.[ReconNum] FROM  [dbo].[ITR1] U0  
WHERE U0.[TransId] = 608281  AND  U0.[TransRowId] = 0  AND  T2.[ReconNum] = U0.[ReconNum]  ) 
--AND  --(T1.[TransId] <> 608281  OR  T1.[Line_ID] <> 0 )  
AND T0.IsCredit='D'
AND T2.ReconNum =(SELECT MAX(ReconNum) FROM OITR WHERE ReconNum =t2.ReconNum)

ORDER BY T2.[CreateDate]
