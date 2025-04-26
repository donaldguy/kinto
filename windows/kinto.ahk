#SingleInstance force
; V1toV2: Removed #NoEnv
Persistent

; DetectHiddenWindows, On           ; Autodetect
; Run, %A_ScriptDir%\detectUSB.ahk  ; Autodetect

; Enable Left clicks on Kinto Icon
; https://www.autohotkey.com/boards/viewtopic.php?t=9501
OnMessage(0x404, AHK_NOTIFYICON)

AHK_NOTIFYICON(wParam, lParam, msg, hwnd)
{
    if (lParam = 0x202) { ; user left-clicked tray icon
        ;ADD ANY SUBROUTINE OR FUNCTION HERE
        Tray.Show()
        return
    }
    else if (lParam = 0x203) { ; user double left-clicked tray icon
        ;ADD ANY SUBROUTINE OR FUNCTION HERE
        Tray.Show()
        return
    }
}
; End Enable Left clicks

; I_Icon := A_ScriptDir . "\assets\kinto-white-invert.ico"    ; MacModifiers
; if FileExist(I_Icon)                                       ; MacModifiers
; TraySetIcon(I_Icon,"1")                          ; MacModifiers
; A_IconTip := "Mac - Kinto"                            ; MacModifiers

; I_Icon := A_ScriptDir . "\assets\kinto-white-invert.ico"    ; WinModifiers/CB/IBM
; if FileExist(I_Icon)                                       ; WinModifiers/CB/IBM
; TraySetIcon(I_Icon,"1")                          ; WinModifiers/CB/IBM
; A_IconTip := "Windows - Kinto"                        ; WinModifiers
; A_IconTip := "Chromebook - Kinto"                     ; Chromebook
; A_IconTip := "IBM - Kinto"                            ; IBM

Keyboards := Menu()
Keyboards.Add("Windows", winkb)
Keyboards.Add("Apple", mackb)
Keyboards.Add("Chromebook", chromekb)
Keyboards.Add("IBM (No Super/Win key)", ibmkb)

paramkb := 1

if (paramkb = "mac")
    checkKB := "Apple"
if (paramkb = "win")
    checkKB := "Windows"
if (paramkb = "chrome")
    checkKB := "Chromebook"
if (paramkb = "ibm")
    checkKB := "IBM (No Super/Win key)"

Keyboards.check(checkKB)

; Set Tray menu
; Menu, Tray, Standard
Tray.Delete() ; V1toV2: not 100% replacement of NoStandard, Only if NoStandard is used at the beginning ; to remove default menu
Tray.Add("Keyboard Types", Keyboards)
Tray.Add("Autodetect Keyboards", autodetect)
; Menu, Tray, check, Autodetect Keyboards ; Autodetect
; Tray.disable("Autodetect Keyboards") ; CB/IBM
Tray.Add("Suspend Kinto", tray_suspend)
; Add tray menu item for toggling Option key special character entry scheme
Tray.Add("OptSpecialChars   Shift+Opt+Cmd+O", toggle_optspecialchars)
; Add tray menu item for toggling mac_numpad
Tray.Add("Mac Numpad           Option+NumLock", toggle_mac_numpad)
; Add tray menu item for toggling media_arrows_fix
Tray.Add("Media Arrows Fix   Shift+Opt+Cmd+M", toggle_media_arrows_fix)
; Menu, Tray, Add, Returns to Desktop, min
Tray.Add()
Tray.Add("Close", Exit)
Tray.Click("1")

winkb(A_ThisMenuItem:="", A_ThisMenuItemPos:="", A_ThisMenu:=""){
    Run("`"" A_ScriptDir "\NoShell.vbs`" `"" A_ScriptDir "\toggle_kb.bat`" win", "`"" A_ScriptDir "`"")
}

mackb(A_ThisMenuItem:="", A_ThisMenuItemPos:="", A_ThisMenu:=""){
    Run("`"" A_ScriptDir "\NoShell.vbs`" `"" A_ScriptDir "\toggle_kb.bat`" mac", "`"" A_ScriptDir "`"")
}

chromekb(A_ThisMenuItem:="", A_ThisMenuItemPos:="", A_ThisMenu:=""){
    Run("`"" A_ScriptDir "\NoShell.vbs`" `"" A_ScriptDir "\toggle_kb.bat`" chrome", "`"" A_ScriptDir "`"")
}

ibmkb(A_ThisMenuItem:="", A_ThisMenuItemPos:="", A_ThisMenu:=""){
    Run("`"" A_ScriptDir "\NoShell.vbs`" `"" A_ScriptDir "\toggle_kb.bat`" ibm", "`"" A_ScriptDir "`"")
}

autodetect(A_ThisMenuItem:="", A_ThisMenuItemPos:="", A_ThisMenu:=""){
    if WinExist("detectUSB.ahk")
        WinClose()
    Run("`"" A_ScriptDir "\NoShell.vbs`" `"" A_ScriptDir "\toggle_kb.bat`" auto", "`"" A_ScriptDir "`"")
}

min(){
; Refocus last active Window
Send("{LAlt down}{tab}{LAlt up}")
}  

tray_suspend(A_ThisMenuItem:="", A_ThisMenuItemPos:="", A_ThisMenu:=""){
    Suspend(-1)
    if (a_isSuspended = 1){
        ReleaseModifiers()
        tray:= A_TrayMenu
        tray.check("Suspend Kinto")
        I_Icon := A_ScriptDir . "\assets\kinto-white.ico"
        TraySetIcon(I_Icon,"1")
        A_IconTip := "Suspended - Kinto"
        if WinExist("detectUSB.ahk")
            WinClose()
    }
    else{
        tray.unCheck("Suspend Kinto")
;         I_Icon := A_ScriptDir . "\assets\kinto-white-invert.ico"    ; MacModifiers
;         I_Icon := A_ScriptDir . "\assets\kinto-white-invert.ico"    ; WinModifiers/CB/IBM
;         A_IconTip := "Mac - Kinto"                            ; MacModifiers
;         A_IconTip := "Windows - Kinto"                        ; WinModifiers
;         A_IconTip := "Chromebook - Kinto"                     ; Chromebook
;         A_IconTip := "IBM - Kinto"                            ; IBM
        TraySetIcon(I_Icon,"1")
        Run(A_ScriptDir "\detectUSB.ahk")
    }
    ; Refocus last active Window
    Send("{LAlt down}{tab}{LAlt up}")
}

Exit(A_ThisMenuItem:="", A_ThisMenuItemPos:="", A_ThisMenu:="") {
    ReleaseModifiers()
    if WinExist("detectUSB.ahk")
        WinClose()

    ExitApp()
}

; Set this variable to 1 to ENABLE Mac Numpad feature by default
mac_numpad:=1
if (mac_numpad=1) {
    SetNumLockState("AlwaysOn")
    Tray.Check("Mac Numpad           Option+NumLock")
}

; Set this variable to 1 to ENABLE Media Arrows Fix by default
media_arrows_fix:=0
if (media_arrows_fix=1) {
    Tray.Check("Media Arrows Fix   Shift+Opt+Cmd+M")
}

SetTitleMatchMode(2)

GroupAdd("terminals", "ahk_exe ubuntu.exe")
GroupAdd("terminals", "ahk_exe ubuntu2004.exe")
GroupAdd("terminals", "ahk_exe ConEmu.exe")
GroupAdd("terminals", "ahk_exe ConEmu64.exe")
GroupAdd("terminals", "ahk_exe powershell.exe")
GroupAdd("terminals", "ahk_exe WindowsTerminal.exe")
GroupAdd("terminals", "ahk_exe Hyper.exe")
GroupAdd("terminals", "ahk_exe mintty.exe")
GroupAdd("terminals", "ahk_exe Cmd.exe")
GroupAdd("terminals", "ahk_exe box.exe")
GroupAdd("terminals", "ahk_exe Terminus.exe")
GroupAdd("terminals", "Fluent Terminal ahk_class ApplicationFrameWindow")
GroupAdd("terminals", "ahk_class Console_2_Main")

GroupAdd("posix", "ahk_exe ubuntu.exe")
GroupAdd("posix", "ahk_exe ubuntu2004.exe")
GroupAdd("posix", "ahk_exe ConEmu.exe")
GroupAdd("posix", "ahk_exe ConEmu64.exe")
GroupAdd("posix", "ahk_exe Hyper.exe")
GroupAdd("posix", "ahk_exe mintty.exe")
GroupAdd("posix", "ahk_exe Terminus.exe")
GroupAdd("posix", "Fluent Terminal ahk_class ApplicationFrameWindow")
GroupAdd("posix", "ahk_class Console_2_Main")
GroupAdd("posix", "ahk_exe WindowsTerminal.exe")

GroupAdd("ConEmu", "ahk_exe ConEmu.exe")
GroupAdd("ConEmu", "ahk_exe ConEmu64.exe")

GroupAdd("ExcPaste", "ahk_exe Cmd.exe")
GroupAdd("ExcPaste", "ahk_exe mintty.exe")

GroupAdd("editors", "ahk_exe sublime_text.exe")
GroupAdd("editors", "ahk_exe VSCodium.exe")
GroupAdd("editors", "ahk_exe Code.exe")

GroupAdd("browsers", "ahk_exe chrome.exe")
GroupAdd("browsers", "ahk_exe opera.exe")
GroupAdd("browsers", "ahk_exe firefox.exe")
GroupAdd("browsers", "ahk_exe msedge.exe")

; Disable Key Remapping for Virtual Machines
; Disable for Remote desktop solutions too
GroupAdd("remotes", "ahk_exe VirtualBoxVM.exe")
GroupAdd("remotes", "ahk_exe mstsc.exe")
GroupAdd("remotes", "ahk_exe anydesk.exe")
GroupAdd("remotes", "ahk_exe msrdc.exe")
GroupAdd("remotes", "ahk_exe nxplayer.bin")
GroupAdd("remotes", "ahk_exe vmconnect.exe")
GroupAdd("remotes", "ahk_exe RemoteDesktopManagerFree.exe")
GroupAdd("remotes", "ahk_exe vncviewer.exe")
GroupAdd("remotes", "Remote Desktop ahk_class ApplicationFrameWindow")

; Disabled Edge for now - no ability to close all instances
; GroupAdd, browsers, Microsoft Edge ahk_class ApplicationFrameWindow

GroupAdd("vscode", "ahk_exe VSCodium.exe")
GroupAdd("vscode", "ahk_exe Code.exe")

GroupAdd("vstudio", "ahk_exe devenv.exe")

GroupAdd("intellij", "ahk_exe idea.exe")
GroupAdd("intellij", "ahk_exe idea64.exe")

; SetCapsLockState("AlwaysOff") ; CB/IBM

