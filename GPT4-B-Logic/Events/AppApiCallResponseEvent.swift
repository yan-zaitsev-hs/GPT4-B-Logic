//
//  AppApiCallResponseAction.swift
//  GPT4-B-Logic
//
//  Created by Yan Zaitsev on 21.04.2023.
//

import Foundation
import OpenAIKit

struct AppApiCallResponseEvent {
    let action = String(describing: Self.self)
    let requestId: String
    let response: String
}
//
extension AppApiCallResponseEvent: AppEvent {
    var eventName: String {
        return action
    }

    var description: String {
        return "Api response received. Size = \(response.count) bytes."
    }

    func createGPTMessage() -> Chat.Message {
        return .system(content: """
        Event='\(action)'
        request_id='\(requestId)'
        <start of response>
        \(response)
        <end of response>
        """)
    }

    static var spec: String {
        let example = Self(
            requestId: "<request id of api call>",
            response: "<string representation of the api response>")

        return """
        Name: \(example.action)
        Description: Api response is received
        <Start of example>
        \(example.createGPTMessage().content)
        <End of example>
        """
    }
}
