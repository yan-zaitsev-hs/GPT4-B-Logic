//
//  AppUserInterationAction.swift
//  GPT4-B-Logic
//
//  Created by Yan Zaitsev on 21.04.2023.
//

import Foundation
import OpenAIKit

struct AppUserInterationEvent {
    let action = String(describing: Self.self)
    let page: String
    let parameters: [String: String]
    let interation: String
}

extension AppUserInterationEvent: AppEvent {
    func createGPTMessage() -> Chat.Message {
        return .user(content: """
        Event='\(action)'
        Page='\(page)'
        <start of parameters>
        \(parameters.enumerated().map { (index, item) in
            "\(item.key)='\(item.value)'" }.joined(separator: "\n")
        )
        <end of parameters>
        Interaction: \(interation)
        """)
    }

    static var spec: String {
        let example = Self(
            page: "<page name or page id>",
            parameters: ["<Parameter0>": "<Value0>", "<ParameterN>": "<ValueN>"],
            interation: "<user interaction description>")

        return """
        Name: \(example.action)
        Description: User interacted with application
        <Start of example>
        \(example.createGPTMessage().content)
        <End of example>
        """
    }
}