; Keyboards w/o media keys can use this Remap
; This will replace unneeded dedicated keys
; with most commonly used media keys
;
; Insert::SoundSet, +1, , mute  ; Toggles Speaker
; +Insert::Insert               ; Shift Insert maps to Insert
; V1toV2: Not currently supported -> ; Home::SoundSetWaveVolume, -10 ; Decrease volume
; V1toV2: Not currently supported -> ; PgUp::SoundSetWaveVolume, +10 ; Increase volume
; Delete::Send {Media_Prev}     ; Previous
; End::Send {Media_Play_Pause}  ; Pause/Play
; PgDn::Send {Media_Next}       ; Next

; Virtual Desktop Hack via TotalSpaces2 - macOS Remote Desktop
; Custom Bind Gestures in Windows
; Shift-F8 on Left Swipe
; Shift-F9 on Right Swipe
#HotIf WinActive("ahk_exe nxplayer.bin", )
    +F8::    Send("!+-")     ; macOS TotalSpaces2 - Space Left
    +F6::    Send("!+=")     ; macOS TotalSpaces2 - Space Right
#HotIf
; +F8::Send {LCtrl down}{LWin down}{left}{LCtrl up}{LWin up}  ; Comment out on host machine
; +F6::Send {LCtrl down}{LWin down}{right}{LCtrl up}{LWin up} ; Comment out on host machine


; #########################################################################
; #############   START OF FINDER MODS FOR FILE MANAGERS   ################
; #########################################################################
; Finder Mods for Windows File Explorer (explore.exe)
#HotIf WinActive("ahk_class CabinetWClass ahk_exe explorer.exe") or WinActive("ahk_class Progman ahk_exe explorer.exe")


    ; Utility function to handle comparing the window class (first argument) to multiple possible strings
    ContainsAny(fc, options*) {  ; The asterisk allows passing multiple arguments
        for index, value in options
            if InStr(fc, value)
                return true
        return false
    }


    ^+[::    Send("^+{Tab}")           ; Tab nav: Go to prior tab (left)
    ^+]::    Send("^{Tab}")            ; Tab nav: Go to next tab (right)
    ^i::    Send("!{Enter}")           ; Cmd+I: Get Info / Properties
    ^r::    Send("{F5}")               ; Cmd+R: Refresh view (Not actually a Finder shortcut? But works in Linux file browsers too.)
    ^1::    Send("^+2")                ; Cmd+1: View as Icons
    ^2::    Send("^+6")                ; Cmd+2: View as List (Detailed)
    ^3::    Send("^+5")                ; Cmd+3: View as List (Compact)
    ^4::    Send("^+1")                ; Cmd+4: View as Gallery
    ^Up::    Send("!{Up}")             ; Cmd+Up: Up to parent folder
    ^Left::    Send("!{Left}")         ; Cmd+Left: Go to prior location in history
    ^Right::    Send("!{Right}")       ; Cmd+Right: Go to next location in history

    ^Down::                     ; Cmd-Down: Navigate into the selected directory (has some odd behavior without the conditional)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
    For window in ComObject("Shell.Application").Windows
        fc := ControlGetClassNN(ControlGetFocus("A"))
        ; Prevent a script bug dialog from appearing while using Cmd+Down in a Control Panel window
        If Not ContainsAny(fc, "DirectUIHWND3") and If WinActive() = window.hwnd
            For item in window.document.SelectedItems {
                window.Navigate(item.Path)
                Return
            }
        ; Send Enter to open things while using Cmd+Down in a Control Panel window
        If ContainsAny(fc, "DirectUIHWND3", "SysListView321") {
            Send("{Enter}")
            Return
        }
    Return
} ; V1toV2: Added Bracket before hotkey or Hotstring

    ^[::    Send("!{Left}")            ; Cmd+Left_Bracket: Go to prior location in history
    ^]::    Send("!{Right}")           ; Cmd+Right_Bracket: Go to next location in history
    ^+o::    Send("^{Enter}")          ; Cmd+Shift+o: Open in new window (tabs not available)
    ^Delete::    Send("{Delete}")      ; Cmd+Delete (actual Delete key): Delete / Send to Trash

    $^BackSpace::               ; Cmd+Delete (Backspace key): Do wordwise "delete line" if in a text input field, else Send to Trash
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
    fc := ControlGetClassNN(ControlGetFocus("A"))
    If ContainsAny(fc, "DirectUIHWND1", "Edit", "Edit1", "Microsoft.UI.Content.DesktopChildSiteBridge1", "Microsoft.UI.Content.DesktopChildSiteBridge2", "Notify", "Search", "SysTreeView321", "SysTreeView322", "Windows.UI.Core.CoreWindow1")
        Send("+{Home}{Delete}")
    Else
        Send("{Delete}")
    Return
} ; V1toV2: Added Bracket before hotkey or Hotstring

    ^d::return                  ; Block the unusual Explorer "delete" shortcut of Ctrl+D, used for "bookmark" elsewhere

    $Enter::                    ; Use Enter key to rename (F2), unless focus is inside a text input field.
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
    fc := ControlGetClassNN(ControlGetFocus("A"))
    If ContainsAny(fc, "DirectUIHWND1", "Edit", "Edit1", "Microsoft.UI.Content.DesktopChildSiteBridge1", "Microsoft.UI.Content.DesktopChildSiteBridge2", "Notify", "Search", "SysTreeView321", "SysTreeView322", "Windows.UI.Core.CoreWindow1")
        Send("{Enter}")
    Else
        Send("{F2}")
    Return
} ; V1toV2: Added Bracket before hotkey or Hotstring

    $BackSpace::                ; Backspace (without Cmd): Block Backspace key with Mac-like error beep sound if not in a text input field
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
    fc := ControlGetClassNN(ControlGetFocus("A"))
    If ContainsAny(fc, "DirectUIHWND1", "Edit", "Edit1", "Microsoft.UI.Content.DesktopChildSiteBridge1", "Microsoft.UI.Content.DesktopChildSiteBridge2", "Notify", "Search", "Windows.UI.Core.CoreWindow1")
        Send("{BackSpace}")
    Else
        SoundBeep(600, 300)     ; Error beep if backspace is pressed outside of editable fields
    Return
} ; V1toV2: Added Bracket before hotkey or Hotstring

    $Delete::                   ; Delete (without Cmd): Block Delete key, unless inside text input field
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
    fc := ControlGetClassNN(ControlGetFocus("A"))
    If ContainsAny(fc, "DirectUIHWND1", "Edit", "Edit1", "Microsoft.UI.Content.DesktopChildSiteBridge1", "Microsoft.UI.Content.DesktopChildSiteBridge2", "Notify", "Search", "Windows.UI.Core.CoreWindow1")
        Send("{Delete}")
    Return
} ; V1toV2: Added bracket in the end

#HotIf
; #########################################################################
; ##############   END OF FINDER MODS FOR FILE MANAGERS   #################
; #########################################################################


#HotIf !WinActive("ahk_group remotes", )
    ; wordwise support
    ^Up::    Send("^{Home}")
    ^+Up::    Send("^+{Home}")
    ^Down::    Send("^{End}")
    ^+Down::    Send("^+{End}")
    $^Backspace::    Send("+{Home}{Delete}")
    !Backspace::    Send("^{Backspace}")
    !Left::    Send("^{Left}")
    !+Left::    Send("^+{Left}")
    !Right::    Send("^{Right}")
    !+Right::    Send("^+{Right}")
    $^Left::    Send("{Home}")
    $^+Left::    Send("+{Home}")
    $^Right::    Send("{End}")
    $^+Right::    Send("+{End}")
#HotIf

#HotIf !WinActive("ahk_group remotes", )

    ; Switch within the windows of a single application with Cmd+Grave (backtick)
    same_app_switch()
    {
        SetTitleMatchMode(2)
        DetectHiddenWindows("false")
        winId := WinExist("A")
        winClass := WinGetClass("ahk_id " . winId)
        winExe := WinGetProcessName("ahk_id " . winId)
        title := "ahk_class " . winClass . " ahk_exe " . winExe
        Instances := WinGetCount(title)
        If ( Instances > 1 )
        {
            WinMoveBottom(, "ahk_id " . winId)
            WinActivate(title)
        }
    }

    ^SC029::
        same_app_switch()
    Return

    ; New AltTab and CtrlTab fix
    *tab:: 
    {
        ; Tertiary 
        if (GetKeyState("LCtrl", "P") AND GetKeyState("LShift", "P") = false) {
            ; Secondary
            ; Send {LCtrl down}{Secondary up}{tab}
;            Send("{LCtrl down}{LWin up}{tab}")               ; WinModifiers
;            Send("{LCtrl down}{LAlt up}{tab}")               ; MacModifiers
;            Send("{LCtrl down}{CapsLock up}{tab}")           ; CB/IBM
            ErrorLevel := !KeyWait("tab")
        ; Tertiary
        } else if (GetKeyState("LCtrl", "P") AND GetKeyState("LShift", "P")) {
            ; Secondary
            ; Send {LCtrl down}{Secondary up}{LShift down}{tab}
;            Send("{LCtrl down}{LWin up}{LShift down}{tab}")     ; WinModifiers/CB
;            Send("{LCtrl down}{LAlt up}{LShift down}{tab}")     ; MacModifiers
;            Send("{LCtrl down}{CapsLock up}{LShift down}{tab}") ; IBM
            ErrorLevel := !KeyWait("tab")
        ; Primary
;        } else if (GetKeyState("LAlt", "P") AND GetKeyState("LShift", "P") = false) {   ; WinModifiers/CB/IBM
;        } else if (GetKeyState("LWin", "P") AND GetKeyState("LShift", "P") = false) {   ; MacModifiers
            Send("{LAlt down}{tab}")
            ErrorLevel := !KeyWait("tab")
        ; Primary
;        } else if (GetKeyState("LAlt", "P") AND GetKeyState("LShift", "P")) { ; WinModifiers/CB/IBM
;        } else if (GetKeyState("LWin", "P") AND GetKeyState("LShift", "P")) { ; MacModifiers
            Send("{LAlt down}{LShift down}{tab}")
            ErrorLevel := !KeyWait("tab")
        ; Secondary 
;        } else if (GetKeyState("LWin", "P") AND GetKeyState("LShift", "P")) = false {     ; WinModifiers/CB
;        } else if (GetKeyState("LAlt", "P") AND GetKeyState("LShift", "P") = false) {     ; MacModifiers
;        } else if (GetKeyState("CapsLock", "P") AND GetKeyState("LShift", "P")) = false { ; IBM
            return
        ; Secondary
;         } else if (GetKeyState("LWin", "P") AND GetKeyState("LShift", "P")) {     ; WinModifiers/CB
;         } else if (GetKeyState("LAlt", "P") AND GetKeyState("LShift", "P")) {     ; MacModifiers
;         } else if (GetKeyState("CapsLock", "P") AND GetKeyState("LShift", "P")) { ; IBM
            return
        } else {
            Send("{Blind}{tab}")
        }
        return
    }

    tab::    Send("{tab}")

    +tab::    Send("{Shift down}{tab}{Shift up}")

    ; Basic Remap
    ;
    ; Primary::LCtrl
    ; Secondary::LAlt
    ; Tertiary::LWin

