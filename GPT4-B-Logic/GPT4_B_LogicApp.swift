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
            ZStack() {
                state.pages.last!.view
                VStack {
                    Spacer()
                    GPTActivitiesView()
                }

            }
            .padding()
            .environmentObject(gpt)
            .environmentObject(state)
            .environmentObject(GPTHelper.shared)
            .environmentObject(CADisplayLinkTicker.shared)
        }
    }
}

struct GPTActivitiesView: View {
    @EnvironmentObject var helper: GPTHelper
    var body: some View {
        VStack(spacing: 4) {
            ForEach(helper.activities) { activity in
                switch activity {
                case .event(let event):
                    ActivityView(
                        title: "Sending to GPT...",
                        description: "\(event.eventName) => \(event.description)",
                        startTime: event.createdAt
                    )
                case .action(let action):
                    ActivityView(
                        title: "Received from GPT",
                        description: action.name,
                        startTime: nil
                    )
                }
            }
        }.background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.1))
        }
    }
}

struct ActivityView: View {
    @EnvironmentObject var ticker: CADisplayLinkTicker

    let title: String
    let description: String
    let startTime: Date?

    private var duration: TimeInterval? {
        if let startTime {
            return Date.now.timeIntervalSince(startTime)
        } else {
            return nil
        }
    }

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                    Text(description)
                }
                Spacer()
                if let duration {
                    Text(String(format: "%.1f sec", duration))
                }
            }.padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
        }
    }
}

class CADisplayLinkTicker: ObservableObject {
    static var shared = CADisplayLinkTicker()

    @Published var tick: Int = 0
    private var displayLink: CADisplayLink?

    init() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateDuration))
        displayLink?.add(to: .current, forMode: .default)
    }

    @objc private func updateDuration() {
        tick += 1
    }
}
