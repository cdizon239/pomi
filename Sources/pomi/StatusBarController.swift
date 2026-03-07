import AppKit

@MainActor
class StatusBarController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()
    private let pomo = PomodoroTimer()

    private var startItem: NSMenuItem!
    private var stopItem: NSMenuItem!
    private var durationMenu: NSMenu!

    init() {
        setupButton()
        setupMenu()
        setupTimer()
    }

    func cleanup() {
        pomo.stop()
    }

    // MARK: - Setup

    private func setupButton() {
        guard let button = statusItem.button else { return }
        button.image = tomatoIcon(size: 16)
        button.imagePosition = .imageLeft
        button.title = ""
    }

    private func setupMenu() {
        startItem = makeItem("Start Focus", action: #selector(startFocus))

        stopItem = makeItem("Stop", action: #selector(stopTimer))
        stopItem.isHidden = true

        menu.addItem(.separator())

        let durationParent = NSMenuItem(title: "Focus Duration", action: nil, keyEquivalent: "")
        durationMenu = NSMenu()
        for minutes in [25, 35, 45, 60] {
            let item = makeItem("\(minutes) minutes", action: #selector(pickDuration(_:)), inMenu: durationMenu)
            item.tag = minutes
            item.state = minutes == 25 ? .on : .off
        }
        durationParent.submenu = durationMenu
        menu.addItem(durationParent)

        menu.addItem(.separator())

        let quit = NSMenuItem(title: "Quit pomi", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quit)

        statusItem.menu = menu
    }

    @discardableResult
    private func makeItem(_ title: String, action: Selector, inMenu target: NSMenu? = nil) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        (target ?? menu).addItem(item)
        return item
    }

    private func setupTimer() {
        pomo.onTick = { [weak self] time in
            self?.setTitle(" \(time)")
        }
        pomo.onComplete = { [weak self] finished in
            self?.handleComplete(finished)
        }
    }

    // MARK: - Actions

    @objc private func startFocus() {
        beginSession(.focus)
    }

    @objc private func stopTimer() {
        pomo.stop()
        setTitle("")
        startItem.isHidden = false
        stopItem.isHidden = true
    }

    @objc private func pickDuration(_ sender: NSMenuItem) {
        pomo.setFocusMinutes(sender.tag)
        durationMenu.items.forEach { $0.state = $0.tag == sender.tag ? .on : .off }
    }

    // MARK: - Internal

    private func beginSession(_ state: PomodoroState) {
        pomo.start(state)
        let mins = state == .focus ? pomo.focusMinutes : pomo.breakMinutes
        setTitle(String(format: " %d:00", mins))
        startItem.isHidden = true
        stopItem.isHidden = false
    }

    private func setTitle(_ text: String) {
        statusItem.button?.title = text
    }

    private func handleComplete(_ finished: PomodoroState) {
        setTitle("")
        startItem.isHidden = false
        stopItem.isHidden = true

        let (title, body, nextState): (String, String, PomodoroState?) = finished == .focus
            ? ("Focus complete!", "Nice work. Take a \(pomo.breakMinutes)-minute break?", .rest)
            : ("Break over!", "Ready for another focus session?", .focus)

        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = body
        alert.addButton(withTitle: nextState == .rest ? "Start Break" : "Start Focus")
        alert.addButton(withTitle: "Not now")
        alert.icon = tomatoIcon(size: 64)

        NSApp.activate(ignoringOtherApps: true)
        if alert.runModal() == .alertFirstButtonReturn, let next = nextState {
            beginSession(next)
        }
    }

    // MARK: - Tomato Icon

    private func tomatoIcon(size: CGFloat) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()

        let pad: CGFloat = size * 0.05
        let bodySize = size * 0.78
        let bodyX = (size - bodySize) / 2
        let bodyY = pad

        // Body
        NSColor(red: 0.88, green: 0.18, blue: 0.18, alpha: 1).setFill()
        NSBezierPath(ovalIn: NSRect(x: bodyX, y: bodyY, width: bodySize, height: bodySize)).fill()

        // Shine
        NSColor(white: 1, alpha: 0.3).setFill()
        let shineSize = bodySize * 0.22
        NSBezierPath(ovalIn: NSRect(
            x: bodyX + bodySize * 0.22,
            y: bodyY + bodySize * 0.58,
            width: shineSize,
            height: shineSize * 0.7
        )).fill()

        // Stem
        let stemColor = NSColor(red: 0.18, green: 0.60, blue: 0.22, alpha: 1)
        stemColor.setStroke()
        let stemPath = NSBezierPath()
        stemPath.lineWidth = max(1.2, size * 0.07)
        stemPath.lineCapStyle = .round
        stemPath.move(to: NSPoint(x: size * 0.5, y: bodyY + bodySize - 1))
        stemPath.line(to: NSPoint(x: size * 0.5, y: size - pad))
        stemPath.stroke()

        // Leaf
        stemColor.setFill()
        let leafPath = NSBezierPath()
        let cx = size * 0.5
        let cy = bodyY + bodySize * 0.9
        leafPath.move(to: NSPoint(x: cx, y: cy))
        leafPath.curve(
            to: NSPoint(x: cx + size * 0.22, y: cy + size * 0.06),
            controlPoint1: NSPoint(x: cx + size * 0.08, y: cy + size * 0.14),
            controlPoint2: NSPoint(x: cx + size * 0.20, y: cy + size * 0.12)
        )
        leafPath.curve(
            to: NSPoint(x: cx, y: cy),
            controlPoint1: NSPoint(x: cx + size * 0.18, y: cy + size * 0.02),
            controlPoint2: NSPoint(x: cx + size * 0.08, y: cy)
        )
        leafPath.fill()

        image.unlockFocus()
        image.isTemplate = false
        return image
    }
}