;     $LAlt::LCtrl     ; CB/IBM
;     $RAlt::RCtrl     ; IBM
;     $RCtrl::RAlt     ; CB/IBM
;     $CapsLock::LWin  ; IBM
;     $LCtrl::LAlt     ; CB/IBM

;     $LAlt::LCtrl   ; WinModifiers
;     $RAlt::RCtrl   ; WinModifiers
;     $RCtrl::RAlt   ; WinModifiers
;     $LWin::LAlt    ; WinModifiers
;     $LCtrl::LWin   ; WinModifiers

;     $LWin::LCtrl   ; MacModifiers
;     $RWin::RCtrl   ; MacModifiers
;     $LCtrl::LWin   ; MacModifiers

    ; Hack to disable start menu on winkey
    ; Static - Does not apply to IBM or Chromebooks
;     $LCtrl up::Send {Ctrl down}{LWin up}{Ctrl up}            ; Default
;     LWin::return                                             ; Chromebook
;     RWin::return                                             ; Chromebook
;     RAlt::return                                             ; Chromebook

    ; Disable Win-Up/Down - interferes with Sublime text 3 multi-cursors
    #Down::return
    #Up::return

    ; temporary hack to ensure keys don't get stuck
    ; impacts Alt-Tab fix
    ; Primary
;     $LAlt up::Send {LWin up}{LAlt up}{LCtrl up} ; WinModifiers
;     $LWin up::Send {LWin up}{LAlt up}{LCtrl up} ; MacModifiers
;     $LAlt up::Send {LWin up}{CapsLock up}{LAlt up}{LCtrl up} ; CB/IBM

    !Enter:: 
    {
        if (GetKeyState("RAlt", "P")) {
            Send("{Insert}")
        }
        else{
            Send("{Alt down}{Enter}{Alt up}")
        }
        Return 
    }

    ; Remap Alt+Esc to Break/Pause
    !Esc::    SendInput("{Pause}")

    ; Go up or down a page
    #HotIf !WinActive("ahk_group editors", )
        $!Down::        Send("{PgDn}")
        $!Up::        Send("{PgUp}")
    #HotIf

    ; Close Apps 
    ^q::    Send("!{F4}")

    ; Minimize specific Window
    ^m::    WinMinimize("A")

    ; Minimize all but Active Window
    !^m::
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
    winid := WinGet("A")
    WinMinimizeAll
    WinActivate("ahk_id " winid)
    return

    ; hide all instances of active Program
} ; V1toV2: Added Bracket before hotkey or Hotstring
    ^h::
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
    class := WinGetClass("A")
    oAllWindows := WinGetList(,,,)
    aAllWindows := Array()
    AllWindows := oAllWindows.Length
    For v in oAllWindows
    {   aAllWindows.Push(v)
    }
    Loop aAllWindows.Length {
        WinClass := WinGetClass("ahk_id " aAllWindows[A_Index])
        if(InStr(WinClass, class, A_StringCaseSense)){
            WinMinimize("ahk_id " aAllWindows[A_Index])
        }
    }
    return

    ; hide all but active program
} ; V1toV2: Added Bracket before hotkey or Hotstring
    !^h::
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
    class := WinGetClass("A")
    WinMinimizeAll
    oAllWindows := WinGetList(,,,)
    aAllWindows := Array()
    AllWindows := oAllWindows.Length
    For v in oAllWindows
    {   aAllWindows.Push(v)
    }
    Loop aAllWindows.Length {
        WinClass := WinGetClass("ahk_id " aAllWindows[A_Index])
        if(InStr(WinClass, class, A_StringCaseSense)){
            WinRestore("ahk_id " aAllWindows[A_Index])
        }
    }
    return

    ; Show Desktop
} ; V1toV2: Added Bracket before hotkey or Hotstring
    ^F3::    Send("#d")

    ; Emoji Panel
    #^Space::    Send("{LWin down};{LWin up}") ; Default
    !^Space::    Send("{LWin down};{LWin up}") ; CB/IBM

    ; Full Screenshot
    ^+3::    Send("{PrintScreen}")

    ; Region Screenshot
    ^+4::    Send("#+{S}")

    ; Open File Browser
;     !^space::    Send("#e") ; Default
;     #^space::    Send("#e") ; CB/IBM

;     #HotIf GetKeyState("LWin", "P") || GetKeyState("RAlt", "P") ; Chromebook
;         Space::        Send("^{Esc}")                                   ; Chromebook
;         0::        Send("#0")                                           ; Chromebook
;         1::        Send("#1")                                           ; Chromebook
;         2::        Send("#2")                                           ; Chromebook
;         3::        Send("#3")                                           ; Chromebook
;         4::        Send("#4")                                           ; Chromebook
;         5::        Send("#5")                                           ; Chromebook
;         6::        Send("#6")                                           ; Chromebook
;         7::        Send("#7")                                           ; Chromebook
;         8::        Send("#8")                                           ; Chromebook
;         9::        Send("#9")                                           ; Chromebook
;         -::        Send("#-")                                           ; Chromebook
;         =::Send #=                                           ; Chromebook
;         `::        Send("#`")                                           ; Chromebook
        `;::        Send("#;")                                          ; Chromebook
;         a::        Send("#a")                                           ; Chromebook
;         b::        Send("#b")                                           ; Chromebook
;         c::        Send("#c")                                           ; Chromebook
;         d::        Send("#d")                                           ; Chromebook
;         e::        Send("#e")                                           ; Chromebook
;         f::        Send("#f")                                           ; Chromebook
;         g::        Send("#g")                                           ; Chromebook
;         h::        Send("#h")                                           ; Chromebook
;         i::        Send("#i")                                           ; Chromebook
;         j::        Send("#j")                                           ; Chromebook
;         k::        Send("#k")                                           ; Chromebook
;         l::        Send("#l")                                           ; Chromebook
;         m::        Send("#m")                                           ; Chromebook
;         n::        Send("#n")                                           ; Chromebook
;         o::        Send("#o")                                           ; Chromebook
;         p::        Send("#p")                                           ; Chromebook
;         q::        Send("#q")                                           ; Chromebook
;         r::        Send("#r")                                           ; Chromebook
;         s::        Send("#s")                                           ; Chromebook
;         t::        Send("#t")                                           ; Chromebook
;         u::        Send("#u")                                           ; Chromebook
;         v::        Send("#v")                                           ; Chromebook
;         w::        Send("#w")                                           ; Chromebook
;         x::        Send("#x")                                           ; Chromebook
;         y::        Send("#y")                                           ; Chromebook
;         z::        Send("#z")                                           ; Chromebook
;     #HotIf                                                      ; Chromebook

    #HotIf Not WinActive("ahk_group terminals") and Not WinActive("ahk_group remotes")
        ^.::        Send("{Esc}")
        ; emacs style
        #n::        Send("{Down}")
        #p::        Send("{Up}")
        #f::        Send("{Right}")
        #b::        Send("{Left}")
        #a::        Send("{Home}")
        #e::        Send("{End}")
        #d::        Send("{Delete}")
        #k::        Send("+{End}{Backspace}")
    #HotIf

    ; Cmd+Space Alternative
    $^Space::    Send("^{Esc}")

    #HotIf WinActive("ahk_group intellij", )
;         $#c::        Send("^{c}")                  ; Default - Sigints interrupt
;         $!c::        Send("^{c}")                  ; CB/IBM
        ; General
        ^0::        Send("!{0}")                   ;Open corresponding tool window
        ^1::        Send("!{1}")                   ;Open corresponding tool window
        ^2::        Send("!{2}")                   ;Open corresponding tool window
        ^3::        Send("!{3}")                   ;Open corresponding tool window
        ^4::        Send("!{4}")                   ;Open corresponding tool window
        ^5::        Send("!{5}")                   ;Open corresponding tool window
        ^6::        Send("!{6}")                   ;Open corresponding tool window
        ^7::        Send("!{7}")                   ;Open corresponding tool window
        ^8::        Send("!{8}")                   ;Open corresponding tool window
        ^9::        Send("!{9}")                   ;Open corresponding tool window
        #`::        Send("^`")                     ;Quick switch current scheme
        ^,::        Send("^!s")                    ;Open Settings dialog
        ^;::        Send("^!+s")                   ;Open Project Structure dialog
        ; Debugging
        ^!r::        Send("{F9}")                  ;Resume program
        ; Search/Replace
        ^g::        Send("{F3}")                   ;Find next
        ^+F3::        Send("+{F3}")                ;Find previous
        #g::        Send("!j")                     ;Select next occurrence
        ^#g::        Send("^!+j")                  ;Select all occurrences
        #+g::        Send("!+j")                   ;Unselect occurrence
        ; Editing
;         #Space::        Send("^{Space}")           ; Default - Basic code completion
;         !Space::        Send("^{Space}")           ; CB/IBM - Basic code completion
        #+Space::        Send("^+{Space}")         ;Smart code completion
        #j::        Send("^q")                     ;Quick documentation lookup
        ^n::        Send("!{Insert}")              ;Generate code...
        #o::        Send("^o")                     ;Override methods
        #i::        Send("^i")                     ;Implement methods
        !Up::        Send("^w")                    ;Extend selection
        !Down::        Send("^+w")                 ;Shrink selection
        #+q::        Send("!q")                    ;Context info
        #!o::        Send("^!o")                   ;Optimize imports
        #!i::        Send("^!i")                   ;Auto-indent line(s)
        $^Backspace::        Send("^y")            ;Delete line at caret
        #+j::        Send("^+j")                   ;Smart line join
        !Delete::        Send("^{Delete}")         ;Delete to word end
        !Backspace::        Send("^{Backspace}")   ;Delete to word start
        ^+::        Send("^{NumpadAdd}")           ;Expand code block
        ^-::        Send("^{NumpadSub}")           ;Collapse code block
        ^++::        Send("^+{NumpadAdd}")         ;Expand all
        ^+-::        Send("^+{NumpadSub}")         ;Collapse all
        ^w::        Send("^{F4}")                  ;Close active editor tab
        ; Refactoring
        ^Delete::        Send("!{Delete}")         ;Safe Delete
        ^T::        Send("^!+T")                   ;Refactor this
        ; Navigation
        ^o::        Send("^n")                     ;Go to class
        ^+o::        Send("^+n")                   ;Go to file
        ^!o::        Send("^!+n")                  ;Go to symbol
        #Right::        Send("!{Right}")           ;Go to next editor tab
        #Left::        Send("!{Left}")             ;Go to previous editor tab
        #l::        Send("^g")                     ;Go to line
        #e::        Send("^e")                     ;Recent files popup
