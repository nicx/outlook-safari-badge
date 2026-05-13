#!/usr/bin/env swift
// Generates icon PNGs for the extension + macOS app icon set.
// Run: swift generate-icons.swift

import AppKit
import CoreGraphics

func drawIcon(size: CGFloat) -> NSBitmapImageRep {
    let pixels = Int(size)
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixels,
        pixelsHigh: pixels,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    guard let ctx = NSGraphicsContext.current?.cgContext else {
        NSGraphicsContext.restoreGraphicsState()
        return rep
    }

    // Background — rounded square, Outlook-ish blue
    let bgRect = CGRect(x: 0, y: 0, width: size, height: size)
    let radius = size * 0.225
    let bgPath = CGPath(roundedRect: bgRect, cornerWidth: radius, cornerHeight: radius, transform: nil)
    ctx.addPath(bgPath)
    ctx.setFillColor(NSColor(srgbRed: 0.0, green: 0.46, blue: 0.83, alpha: 1.0).cgColor)
    ctx.fillPath()

    // Envelope — centered, white, slightly inset
    let envInset = size * 0.18
    let envHeight = size * 0.46
    let envWidth = size - 2 * envInset
    let envY = (size - envHeight) / 2 - size * 0.02
    let envRect = CGRect(x: envInset, y: envY, width: envWidth, height: envHeight)
    let envCorner = size * 0.04

    ctx.setFillColor(NSColor.white.cgColor)
    ctx.addPath(CGPath(roundedRect: envRect, cornerWidth: envCorner, cornerHeight: envCorner, transform: nil))
    ctx.fillPath()

    // Envelope flap (triangle on top half)
    ctx.setStrokeColor(NSColor(srgbRed: 0.0, green: 0.46, blue: 0.83, alpha: 1.0).cgColor)
    ctx.setLineWidth(size * 0.035)
    ctx.setLineJoin(.round)
    ctx.move(to: CGPoint(x: envRect.minX + envCorner * 0.5, y: envRect.maxY - envCorner * 0.5))
    ctx.addLine(to: CGPoint(x: envRect.midX, y: envRect.midY + envHeight * 0.05))
    ctx.addLine(to: CGPoint(x: envRect.maxX - envCorner * 0.5, y: envRect.maxY - envCorner * 0.5))
    ctx.strokePath()

    // Red notification badge — top-right corner
    let badgeSize = size * 0.34
    let badgeRect = CGRect(
        x: size - badgeSize - size * 0.06,
        y: size - badgeSize - size * 0.06,
        width: badgeSize,
        height: badgeSize
    )
    // White ring around the badge for separation
    let ringRect = badgeRect.insetBy(dx: -size * 0.025, dy: -size * 0.025)
    ctx.setFillColor(NSColor.white.cgColor)
    ctx.addPath(CGPath(ellipseIn: ringRect, transform: nil))
    ctx.fillPath()

    // The red dot
    ctx.setFillColor(NSColor(srgbRed: 0.86, green: 0.18, blue: 0.18, alpha: 1.0).cgColor)
    ctx.addPath(CGPath(ellipseIn: badgeRect, transform: nil))
    ctx.fillPath()

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

func savePNG(_ rep: NSBitmapImageRep, to path: String) {
    guard let data = rep.representation(using: .png, properties: [:]) else {
        print("⚠️ could not encode \(path)")
        return
    }
    let url = URL(fileURLWithPath: path)
    try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try? data.write(to: url)
    print("✓ \(path)")
}

let rootArg = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : FileManager.default.currentDirectoryPath
let root = (rootArg as NSString).expandingTildeInPath

// Extension manifest icons
let extDir = "\(root)/Extension/icons"
for size in [48, 96, 128] {
    let img = drawIcon(size: CGFloat(size))
    savePNG(img, to: "\(extDir)/icon-\(size).png")
}

// macOS AppIcon.appiconset — produces all required sizes
let appIconDir = "\(root)/OutlookSafariBadge/OutlookSafariBadge/Assets.xcassets/AppIcon.appiconset"
struct IconSpec { let name: String; let size: Int }
let appIcons: [IconSpec] = [
    .init(name: "icon_16x16.png",       size: 16),
    .init(name: "icon_16x16@2x.png",    size: 32),
    .init(name: "icon_32x32.png",       size: 32),
    .init(name: "icon_32x32@2x.png",    size: 64),
    .init(name: "icon_128x128.png",     size: 128),
    .init(name: "icon_128x128@2x.png",  size: 256),
    .init(name: "icon_256x256.png",     size: 256),
    .init(name: "icon_256x256@2x.png",  size: 512),
    .init(name: "icon_512x512.png",     size: 512),
    .init(name: "icon_512x512@2x.png",  size: 1024),
]
for spec in appIcons {
    let img = drawIcon(size: CGFloat(spec.size))
    savePNG(img, to: "\(appIconDir)/\(spec.name)")
}

// LargeIcon (used in container app UI by template)
let largeIconDir = "\(root)/OutlookSafariBadge/OutlookSafariBadge/Assets.xcassets/LargeIcon.imageset"
for (suffix, size) in [("", 128), ("@2x", 256), ("@3x", 384)] {
    let img = drawIcon(size: CGFloat(size))
    savePNG(img, to: "\(largeIconDir)/LargeIcon\(suffix).png")
}

print("Done.")
