Attribute VB_Name = "Ranges"
Option Explicit

Sub Range_Lastrow()

    Range("K6:K12").ClearContents

    Range("K6").Value = Range("A4").End(xlDown).Row
    Range("K7").Value = Range("A" & Rows.Count).End(xlUp).Row + 1
    Range("K8").Value = Range("A4").End(xlToRight).Column
    Range("K9").Value = Range("B10").CurrentRegion.Address
    Range("K10").Value = Range("B10").CurrentRegion.Rows.Count
    Range("K11").Value = Cells.SpecialCells(xlCellTypeLastCell).Row
    Range("K12").Value = ActiveSheet.UsedRange.Rows.Count
    
End Sub
