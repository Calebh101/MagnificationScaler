//
//  NoPermsView.swift
//  MagnificationScaler
//
//  Created by caleb on 6/30/26.
//

import SwiftUI

struct NoPermsView: View {
    static let width = 420.0
    static let height = 100.0
    
    var body: some View {
        VStack {
            Text("Please enable accessibility permissions for MagnificationScaler.").font(.body)
            Text("Then restart the app.").font(.body)
            Button("Quit") { NSApplication.shared.terminate(nil) }
        }.frame(width: Self.width, height: Self.height)
    }
}

#Preview {
    NoPermsView().frame(width: NoPermsView.width, height: NoPermsView.height)
}
