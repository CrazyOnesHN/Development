exec sp_executesql N'SELECT T0.[DocEntry] , T0.[DocNum] , T0.[DocType] , T0.[Canceled] , T0.[Handwrtten] , T0.[Printed] , T0.[DocDate] , T0.[DocDueDate] , T0.[CardCode] 
, T0.[CardName] , T0.[Address] , T0.[DdctPrcnt] , T0.[DdctSum] , T0.[DdctSumFC] , T0.[CashAcct] , T0.[CashSum] , T0.[CashSumFC] , T0.[CreditSum] , T0.[CredSumFC] , 
T0.[CheckAcct] , T0.[CheckSum] , T0.[CheckSumFC] , T0.[TrsfrAcct] , T0.[TrsfrSum] , T0.[TrsfrSumFC] , T0.[TrsfrDate] , T0.[TrsfrRef] , T0.[PayNoDoc] , T0.[NoDocSum] , 
T0.[NoDocSumFC] , T0.[DocCurr] , T0.[DiffCurr] , T0.[DocRate] , T0.[SysRate] , T0.[DocTotal] , T0.[DocTotalFC] , T0.[Ref1] , T0.[Ref2] , T0.[CounterRef] , T0.[Comments] 
, T0.[JrnlMemo] , T0.[TransId] , T0.[DocTime] , T0.[ShowAtCard] , T0.[SpiltTrans] , T0.[CreateTran] , T0.[Flags] , T0.[CntctCode] , T0.[DdctSumSy] , T0.[CashSumSy] , 
T0.[CredSumSy] , T0.[CheckSumSy] , T0.[TrsfrSumSy] , T0.[NoDocSumSy] , T0.[DocTotalSy] , T0.[ObjType] , T0.[StornoRate] , T0.[UpdateDate] , T0.[CreateDate] , 
T0.[ApplyVAT] , T0.[TaxDate] , T0.[Series] , T0.[confirmed] , T0.[ShowJDT] , T0.[BankCode] , T0.[BankAcct] , T0.[DataSource] , T0.[UserSign] , T0.[LogInstanc] , 
T0.[VatGroup] , T0.[VatSum] , T0.[VatSumFC] , T0.[VatSumSy] , T0.[FinncPriod] , T0.[VatPrcnt] , T0.[Dcount] , T0.[DcntSum] , T0.[DcntSumFC] , T0.[DcntSumSy] , T
0.[SpltCredLn] , T0.[PrjCode] , T0.[PaymentRef] , T0.[Submitted] , T0.[Status] , T0.[PayMth] , T0.[BankCountr] , T0.[FreightSum] , T0.[FreigtFC] , 
T0.[FreigtSC] , T0.[BoeAcc] , T0.[BoeNum] , T0.[BoeSum] , T0.[BoeSumFc] , T0.[BoeSumSc] , T0.[BoeAgent] , 
T0.[BoeStatus] , T0.[WtCode] , T0.[WtSum] , T0.[WtSumFrgn] , T0.[WtSumSys] , T0.[WtAccount] , T0.[WtBaseAmnt] , 
T0.[Proforma] , T0.[BoeAbs] , T0.[BpAct] , T0.[BcgSum] , T0.[BcgSumFC] , T0.[BcgSumSy] , T0.[PIndicator] , 
T0.[PaPriority] , T0.[PayToCode] , T0.[IsPaytoBnk] , T0.[PBnkCnt] , T0.[PBnkCode] , T0.[PBnkAccnt] , 
T0.[PBnkBranch] , T0.[WizDunBlck] , T0.[WtBaseSum] , T0.[WtBaseSumF] , T0.[WtBaseSumS] , T0.[UndOvDiff] ,
T0.[UndOvDiffS] , T0.[BankActKey] , T0.[VersionNum] , T0.[VatDate] , T0.[TransCode] , T0.[PaymType] , 
T0.[TfrRealAmt] , T0.[CancelDate] , T0.[OpenBal] , T0.[OpenBalFc] , T0.[OpenBalSc] , T0.[BcgTaxSum] , 
T0.[BcgTaxSumF] , T0.[BcgTaxSumS] , T0.[TpwID] , T0.[ChallanNo] , T0.[ChallanBak] , T0.[ChallanDat] , 
T0.[WddStatus] , T0.[BcgVatGrp] , T0.[BcgVatPcnt] , T0.[SeqCode] , T0.[Serial] , T0.[SeriesStr] , 
T0.[SubStr] , T0.[BSRCode] , T0.[LocCode] , T0.[WTOnhldPst] , T0.[UserSign2] , T0.[BuildDesc] , 
T0.[ResidenNum] , T0.[OperatCode] , T0.[UndOvDiffF] , T0.[MIEntry] , T0.[FreeText1] , T0.[FreeText2] ,
T0.[FreeText3] , T0.[ShowDocNo] , T0.[TDSInterst] , T0.[TDSCharges] , T0.[CUP] , T0.[CIG] , T0.[MIType] ,
T0.[SupplCode] , T0.[BPLId] , T0.[BPLName] , T0.[VATRegNum] , T0.[BPLCentPmt] , T0.[DraftKey] , T0.[TDSFee] , 
T0.[MinHeadCL] , T0.[SEPADate] , T0.[OwnerCode] , T0.[AgrNo] , T0.[CreateTS] , T0.[UpdateTS] , T0.[TDSType] ,
T0.[DrNo] , T0.[PmntWTCert] , T0.[EnPBnkAcct] , T0.[EncryptIV] , T0.[DPPStatus] , T0.[PriceMode] , 
T0.[AtcEntry] , T0.[Attachment] , T0.[EnblDpmTax]  

FROM [dbo].[ORCT] T0 

WHERE T0.[DocEntry] = (@P1)   

ORDER BY T0.[DocEntry]',N'@P1 int',10207