//
//  GPTRequest.swift
//  GPT4-B-Logic
//
//  Created by Yan Zaitsev on 23.04.2023.
//

import Foundation

class GPTHelperEvent {
    private let helper: GPTHelper
    let id: UUID
    let createdAt: Date
    let eventName: String
    let description: String

    init(helper: GPTHelper, id: UUID = .init(), createdAt: Date = .now, eventName: String, description: String) {
        self.helper = helper
        self.id = id
        self.createdAt = createdAt
        self.eventName = eventName
        self.description = description
    }

    func finish() {
        let helperInstance = helper
        let identifier = id
        Task { @MainActor in
            helperInstance.finishActivity(id: identifier)
        }
    }

    deinit {
        finish()
    }
}

struct GPTHelperAction {
    var id: UUID = .init()
    var createdAt: Date = .now
    let name: String
}

enum GPTHelperActivity: Identifiable {
    case event(GPTHelperEvent)
    case action(GPTHelperAction)

    var id: UUID {
        switch self {
        case .event(let data):
            return data.id
        case .action(let data):
            return data.id
        }
    }
}

@MainActor
class GPTHelper: ObservableObject {
    static var shared = GPTHelper()
    
    @Published var activities = [GPTHelperActivity]()

    init(activities: [GPTHelperActivity] = [GPTHelperActivity]()) {
        self.activities = activities
    }

    func gptStarted() -> GPTHelperEvent {
        let event = GPTHelperEvent(
            helper: self,
            eventName: "GPT starting...",
            description: "Sending AppSpec as a prompt for validation"
        )
        activities.append(.event(event))
        return event
    }

    func addEvent(_ event: AppEvent) -> GPTHelperEvent {
        let event = GPTHelperEvent(
            helper: self,
            eventName: event.eventName,
            description: event.description)
        activities.append(.event(event))
        return event
    }

    func finishActivity(id: UUID) {
        activities.removeAll { $0.id == id }
    }

    func addAction(name: String) {
        let action = GPTHelperAction(name: name)
        activities.append(.action(action))
        Task { @MainActor in
            try await Task.sleep(nanoseconds: 5_000_000_000)
            finishActivity(id: action.id)
        }
    }
}
