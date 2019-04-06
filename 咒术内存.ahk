#Include, <classMemory>
#Include, <Debug>
#SingleInstance, Force
#InstallKeybdHook
#KeyHistory 0
#NoEnv
OnExit, RenameAndExit
gosub, TimeCheck

Start:

if (A_OSVersion = "WIN_7")
	gosub, PermissionGet

SetTitleMatchMode, 3
Process, Priority, , H
SetBatchLines, -1
ListLines Off
bType:=1
bModeV:=0
bPVP:=0
bModeY:=1

Hotkey, IfWinActive, 剑灵
Hotkey, Xbutton1, ScriptOn
Hotkey, Insert, ModeChange1
Hotkey, Home, ModeChange2
;~ Hotkey, PGUP, ModeChange3
;~ Hotkey, !F1, MemoryTest
return

PermissionGet:
	sFilePath:="C:\Windows\System32\csrss.exe"
	sCommandLine:="takeown /f " sFilePath " && icacls " sFilePath " /grant administrators:F"
	Run, %ComSpec% /c %sCommandLine%,, Hide
	DllCall("RegisterShellHookWindow", "Ptr", A_ScriptHwnd)
	oMsgNum := DllCall("RegisterWindowMessage", Str,"SHELLHOOK")
	OnMessage(oMsgNum, "fnShellMessage")
return

Rename:
	if WinExist("ahk_exe Client64.exe") || A_TickCount-vRenameTime > 10000
	{
		FileMove, C:\Windows\System32\csrssrename.exe, C:\Windows\System32\csrss.exe, 1
		SetTimer, Rename, Off
	}
return

RenameAndExit:
	if !FileExist(A_WinDir "\System32\csrss.exe")
		FileMove, % A_WinDir "\System32\csrssrename.exe", % A_WinDir "\System32\csrss.exe", 1
ExitApp

TimeCheck:
	if (A_Now > 20190421000000)
	{
		MsgBox 异常~
		ExitApp
	}
return
Memorytest:
return

ModeChange1:
	bModeY:=!bModeY
	ToolTip, % bModeY?"开启自动使用灵":"关闭自动使用灵", % A_ScreenWidth/2, % A_ScreenHeight/2
	SetTimer, ToolTipoff, 500
return

ModeChange2:
	bModeC:=!bModeC
	ToolTip % bModeC?"自动使用C":"关闭自动使用C", % A_ScreenWidth/2, % A_ScreenHeight/2
	SetTimer, ToolTipoff, 500
return

ModeChange3:
	bType:=!bType
	ToolTip % bType?"已切换为风系":"已切换为雷系", % A_ScreenWidth/2, % A_ScreenHeight/2
	SetTimer, ToolTipoff, 500
return


ToolTipoff:
SetTimer, ToolTipoff, Off
ToolTip
return


ScriptOn:
if fnUpdateBase()
	return
Loop
{
	if !GetKeyState("Xbutton1", "p")
		break
	else if fnCheckKeys({"1":"1","x":"x","Xbutton2":"7"})
		continue
	iMP := oBs.Read(iAddrMP, "Int")
	bFlag4 := oBs.Read(iFlagAddr4_1, "Int")
	, bFlag4 |= oBs.Read(iFlagAddr4_2, "Int")
	
	, fCD2 := oBs.Read(iCDAddr2, "Float")
	, fCD3 := oBs.Read(iCDAddr3, "Float")
	, fCDf := oBs.Read(iCDAddrf, "Float")
	, fCDy := oBs.Read(iCDAddry, "Float")
	, fCDv := oBs.Read(iCDAddrv, "Float")
	, fCDc := oBs.Read(iCDAddrc, "Float")

	, sName2 := oBs.readString(iNameAddr2, 4, "utf-16")
	, sNamet := oBs.readString(iNameAddrt, 4, "utf-16")
	, sNamef := oBs.readString(iNameAddrf, 4, "utf-16")
	, sNametab := oBs.readString(iNameAddrtab, 4, "utf-16")
	if (sNametab="超神")
		Send {tab}
	else if bModeY && (fCDy = 1)
		Send y
	else if (fCD2 = 1) && (sName2="荒废")
		Send 2
	else if (fCD3 = 1)
		Send 3
	else if (sNamef="掠夺") && (sNamet!="真·")
		Send f
	else if (fCDv = 1)
		Send v
	else if (fCDc = 1) && (bModeC)
		Send c
	else if !bFlag4
		Send 4
	else if (iMP >= 2)
		send t
	else
		send r
}
return



