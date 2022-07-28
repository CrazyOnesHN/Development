Attribute VB_Name = "Layer1"
Option Explicit
Global nextID As Integer
Public EditNum As Long 'listindex number to communicate 2 forms
Public mySelection As Range 'for next line in quotation table

Public Sub GenerateItemId()

    Dim largestID() As Integer
    Dim i As Integer
    
    
    ReDim largestID(1 To Worksheets.Count - 1)
    
    For i = 2 To Worksheets.Count
        Worksheets(i).Select
        Range("B16").Select
        Range(Selection, Selection.End(xlDown)).Select
        
        largestID(i - 1) = Application.Max(Selection)
      
    Next i
    
    nextID = Application.Max(largestID) + 1

End Sub


Sub Reference_Sheet_Quotation()

    Quotation.Activate
    
End Sub


Sub Customer_Master()
    
    frmMasterData.cmdAdd.Caption = "Add"
    frmMasterData.Show

End Sub

Sub Master_Data()
    
    MasterData.Activate

End Sub

Sub View_Master()

    frmViewMasterData.Show
    
End Sub


Sub Find_Cust_Comp(SearchRange As Range, SearchValue As String)

    Dim cell As Range
    Dim c As Byte
    
'    searchrange is either customer or company range
    For Each cell In SearchRange
        c = InStr(1, cell.Value, SearchRange, vbTextCompare)
        'there is a match for the text
        If c > 0 Then
        'add matching to listbox
        'add the customer name
        frmGetCustomer.Me.lstCustomer.AddItem MasterData.Range("A" & cell.Row).Value
        'add company name
        frmGetCustomer.Me.lstCustomer.List(frmGetCustomer.Me.lstCustomer.ListCount - 1, 1) = MasterData.Range("B" & cell.Row).Value
        
    Next cell

End Sub

Public Function YearsSince(myDate As Date) As Long

    YearsSince = Year(Date) - Year(myDate)

End Function

Public Function YearsSinceOP(myDate As Date, Optional Txt As String) As Variant

    If VBA.IsMissing(Txt) Then
        YearsSinceOP = Year(Date) - Year(myDate)
    Else
        YearsSinceOP = Year(Date) - Year(myDate) & " " & Txt
    End If

End Function


Public Function TheAge(myDate As Date) As String
    
    Dim myMonths As Long
    Dim myYear As Long
    
    myMonths = Month(Date) - Month(myDate)
    myYear = Year(Date) - Year(myDate)
    
    TheAge = myYear & " " & "Years & " & " " & myMonths & " " & "Months"

End Function

Public Function TextOnly(TextValue) As String

    Dim i As Long
    Dim t As String
    
    TextValue = Trim(TextValue)
    For i = 1 To Len(TextValue)
        If Not IsNumeric(Mid(TextValue, i, 1)) Then
            t = t & Mid(TextValue, i, 1)
        End If
    Next i
    TextOnly = t

End Function

Public Function NumberOnly(TextValue) As Variant

    Dim i As Long
    Dim n As String
    
    TextValue = Trim(TextValue)
    For i = 1 To Len(TextValue)
        If IsNumeric(Mid(TextValue, i, 1)) Then
            n = n & Mid(TextValue, i, 1)
        End If
    Next i
    If n > 0 Then
        NumberOnly = n
    Else
        NumberOnly = ""
    End If
End Function

