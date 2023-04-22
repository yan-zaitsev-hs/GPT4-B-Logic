//
//  AppInteraction.swift
//  GPT4-B-Logic
//
//  Created by Yan Zaitsev on 21.04.2023.
//

import Foundation
import OpenAIKit

protocol AppEvent {
    func createGPTMessage() -> Chat.Message
}