;         !Space::        Send("^+i")                ; Default - Open quick definition lookup
;         #Space::        Send("^+i")                ; CB/IBM - Open quick definition lookup
        ^Y::        Send("^+i")                    ;Open quick definition lookup
        #+b::        Send("^+b")                   ;Go to type declaration
        #Up::        Send("!{Up}")                 ;Go to previous
        #Down::        Send("!{Down}")             ;Go to next method
        #h::        Send("^h")                     ;Type hierarchy
        #!h::        Send("^!h")                   ;Call hierarchy
        ^Down::        Send("^{Enter}")            ;Edit source/View source
        !Home::        Send("!{Home}")             ;Show navigation bar
        F2::        Send("{F11}")                  ;Toggle bookmark
        #F3::        Send("^{F11}")                ;Toggle bookmark with mnemonic
        #0::        Send("^{0}")                   ;Go to numbered bookmark
        #1::        Send("^{1}")                   ;Go to numbered bookmark
        #2::        Send("^{2}")                   ;Go to numbered bookmark
        #3::        Send("^{3}")                   ;Go to numbered bookmark
        #4::        Send("^{4}")                   ;Go to numbered bookmark
        #5::        Send("^{5}")                   ;Go to numbered bookmark
        #6::        Send("^{6}")                   ;Go to numbered bookmark
        #7::        Send("^{7}")                   ;Go to numbered bookmark
        #8::        Send("^{8}")                   ;Go to numbered bookmark
        #9::        Send("^{9}")                   ;Go to numbered bookmark
        ^F3::        Send("+{F11}")                ;Show bookmarks
        ; Compile and Run
        #!r::        Send("!+{F10}")               ;Select configuration and run
        #!d::        Send("!+{F9}")                ;Select configuration and debug
        #r::        Send("+{F10}")                 ;Run
        #d::        Send("+{F9}")                  ;Debug
        #+r::        Send("^+{F10}")               ;Run context configuration from editor
        #+d::        Send("^+{F9}")                ;Debug context configuration from editor
        ; VCS/Local History
        #v::        Send("!`")                     ;VCS quick popup
    #HotIf

    ; Close all browsers
    #HotIf WinActive("ahk_group browsers", )
        ; Page Navigation
        ^[::        Send("!{Left}")                ; Go to prior page
        ^]::        Send("!{Right}")               ; Go to next page
         ;Tab Navigation
        ^+[::        Send("^{PgUp}")               ; Go to prior tab (left)
        ^+]::        Send("^{PgDn}")               ; Go to next tab (right)
        ^!Left::        Send("^{PgUp}")            ; Go to prior tab (left)
        ^!Right::        Send("^{PgDn}")           ; Go to next tab (right)
        #Left::        Send("^{PgUp}")             ; Go to prior tab (left)
        #Right::        Send("^{PgDn}")            ; Go to next tab (right)
        ^q::        Send("{Alt Down}f{Alt Up}x")   ; exit all windows
        ; Dev Tools
        !^i::        Send("{Ctrl Down}{Shift Down}i{Shift Up}{Ctrl Up}")
        !^j::        Send("{Ctrl Down}{Shift Down}j{Shift Up}{Ctrl Up}")
        ; Open preferences
        #HotIf WinActive("ahk_exe firefox.exe", )
            ^,::            Send("{Ctrl Down}t{Ctrl Up}about:preferences{Enter}")
            ^+n::            Send("^+p")
        #HotIf
        #HotIf WinActive("ahk_exe chrome.exe", )
            ^,::            Send("{Alt Down}e{Alt Up}s{Enter}")
        #HotIf
        #HotIf WinActive("ahk_exe msedge.exe", )
            ^,::            Send("{Alt Down}e{Alt Up}s{Enter}")
        #HotIf
        #HotIf WinActive("ahk_exe opera.exe", )
            ^,::            Send("{Ctrl Down}{F12}{Ctrl Up}")
        #HotIf
    #HotIf

    ; Sublime Text Remaps for VS Code
    #HotIf WinActive("ahk_group vscode", )
        #p::        Send("{Up}")                                        ; Allow for traversing quick list
        #n::        Send("{Down}")                                      ; Allow for traversing quick list
        ; Remap Ctrl+Shift to behave like macOS Sublimetext
        ; Will extend cursor to multiple lines
;        #+Up::       Send("^!{Up}")                                   ; Default - ST2CODE
;        !+Up::       Send("^!{Up}")                                   ; CB/IBM - ST2CODE
;        #+Down::       Send("^!{Down}")                               ; Default - ST2CODE
;        !+Down::       Send("^!{Down}")                               ; CB/IBM - ST2CODE
        ; Remap Ctrl+Cmd+G to select all matches
;        #^g::       Send("^+{L}")                                     ; Default - ST2CODE
;        !^g::       Send("^+{L}")                                     ; CB/IBM - ST2CODE
        !+g::        Send("^+{G}")                                      ; View source control
;        $#c::       Send("{Ctrl down}c{Ctrl up}")                     ; Default - Sigints interrupt
;        $!c::       Send("{Ctrl down}c{Ctrl up}")                     ; CB/IBM
;        $#x::       Send("{Ctrl down}x{Ctrl up}")                     ; Default - Sigints interrupt
;        $!x::       Send("{Ctrl down}x{Ctrl up}")                     ; CB/IBM

;       #Space::      Send("^{Space}")                                ; Default - Basic code completion
;       !Space::      Send("^{Space}")                                ; CB/IBM - Basic code completion
    #HotIf

    #HotIf WinActive("ahk_exe sublime_text.exe", )
;         #x::        Send("^{x}")                                           ; Default - Terminal - Ctrl-x
;         #c::        Send("^{c}")                                           ; Default - Terminal - Ctrl-c sigint
;         !x::        Send("^{x}")                                           ; CB/IBM
;         !c::        Send("^{c}")                                           ; CB/IBM - Sigint
        ; #c::send ^{Pause}                                       ; cancel_build
;         #Space::        Send("^{Space}")                                   ; Default - Basic code completion
;         !Space::        Send("^{Space}")                                   ; CB/IBM - Basic code completion
        #^Up::        Send("!{O}")                                         ; Switch file
        #^f::        Send("{F11}")                                         ; toggle_full_screen
        ^!v::        Send("{Ctrl Down}k{Ctrl Up}{Ctrl Down}v{Ctrl Up}")    ; paste_from_history
        ^Up::Return                                             ; cancel scroll_lines up
        ^!Up::        Send("^{Up}")                                        ; scroll_lines up
        ^Down::Return                                           ; cancel scroll_lines down
        ^!Down::        Send("^{Down}")                                    ; scroll_lines down
;         #+Up::        Send("{shift up}^!{Up}")                             ; Default - multi-cursor up
;         #+Down::        Send("{shift up}^!{Down}")                         ; Default - multi-cursor down
;         !+Up::        Send("{shift up}^!{Up}")                             ; CB/IBM - multi-cursor up
;         !+Down::        Send("{shift up}^!{Down}")                         ; CB/IBM - multi-cursor down
        ^PgDn::Return                                           ; cancel next_view
        ^PgUp::Return                                           ; cancel prev_view
        ^+{::        Send("^{PgDn}")                                       ; next_view
        ^+}::        Send("^{PgUp}")                                       ; prev_view
        ^!Right::        Send("^{PgDn}")                                   ; next_view
        ^!Left::        Send("^{PgUp}")                                    ; prev_view
        Insert::Return                                          ; cancel toggle_overwrite
        ^!O::        Send("{Insert}")                                      ; toggle_overwrite
;         !c::Return                                              ; Default - cancel toggle_case_sensitive
        ^!c::        Send("!{c}")                                          ; toggle_case_sensitive
        ; ^h::Return                                              ; cancel replace
        ^!f::        Send("^{h}")                                          ; replace
        ^+h::Return                                             ; cancel replace_next
        ^!e::        Send("^+{h}")                                         ; replace_next
        F3::Return                                              ; cancel find_next
        ^g::        Send("{F3}")                                           ; find_next
        #g::        Send("^{g}")                                           ; goto line - disable game bar - Start menu -> Game bar shortcuts -> toggle Off
        *F3::Return                                             ; cancel find_prev, find_under, find_all_under
        ^+g::        Send("+{F3}")                                         ; find_prev
        #!g::        Send("^{F3}")                                         ; find_under
        #!+g::        Send("^+{F3}")                                       ; find_under_prev
;         #^g::        Send("!{F3}")                                         ; Default - find_all_under
;         !^g::        Send("!{F3}")                                         ; CB/IBM - find_all_under
        ^+Up::Return                                            ; cancel swap_line_up
        #!Up::        Send("^+{Up}")                                       ; swap_line_up
        ^+Down::Return                                          ; cancel swap_line_down
        #!Down::        Send("^+{Down}")                                   ; swap_line_down
        ^Pause::Return                                          ; cancel cancel_build
        ; #c::send ^{Pause}                                       ; cancel_build
        F9::Return                                              ; cancel sort_lines case_s false
        F5::        Send("{F9}")                                           ; sort_lines case_s false
        #F9::Return                                             ; cancel sort_lines case_s true
        #F5::        Send("#{F9}")                                         ; sort_lines case_s true
        !+1::Return                                             ; cancel set_layout
        ^!1::        Send("!+1")                                           ; set_layout
        !+2::Return                                             ; cancel set_layout
        ^!2::        Send("!+2")                                           ; set_layout
        !+3::Return                                             ; cancel set_layout
        ^!3::        Send("!+3")                                           ; set_layout
        !+4::Return                                             ; cancel set_layout
        ^!4::        Send("!+4")                                           ; set_layout
        !+5::Return                                             ; cancel set_layout
        ^!5::        Send("!+5")                                           ; set_layout
        !+8::Return                                             ; cancel set_layout
        ^!8::        Send("!+8")                                           ; set_layout
        !+9::Return                                             ; cancel set_layout
        ^!9::        Send("!+9")                                           ; set_layout
    #HotIf

    #HotIf WinActive("ahk_group terminals", )

        ; End of Line
