; Remap Caps Lock to Escape and Escape to Caps Lock

; Make the physical Caps Lock key send an Escape keystroke.
; This overrides its default toggling behavior.
CapsLock::Send {Esc}

; Make the physical Escape key toggle the actual Caps Lock state (On/Off).
; This overrides Escape's default behavior.
Esc::SetCapsLockState, Toggle

Return