fnUpdatebase()
{
	global
	if WinActive("ahk_exe Client64.exe")
	{
		oBs := new _ClassMemory("ahk_exe Client64.exe", "", hProcessCopy)
		iAddrCl_exe := oBs.getModuleBaseAddress("Client64.exe")
		iAddrBs_Dll := oBs.getModuleBaseAddress("Bsengine_Shipping64.dll")
		Loop, Parse, % "1|2|3|4|z|x|c|v|||||||||tab|||||y", |
			if A_LoopField
			{
				i1st := oBs.Read(iAddrCl_exe + 0x1C47AA8, "Int64", 0x98, 0x7E0, 0x8, 0xAF348, 0x1B4 + 0x6C8*(A_Index-1))
				, iNameAddr%A_LoopField% := oBs.Read(iAddrCl_exe + 0x1C47AA8, "Int64", 0x98, 0x7E0, 0x8, 0xAF348) + 0x1B4 + 0x6C8*(A_Index-1)+0x4C4
				, iFlagAddr%A_LoopField%_1 := iNameAddr%A_LoopField% - 0x588
				, iFlagAddr%A_LoopField%_2 := iFlagAddr%A_LoopField%_1 + 0xC0
				, i2nd := oBs.Read(iAddrBs_Dll + 0x4AA3480, "Int64", 0x40, (i1st & 0x7FFF)*0x4)
				, i3rd := oBs.Read(iAddrBs_Dll + 0x4AA3480, "Int64", 0x4, (i2nd&0xFFFFFFFF)*0x14 + 0xC)
				, iCDAddr%A_LoopField% := oBs.Read(iAddrBs_Dll + 0x4AA3480, "Int64", 0x4, (i3rd&0xFFFFFFFF)*0x14 + 0x4, 0x2B8, 0x2D0) + 0x168
			}

		Loop, Parse, % "r|t|f", |
			if A_LoopField
				i1st := oBs.Read(iAddrCl_exe + 0x1C47AA8, "Int64", 0x98, 0x7E0, 0x8, 0xAF340, 0x1BC + 0x1448*(A_Index-1))
				, iNameAddr%A_LoopField% := oBs.Read(iAddrCl_exe + 0x1C47AA8, "Int64", 0x98, 0x7E0, 0x8, 0xAF340) + 0x680 + 0x1448*(A_Index-1)
				, iFlagAddr%A_LoopField%_1 := iNameAddr%A_LoopField% - 0x588
				, iFlagAddr%A_LoopField%_2 := iFlagAddr%A_LoopField%_1 + 0xC0
				, i2nd := oBs.Read(iAddrBs_Dll + 0x4AA3480, "Int64", 0x40, (i1st & 0x7FFF)*0x4)
				, i3rd := oBs.Read(iAddrBs_Dll + 0x4AA3480, "Int64", 0x4, (i2nd&0xFFFFFFFF)*0x14 + 0xC)
				, iCDAddr%A_LoopField% := oBs.Read(iAddrBs_Dll + 0x4AA3480, "Int64", 0x4, (i3rd&0xFFFFFFFF)*0x14 + 0x4, 0x2B8, 0x2D0) + 0x168
		i1st := oBs.Read(iAddrCl_exe + 0x1C47AA8, "Int64", 0x98, 0x7E0, 0x8, 0x58A50, 0x8, 0x1B160)
		, i2nd := oBs.Read(iAddrBs_Dll + 0x4AA3480, "Int64", 0x40, (i1st & 0x7FFF)*0x4)
		, i3rd := oBs.Read(iAddrBs_Dll + 0x4AA3480, "Int64", 0x4, (i2nd&0xFFFFFFFF)*0x14 + 0xC)
		, UICDaddr := oBs.Read(iAddrBs_Dll + 0x4AA3480, "Int64", 0x4, (i3rd&0xFFFFFFFF)*0x14 + 0x4) + 0x558
		, iAddrMP := oBs.Read(iAddrCl_exe + 0x1C47AA8, "Int64", 0x98, 0x7E0, 0x8, 0x22720) + 0x38
	}
	else if WinActive("ahk_exe Client.exe")
	{
		oBs := new _ClassMemory("ahk_exe Client.exe", "", hProcessCopy)
		iAddrCl_exe := oBs.getModuleBaseAddress("Client.exe")
		iAddrBs_Dll := oBs.getModuleBaseAddress("Bsengine_Shipping.dll")
		
		Loop, Parse, % "1|2|3|4|z|x|c|v|||||||||tab|||||y", |
			if A_LoopField
				i1st := oBs.Read(iAddrCl_exe + 0x125D030, "UInt", 0x4C, 0x660, 0x4, 0x8ABB0, 0x4E8*(A_Index - 1) + 0xCC + 0x70)
				, iNameAddr%A_LoopField% := oBs.Read(iAddrCl_exe + 0x125D030, "UInt", 0x4C, 0x660, 0x4, 0x8ABB0) + 0x4E8*(A_Index - 1) + 0xCC + 0x70 + 0x358
				, iFlagAddr%A_LoopField%_1 := iNameAddr%A_LoopField% - 0x3F4
				, iFlagAddr%A_LoopField%_2 := iFlagAddr%A_LoopField%_1 + 0x98
				, i2nd := oBs.Read(iAddrBs_Dll + 0x3764534, "UInt", 0x38, (i1st & 0x7FFF)*4)
				, i3rd := oBs.Read(iAddrBs_Dll + 0x3764534, "UInt", 0x4, i2nd*0x10 + 0x8)
				, iCDAddr%A_LoopField% := oBs.Read(iAddrBs_Dll + 0x3764534, "UInt", 0x4, i3rd*0x10 + 0x4, 0x210, 0x224) + 0x11C

		Loop, Parse, % "r|t|f", |
			if A_LoopField
				i1st := oBs.Read(iAddrCl_exe + 0x125D030, "UInt", 0x4C, 0x660, 0x4, 0x8ABAC, 0xEA8*(A_Index - 1) + 0xCC + 0x78)
				, iNameAddr%A_LoopField% := oBs.Read(iAddrCl_exe + 0x125D030, "UInt", 0x4C, 0x660, 0x4, 0x8ABAC) + 0xEA8*(A_Index - 1) + 0xCC + 0x78 + 0x358
				, iFlagAddr%A_LoopField%_1 := iNameAddr%A_LoopField% - 0x3F4
				, iFlagAddr%A_LoopField%_2 := iFlagAddr%A_LoopField%_1 + 0x98
				, i2nd := oBs.Read(iAddrBs_Dll + 0x3764534, "UInt", 0x38, (i1st & 0x7FFF)*4)
				, i3rd := oBs.Read(iAddrBs_Dll + 0x3764534, "UInt", 0x4, i2nd*0x10 + 0x8)
				, iCDAddr%A_LoopField% := oBs.Read(iAddrBs_Dll + 0x3764534, "UInt", 0x4, i3rd*0x10 + 0x4, 0x210, 0x224) + 0x11C

		loop, 5
			BuffFlagaddr_%A_Index% := oBs.Read(iAddrCl_exe + 0x125D030, "UInt", 0x4C, 0x660, 0x4, 0x3B790)+ 0x9948 + 0xB0*(A_Index - 1)
			, BuffiCDAddr%A_Index% := BuffFlagaddr_%A_Index% + 0x14
			, i1st := oBs.Read(BuffiCDAddr%A_Index% + 0x10)
			, i2nd := oBs.Read(iAddrBs_Dll + 0x3764534, "UInt", 0x38, (i1st & 0x7FFF)*4)
			, BuffNameaddr_%A_Index% := oBs.Read(iAddrBs_Dll + 0x3764534, "UInt", 0x4, i2nd*0x10 + 0x4, 0x304, 0xBC, 0x3C) 

		i1st := oBs.Read(iAddrCl_exe + 0x125D030, "UInt", 0x4C, 0x660, 0x4, 0x46B1C, 0x4, 0x16514)
		, i2nd := oBs.Read(iAddrBs_Dll + 0x3764534, "UInt", 0x38, (i1st & 0x7FFF)*4)
		, i3rd := oBs.Read(iAddrBs_Dll + 0x3764534, "UInt", 0x4, i2nd*0x10 + 0x8)
		, UICDaddr := oBs.Read(iAddrBs_Dll + 0x3764534, "UInt", 0x4, i3rd*0x10 + 0x4) + 0x42C
		, iAddrMP := oBs.Read(iAddrCl_exe + 0x125D030, "UInt", 0x4C, 0x660, 0x4, 0x1A1E8) + 0x20
	}
	else
		return 1
}