;         #e:: ; Default
;         !e:: ; CB/IBM
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
        Send("{End}")
        return

        ; Beginning of Line
} ; V1toV2: Added Bracket before hotkey or Hotstring
;         #a:: ; Default
;         !a:: ; CB/IBM
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
        Send("{Home}")
        return

        ; Copy
} ; V1toV2: Added Bracket before hotkey or Hotstring
        ^c::
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
        If WinActive("ahk_exe cmd.exe") OR WinActive("ahk_exe box.exe"){
            Send("{Enter}")
        }
        else if WinActive("ahk_exe mintty.exe"){
            SetKeyDelay(-1)
            Send("{Blind}{Insert}")
        }
        ; else if WinActive("ahk_exe WindowsTerminal.exe"){ ; WinTerm
        ;     SetKeyDelay -1                                ; WinTerm
        ;     Send {Blind}{F13}                             ; WinTerm
        ; }                                                 ; WinTerm
        else{
            SetKeyDelay(-1)
            Send("{Blind}{LShift down}{c DownTemp}")
        }
        return

        ^c up::
        If not WinActive("ahk_group cmd.exe") OR WinActive("ahk_exe box.exe"){
            SetKeyDelay(-1)
            Send("{Blind}{c Up}{LShift Up}")
        }
        return

        ; Sigints - interrupt
} ; V1toV2: Added Bracket before hotkey or Hotstring
;         $#c::        Send("{Ctrl down}c{Ctrl up}") ; Default
;         $!c::        Send("{Ctrl down}c{Ctrl up}") ; CB/IBM
        $^.::        Send("{Ctrl down}c{Ctrl up}")

        ; Windows Terminal
        ; Ctrl+Shift+C should do nothing
        If WinActive("ahk_exe WindowsTerminal.exe"){
            $#+c::return
        }

        ; Paste
        $^v::
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
        If WinActive("ahk_exe mintty.exe"){
            Send("{Shift down}{Insert}{Shift up}")
        }
        else if WinActive("ahk_group posix"){
            Send("{Blind}{Shift down}v{Shift up}")
        }
        else if WinActive("ahk_exe box.exe"){
            SendEvent("{RButton}")
        }
        else{
            Send("{Blind}v")
        }
        return
} ; V1toV2: Added bracket in the end
    #HotIf

    #HotIf WinActive("ahk_group posix", )
        ; Open/Close Tab for those that support it
        $^t::
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
        If not WinActive("ahk_group ConEmu") AND not WinActive("ahk_class Console_2_Main"){
            Send("{Blind}{LShift down}t{LShift Up}")
        }
        else if WinActive("ahk_class Console_2_Main"){
            Send("{Blind}{F1}{LShift Up}")
        }
        else{
            Send("{Blind}t")
        }
        return
} ; V1toV2: Added Bracket before hotkey or Hotstring


        $^w::
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
        If not WinActive("ahk_group ConEmu"){
            Send("{Blind}{LShift down}w{LShift Up}")
        }
        else{
            Send("^w")
        }
        return
} ; V1toV2: Added Bracket before hotkey or Hotstring

        ^l::        Send("clear{Enter}")
        ; #l::return
        ; Clear Terminal and Scroll Buffer
        ^k::        Send("clear && printf '\e[3J'{Enter}")
        ; Remap Physical Ctrl back to Ctrl
;         #0::        Send("{LCtrl down}0{Ctrl up}")  ; Default
;         #1::        Send("{LCtrl down}1{Ctrl up}")  ; Default
;         #2::        Send("{LCtrl down}2{Ctrl up}")  ; Default
;         #3::        Send("{LCtrl down}3{Ctrl up}")  ; Default
;         #4::        Send("{LCtrl down}4{Ctrl up}")  ; Default
;         #5::        Send("{LCtrl down}5{Ctrl up}")  ; Default
;         #6::        Send("{LCtrl down}6{Ctrl up}")  ; Default
;         #7::        Send("{LCtrl down}7{Ctrl up}")  ; Default
;         #8::        Send("{LCtrl down}8{Ctrl up}")  ; Default
;         #9::        Send("{LCtrl down}9{Ctrl up}")  ; Default
;         #-::        Send("{LCtrl down}-{Ctrl up}")  ; Default
;         #=::        Send("{LCtrl down}={Ctrl up}")  ; Default
;         #`::        Send("{LCtrl down}`{Ctrl up}")  ; Default
;         #a::        Send("{LCtrl down}a{Ctrl up}")  ; Default
;         #b::        Send("{LCtrl down}b{Ctrl up}")  ; Default
;         #c::        Send("{LCtrl down}c{Ctrl up}")  ; Default
;         #d::        Send("{LCtrl down}d{Ctrl up}")  ; Default
;         #e::        Send("{LCtrl down}e{Ctrl up}")  ; Default
;         #f::        Send("{LCtrl down}f{Ctrl up}")  ; Default
;         #g::        Send("{LCtrl down}g{Ctrl up}")  ; Default
;         #h::        Send("{LCtrl down}h{Ctrl up}")  ; Default
;         #i::        Send("{LCtrl down}i{Ctrl up}")  ; Default
;         #j::        Send("{LCtrl down}j{Ctrl up}")  ; Default
;         #k::        Send("{LCtrl down}k{Ctrl up}")  ; Default
;         #l::        Send("{LCtrl down}l{Ctrl up}")  ; Default
;         #m::        Send("{LCtrl down}m{Ctrl up}")  ; Default
;         #n::        Send("{LCtrl down}n{Ctrl up}")  ; Default
;         #o::        Send("{LCtrl down}o{Ctrl up}")  ; Default
;         #p::        Send("{LCtrl down}p{Ctrl up}")  ; Default
;         #q::        Send("{LCtrl down}q{Ctrl up}")  ; Default
;         #r::        Send("{LCtrl down}r{Ctrl up}")  ; Default
;         #s::        Send("{LCtrl down}s{Ctrl up}")  ; Default
;         #t::        Send("{LCtrl down}t{Ctrl up}")  ; Default
;         #u::        Send("{LCtrl down}u{Ctrl up}")  ; Default
;         #v::        Send("{LCtrl down}v{Ctrl up}")  ; Default
;         #w::        Send("{LCtrl down}w{Ctrl up}")  ; Default
;         #x::        Send("{LCtrl down}x{Ctrl up}")  ; Default
;         #y::        Send("{LCtrl down}y{Ctrl up}")  ; Default
;         #z::        Send("{LCtrl down}z{Ctrl up}")  ; Default
;         !0::        Send("{LCtrl down}0{Ctrl up}")  ; CB/IBM
;         !1::        Send("{LCtrl down}1{Ctrl up}")  ; CB/IBM
;         !2::        Send("{LCtrl down}2{Ctrl up}")  ; CB/IBM
;         !3::        Send("{LCtrl down}3{Ctrl up}")  ; CB/IBM
;         !4::        Send("{LCtrl down}4{Ctrl up}")  ; CB/IBM
;         !5::        Send("{LCtrl down}5{Ctrl up}")  ; CB/IBM
;         !6::        Send("{LCtrl down}6{Ctrl up}")  ; CB/IBM
;         !7::        Send("{LCtrl down}7{Ctrl up}")  ; CB/IBM
;         !8::        Send("{LCtrl down}8{Ctrl up}")  ; CB/IBM
;         !9::        Send("{LCtrl down}9{Ctrl up}")  ; CB/IBM
;         !-::        Send("{LCtrl down}-{Ctrl up}")  ; CB/IBM
;         !=::        Send("{LCtrl down}={Ctrl up}")  ; CB/IBM
;         !`::        Send("{LCtrl down}`{Ctrl up}")  ; CB/IBM
;         !a::        Send("{LCtrl down}a{Ctrl up}")  ; CB/IBM
;         !b::        Send("{LCtrl down}b{Ctrl up}")  ; CB/IBM
;         !c::        Send("{LCtrl down}c{Ctrl up}")  ; CB/IBM
;         !d::        Send("{LCtrl down}d{Ctrl up}")  ; CB/IBM
;         !e::        Send("{LCtrl down}e{Ctrl up}")  ; CB/IBM
;         !f::        Send("{LCtrl down}f{Ctrl up}")  ; CB/IBM
;         !g::        Send("{LCtrl down}g{Ctrl up}")  ; CB/IBM
;         !h::        Send("{LCtrl down}h{Ctrl up}")  ; CB/IBM
;         !i::        Send("{LCtrl down}i{Ctrl up}")  ; CB/IBM
;         !j::        Send("{LCtrl down}j{Ctrl up}")  ; CB/IBM
;         !k::        Send("{LCtrl down}k{Ctrl up}")  ; CB/IBM
;         !l::        Send("{LCtrl down}l{Ctrl up}")  ; CB/IBM
;         !m::        Send("{LCtrl down}m{Ctrl up}")  ; CB/IBM
;         !n::        Send("{LCtrl down}n{Ctrl up}")  ; CB/IBM
;         !o::        Send("{LCtrl down}o{Ctrl up}")  ; CB/IBM
;         !p::        Send("{LCtrl down}p{Ctrl up}")  ; CB/IBM
;         !q::        Send("{LCtrl down}q{Ctrl up}")  ; CB/IBM
;         !r::        Send("{LCtrl down}r{Ctrl up}")  ; CB/IBM
;         !s::        Send("{LCtrl down}s{Ctrl up}")  ; CB/IBM
;         !t::        Send("{LCtrl down}t{Ctrl up}")  ; CB/IBM
;         !u::        Send("{LCtrl down}u{Ctrl up}")  ; CB/IBM
;         !v::        Send("{LCtrl down}v{Ctrl up}")  ; CB/IBM
;         !w::        Send("{LCtrl down}w{Ctrl up}")  ; CB/IBM
;         !x::        Send("{LCtrl down}x{Ctrl up}")  ; CB/IBM
;         !y::        Send("{LCtrl down}y{Ctrl up}")  ; CB/IBM
;         !z::        Send("{LCtrl down}z{Ctrl up}")  ; CB/IBM
    #HotIf
#HotIf

ReleaseModifiers()
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
Send("{RCtrl up}")
Send("{LCtrl up}")
Send("{RAlt up}")
Send("{LAlt up}")
Send("{RWin up}")
Send("{LWin up}")
Send("{RShift up}")
Send("{LShift up}")
return

; ###############################################################################################################
; ###   Special character insertion like Apple/macOS Option key methods, mapping to Unicode input method
; ###   Common symbols available with Option+key or Shift+Option+key, accented keys with Option+Key1, then Key2
; ###############################################################################################################

; Shortcut to activate Option key special character scheme
} ; V1toV2: Added Bracket before hotkey or Hotstring
^+!o::toggle_optspecialchars()

