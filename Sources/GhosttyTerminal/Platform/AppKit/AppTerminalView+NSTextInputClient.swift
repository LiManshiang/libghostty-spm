//
//  AppTerminalView+NSTextInputClient.swift
//  libghostty-spm
//
//  Created by Lakr233 on 2026/3/17.
//

#if canImport(AppKit) && !canImport(UIKit)
    import AppKit

    extension AppTerminalView: @preconcurrency NSTextInputClient {
        open func insertText(_ string: Any, replacementRange _: NSRange) {
            inputHandler?.inputMethodHandler?.insertText(string)
        }

        open func setMarkedText(
            _ string: Any,
            selectedRange: NSRange,
            replacementRange _: NSRange
        ) {
            inputHandler?.inputMethodHandler?.setMarkedText(
                string,
                selectedRange: selectedRange
            )
        }

        open func unmarkText() {
            inputHandler?.inputMethodHandler?.unmarkText()
        }

        open func selectedRange() -> NSRange {
            inputHandler?.inputMethodHandler?.currentSelectedRange()
                ?? NSRange(location: NSNotFound, length: 0)
        }

        open func markedRange() -> NSRange {
            inputHandler?.inputMethodHandler?.markedRange()
                ?? NSRange(location: NSNotFound, length: 0)
        }

        open func hasMarkedText() -> Bool {
            inputHandler?.inputMethodHandler?.hasMarkedText ?? false
        }

        open func attributedSubstring(
            forProposedRange range: NSRange,
            actualRange: NSRangePointer?
        ) -> NSAttributedString? {
            inputHandler?.inputMethodHandler?.attributedSubstring(
                forProposedRange: range,
                actualRange: actualRange
            )
        }

        open func validAttributesForMarkedText() -> [NSAttributedString.Key] {
            []
        }

        open func firstRect(
            forCharacterRange _: NSRange,
            actualRange _: NSRangePointer?
        ) -> NSRect {
            guard let surface else { return .zero }

            let point = surface.imePoint()
            // The ime point is the caret cell, where ghostty also renders the
            // inline preedit (the composing pinyin). The candidate window
            // would otherwise overlap the preedit, so anchor the rect one
            // full cell ABOVE the caret — the candidate list then appears
            // above the composing text instead of covering it. Clamped so a
            // caret near the top never pushes the rect off-screen (the input
            // method flips the candidate list below in that case).
            let caretY = bounds.height - point.y - point.height
            let y = max(0, caretY + point.height)
            // A zero-width rect (ghostty reports the caret, not the preedit
            // extent) makes the input method anchor the candidate window
            // directly on top of the composing text. Give it the cell width
            // so it offsets next to the preedit instead of covering it.
            let width = max(point.width, 16)
            let viewRect = NSRect(x: point.x, y: y, width: width, height: point.height)

            guard let window else { return viewRect }
            let windowRect = convert(viewRect, to: nil)
            return window.convertToScreen(windowRect)
        }

        open func characterIndex(for _: NSPoint) -> Int {
            NSNotFound
        }
    }
#endif
