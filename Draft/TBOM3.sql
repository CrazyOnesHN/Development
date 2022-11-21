 SELECT 
 "T_BOMEX"."FGCode", 
 "T_BOMEX"."Level1", 
 "T_BOMEX"."QTYL1", 
 "T_BOMEX"."FactorFG", 
 "T_BOMEX"."SetupLaborFG", 
 "T_BOMEX"."StdProdQtyFG", 
 "T_BOMEX"."SetupMFGOHFG", 
 "T_BOMEX"."StageL1", 
 "T_BOMEX"."Loss", 
 "OITM"."AvgPrice", 
 "OITM"."CreateDate"

 FROM   "KINYO_DEV"."dbo"."T_BOMEX" 
 
 "T_BOMEX" INNER JOIN "KINYO-LIVE"."dbo"."OITM" "OITM" ON "T_BOMEX"."FGCode"="OITM"."ItemCode"

WHERE   NOT ("T_BOMEX"."FGCode" LIKE N'4%' OR "T_BOMEX"."FGCode" LIKE N'c%') AND "OITM"."CreateDate">={ts '2022-03-03 00:00:00'} AND "T_BOMEX"."FGCode"='87ATM///0475007'

ORDER BY "T_BOMEX"."FGCode", "T_BOMEX"."StageL1", "T_BOMEX"."Level1"


