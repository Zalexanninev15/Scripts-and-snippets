#include <FileConstants.au3>

Global $AppDataDir = @AppDataDir & "\flameshot"
Global $LocalDir = @AppDataDir & "\..\Local\flameshot"
Global $LocalRegion = $LocalDir & "\flameshot\cache\region.txt"
Global $AppDataConfig = $AppDataDir & "\flameshot.ini"
Global $BackupConfig = $AppDataDir & "\flameshot_backup.ini"
Global $ScriptDir = @ScriptDir
Global $LocalConfig = $ScriptDir & "\flport.ini"
Global $FlameshotExe = $ScriptDir & "\flameshot.exe"

Opt("RunErrorsFatal", 0)
Opt("TrayIconHide", 1)

Global $AntiBackup = False
If $CmdLine[0] > 0 Then
    For $i = 1 To $CmdLine[0]
        If StringLower($CmdLine[$i]) = "-n" Then
            $AntiBackup = True
            ExitLoop
        EndIf
    Next
EndIf

If Not FileExists($AppDataDir) Then DirCreate($AppDataDir)

If Not $AntiBackup Then
    If FileExists($AppDataConfig) Then
        FileMove($AppDataConfig, $BackupConfig, $FC_OVERWRITE + $FC_CREATEPATH)
    EndIf

    If Not FileExists($AppDataConfig) And FileExists($LocalConfig) Then
        FileCopy($LocalConfig, $AppDataConfig, $FC_OVERWRITE + $FC_CREATEPATH)
    EndIf
Else
    If FileExists($AppDataConfig) Then FileDelete($AppDataConfig)
	If FileExists($LocalConfig) Then
        FileCopy($LocalConfig, $AppDataConfig, $FC_OVERWRITE + $FC_CREATEPATH)
    EndIf
EndIf

Local $FlameshotPID = Run('"' & $FlameshotExe & '"', $ScriptDir)

ProcessWaitClose($FlameshotPID)

If FileExists($AppDataConfig) Then
        FileMove($AppDataConfig, $LocalConfig, $FC_OVERWRITE + $FC_CREATEPATH)
EndIf

If Not $AntiBackup Then
    If FileExists($BackupConfig) Then
        FileMove($BackupConfig, $AppDataConfig, $FC_OVERWRITE + $FC_CREATEPATH)
    Else
        DirRemove($AppDataDir, 1)
    EndIf
Else
    DirRemove($AppDataDir, 1)
EndIf

If FileExists($LocalRegion) Then
	DirRemove($LocalDir, 1)
EndIf