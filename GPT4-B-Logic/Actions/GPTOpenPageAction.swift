//
//  PageNavigationAction.swift
//  GPT4-B-Logic
//
//  Created by Yan Zaitsev on 21.04.2023.
//

import Foundation

struct ExamplePageData: Codable {
    let data: String
}

struct AppPageData: Codable {
    let repositoriesPageData: RepositoriesPageData?
    let loadingPageData: LoadingPageData?
    let alertPageData: AlertPageData?
}

struct GPTOpenPageAction: Codable {
    static var name = String(describing: Self.self)
    var action = Self.name
    let page_id: String
    let parameters: AppPageData
}

extension GPTOpenPageAction {
    static var spec: String {
        let example = Self(
            page_id: "<Your generated unique string identifier. You will use it to manipulate the page in future.>",
            parameters: AppPageData(repositoriesPageData: nil, loadingPageData: nil, alertPageData: nil)
        )
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let json = String(data: try! jsonEncoder.encode(example), encoding: .utf8)!

        return """
Name: '\(example.action)'
Description: push new page to navigation stack of application.
<start of json representation>
\(json)
<end of json representation>
property 'parameters' should contain one of the next properties:
- key: 'repositoriesPageData', value: data for '\(RepositoriesPage.name)' page
- key: 'loadingPageData', value: data for '\(LoadingPage.name)' page
- key: 'alertPageData', value: data for '\(AlertPage.name)' page
"""
    }
}
