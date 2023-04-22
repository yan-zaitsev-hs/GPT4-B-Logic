//
//  GPTAction.swift
//  GPT4-B-Logic
//
//  Created by Yan Zaitsev on 21.04.2023.
//

import Foundation

enum GPTAction {
    case openPage(GPTOpenPageAction)
    case closePage(GPTClosePageAction)
    case apiCall(GPTApiCallAction)
}
