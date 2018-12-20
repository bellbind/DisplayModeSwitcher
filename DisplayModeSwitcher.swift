#!/usr/bin/env swift -import-objc-header cg-hidden.h
// DisplayMode switcher on StatrusBar (for swift4)
// $ swiftc -import-objc-header cg-hidden.h DisplayModeSwitcher.swift
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
        let count = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        defer {count.deallocate()}
        CGSGetNumberOfDisplayModes(display, count)
        let current = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        defer {current.deallocate()}
        CGSGetCurrentDisplayMode(display, current)

        let dmode = UnsafeMutablePointer<CGSDisplayMode>.allocate(capacity: 1)
        defer {dmode.deallocate()}
        let size = Int32(MemoryLayout<CGSDisplayMode>.size)
        let items = (0 ..< count.pointee).map {(i) -> NSMenuItem in
            CGSGetDisplayModeDescriptionOfLength(display, i, dmode, size)
            let mark = i == current.pointee ? "\u{2713}" : ""
            let mi = NSMenuItem()
            mi.attributedTitle = resolution(
              "\(i)", "\(dmode.pointee.width)", "\(dmode.pointee.height)",  "\(mark)")
            mi.target = self
            mi.action = #selector(self.switchMode(_:))
            mi.tag = Int(i)
            return mi
        }
        for item in items {menu.addItem(item)}

        menu.addItem(NSMenuItem.separator())
        let terminate = #selector(NSApplication.shared.terminate) 
        menu.addItem(withTitle: "Quit", action: terminate, keyEquivalent: "")
    }
    @objc func switchMode(_ sender: NSMenuItem) {
        let display = CGMainDisplayID()
        let config = UnsafeMutablePointer<CGDisplayConfigRef?>.allocate(capacity: 1)
        defer {config.deallocate()}
        CGBeginDisplayConfiguration(config)
        CGSConfigureDisplayMode(config.pointee, display, Int32(sender.tag))
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
statusItem.button?.title = "\u{1F5A5}"
statusItem.menu = menu
NSApplication.shared.run()
