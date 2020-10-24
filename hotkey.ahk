vdsk_created := false
vdsk_current := 0

Tab::
    KeyWait, Tab
    KeyWait, Tab, D T.2
    if (ErrorLevel) {
        return
    }

    if (vdsk_created = false) {
        Send, {LControl Down}{Lwin Down}d{LControl Up}{Lwin Up}
        vdsk_created := true
        vdsk_current := 1
    } else if (vdsk_created = true and vdsk_current = 0) {
        Send, {LControl Down}{LWin Down}{Right}{LControl Up}{LWin Up}
        vdsk_current := 1
    } else if (vdsk_created = true and vdsk_current = 1) {
        Send, {LControl Down}{LWin Down}{Left}{LControl Up}{LWin Up}
        vdsk_current := 0
    } else {
        return
    }

return
