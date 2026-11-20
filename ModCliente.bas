Attribute VB_Name = "ModCliente"
Option Explicit

' Convierte el nombre del papel (celda J2 de CLIENTE) al codigo de Excel
Private Function CodigoPapel(ByVal t As String) As Long
    Select Case UCase(Trim(t))
        Case "A3": CodigoPapel = xlPaperA3
        Case "A5": CodigoPapel = xlPaperA5
        Case "CARTA": CodigoPapel = xlPaperLetter
        Case "OFICIO": CodigoPapel = xlPaperLegal
        Case Else: CodigoPapel = xlPaperA4
    End Select
End Function

' Aplica tamano de papel (J2) y orientacion (J3) a la hoja CLIENTE
Sub AplicarPapel()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets("CLIENTE")
    With ws.PageSetup
        .PrintArea = "$A$1:$G$29"
        .PaperSize = CodigoPapel(CStr(ws.Range("J2").Value))
        If UCase(Trim(CStr(ws.Range("J3").Value))) = "HORIZONTAL" Then
            .Orientation = xlLandscape
        Else
            .Orientation = xlPortrait
        End If
        .Zoom = False
        .FitToPagesWide = 1
        .FitToPagesTall = False
        .CenterHorizontally = True
    End With
End Sub

' Aplica el papel, oculta las filas sin producto y exporta a PDF en la carpeta del archivo
Sub ExportarPDFCliente()
    Dim ws As Worksheet, r As Long, cot As String, ruta As String
    Set ws = ThisWorkbook.Worksheets("CLIENTE")
    cot = Trim(CStr(ws.Range("C6").Value))
    If cot = "" Then
        MsgBox "Escribe primero el N° de cotización en CLIENTE (celda C6).", vbExclamation
        Exit Sub
    End If
    If ThisWorkbook.Path = "" Then
        MsgBox "Guarda primero el archivo en tu PC.", vbExclamation
        Exit Sub
    End If
    cot = Replace(Replace(Replace(cot, "/", "-"), "\", "-"), ":", "-")
    ruta = ThisWorkbook.Path & Application.PathSeparator & "Cotizacion_" & cot & ".pdf"

    On Error GoTo Fin
    Application.ScreenUpdating = False
    AplicarPapel
    For r = 10 To 29
        ws.Rows(r).Hidden = (CStr(ws.Cells(r, 3).Value) = "")
    Next r
    ws.ExportAsFixedFormat Type:=xlTypePDF, Filename:=ruta, Quality:=xlQualityStandard, _
        IncludeDocProperties:=False, IgnorePrintAreas:=False, OpenAfterPublish:=True
Fin:
    ws.Rows("10:29").Hidden = False
    Application.ScreenUpdating = True
    If Err.Number <> 0 Then MsgBox "No se pudo exportar: " & Err.Description, vbExclamation
End Sub
