//
//  AppTerminalView+PublicInput.swift
//  libghostty-spm
//
//  Public wrappers around `TerminalSurface` write paths so hosts can
//  inject bytes into the pty without reaching for internal API.
//

#if canImport(AppKit) && !canImport(UIKit)
    import AppKit
    import GhosttyKit

    extension AppTerminalView {
        /// Send raw UTF-8 text directly to the underlying pty (bypassing
        /// key translation). Use this for synthetic input like `\x1b[Z`
        /// (Shift+Tab / CSI Z) or multi-line paste-style injections.
        /// No-op when the surface has not been created yet.
        public func sendText(_ text: String) {
            surface?.sendText(text)
        }

        /// Send a synthesized Escape key press, as if the physical key were hit.
        ///
        /// `sendText` cannot carry this one: it is the text/IME commit path
        /// (see `TerminalTextInputHandler.insertText`) and re-encodes what it is
        /// given as key events, so a raw 0x1B leaves the pty as a *space*. A key
        /// event goes the same way a real Escape press does, so the session
        /// receives whatever its negotiated keyboard protocol expects — 0x1B
        /// normally, or the kitty-protocol form when the program asked for it.
        ///
        /// No-op when the surface has not been created yet.
        public func sendEscapeKey() {
            guard let surface else { return }
            for action in [GHOSTTY_ACTION_PRESS, GHOSTTY_ACTION_RELEASE] {
                var input = ghostty_input_key_s()
                input.action = action
                input.mods = GHOSTTY_MODS_NONE
                input.consumed_mods = GHOSTTY_MODS_NONE
                input.keycode = 0x35 // macOS virtual keycode for Escape
                input.text = nil
                input.unshifted_codepoint = 0x1B
                input.composing = false
                surface.sendKeyEvent(input)
            }
        }

        /// Invoke a named Ghostty binding action (e.g. "copy_to_clipboard",
        /// "clear_screen"). Returns true when the action dispatched.
        @discardableResult
        public func performBindingAction(_ action: String) -> Bool {
            surface?.performBindingAction(action) ?? false
        }

        /// Jump the viewport by a number of shell prompts.
        ///
        /// Negative offsets move toward older prompts and positive offsets move
        /// toward newer prompts. Prompt navigation requires shell integration.
        @discardableResult
        public func jumpToPrompt(by offset: Int16) -> Bool {
            surface?.jumpToPrompt(by: offset) ?? false
        }

        /// Reveal an absolute scrollback row, where zero is the first row.
        @discardableResult
        public func scrollToRow(_ row: UInt) -> Bool {
            surface?.scrollToRow(row) ?? false
        }
    }
#endif
