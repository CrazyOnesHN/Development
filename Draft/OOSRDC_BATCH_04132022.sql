 SELECT 
 
 "_BMM_PNMAST"."U_BATCHNO", 
 "_BMM_PNMAST"."U_ITEMCODE", 
 "OITM"."ItemName", 
 "_BMM_PNMAST"."U_BATCHSTATUS", 
 "OITM"."SLength1", 
 "OITM"."SWidth1", 
 "OITM"."SHeight1", 
 "OITM"."U_Punch", 
 "OITM"."U_Bar1", 
 "OITM"."U_Bar2", 
 "OITM"."U_Press", 
 "_BMM_PNITEM"."U_LINETYPE", 
 "_BMM_PNITEM"."U_ACTUALQTY", 
 "OITM"."U_Spec1", 
 "OITM"."U_Spec2", 
 "_BMM_PNMAST"."U_SONUMBER", 
 "ORDR"."CardCode", 
 "ORDR"."CardName", 
 "ORDR"."ShipToCode", 
 "ORDR"."NumAtCard", 
 "ORDR"."U_SOExtNotes", 
 "ORDR"."U_ShipInstr", 
 "ORDR"."DocDueDate", 
 "ORDR"."U_Rush", 
 "RDR1"."LineNum" 
 
 FROM   
 
 ((("@BMM_PNMAST" "_BMM_PNMAST" LEFT OUTER JOIN "OITM" "OITM" ON 
 "_BMM_PNMAST"."U_ITEMCODE"="OITM"."ItemCode") LEFT OUTER JOIN "ORDR" "ORDR" ON 
 "_BMM_PNMAST"."U_SONUMBER"="ORDR"."DocNum") INNER JOIN "@BMM_PNITEM" "_BMM_PNITEM" ON 
 "_BMM_PNMAST"."DocEntry"="_BMM_PNITEM"."DocEntry") LEFT OUTER JOIN "RDR1" "RDR1" ON 
 ("OITM"."ItemCode"="RDR1"."ItemCode") AND ("ORDR"."DocEntry"="RDR1"."DocEntry") 
 
 
 WHERE  "_BMM_PNMAST"."U_BATCHNO"=N'2203-0185' AND "_BMM_PNITEM"."U_LINETYPE"=7