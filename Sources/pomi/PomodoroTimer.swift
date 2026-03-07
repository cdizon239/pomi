import Foundation
import AppKit

enum PomodoroState {
    case idle
    case focus
    case rest
}

@MainActor
class PomodoroTimer {
    var onTick: ((String) -> Void)?
    var onComplete: ((PomodoroState) -> Void)?

    private var timer: Timer?
    private var remaining: Int = 0
    private(set) var state: PomodoroState = .idle
    private(set) var focusMinutes: Int = 25
    let breakMinutes: Int = 5

    func setFocusMinutes(_ minutes: Int) {
        focusMinutes = minutes
    }

    func start(_ state: PomodoroState) {
        self.state = state
        remaining = (state == .focus ? focusMinutes : breakMinutes) * 60
        scheduleTimer()
    }

    func stop() {
        invalidate()
        state = .idle
    }

    private func scheduleTimer() {
        invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func tick() {
        remaining -= 1
        if remaining <= 0 {
            let finished = state
            invalidate()
            state = .idle
            NSSound(named: NSSound.Name("Glass"))?.play()
            onComplete?(finished)
        } else {
            let m = remaining / 60
            let s = remaining % 60
            onTick?(String(format: "%d:%02d", m, s))
        }
    }

    private func invalidate() {
        timer?.invalidate()
        timer = nil
    }
}
