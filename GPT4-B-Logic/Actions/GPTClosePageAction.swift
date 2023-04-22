//
//  ClosePageAction.swift
//  GPT4-B-Logic
//
//  Created by Yan Zaitsev on 21.04.2023.
//

import Foundation

struct GPTClosePageAction: Codable {
    static var name = String(describing: Self.self)
    var action = Self.name
    var page_id: String
}

extension GPTClosePageAction {
    static var spec: String {
        let example = Self(
            page_id: "<page identifier of closing page. This page will be removed from navigation stack>"
        )
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let json = String(data: try! jsonEncoder.encode(example), encoding: .utf8)!

        return """
Name: '\(example.action)'
Description: Close the page.
<start of json representation>
\(json)
<end of json representation>
"""
    }
}
