exec sp_executesql 

N'SELECT T0.[DocNum] , 
T0.[LineID] , T0.[DueDate] , 
T0.[CheckNum] , T0.[BankCode] , 
T0.[Branch] , T0.[AcctNum] , 
T0.[Details] , T0.[Trnsfrable] , T0.[CheckSum] , T0.[Currency] , T0.[Flags] , 
T0.[ObjType] , T0.[LogInstanc] , T0.[CountryCod] , T0.[CheckAct] , T0.[CheckAbs] ,
T0.[BnkActKey] , T0.[ManualChk] , T0.[FiscalID] , T0.[OrigIssdBy] , T0.[Endorse] ,
T0.[EndorsChNo] , T0.[EnAcctNum] , T0.[EncryptIV]  

FROM [dbo].[RCT1] T0 

WHERE ((T0.[DocNum] = (@P1) ))  ORDER BY T0.[DocNum],T0.[LineID]',N'@P1 int',10207