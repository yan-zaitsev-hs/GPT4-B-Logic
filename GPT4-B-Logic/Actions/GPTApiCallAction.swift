//
//  ApiCallAction.swift
//  GPT4-B-Logic
//
//  Created by Yan Zaitsev on 21.04.2023.
//

import Foundation

struct GPTApiCallAction: Codable {
    static var name = String(describing: Self.self)
    var action = Self.name
    let method: String
    let url: String
    let request_id: String
}

extension GPTApiCallAction {
    static var spec: String {
        let example = Self(
            method: "<http method, can be GET or POST>",
            url: "<full url address of requisted resource>",
            request_id: "<Your generated unique string identifier. Api response will contain this identifier>"
        )
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let json = String(data: try! jsonEncoder.encode(example), encoding: .utf8)!

        return """
Name: '\(example.action)'
Description: Call the REST api with provided parameters.
<start of json representation>
\(json)
<end of json representation>
"""
    }
}
