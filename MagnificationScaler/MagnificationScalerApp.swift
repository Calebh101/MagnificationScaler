//
//  MagnificationScalerApp.swift
//  MagnificationScaler
//
//  Created by caleb on 6/29/26.
//

import SwiftUI
import SwiftData

let version = "0.0.0A"
let previous = PreviousValue()

class MSSettings {
    @AppStorage("location") static public var location = "tb"
    @AppStorage("scale") static public var scale: Double = 1.0
    @AppStorage("autoRestartDock") static public var autoRestartDock = true
    @AppStorage("enableMagnification") static public var enableMagnification = true
}

func setDock(size: CGSize, override: Bool = false) {
    let enableMagnification = MSSettings.enableMagnification
    let scale = MSSettings.scale
    let location = MSSettings.location
    let autoRestartDock = MSSettings.autoRestartDock
    
    let factor = location == "tb" ? size.height : size.width
    if !override && factor == previous.value { return }
    previous.value = factor

    let dockDefaults = UserDefaults(suiteName: "com.apple.dock")!
    let results = factor * scale

    dockDefaults.set(enableMagnification, forKey: "magnification")
    dockDefaults.set(results, forKey: "largesize")
    dockDefaults.synchronize()

    if autoRestartDock {
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
        popover.contentSize = NSSize(width: width, height: height)
        popover.behavior = .transient
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
