Function JoinText(rng As Range, Optional delimiter As String = ",") As String
    Dim cell As Range
    Dim result As String
    For Each cell In rng
        If cell.Value <> "" Then
            result = result & cell.Value & delimiter
        End If
    Next cell
    If Len(result) > 0 Then
        result = Left(result, Len(result) - Len(delimiter)) ' 最後の区切りを削除
    End If
    JoinText = result
End Function