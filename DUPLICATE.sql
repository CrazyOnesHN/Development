


--SELECT * FROM OITR WHERE ReconNum IN (29443,29261)

--SELECT * FROM OINV WHERE DocNum=712645
--SELECT * FROM OITR WHERE ReconNum IN (29443,29261)
SELECT * FROM ITR1 WHERE ReconNum IN (29443,29261) AND IsCredit='D'
SELECT MAX(ReconNum) FROM ITR1 WHERE SrcObjAbs=17219 


--SELECT MAX(ReconNum) FROM ITR1 WHERE TransId=611626



