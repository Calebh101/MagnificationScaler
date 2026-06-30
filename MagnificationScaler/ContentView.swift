//
//  ContentView.swift
//  MagnificationScaler
//
//  Created by caleb on 6/29/26.
//

import SwiftUI

let width = 450.0
let height = 250.0

struct ContentView: View {
    @AppStorage("location") private var location = "tb"
    @AppStorage("scale") private var scale: Double = 1.0
    @AppStorage("autoRestartDock") private var autoRestartDock = true
    @AppStorage("enableMagnification") private var enableMagnification = true
    
    @State private var showInfoLocation = false
    @State private var showInfoScale = false
    
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
                    Text("The proportion to your dock's height/width to the magnification set.\n1.0 is the default, and correlates to medium magnification.")
                        .padding().frame(width: 400)
                }
            }
            Spacer().frame(height: 20)
            HStack {
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
            }
            Spacer().frame(height: 20)
            Toggle("Enable Magnification", isOn: $enableMagnification)
            Toggle("Auto-Restart Dock", isOn: $autoRestartDock)
            Spacer().frame(height: 20)
            HStack {
                Button("Apply") {
                    if let size = getDockSize() {
                        setDock(size: size, override: true)
                    }
                }
                Button("Restart Dock") { restartDock() }
                Button("Quit") { NSApplication.shared.terminate(nil) }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView().frame(width: width, height: height)
}