; Function (subroutine?) for activation by tray menu item or keyboard shortcut
toggle_optspecialchars(A_ThisMenuItem := "", A_ThisMenuItemPos := "", MyMenu := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
    optspecialchars:=!optspecialchars         ; Toggle value of optspecialchars variable on/off
    if (optspecialchars = 1) {
        Tray.Check("OptSpecialChars      Shift+Opt+Cmd+O")
        MsgBox("Option key special character entry scheme is now ENABLED.`n`n"
                            . "WARNING: This will interfere with many Alt and Alt-Shift shortcuts.`n`n"
                            . "Disable from tray menu or with Shift+Opt+Cmd+O.", "ALERT", 0)
        return
    }
    if (optspecialchars = 0) {
        Tray.Uncheck("OptSpecialChars      Shift+Opt+Cmd+O")
        MsgBox("Option key special character entry scheme is now DISABLED.", "ALERT", 0)
        return
    }
    return

#HotIf !WinActive("ahk_group remotes") && optspecialchars = 1

    ; ######   NUMBER KEYS ROW   ######

    ; Dead_Keys_Accent_Grave
    ; ###   SC029 is ` (Grave key above Tab)
    ; Grave accent: Option+`, then key to accent
    $!SC029::
        ; Use Apple "dead keys" Option key method to attach accents to next character typed
        ; Grave accent activated by Option+` (Alt plus scan code SC029, or !SC029)
        Send("{U+0060}{Shift down}{Left}{Shift up}")
        A_StringCaseSense := true
        ; watch next input string
        ihUserInput := InputHook("L1","{BS}{Del}{Left}{Right}{Up}{Down}{LAlt}{RAlt}{LCtrl}{RCtrl}"), ihUserInput.Start(), ErrorLevel := ihUserInput.Wait(), UserInput := ihUserInput.Input
        ; MsgBox % GetKeyName(UserInput)              ; Debugging: Show normalized key name
        ; MsgBox % ErrorLevel                         ; Debugging: Show ErrorLevel value
        name := GetKeyName(UserInput)               ; Get normalized name of UserInput
        e := SubStr(ErrorLevel, 8)                  ; Get normalized name of EndKey
Switch {
            Default:             Send("{Right}" UserInput)    ; No match? Leave accent char and send input.
            Case name = "Escape":             Send("{Right}")               ; Escape: Leave accent character, exit dead key
            Case name = "Space":             Send("{Right}")               ; Space: Leave accent character, exit dead key
            Case e = "Up":             Send("{Right}{Up}")           ; Up: Leave accent character, exit dead key, move
            Case e = "Down":             Send("{Right}{Down}")         ; Down: Leave accent character, exit dead key, move
            Case e = "Left":             Send("{Right}{Left}")         ; Left: Leave accent character, exit dead key, move
            Case e = "Right":             Send("{Right}{Right}")        ; Right: Leave accent character, exit dead key, move
            Case e = "Backspace":             Send("{Right}{BS}")           ; Backspace: Delete accent character
            Case UserInput == "a":             Send("{U+00E0}")              ; Ã  {U+00E0} (Alt+0224)
            Case UserInput == "e":             Send("{U+00E8}")              ; Ã¨ {U+00E8} (Alt+0232)
            Case UserInput == "i":             Send("{U+00EC}")              ; Ã¬ {U+00EC} (Alt+0236)
            Case UserInput == "o":             Send("{U+00F2}")              ; Ã² {U+00F2} (Alt+0242)
            Case UserInput == "u":             Send("{U+00F9}")              ; Ã¹ {U+00F9} (Alt+0249)
            Case UserInput == "A":             Send("{U+00C0}")              ; Ã€ {U+00C0} (Alt+0192)
            Case UserInput == "E":             Send("{U+00C8}")              ; Ãˆ {U+00C8} (Alt+0200)
            Case UserInput == "I":             Send("{U+00CC}")              ; ÃŒ {U+00CC} (Alt+0204)
            Case UserInput == "O":             Send("{U+00D2}")              ; Ã’ {U+00D2} (Alt+0210)
            Case UserInput == "U":             Send("{U+00D9}")              ; Ã™ {U+00D9} (Alt+0217)
        }
        Return

    ; ###   SC029 is ` (Grave key above Tab)
    $!+SC029::    Send("{U+0060}") ; Grave Accent diacritic (non-combining) {U+0060}: ` (Alt+96)
} ; V1toV2: Added Bracket before hotkey or Hotstring
    $!1::    Send("{U+00A1}") ; Inverted Exclamation Mark {U+00A1}: Â¡ (Alt+0161)
    $!+1::    Send("{U+2044}") ; Fraction Slash, solidus {U+2044}: â„ (Alt+8260) [Needs Unicode]
    $!2::    Send("{U+2122}") ; Trade Mark Sign Emoji {U+2122}: â„¢ (Alt+0153)
    $!+2::    Send("{U+20AC}") ; Euro currency symbol {U+20AC}: â‚¬ (Alt+0128)
    $!3::    Send("{U+00A3}") ; British Pound currency symbol {U+00A3}: Â£ (Alt+0163)
    $!+3::    Send("{U+2039}") ; Single Left-Pointing Angle Quotation mark {U+2039}: â€¹ (Alt+0139)
    $!4::    Send("{U+00A2}") ; Cent currency symbol {U+00A2}: Â¢ (Alt+0162)
    $!+4::    Send("{U+203A}") ; Single Right-Pointing Angle Quotation mark {U+203A}: â€º (Alt+0155)
    $!5::    Send("{U+221E}") ; Infinity mathematical symbol {U+221E}: âˆž (Alt+236)
    $!+5::    Send("{U+FB01}") ; fi Latin small ligature {U+FB01}: ï¬ (Alt+64257) [Needs Unicode]
    $!6::    Send("{U+00A7}") ; Section symbol {U+00A7}: Â§ (Alt+0167)
    $!+6::    Send("{U+FB02}") ; fl Latin small ligature {U+FB02}: ï¬‚ (Alt+64258) [Needs Unicode]
    $!7::    Send("{U+00B6}") ; Paragraph mark (Pilcrow) symbol {U+00B6}: Â¶ (Alt+0182)
    $!+7::    Send("{U+2021}") ; Double dagger (cross) symbol {U+2021}: â€¡ (Alt+0135)
    $!8::    Send("{U+2022}") ; Bullet point symbol {U+2022}: â€¢ (Alt+0149) 
    $!+8::    Send("{U+00B0}") ; Degree symbol {U+00B0}: Â° (Alt+0176)
    $!9::    Send("{U+00AA}") ; Feminine Ordinal Indicator symbol {U+00AA}: Âª (Alt+0170)
    $!+9::    Send("{U+00B7}") ; Middle Dot (interpunct/middot) symbol {U+00B7}: Â· (Alt+0183) 
    $!0::    Send("{U+00BA}") ; Masculine Ordinal Indicator symbol {U+00BA}: Âº (Alt+0186)
    $!+0::    Send("{U+201A}") ; Single low-9 quotation mark {U+201A}: â€š (Alt+0130) 
    $!-::    Send("{U+2013}") ; En Dash symbol {U+2013}: â€“ (Alt+0150)
    $!+-::    Send("{U+2014}") ; Em Dash symbol {U+2014}: â€” (Alt+0151)
    $!=::    Send("{U+2260}") ; Not Equal To symbol {U+2260}: â‰  (Alt+8800) [Needs Unicode]
    $!+=::    Send("{U+00B1}") ; Plus Minus symbol {U+00B1}: Â± (Alt+0177)


    ; ######   LETTER AND PUNCTUATION KEYS   ###### [ in QWERTY order ]

    ; ##############
    ; ###   1st row: Tab-key row [ qwertyuiop[]\ ] [ QWERTYUIOP{}| ]

    $!q::    Send("{U+0153}") ; Small oe (oethel) ligature {U+0153}: Å“ (Alt+0156)
    $!+q::    Send("{U+0152}") ; Capital OE (Oethel) ligature {U+0152}: Å’ (Alt+0140)
    $!w::    Send("{U+2211}") ; N-Ary Summation (sigma) notation {U+2211}: âˆ‘ [Needs Unicode]
    $!+w::    Send("{U+201E}") ; Double Low-9 Quotation mark {U+201E}: â€ž (Alt+0132)

    ; Dead_Keys_Accent_Acute
    ; Acute accent: Option+e, then key to accent
    $!e::
        ; Use Apple "dead keys" Option key method to attach accents to next character typed
        ; Acute accent activated by Option+e (logical Alt+e)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
        Send("{U+00B4}{Shift down}{Left}{Shift up}")
        A_StringCaseSense := true
        ; watch next input string
        ihUserInput := InputHook("L1","{BS}{Del}{Left}{Right}{Up}{Down}{LAlt}{RAlt}{LCtrl}{RCtrl}"), ihUserInput.Start(), ErrorLevel := ihUserInput.Wait(), UserInput := ihUserInput.Input
        ; MsgBox % GetKeyName(UserInput)              ; Debugging: Show normalized key name
        ; MsgBox % ErrorLevel                         ; Debugging: Show ErrorLevel value
        name := GetKeyName(UserInput)               ; Get normalized name of UserInput
        e := SubStr(ErrorLevel, 8)                  ; Get normalized name of EndKey
Switch {
            Default:             Send("{Right}" UserInput)    ; No match? Leave accent char and send input.
            Case name = "Escape":             Send("{Right}")               ; Escape: Leave accent character, exit dead key
            Case name = "Space":             Send("{Right}")               ; Space: Leave accent character, exit dead key
            Case e = "Up":             Send("{Right}{Up}")           ; Up: Leave accent character, exit dead key, move
            Case e = "Down":             Send("{Right}{Down}")         ; Down: Leave accent character, exit dead key, move
            Case e = "Left":             Send("{Right}{Left}")         ; Left: Leave accent character, exit dead key, move
            Case e = "Right":             Send("{Right}{Right}")        ; Right: Leave accent character, exit dead key, move
            Case e = "Backspace":             Send("{Right}{BS}")           ; Backspace: Delete accent character
            Case UserInput == "a":             Send("{U+00E1}")              ; Ã¡ {U+00E1} (Alt+0225)
            Case UserInput == "e":             Send("{U+00E9}")              ; Ã© {U+00E9} (Alt+0233)
            Case UserInput == "i":             Send("{U+00ED}")              ; Ã­ {U+00ED} (Alt+0237)
            Case UserInput == "o":             Send("{U+00F3}")              ; Ã³ {U+00F3} (Alt+0243)
            Case UserInput == "u":             Send("{U+00FA}")              ; Ãº {U+00FA} (Alt+0250)
            Case UserInput == "A":             Send("{U+00C1}")              ; Ã {U+00C1} (Alt+0193)
            Case UserInput == "E":             Send("{U+00C9}")              ; Ã‰ {U+00C9} (Alt+0201)
            Case UserInput == "I":             Send("{U+00CD}")              ; Ã {U+00CD} (Alt+0205)
            Case UserInput == "O":             Send("{U+00D3}")              ; Ã“ {U+00D3} (Alt+0211)
            Case UserInput == "U":             Send("{U+00DA}")              ; Ãš {U+00DA} (Alt+0218)
        }
        Return
} ; V1toV2: Added Bracket before hotkey or Hotstring

    $!+e::    Send("{U+00B4}") ; Acute accent diacritic (non-combining) {U+00B4}: Â´ (Alt+0180)
    $!r::    Send("{U+00AE}") ; Registered Trade Mark Sign {U+00AE}: Â® (Alt+0174)
    $!+r::    Send("{U+2030}") ; Per mille symbol {U+2030}: â€° (Alt+0137)
    $!t::    Send("{U+2020}") ; Simple dagger (cross) symbol {U+2020}: â€  (Alt+0134)
    $!+t::    Send("{U+02C7}") ; Caron/hacek diacritic (non-combining) {U+02C7}: Ë‡ (Alt+0134)
    $!y::    Send("{U+00A5}") ; Yen currency symbol {U+00A5}: Â¥ (Alt+0165)
    $!+y::    Send("{U+00C1}") ; Latin Capital Letter a with Acute {U+00C1}: Ã (Alt+0193)

    ; Dead_Keys_Accent_Umlaut
    ; Umlaut/Diaeresis accent: Option+u, then key to accent
    $!u::
        ; Use Apple "dead keys" Option key method to attach accents to next character typed
        ; Umlaut/Diaeresis accent activated by Option+u (logical Alt+u)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
        Send("{U+00A8}{Shift down}{Left}{Shift up}")
        A_StringCaseSense := true
        ; watch next input string
        ihUserInput := InputHook("L1","{BS}{Del}{Left}{Right}{Up}{Down}{LAlt}{RAlt}{LCtrl}{RCtrl}"), ihUserInput.Start(), ErrorLevel := ihUserInput.Wait(), UserInput := ihUserInput.Input
        ; MsgBox % GetKeyName(UserInput)              ; Debugging: Show normalized key name
        ; MsgBox % ErrorLevel                         ; Debugging: Show ErrorLevel value
        name := GetKeyName(UserInput)               ; Get normalized name of UserInput
        e := SubStr(ErrorLevel, 8)                  ; Get normalized name of EndKey
Switch {
            Default:             Send("{Right}" UserInput)    ; No match? Leave accent char and send input.
            Case name = "Escape":             Send("{Right}")               ; Escape: Leave accent character, exit dead key
            Case name = "Space":             Send("{Right}")               ; Space: Leave accent character, exit dead key
            Case e = "Up":             Send("{Right}{Up}")           ; Up: Leave accent character, exit dead key, move
            Case e = "Down":             Send("{Right}{Down}")         ; Down: Leave accent character, exit dead key, move
            Case e = "Left":             Send("{Right}{Left}")         ; Left: Leave accent character, exit dead key, move
            Case e = "Right":             Send("{Right}{Right}")        ; Right: Leave accent character, exit dead key, move
            Case e = "Backspace":             Send("{Right}{BS}")           ; Backspace: Delete accent character
            Case UserInput == "a":             Send("{U+00E4}")              ; Ã¤ {U+00E4} (Alt+0228)
            Case UserInput == "e":             Send("{U+00EB}")              ; Ã« {U+00EB} (Alt+0235)
            Case UserInput == "i":             Send("{U+00EF}")              ; Ã¯ {U+00EF} (Alt+0239)
            Case UserInput == "o":             Send("{U+00F6}")              ; Ã¶ {U+00F6} (Alt+0246)
            Case UserInput == "u":             Send("{U+00FC}")              ; Ã¼ {U+00FC} (Alt+0252)
            Case UserInput == "y":             Send("{U+00FF}")              ; Ã¿ {U+00FF} (Alt+0255)
            Case UserInput == "A":             Send("{U+00C4}")              ; Ã„ {U+00C4} (Alt+0196)
            Case UserInput == "E":             Send("{U+00CB}")              ; Ã‹ {U+00CB} (Alt+0203)
            Case UserInput == "I":             Send("{U+00CF}")              ; Ã {U+00CF} (Alt+0207)
            Case UserInput == "O":             Send("{U+00D6}")              ; Ã– {U+00D6} (Alt+0214)
            Case UserInput == "U":             Send("{U+00DC}")              ; Ãœ {U+00DC} (Alt+0220)
            Case UserInput == "Y":             Send("{U+0178}")              ; Å¸ {U+0178} (Alt+0159)
        }
        Return
} ; V1toV2: Added Bracket before hotkey or Hotstring

    $!+u::    Send("{U+00A8}") ; Umlaut/Diaeresis diacritic (non-combining) {U+00A8}: Â¨ (Alt+0168)

    ; Dead_Keys_Accent_Circumflex
    ; Circumflex accent: Option+i, then key to accent
    $!i::
        ; Use Apple "dead keys" Option key method to attach accents to next character typed
        ; Circumflex accent activated by Option+i (logical Alt+i)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
        Send("{U+02C6}{Shift down}{Left}{Shift up}")
        A_StringCaseSense := true
        ; watch next input string
        ihUserInput := InputHook("L1","{BS}{Del}{Left}{Right}{Up}{Down}{LAlt}{RAlt}{LCtrl}{RCtrl}"), ihUserInput.Start(), ErrorLevel := ihUserInput.Wait(), UserInput := ihUserInput.Input
        ; MsgBox % GetKeyName(UserInput)              ; Debugging: Show normalized key name
        ; MsgBox % ErrorLevel                         ; Debugging: Show ErrorLevel value
        name := GetKeyName(UserInput)               ; Get normalized name of UserInput
        e := SubStr(ErrorLevel, 8)                  ; Get normalized name of EndKey
Switch {
            Default:             Send("{Right}" UserInput)    ; No match? Leave accent char and send input.
            Case name = "Escape":             Send("{Right}")               ; Escape: Leave accent character, exit dead key
            Case name = "Space":             Send("{Right}")               ; Space: Leave accent character, exit dead key
            Case e = "Up":             Send("{Right}{Up}")           ; Up: Leave accent character, exit dead key, move
            Case e = "Down":             Send("{Right}{Down}")         ; Down: Leave accent character, exit dead key, move
            Case e = "Left":             Send("{Right}{Left}")         ; Left: Leave accent character, exit dead key, move
            Case e = "Right":             Send("{Right}{Right}")        ; Right: Leave accent character, exit dead key, move
            Case e = "Backspace":             Send("{Right}{BS}")           ; Backspace: Delete accent character
            Case UserInput == "a":             Send("{U+00E2}")              ; Ã¢ {U+00E2} (Alt+0226)
            Case UserInput == "e":             Send("{U+00EA}")              ; Ãª {U+00EA} (Alt+0234)
            Case UserInput == "i":             Send("{U+00EE}")              ; Ã® {U+00EE} (Alt+0238)
            Case UserInput == "o":             Send("{U+00F4}")              ; Ã´ {U+00F4} (Alt+0244)
            Case UserInput == "u":             Send("{U+00FB}")              ; Ã» {U+00FB} (Alt+0251)
            Case UserInput == "A":             Send("{U+00C2}")              ; Ã‚ {U+00C2} (Alt+0194)
            Case UserInput == "E":             Send("{U+00CA}")              ; ÃŠ {U+00CA} (Alt+0202)
            Case UserInput == "I":             Send("{U+00CE}")              ; ÃŽ {U+00CE} (Alt+0206)
            Case UserInput == "O":             Send("{U+00D4}")              ; Ã” {U+00D4} (Alt+0212)
            Case UserInput == "U":             Send("{U+00DB}")              ; Ã› {U+00DB} (Alt+0219)
        }
        Return
} ; V1toV2: Added Bracket before hotkey or Hotstring

    $!+i::    Send("{U+02C6}") ; Modifier Letter Circumflex Accent {U+02C6}: Ë† (Alt+0137)
    $!o::    Send("{U+00F8}") ; Latin Small Letter o with Stroke {U+00F8}: Ã¸ (Alt+0248)
    $!+o::    Send("{U+00D8}") ; Latin Capital Letter O with Stroke {U+00D8}: Ã˜ (Alt+0216)
    $!p::    Send("{U+03C0}") ; Greek Small Letter Pi {U+03C0}: Ï€ (Alt+227)
    $!+p::    Send("{U+220F}") ; N-Ary Product mathematical symbol {U+220F}: âˆ [Needs Unicode]
    $![::    Send("{U+201C}") ; Left Double Quotation Mark {U+201C}: â€œ (Alt+0147)
    $!+[::    Send("{U+201D}") ; Right Double Quotation Mark {U+201D}: â€ (Alt+8)
    $!]::    Send("{U+2018}") ; Left Single Quotation Mark {U+2018}: â€˜ (Alt+0145)
    $+!]::    Send("{U+2019}") ; Right Single Quotation Mark {U+2019}: â€™ (Alt+0146)
    $!\::    Send("{U+00AB}") ; LEFT-POINTING DOUBLE ANGLE QUOTATION MARK {U+00AB}: Â« (Alt+0171)
    $!+\::    Send("{U+00BB}") ; RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK {U+00BB}: Â» (Alt+0187)


    ; ##############
    ; ###   2nd row: Caps Lock row [ asdfghjkl;' ] [ ASDFGHJKL:" ]

    $!a::    Send("{U+00E5}") ; Small Letter a with Ring Above {U+00E5}: Ã¥ (Alt+0229)
    $!+a::    Send("{U+00C5}") ; Capital Letter A with Ring Above {U+00C5}: Ã… (Alt+0197)
    $!s::    Send("{U+00DF}") ; German Eszett/beta (Sharfes/Sharp S) {U+00DF}: ÃŸ (Alt+0223)
    $!+s::    Send("{U+00CD}") ; Latin Capital Letter I with Acute {U+00CD}: Ã (Alt+0205)
    $!d::    Send("{U+2202}") ; Partial Differential mathematical symbol {U+2202}: âˆ‚ (Alt+2202) [Needs Unicode]
    $!+d::    Send("{U+00CE}") ; Latin Capital Letter I with Circumflex {U+00CE}: ÃŽ (Alt+0206)
    $!f::    Send("{U+0192}") ; Function/florin currency symbol {U+0192}: Æ’ (Alt+159)
    $!+f::    Send("{U+00CF}") ; Latin Capital Letter I with Diaeresis {U+00CF}: Ã (Alt+0207)

    ; #######################################################################
    ; ##  Problem: Option+g (Win+g) brings up Windows XBox Game Bar! 
    ; ##  To remove/disable paste this text in PowerShell (without quotes): 
    ; ##  "Get-AppxPackage Microsoft.XboxGamingOverlay | Remove-AppxPackage"
    ; #######################################################################
    $!g::    Send("{U+00A9}") ; Copyright Sign {U+00A9}: Â© (Alt+0169)
    $!+g::    Send("{U+02DD}") ; Double Acute Accent diacritic (non-combining) {U+02DD}: Ë [Needs Unicode]
    $!h::    Send("{U+02D9}") ; Dot Above diacritic (non-combining) {U+02D9}: Ë™ [Needs Unicode]
    $!+h::    Send("{U+00D3}") ; Latin Capital Letter O with Acute {U+00D3}: Ã“ (Alt+0211)
    $!j::    Send("{U+2206}") ; Increment, laplace operator symbol {U+2206}: âˆ† [Needs Unicode]
    $!+j::    Send("{U+00D4}") ; Latin Capital Letter O with Circumflex {U+00D4}: Ã” (Alt+0212)
    $!k::    Send("{U+02DA}") ; Ring Above diacritic (non-combining) {U+02DA}: Ëš [Needs Unicode]

    ; Apple logo {U+F8FF}: ï£¿ [Unicode Private Use Area, req's Baskerville Old Face font]
    ; $!+k::Send, {U+F8FF}    ; This Unicode address only works with Mac fonts
    $!+k::
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
        Send("{U+F000}")    ; Change font of inserted character (may be invisible) to Baskerville Old Face
        apple_logo_alert:=1     ; Set to zero to disable, one to enable (default is enabled)
        if (apple_logo_alert=1) {
            MsgBox("ALERT: Change the font of the inserted character!`n`n"
                                . "Apple logo character requires the Baskerville Old Face font.`n`n`n"
                                . "Note 1: The character has been inserted but may be INVISIBLE`n"
                                . "             (i.e., non-printing) in its current font.`n`n`n"
                                . "Note 2: The inserted character will probably NOT be portable`n"
                                . "             to a Mac document/font. Use only for print/PDF `n"
                                . "             purposes on PC.`n`n`n"
                                . "Note 3: Search for apple_logo_alert in kinto.ahk config and `n"
                                . "             set it to zero to disable this MsgBox.`n`n`n", "ALERT", 0)
        }
        return

    ; #######################################################################
    ; ##  Option+L works, but will also trigger the Win+L screen locking.
    ; ##  The screen locking shortcut can only be disabled in the registry. 
    ; #######################################################################
} ; V1toV2: Added Bracket before hotkey or Hotstring
    $!l::    Send("{U+00AC}") ; Not Sign angled dash symbol {U+00AC}: Â¬ (Alt+170)
    $!+l::    Send("{U+00D2}") ; Latin Capital Letter O with Grave {U+00D2}: Ã’ (Alt+0210)
    $!;::    Send("{U+2026}") ; Horizontal elipsis {U+2026}: â€¦ (Alt+0133)
    $!+;::    Send("{U+00DA}") ; Latin Capital Letter U with Acute {U+00DA}: Ãš (Alt+0218)

    ; #######################################################################
    ; ##  SC028 is single-quote key scan code
    ; #######################################################################
    $!SC028::    Send("{U+00E6}") ; Small ae ligature {U+00E6}: Ã¦ (Alt+0230)
    $!+SC028::    Send("{U+00C6}") ; Capital AE ligature {U+00C6}: Ã† (Alt+0198)


    ; ##############
    ; ###   3rd row: Shift-Keys row [ zxcvbnm,./ ] [ ZXCVBNM<>? ]

    $!z::    Send("{U+03A9}") ; Greek Capital Letter Omega symbol {U+03A9} Î© (Alt+234)
    $!+z::    Send("{U+00B8}") ; Spacing Cedilla diacritic symbol (non-combining) {U+00B8}: Â¸ (Alt+0184)
    $!x::    Send("{U+2248}") ; Almost Equal To symbol {U+2248}: â‰ˆ (Alt+247)
    $!+x::    Send("{U+02DB}") ; Ogonek diacritic (non-combining) {U+02DB}: Ë› [Needs Unicode]
    $!c::    Send("{U+00E7}") ; Small Letter c with Cedilla {U+00E7}: Ã§ (Alt+0231)
    $!+c::    Send("{U+00C7}") ; Capital Letter C with Cedilla {U+00C7}: Ã‡ (Alt+0199)
    $!v::    Send("{U+221A}") ; Square Root radical sign {U+221A}: âˆš (Alt+251)
    $!+v::    Send("{U+25CA}") ; Lozenge (diamond) shape symbol {U+25CA}: â—Š [Needs Unicode]
    $!b::    Send("{U+222B}") ; Integral mathematical symbol {U+222B}: âˆ« [Needs Unicode]
    $!+b::    Send("{U+0131}") ; Latin Small Letter Dotless i {U+0131}: Ä± [Needs Unicode]

    ; Dead_Keys_Accent_Tilde
    ; Tilde accent: Option+n, then key to accent
    $!n::
        ; Use Apple "dead keys" Option key method to attach accents to next character typed
        ; Tilde accent activated by Option+n (logical Alt+n)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
        Send("{U+02DC}{Shift down}{Left}{Shift up}")
        A_StringCaseSense := true
        ; watch next input string
        ihUserInput := InputHook("L1","{BS}{Del}{Left}{Right}{Up}{Down}{LAlt}{RAlt}{LCtrl}{RCtrl}"), ihUserInput.Start(), ErrorLevel := ihUserInput.Wait(), UserInput := ihUserInput.Input
        ; MsgBox % GetKeyName(UserInput)              ; Debugging: Show normalized key name
        ; MsgBox % ErrorLevel                         ; Debugging: Show ErrorLevel value
        name := GetKeyName(UserInput)               ; Get normalized name of UserInput
        e := SubStr(ErrorLevel, 8)                  ; Get normalized name of EndKey
