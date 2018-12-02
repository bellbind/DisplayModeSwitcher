#!/usr/bin/env swift -import-objc-header cg-hidden.h
// $ swiftc -import-objc-header cg-hidden.h displaymode.swift
import Foundation
import CoreFoundation
import CoreGraphics

let display = CGMainDisplayID()
let count = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
defer {count.deallocate()}
CGSGetNumberOfDisplayModes(display, count);

let argv = CommandLine.arguments
if argv.count == 2 {
    guard let modeNum = Int32(argv[1]) else {
        fputs("mode num should be integer but: \(argv[1])\n", stderr)
        exit(1)
    }
    if modeNum < 0 || count.pointee <= modeNum {
        fputs("mode num should be in 0-\(count.pointee - 1) but: \(argv[1])\n", stderr)
        exit(1)
    }
    let config = UnsafeMutablePointer<CGDisplayConfigRef?>.allocate(capacity: 1)
    defer {config.deallocate()}
    CGBeginDisplayConfiguration(config)
    CGSConfigureDisplayMode(config.pointee, display, modeNum)
    CGCompleteDisplayConfiguration(config.pointee, CGConfigureOption.permanently)
}

let current = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
defer {current.deallocate()}
CGSGetCurrentDisplayMode(display, current);
let dmode = UnsafeMutablePointer<CGSDisplayMode>.allocate(capacity: 1)
defer {dmode.deallocate()}
let size = Int32(MemoryLayout<CGSDisplayMode>.size)

CGSGetDisplayModeDescriptionOfLength(display, current.pointee, dmode, size)
print(String(format: "current: %5d x %-5d", dmode.pointee.width, dmode.pointee.height))

for i in 0 ..< count.pointee {
    CGSGetDisplayModeDescriptionOfLength(display, i, dmode, size)
    let mark = i == current.pointee ? "(current)" : ""
    print(String(format: "mode %2d: %5d x %-5d \(mark)",
                 i, dmode.pointee.width, dmode.pointee.height))
}
