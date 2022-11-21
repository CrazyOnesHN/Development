

SELECT 

T1.TransType,
T1.BaseRef,
T1.TransId,
T1.Line_ID,
T1.RefDate,
T1.DueDate,
T2.ReconDate,
T1.LineMemo,
T1.BalDueDeb,
T0.ReconSum,
T0.ReconNum,
T1.ShortName,
T0.IsCredit


FROM ITR1 T0

	INNER JOIN JDT1 T1 ON T0.TransRowId=T1.Line_ID	AND T0.TransId=T1.TransId
	INNER JOIN OITR T2 ON T2.ReconNum=T0.ReconNum

WHERE 

T1.BaseRef IN (712596,712852,712865,712954)	AND
T0.IsCredit='D'		AND
t0.ReconNum = (SELECT MAX(TA.ReconNum) FROM ITR1 TA
				INNER JOIN JDT1 TB ON TB.Line_ID=TA.TransRowId AND TB.TransId=TA.TransId
				WHERE TB.BaseRef=T1.BaseRef AND TB.TransId=T1.TransId)

--GROUP BY
	
--	T1.TransType,
--	T1.BaseRef,
--	T1.TransId,
--	T1.Line_ID,
--	T1.RefDate,
--	T1.DueDate,
--	T1.LineMemo,
--	T1.BalDueDeb,
--	T0.ReconSum,
--	T0.ReconNum,
--	T1.ShortName,
--	T0.IsCredit
	