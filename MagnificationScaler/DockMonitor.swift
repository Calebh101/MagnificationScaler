//
//  DockMonitor.swift
//  MagnificationScaler
//
//  Created by caleb on 6/29/26.
//

import Foundation
import AppKit

func restartDock() {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
    task.arguments = ["Dock"]
    try? task.run()
}

func getDockSize() -> CGSize? {
    guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dock").first else {
        print("Couldn't find dock app")
        return nil
    }

    let element = AXUIElementCreateApplication(app.processIdentifier)
    var ref: CFTypeRef?
    let e = AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &ref)

    // Get the dock's UI elements
    guard e == .success, let children = ref as? [AXUIElement] else {
        print("Couldn't get children:", e.rawValue)
        return nil
    }

    for child in children {
        var ref: CFTypeRef?
        AXUIElementCopyAttributeValue(child, kAXRoleAttribute as CFString, &ref)

        // Check if list element
        if (ref as? String) == kAXListRole {
            var ref: CFTypeRef?
            let e = AXUIElementCopyAttributeValue(child, kAXSizeAttribute as CFString, &ref)

            guard e == .success, let ref: CFTypeRef else {
                continue
            }

            var size = CGSize.zero
            let value = unsafeDowncast(ref as AnyObject, to: AXValue.self)

            if AXValueGetValue(value, .cgSize, &size) {
                return size
            }
        }
    }

    print("No results")
    return nil
}

actor DockMonitor {
    private var dockObserver: NSObjectProtocol?
    private var launchObserver: NSObjectProtocol?
    private var pollTask: Task<Void, Never>?
    private var lastSeenSize: CGSize?

    func start(_ callback: @escaping @Sendable (CGSize) -> Void) {
        if let size = getDockSize() {
            callback(size)
        }

        pollTask = Task {
            while !Task.isCancelled {
                if let size = getDockSize() {
                    if size != lastSeenSize {
                        lastSeenSize = size
                    } else { // 0.5s
                        callback(size)
                    }
                }
                
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
            }
        }
    }

    func stop() {
        pollTask?.cancel()
        pollTask = nil
    }
}
