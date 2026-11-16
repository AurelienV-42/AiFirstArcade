import AppKit

let size = 1024.0
let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()

NSColor(red: 0.86, green: 0.92, blue: 0.96, alpha: 1).setFill()
NSRect(x: 0, y: 0, width: size, height: size).fill()

let red = NSColor(red: 0.94, green: 0.39, blue: 0.35, alpha: 1)
let redDeep = NSColor(red: 0.72, green: 0.26, blue: 0.23, alpha: 1)
let gold = NSColor(red: 0.95, green: 0.70, blue: 0.24, alpha: 1)

redDeep.setFill()
NSBezierPath(roundedRect: NSRect(x: 212, y: 150, width: 600, height: 470), xRadius: 70, yRadius: 70).fill()
red.setFill()
NSBezierPath(roundedRect: NSRect(x: 212, y: 180, width: 600, height: 440), xRadius: 70, yRadius: 70).fill()
redDeep.setFill()
NSBezierPath(roundedRect: NSRect(x: 180, y: 590, width: 664, height: 140), xRadius: 50, yRadius: 50).fill()
gold.setFill()
NSRect(x: 462, y: 180, width: 100, height: 550).fill()

func star(center: NSPoint, radius: Double) -> NSBezierPath {
    let path = NSBezierPath()
    for index in 0..<10 {
        let r = index.isMultiple(of: 2) ? radius : radius * 0.45
        let angle = Double(index) * .pi / 5 + .pi / 2
        let point = NSPoint(x: center.x + cos(angle) * r, y: center.y + sin(angle) * r)
        if index == 0 { path.move(to: point) } else { path.line(to: point) }
    }
    path.close()
    return path
}
star(center: NSPoint(x: 512, y: 830), radius: 150).fill()

image.unlockFocus()
guard let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else { exit(1) }
try png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
