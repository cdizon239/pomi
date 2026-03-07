import AppKit

func drawTomato(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let pad = size * 0.08
    let bodySize = size * 0.72
    let bodyX = (size - bodySize) / 2
    let bodyY = pad

    // Shadow
    let shadow = NSShadow()
    shadow.shadowColor = NSColor(white: 0, alpha: 0.25)
    shadow.shadowOffset = NSSize(width: 0, height: -size * 0.02)
    shadow.shadowBlurRadius = size * 0.04
    shadow.set()

    // Body
    NSColor(red: 0.88, green: 0.15, blue: 0.15, alpha: 1).setFill()
    NSBezierPath(ovalIn: NSRect(x: bodyX, y: bodyY, width: bodySize, height: bodySize)).fill()

    // Remove shadow for details
    let noShadow = NSShadow()
    noShadow.shadowColor = nil
    noShadow.set()

    // Highlight
    NSColor(white: 1, alpha: 0.3).setFill()
    let shineSize = bodySize * 0.25
    NSBezierPath(ovalIn: NSRect(
        x: bodyX + bodySize * 0.2,
        y: bodyY + bodySize * 0.55,
        width: shineSize,
        height: shineSize * 0.65
    )).fill()

    // Stem
    let stemColor = NSColor(red: 0.15, green: 0.55, blue: 0.20, alpha: 1)
    stemColor.setStroke()
    let stemPath = NSBezierPath()
    stemPath.lineWidth = max(2, size * 0.05)
    stemPath.lineCapStyle = .round
    stemPath.move(to: NSPoint(x: size * 0.5, y: bodyY + bodySize - size * 0.02))
    stemPath.line(to: NSPoint(x: size * 0.5, y: size - pad * 1.5))
    stemPath.stroke()

    // Leaf
    stemColor.setFill()
    let leafPath = NSBezierPath()
    let cx = size * 0.5
    let cy = bodyY + bodySize * 0.88
    leafPath.move(to: NSPoint(x: cx, y: cy))
    leafPath.curve(
        to: NSPoint(x: cx + size * 0.2, y: cy + size * 0.06),
        controlPoint1: NSPoint(x: cx + size * 0.06, y: cy + size * 0.13),
        controlPoint2: NSPoint(x: cx + size * 0.18, y: cy + size * 0.11)
    )
    leafPath.curve(
        to: NSPoint(x: cx, y: cy),
        controlPoint1: NSPoint(x: cx + size * 0.16, y: cy + size * 0.02),
        controlPoint2: NSPoint(x: cx + size * 0.06, y: cy)
    )
    leafPath.fill()

    // Left leaf
    let leafPath2 = NSBezierPath()
    leafPath2.move(to: NSPoint(x: cx, y: cy))
    leafPath2.curve(
        to: NSPoint(x: cx - size * 0.15, y: cy + size * 0.08),
        controlPoint1: NSPoint(x: cx - size * 0.04, y: cy + size * 0.12),
        controlPoint2: NSPoint(x: cx - size * 0.12, y: cy + size * 0.12)
    )
    leafPath2.curve(
        to: NSPoint(x: cx, y: cy),
        controlPoint1: NSPoint(x: cx - size * 0.12, y: cy + size * 0.03),
        controlPoint2: NSPoint(x: cx - size * 0.04, y: cy)
    )
    leafPath2.fill()

    image.unlockFocus()
    return image
}

func pngData(from image: NSImage, size: Int) -> Data? {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size, pixelsHigh: size,
        bitsPerSample: 8, samplesPerPixel: 4,
        hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0, bitsPerPixel: 0
    )!
    rep.size = NSSize(width: size, height: size)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    image.draw(in: NSRect(x: 0, y: 0, width: size, height: size))
    NSGraphicsContext.restoreGraphicsState()

    return rep.representation(using: .png, properties: [:])
}

let iconsetPath = "/Users/charmillecoleen/dev/pomi/AppIcon.iconset"
try? FileManager.default.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

let sizes: [(name: String, size: Int)] = [
    ("icon_16x16", 16),
    ("icon_16x16@2x", 32),
    ("icon_32x32", 32),
    ("icon_32x32@2x", 64),
    ("icon_128x128", 128),
    ("icon_128x128@2x", 256),
    ("icon_256x256", 256),
    ("icon_256x256@2x", 512),
    ("icon_512x512", 512),
    ("icon_512x512@2x", 1024),
]

for entry in sizes {
    let image = drawTomato(size: CGFloat(entry.size))
    if let data = pngData(from: image, size: entry.size) {
        let path = "\(iconsetPath)/\(entry.name).png"
        try! data.write(to: URL(fileURLWithPath: path))
    }
}

print("Iconset generated.")
