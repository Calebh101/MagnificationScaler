//
//  MagnificationScalerApp.swift
//  MagnificationScaler
//
//  Created by caleb on 6/29/26.
//

import SwiftUI
import SwiftData

let version = "0.0.0D"
let previous = PreviousValue()

enum DockOrientation: String {
    case left
    case right
    case bottom
    
    func name() -> String {
        switch self {
            case .bottom: return "Bottom"
            case .left: return "Left"
            case .right: return "Right"
        }
    }
}

func getDockOrientation() -> DockOrientation? {
    return UserDefaults(suiteName: "com.apple.dock")?
        .string(forKey: "orientation")
        .flatMap(DockOrientation.init(rawValue:))
}

class MSSettings {
    @AppStorage("scale") static public var scale: Double = 1.0
    @AppStorage("factorChangeThreshold") static public var factorChangeThreshold: Double = 1.0
    @AppStorage("autoRestartDock") static public var autoRestartDock = true
    @AppStorage("enableMagnification") static public var enableMagnification = true
}

func setDock(size: CGSize, override: Bool = false) {
    let enableMagnification = MSSettings.enableMagnification
    let scale = MSSettings.scale
    let autoRestartDock = MSSettings.autoRestartDock
    let threshold = MSSettings.factorChangeThreshold
    let location = getDockOrientation() ?? .bottom
    
    let factor = location == .bottom ? size.height : size.width
    let diff = abs(Double(factor) - Double(previous.value))

    if !override && diff == 0 { return }
    previous.value = factor

    let dockDefaults = UserDefaults(suiteName: "com.apple.dock")!
    let results = factor * scale

    dockDefaults.set(enableMagnification, forKey: "magnification")
    dockDefaults.set(results, forKey: "largesize")
    dockDefaults.synchronize()

    if autoRestartDock && (override || diff >= threshold) {
        restartDock()
    }
    
    let isEnabled = dockDefaults.bool(forKey: "magnification")
    let dockSize = dockDefaults.double(forKey: "largesize")
    print("Set dock magnification:", factor, scale, results, dockSize, isEnabled, location, autoRestartDock)
}

final class PreviousValue: @unchecked Sendable {
    nonisolated(unsafe) var value: CGFloat = -1
}

@main
struct MagnificationScalerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

func checkAccessibilityPermission() -> Bool {
    let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
    return AXIsProcessTrustedWithOptions(options as CFDictionary)
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "dock.rectangle", accessibilityDescription: "Menu")
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover = NSPopover()
        popover.behavior = .transient
        
        if !checkAccessibilityPermission() {
            popover.contentSize = NSSize(width: NoPermsView.width, height: NoPermsView.height)
            popover.contentViewController = NSHostingController(rootView: NoPermsView())
            return
        }
        
        popover.contentSize = NSSize(width: width, height: height)
        popover.contentViewController = NSHostingController(rootView: ContentView())
        
        print("Monitor is starting")
        let monitor = DockMonitor()

        Task {
            await monitor.start({ size in
                setDock(size: size)
            })
        }
    }

    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
}