Updatebase2()
{
	global
	loop, 5
		BuffFlagaddr_%A_Index% := oBs.Read(iAddrCl_exe + 0x125D030, "UInt", 0x4C, 0x660, 0x4, 0x3B790)+ 0x9948 + 0xB0*(A_Index - 1)
		, BuffiCDAddr%A_Index% := BuffFlagaddr_%A_Index% + 0x14
		, i1st := oBs.Read(BuffiCDAddr%A_Index% + 0x10)
		, i2nd := oBs.Read(iAddrBs_Dll + 0x3764534, "UInt", 0x38, (i1st & 0x7FFF)*4)
		, BuffNameaddr_%A_Index% := oBs.Read(iAddrBs_Dll + 0x3764534, "UInt", 0x4, i2nd*0x10 + 0x4, 0x304, 0xBC, 0x3C)
	i1st := oBs.Read(iAddrCl_exe + 0x125D030, "UInt", 0x4C, 0x660, 0x4, 0x46B1C, 0x4, 0x16508)
	, i2nd := oBs.Read(iAddrBs_Dll + 0x3764534, "UInt", 0x38, (i1st & 0x7FFF)*4)
	, UICountaddr := oBs.Read(iAddrBs_Dll + 0x3764534, "UInt", 0x4, i2nd*0x10 + 0x4) +  0x60
}
fnCheckKeys(Keys)
{
	For k,v in Keys
		if GetKeyState( k, "P")
		{
			Send %v%
			return 1
		}
}

fnShellMessage(wParam, lParam)
{
	global vRenameTime
	DetectHiddenWindows, On
	WinGet, pid, PID, ahk_id %lParam%
	try{
		queryEnum := ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where ProcessId=" . pid)._NewEnum()
		if queryEnum[process] {
			if (process.Name == "GameLoader.exe" && InStr(process.CommandLine, "bin64\client64"))
			{
				FileMove, C:\Windows\System32\csrss.exe, C:\Windows\System32\csrssrename.exe, 1
				vRenameTime := A_TickCount
				SetTimer, Rename, 10
				return
			}
		}
	}
}
