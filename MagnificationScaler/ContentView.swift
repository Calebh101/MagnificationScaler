//
//  ContentView.swift
//  MagnificationScaler
//
//  Created by caleb on 6/29/26.
//

import SwiftUI
import ServiceManagement

let width = 500.0
let height = 350.0

struct ContentView: View {
    @AppStorage("scale") private var scale: Double = 1.0
    @AppStorage("enableMagnification") private var enableMagnification = true

    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled
    @State private var dockSizeText = "Unavailable"

    @State private var showInfoLocation = false
    @State private var showInfoScale = false
    @State private var showInfoThreshold = false
    @State private var showDockSize = false

    var body: some View {
        VStack {
            Text("MagnificationScaler").font(.title)
            Text("V. \(version) by Calebh101").font(.body)
            Spacer().frame(height: 20)
            HStack {
                Text("Scale: \(scale, specifier: "%.2f")")
                Slider(value: $scale, in: 0.5...3.0, step: 0.05)
                Button {
                    showInfoScale.toggle()
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showInfoScale) {
                    Text("The proportion of your dock's height/width to the magnification set.\n1.0 is the default, and correlates to medium magnification.")
                        .padding().frame(width: 400)
                }
            }
            Spacer().frame(height: 20)
            Toggle("Enable Magnification", isOn: $enableMagnification)
            Toggle("Launch at Login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { old, new in
                    do {
                        if new {
                            try SMAppService.mainApp.register()
                        } else {
                            try SMAppService.mainApp.unregister()
                        }
                    } catch {
                        print("Failed: \(error)")
                    }
                }
            Spacer().frame(height: 20)
            HStack {
                Button("Apply") {
                    if let size = getDockSize() {
                        setDock(size: size, override: true)
                    }
                }
                Button("Restart Dock") { restartDock() }
            }
            HStack {
                Button("Dock Info") {
                    var sizeText: String
                    var orienText: String

                    if let size = getDockSize() {
                        sizeText = "\(size.width)px x \(size.height)px";
                    } else {
                        sizeText = "Unavailable"
                    }

                    if let orientation = getDockOrientation() {
                        orienText = orientation.name()
                    } else {
                        orienText = "Unavailable (defaults to \(DockOrientation.bottom.name())"
                    }

                    dockSizeText = "Size (wxh): \(sizeText)\nOrientation: \(orienText)"
                    showDockSize = true
                }
                .alert("Dock Info", isPresented: $showDockSize) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(dockSizeText)
                }
                Button("Quit") { NSApplication.shared.terminate(nil) }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView().frame(width: width, height: height)
}
