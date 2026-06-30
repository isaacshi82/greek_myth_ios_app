//
//  ContentView.swift
//  Mythic Paths: Olympus
//
//  Created by Yunong Shi on 5/19/26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false

    var body: some View {
        ZStack {
            if hasSeenWelcome {
                MainMenuView()
                    .transition(.opacity)
            } else {
                WelcomeView {
                    withAnimation(.easeInOut) { hasSeenWelcome = true }
                }
                .transition(.opacity)
            }
        }
    }
}

#Preview {
    ContentView()
}
