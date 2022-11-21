 
 
 SELECT "T_BOMEX"."FGCode", "T_BOMEX"."Level1", "Z_COST"."Fabric", "Z_COST"."LaborHrs", "Z_COST"."LaborCost", "Z_COST"."LaborOHHrs", "Z_COST"."LaborOHCost", "Z_COST"."MFGOHHrs", "Z_COST"."MFGOHCost", "Z_COST"."TotalCost", "T_BOMEX"."QTYL1", "Z_COST"."RawMaterial", "Z_COST"."ValidFrom", "Z_COST"."ValidTo"
 FROM   "KINYO_DEV"."dbo"."T_BOMEX" "T_BOMEX" INNER JOIN "KINYO_DEV"."dbo"."Z_COST" "Z_COST" ON "T_BOMEX"."FGCode"="Z_COST"."ItemCode"
 WHERE  "Z_COST"."ValidFrom">={d '2022-03-03'} AND "Z_COST"."ValidTo" IS  NULL 
 ORDER BY "T_BOMEX"."FGCode", "T_BOMEX"."Level1"


