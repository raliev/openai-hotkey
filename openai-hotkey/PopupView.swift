//
//  PopupView.swift
//  openai-hotkey
//
//  Created by Rauf Aliev on 12/1/23.
//

import SwiftUI

struct PopupView: View {
    @Binding var isPresented: Bool
    var stopAction: () -> Void

    var body: some View {
        VStack {
            Text("Playing...")
            Button("Stop") {
                stopAction()
                isPresented = false
                PopupWindowController.shared.hideWindow()
            }
        }
        .frame(width: 200, height: 100)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}
