declare @p1 int
set @p1=NULL
exec sp_prepexec @p1 output,N'@P1 int',N'SELECT T0.[BatchNum] , T0.[TransId] , T0.[BtfStatus] , T0.[TransType] , T0.[BaseRef] , T0.[RefDate] , T0.[Memo] , T0.[Ref1] , T0.[Ref2] , T0.[CreatedBy] , T0.[LocTotal] , T0.[FcTotal] , T0.[SysTotal] , T0.[TransCode] , T0.[OrignCurr] , T0.[TransRate] , T0.[BtfLine] , T0.[TransCurr] , T0.[Project] , T0.[DueDate] , T0.[TaxDate] , T0.[PCAddition] , T0.[FinncPriod] , T0.[DataSource] , T0.[UpdateDate] , T0.[CreateDate] , T0.[UserSign] , T0.[UserSign2] , T0.[RefndRprt] , T0.[LogInstanc] , T0.[ObjType] , T0.[Indicator] , T0.[AdjTran] , T0.[RevSource] , T0.[StornoDate] , T0.[StornoToTr] , T0.[AutoStorno] , T0.[Corisptivi] , T0.[VatDate] , T0.[StampTax] , T0.[Series] , T0.[Number] , T0.[AutoVAT] , T0.[DocSeries] , T0.[FolioPref] , T0.[FolioNum] , T0.[CreateTime] , T0.[BlockDunn] , T0.[ReportEU] , T0.[Report347] , T0.[Printed] , T0.[DocType] , T0.[AttNum] , T0.[GenRegNo] , T0.[RG23APart2] , T0.[RG23CPart2] , T0.[MatType] , T0.[Creator] , T0.[Approver] , T0.[Location] , T0.[SeqCode] , T0.[Serial] , T0.[SeriesStr] , T0.[SubStr] , T0.[AutoWT] , T0.[WTSum] , T0.[WTSumSC] , T0.[WTSumFC] , T0.[WTApplied] , T0.[WTAppliedS] , T0.[WTAppliedF] , T0.[BaseAmnt] , T0.[BaseAmntSC] , T0.[BaseAmntFC] , T0.[BaseVtAt] , T0.[BaseVtAtSC] , T0.[BaseVtAtFC] , T0.[VersionNum] , T0.[BaseTrans] , T0.[ResidenNum] , T0.[OperatCode] , T0.[Ref3] , T0.[SSIExmpt] , T0.[SignMsg] , T0.[SignDigest] , T0.[CertifNum] , T0.[KeyVersion] , T0.[CUP] , T0.[CIG] , T0.[SupplCode] , T0.[SPSrcType] , T0.[SPSrcID] , T0.[SPSrcDLN] , T0.[DeferedTax] , T0.[AgrNo] , T0.[SeqNum] , T0.[ECDPosTyp] , T0.[RptPeriod] , T0.[RptMonth] , T0.[ExTransId] , T0.[PrlLinked] , T0.[PTICode] , T0.[Letter] , T0.[FolNumFrom] , T0.[FolNumTo] , T0.[RepSection] , T0.[ExclTaxRep] , T0.[IsCoEntry] , T0.[SAPPassprt] , T0.[AtcEntry] , T0.[Attachment] , T0.[EBookable] , T0.[U_BMM_REFDOCNO] , T0.[U_BMM_REFTYPE]  FROM [dbo].[OJDT] T0 WHERE T0.[TransId] = (@P1)  ',606609
select @p1