#!/usr/bin/env swift
// DisplayMode switcher on StatrusBar (for swift4)
// $ swiftc DisplayModeSwitcher.swift
import Cocoa

let monoText = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
let attrsT: [NSAttributedString.Key: Any] = [.font: monoText]
let attrsS: [NSAttributedString.Key: Any] = [.font: monoText, .expansion: 0.8]
func resolution(_ id: String, _ w: String, _ h: String, _ mark: String) -> NSAttributedString {
    let parts = [(String(repeating: " ", count: 3 - id.count), attrsS), ("\(id): ", attrsT),
                 (String(repeating: " ", count: 5 - w.count), attrsS), ("\(w) x \(h)", attrsT),
                 (String(repeating: " ", count: 5 - h.count), attrsS), (mark, attrsT)]
    let title = NSMutableAttributedString()
    for (text, attrs) in parts {title.append(NSAttributedString(string: text, attributes: attrs))}
    return title
}

class Main: NSObject {
    func buildMenu(_ menu: NSMenu) {
        let display = CGMainDisplayID()
        let modes = CGDisplayCopyAllDisplayModes(display, nil)
        guard let dmodes = modes as? [CGDisplayMode] else {return}
        if let current = CGDisplayCopyDisplayMode(display) {
            let now = NSMenuItem()
            now.attributedTitle = resolution("Now", "\(current.width)", "\(current.height)", "")
            menu.addItem(now)
            menu.addItem(NSMenuItem.separator())
            let items = dmodes.enumerated().map {(i, dmode) -> NSMenuItem in
                let mi = NSMenuItem()
                let mark = dmode.ioDisplayModeID == current.ioDisplayModeID ? "\u{2713}" : ""
                mi.attributedTitle = resolution("\(i)", "\(dmode.width)", "\(dmode.height)", mark)
                mi.action = #selector(self.switchMode)
                mi.target = self
                mi.tag = i
                return mi
            }
            for item in items {menu.addItem(item)}
        }
        menu.addItem(NSMenuItem.separator())
        let terminate = #selector(NSApplication.shared.terminate)
        menu.addItem(withTitle: "Quit", action: terminate, keyEquivalent: "")
    }
    @objc func switchMode(_ sender: NSMenuItem) {
        let display = CGMainDisplayID()
        let modes = CGDisplayCopyAllDisplayModes(display, nil)
        guard let dmodes = modes as? [CGDisplayMode] else {return}
        let config = UnsafeMutablePointer<CGDisplayConfigRef?>.allocate(capacity: 1)
        defer {config.deallocate()}
        CGBeginDisplayConfiguration(config)
        CGConfigureDisplayWithDisplayMode(config.pointee, display, dmodes[sender.tag], nil)
        CGCompleteDisplayConfiguration(config.pointee, CGConfigureOption.permanently)
    }
}
extension Main: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        menu.removeAllItems()
        self.buildMenu(menu)
    }
}
let main = Main()

NSApplication.loadApplication()
let menu = NSMenu()
menu.delegate = main
let statusItem = NSStatusBar.system.statusItem(withLength: -1)
statusItem.button?.title = "\u{1F4BB}"
statusItem.menu = menu
NSApplication.shared.run()
