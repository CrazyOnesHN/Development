exec sp_executesql 
N'SELECT T0.[DocNum] , T0.[InvoiceId] , 
T0.[DocEntry] , T0.[SumApplied] , T0.[AppliedFC] , T0.[AppliedSys] , 
T0.[InvType] , T0.[DocRate] , T0.[Flags] , T0.[IntrsStat] , T0.[DocLine] , 
T0.[vatApplied] , T0.[vatAppldFC] , T0.[vatAppldSy] , T0.[selfInv] , T0.[ObjType] , 
T0.[LogInstanc] , T0.[Dcount] , T0.[DcntSum] , T0.[DcntSumFC] , T0.[DcntSumSy] , 
T0.[BfDcntSum] , T0.[BfDcntSumF] , T0.[BfDcntSumS] , T0.[BfNetDcnt] , T0.[BfNetDcntF] , 
T0.[BfNetDcntS] , T0.[PaidSum] , T0.[ExpAppld] , T0.[ExpAppldFC] , T0.[ExpAppldSC] , 
T0.[Rounddiff] , T0.[RounddifFc] , T0.[RounddifSc] , T0.[InstId] , T0.[WtAppld] , 
T0.[WtAppldFC] , T0.[WtAppldSC] , T0.[LinkDate] , T0.[AmtDifPst] , T0.[PaidDpm] , 
T0.[DpmPosted] , T0.[ExpVatSum] , T0.[ExpVatSumF] , T0.[ExpVatSumS] , T0.[IsRateDiff] , 
T0.[WtInvCatS] , T0.[WtInvCatSF] , T0.[WtInvCatSS] , T0.[OcrCode] , T0.[DocTransId] , T0.[MIEntry] , 
T0.[OcrCode2] , T0.[OcrCode3] , T0.[OcrCode4] , T0.[OcrCode5] , T0.[IsSelected] , T0.[WTOnHold] , 
T0.[WTOnhldPst] , T0.[baseAbs] , T0.[MIType] , T0.[DocSubType] , T0.[SpltPmtVAT] , T0.[EncryptIV]  

FROM [dbo].[RCT2] T0 

WHERE ((T0.[DocNum] = (@P1) ))  

ORDER BY T0.[DocNum],T0.[InvoiceId]',N'@P1 int',10207