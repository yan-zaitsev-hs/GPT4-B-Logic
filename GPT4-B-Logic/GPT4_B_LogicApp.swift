//
//  GPT4_B_LogicApp.swift
//  GPT4-B-Logic
//
//  Created by Yan Zaitsev on 21.04.2023.
//

import SwiftUI

@main
struct GPT4_B_LogicApp: App {
    let gpt = GPT()
    @ObservedObject var state = AppState()

    var body: some Scene {
        WindowGroup {
            state.pages.last!.view
            .environmentObject(gpt)
            .environmentObject(state)
        }
    }
}
