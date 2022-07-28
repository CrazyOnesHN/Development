Attribute VB_Name = "PDF"
Option Explicit

Sub Create_PDF()

    
    Dim PDFTable As ListObject
    Dim PDFSheets() As String
    Dim c As Byte 'number of tabs to be exported
    Dim FileName As String
    On Error GoTo Handle:
    
    
    FileName = ThisWorkbook.Path & "\PDFExport"
    Set PDFTable = Worksheets("PDF").ListObjects("PDFTable")
     
    ReDim PDFSheets(1 To PDFTable.DataBodyRange.Rows.Count)
    
    ' fill up the array
    
    For c = 1 To UBound(PDFSheets)
    
        PDFSheets(c) = PDFTable.DataBodyRange(c, 1).Value
    
    Next c
     
    Worksheets(PDFSheets).Select
    ActiveSheet.ExportAsFixedFormat xlTypePDF, FileName
    Worksheets("PDF").Select
    MsgBox "PDF file was created." & vbNewLine & "File is called PDFExport. it is saved on the same directory as this workbook"
    Exit Sub
    
Handle:
If Err.Number = 9 Then
    MsgBox "it looks like a tab name was not spelled correctly, Please double check."
Else
    MsgBox "looks like an Error here..."
End If
End Sub

Sub Email_Worksheets()

    Dim ShName As String
    Dim cell As Range
    
    For Each cell In Worksheets("Email").Range("A6")
        ShName = cell.Value
        ThisWorkbook.Worksheets(ShName).Copy
        
        Application.Dialogs(xlDialogSendMail).Show cell.Offset(0, 1).Value, cell.Offset(0, 2).Value
        ActiveWorkbook.Close False
    
    Next cell

End Sub
