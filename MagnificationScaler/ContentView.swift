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
    @AppStorage("factorChangeThreshold") public var factorChangeThreshold: Double = 1.0
    @AppStorage("autoRestartDock") private var autoRestartDock = true
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
                Slider(value: $scale, in: 0.5...2.0, step: 0.05)
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
            HStack {
                Text("Height/width change threshold:")
                TextField("Pixels", value: $factorChangeThreshold, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
                    .onChange(of: factorChangeThreshold) { old, new in
                        let min = 1.0
                        let max = 999.0

                        if new < min {
                            factorChangeThreshold = min
                        } else if new > max {
                            factorChangeThreshold = max
                        }
                    }
                Button {
                    showInfoThreshold.toggle()
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showInfoThreshold) {
                    Text("How many pixels the dock's Height/width has to change to automatically restart the dock.\nThis is only applicable if Auto-Restart Dock is on.\n\nUse Get Dock Size below to show your dock's current Height/width.")
                        .padding().frame(width: 400)
                }
            }
            /*HStack {
                Picker("Dock location:", selection: $location) {
                    Text("Bottom").tag("tb")
                    Text("Side").tag("lr")
                }.pickerStyle(.menu)
                Button {
                    showInfoLocation.toggle()
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showInfoLocation) {
                    Text("The app uses the dock's current width or height to apply magnification scaling.\n\nIf your dock is at the bottom of your screen, the height will be the magnification factor.\nIf your dock is at the side of your screen, the width will be the magnification factor.\n\nThis setting should reflect your actual dock; changing it will not change your settings.")
                        .padding().frame(width: 400)
                }
            }*/
            Spacer().frame(height: 20)
            Toggle("Enable Magnification", isOn: $enableMagnification)
            Toggle("Auto-Restart Dock", isOn: $autoRestartDock)
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
                .alert("Dock Size", isPresented: $showDockSize) {
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