Switch {
            Default:             Send("{Right}" UserInput)    ; No match? Leave accent char and send input.
            Case name = "Escape":             Send("{Right}")               ; Escape: Leave accent character, exit dead key
            Case name = "Space":             Send("{Right}")               ; Space: Leave accent character, exit dead key
            Case e = "Up":             Send("{Right}{Up}")           ; Up: Leave accent character, exit dead key, move
            Case e = "Down":             Send("{Right}{Down}")         ; Down: Leave accent character, exit dead key, move
            Case e = "Left":             Send("{Right}{Left}")         ; Left: Leave accent character, exit dead key, move
            Case e = "Right":             Send("{Right}{Right}")        ; Right: Leave accent character, exit dead key, move
            Case e = "Backspace":             Send("{Right}{BS}")           ; Backspace: Delete accent character
            Case UserInput == "n":             Send("{U+00F1}")              ; Ã± {U+00F1} (Alt+0241)
            Case UserInput == "a":             Send("{U+00E3}")              ; Ã£ {U+00E3} (Alt+0227)
            Case UserInput == "o":             Send("{U+00F5}")              ; Ãµ {U+00F5} (Alt+0245)
            Case UserInput == "A":             Send("{U+00C3}")              ; Ãƒ {U+00C3} (Alt+0195)
            Case UserInput == "N":             Send("{U+00D1}")              ; Ã‘ {U+00D1} (Alt+0209)
            Case UserInput == "O":             Send("{U+00D5}")              ; Ã• {U+00D5} (Alt+0213)
        }
        Return
} ; V1toV2: Added Bracket before hotkey or Hotstring

    $!+n::    Send("{U+02DC}") ; Small Tilde character {U+02DC}: Ëœ (Alt+0152)
    $!m::    Send("{U+00B5}") ; Micro (mu) symbol {U+00B5}: Âµ (Alt+0181)
    $!+m::    Send("{U+00C2}") ; Latin Capital Letter a with Circumflex {U+00C2}: Ã‚ (Alt+0194)
    $!,::    Send("{U+2264}") ; Less than or equal to symbol {U+2264}: â‰¤ (Alt+243)
    $!+,::    Send("{U+00AF}") ; Macron/overline/apl overbar (non-combining) {U+00AF}: Â¯ (Alt+0175)
    $!.::    Send("{U+2265}") ; Greater than or equal to symbol {U+2265}: â‰¥ (Alt+242)
    $!+.::    Send("{U+02D8}") ; Breve diacritic (non-combining) {U+02D8}: Ë˜ [Needs Unicode]
    $!/::    Send("{U+00F7}") ; Obelus/Division symbol {U+00F7}: Ã· (Alt+0247)
    $!+/::    Send("{U+00BF}") ; Inverted Question Mark {U+00BF}: Â¿ (Alt+0191)

