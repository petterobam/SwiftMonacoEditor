// Copyright 2020 Naked Software, LLC
//
// This program is confidential and proprietary to Naked Software, LLC,
// and may not be reproduced, published, or disclosed to others without
// company authorization.

public indirect enum MonacoEditorKeyBinding {
    case key(MonacoEditorKeyCode)
    case alt(MonacoEditorKeyCode)
    case ctrl(MonacoEditorKeyCode)
    case cmd(MonacoEditorKeyCode)
    case shift(MonacoEditorKeyCode)
    case ctrlCmd(MonacoEditorKeyCode)
    case ctrlShift(MonacoEditorKeyCode)
    case cmdShift(MonacoEditorKeyCode)
    case ctrlCmdShift(MonacoEditorKeyCode)
    case chord(MonacoEditorKeyBinding, MonacoEditorKeyBinding)
    
    var keybinding: String {
        switch self {
        case .key(let value):
            return "monaco.KeyCode.\(value.rawValue)"
            
        case .alt(let value):
            return "monaco.KeyMod.Alt | monaco.KeyCode.\(value.rawValue)"
            
        case .cmd(let value):
            return "monaco.KeyMod.CtrlCmd | monaco.KeyCode.\(value.rawValue)"
            
        case .shift(let value):
            return "monaco.KeyMod.Shift | monaco.KeyCode.\(value.rawValue)"
            
        case .ctrl(let value):
            return "monaco.KeyMod.WinCtrl | monaco.KeyCode.\(value.rawValue)"
            
        case .ctrlCmd(let value):
            return "monaco.KeyMod.CtrlCmd | monaco.KeyMod.WinCtrl | monaco.KeyCode.\(value.rawValue)"
            
        case .ctrlShift(let value):
            return "monaco.KeyMod.WinCtrl | monaco.KeyMod.Shift | monaco.KeyCode.\(value.rawValue)"
            
        case .cmdShift(let value):
            return "monaco.KeyMod.CtrlCmd | monaco.KeyMod.Shift | monaco.KeyCode.\(value.rawValue)"
            
        case .ctrlCmdShift(let value):
            return "monaco.KeyMod.CtrlCmd | monaco.KeyMod.WinCtrl | monaco.KeyMod.Shift | monaco.KeyCode.\(value.rawValue)"
            
        case .chord(let first, let second):
            return "monaco.KeyMod.chord(\(first.keybinding), \(second.keybinding))"
        }
    }
}
