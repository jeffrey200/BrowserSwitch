//
//  BrowserSelectionView.swift
//  BrowserSwitch
//

import AppKit
import SwiftUI

struct BrowserSelectionView: View {
    let options: [BrowserOption]
    let onChoose: (Browser) -> Void
    let onCancel: () -> Void

    @State private var selectedBrowser: Browser

    init(
        options: [BrowserOption],
        initialSelection: Browser,
        onChoose: @escaping (Browser) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.options = options
        self.onChoose = onChoose
        self.onCancel = onCancel
        _selectedBrowser = State(initialValue: initialSelection)
    }

    var body: some View {
        ZStack {
            KeyboardHandlingView { event in
                handleKeyDown(event)
            }
            .allowsHitTesting(false)

            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow, state: .active)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.black.opacity(0.18))

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)

            HStack(spacing: 14) {
                ForEach(options) { option in
                    BrowserTile(
                        option: option,
                        isSelected: option.browser == selectedBrowser
                    )
                    .onHover { isHovering in
                        guard isHovering, option.isInstalled else {
                            return
                        }

                        selectedBrowser = option.browser
                    }
                    .onTapGesture {
                        choose(option)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 22)
        }
        .frame(width: 430, height: 172)
    }

    private func handleKeyDown(_ event: NSEvent) -> Bool {
        switch event.keyCode {
        case 123:
            moveSelection(by: -1)
            return true
        case 124:
            moveSelection(by: 1)
            return true
        case 36, 76:
            chooseSelectedBrowser()
            return true
        case 53:
            onCancel()
            return true
        default:
            return handleNumberKey(event)
        }
    }

    private func handleNumberKey(_ event: NSEvent) -> Bool {
        guard
            let characters = event.charactersIgnoringModifiers,
            let number = Int(characters),
            (1...options.count).contains(number)
        else {
            return false
        }

        choose(options[number - 1])
        return true
    }

    private func moveSelection(by offset: Int) {
        let installedBrowsers = options
            .filter(\.isInstalled)
            .map(\.browser)

        guard !installedBrowsers.isEmpty else {
            return
        }

        let currentIndex = installedBrowsers.firstIndex(of: selectedBrowser) ?? 0
        let nextIndex = (currentIndex + offset + installedBrowsers.count) % installedBrowsers.count
        selectedBrowser = installedBrowsers[nextIndex]
    }

    private func chooseSelectedBrowser() {
        guard let option = options.first(where: { $0.browser == selectedBrowser }) else {
            return
        }

        choose(option)
    }

    private func choose(_ option: BrowserOption) {
        guard option.isInstalled else {
            NSSound.beep()
            return
        }

        onChoose(option.browser)
    }
}

private struct BrowserTile: View {
    let option: BrowserOption
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 10) {
            Image(nsImage: option.browser.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 62, height: 62)
                .opacity(option.isInstalled ? 1 : 0.35)

            Text(option.browser.displayName)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(option.isInstalled ? Color.white : Color.white.opacity(0.38))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .frame(width: 92)
        }
        .frame(width: 112, height: 122)
        .background(selectionBackground)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var selectionBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(isSelected ? Color.white.opacity(0.16) : Color.clear)
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(isSelected ? Color.white.opacity(0.42) : Color.clear, lineWidth: 1)
            }
    }
}
