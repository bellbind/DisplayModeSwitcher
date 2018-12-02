#!/usr/bin/env swift
// swiftc displaymode.swift
import Foundation
import CoreGraphics

let display = CGMainDisplayID()
guard let dmodes = CGDisplayCopyAllDisplayModes(display, nil) as? [CGDisplayMode] else {exit(1)}

let argv = CommandLine.arguments
if argv.count == 2 {
    guard let modeNum = Int(argv[1]) else {
        fputs("mode num should be integer but: \(argv[1])\n", stderr);
        exit(1);
    }
    if modeNum < 0 || dmodes.count <= modeNum {
        fputs("mode num should be in 0-\(dmodes.count - 1) but: \(argv[1])\n", stderr);
        exit(1);
    }
    let config = UnsafeMutablePointer<CGDisplayConfigRef?>.allocate(capacity: 1)
    defer {config.deallocate()}
    CGBeginDisplayConfiguration(config)
    CGConfigureDisplayWithDisplayMode(config.pointee, display, dmodes[modeNum], nil)
    CGCompleteDisplayConfiguration(config.pointee, CGConfigureOption.permanently)
}

if let current = CGDisplayCopyDisplayMode(display) {
    //print("current: \(current.width) x \(current.height)")
    print(String(format: "current: %5d x %-5d", current.width, current.height))
    for (i, dmode) in dmodes.enumerated() {
        let mark = dmode.ioDisplayModeID == current.ioDisplayModeID ? "(current)" : ""
        print(String(format: "mode %2d: %5d x %-5d \(mark)", i, dmode.width, dmode.height))
    }
}