#HotIf ; ### END of special character insertion with Option(Alt) key

; ##########################################################################################
; ###   MAC NUMPAD FEATURE
; ###   Make the numpad always act like a numpad, even when numlock is OFF
; ###   Numlock becomes "Clear" key for use with calculator apps (sends Escape)
; ###   
; ###   To enable this feature by default: 
; ###   Search for "ENABLE Mac Numpad feature" and set the variable to 1
; ##########################################################################################

; Shortcut to activate media arrow keys fix
; ^+!n::Gosub, toggle_mac_numpad
$!NumLock::toggle_mac_numpad()

; Function (subroutine?) for activation by tray menu item or keyboard shortcut
toggle_mac_numpad(A_ThisMenuItem := "", A_ThisMenuItemPos := "", MyMenu := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
    mac_numpad:=!mac_numpad         ; Toggle value of media_arrows_fix variable on/off
    if (mac_numpad = 1) {
        Tray.Check("Mac Numpad           Option+NumLock")
        MsgBox("Mac Numpad feature is now ENABLED.`n`n"
                            . "Disable from tray menu or with Option+NumLock.", "ALERT", 0)
        return
    }
    if (mac_numpad = 0) {
        Tray.Uncheck("Mac Numpad           Option+NumLock")
        MsgBox("Mac Numpad feature is now DISABLED.`n`n"
                            . "Re-enable from tray menu or with Option+NumLock.", "ALERT", 0)
        return
    }

#HotIf !WinActive("ahk_group remotes") && mac_numpad = 1
    ; Make numpad act like a real Mac (always a numpad, Numlock is "Clear")
    $NumLock::    Send("{Esc}")
#HotIf ; Technically unnecessary closing #If, but nullifies previous #If directive

; ##########################################################################################
; ###   MEDIA ARROWS FIX
; ###   Fix to make laptops with media functions on arrow keys act like Apple laptops
; ###   To set this to ENABLED by default, search for "Enable Media Arrows Fix by default"
; ##########################################################################################

; Shortcut to activate media arrow keys fix
} ; V1toV2: Added Bracket before hotkey or Hotstring
^+!m::toggle_media_arrows_fix()

; Function for activation of media arrows fix by tray menu item or keyboard shortcut
toggle_media_arrows_fix(A_ThisMenuItem := "", A_ThisMenuItemPos := "", MyMenu := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
    media_arrows_fix:=!media_arrows_fix         ; Toggle value of optspecialchars variable on/off
    if (media_arrows_fix = 1) {
        Tray.Check("Media Arrows Fix   Shift+Opt+Cmd+M")
        MsgBox("Media Arrows Fix is now ENABLED.`n`n"
                            . "When used with the Fn key, arrow keys with `n"
                            . "media functions will now behave as if they are`n"
                            . "PgUp/PgDn/Home/End navigation keys.`n`n"
                            . "To ENABLE by default, search in kinto.ahk for`n"
                            . "   'Enable Media Arrows Fix by default'`n`n"
                            . "Disable from tray menu or with Shift+Opt+Cmd+M.", "ALERT", 0)
        return
    }
    if (media_arrows_fix = 0) {
        Tray.Uncheck("Media Arrows Fix   Shift+Opt+Cmd+M")
        MsgBox("Media arrow keys fix is now DISABLED.", "ALERT", 0)
        return
    }

#HotIf !WinActive("ahk_group remotes") && media_arrows_fix = 1
    ; Fix for media functions on laptop arrow keys
    $Media_Play_Pause::PgUp
    $Media_Stop::PgDn
    $Media_Prev::Home
    $Media_Next::End
#HotIf
} ; V1toV2: Added bracket in the end
