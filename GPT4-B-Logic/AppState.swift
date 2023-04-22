//
//  AppState.swift
//  GPT4-B-Logic
//
//  Created by Yan Zaitsev on 21.04.2023.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var pages: [any AppPage] = [LandingPage()]

    func processAction(_ action: GPTAction, gpt: GPT) {
        switch action {
        case .openPage(let actionData):
            if let data = actionData.parameters.repositoriesPageData {
                let page = RepositoriesPage(id: actionData.page_id, data: data)
                pages.append(page)
            } else if let data = actionData.parameters.loadingPageData {
                let page = LoadingPage(id: actionData.page_id, data: data)
                pages.append(page)
            } else if let data = actionData.parameters.alertPageData {
                let page = AlertPage(id: actionData.page_id, data: data)
                pages.append(page)
            }
            break
        case .closePage(let actionData):
            pages = pages.filter { $0.id != actionData.page_id }
            break
        case .apiCall(let actionData):
            Task {
                var request = URLRequest(url: URL(string: actionData.url)!)
                request.httpMethod = actionData.method
                let (data, _) = try! await URLSession.shared.data(for: request)
                let body = String(data: data, encoding: .utf8)!
                do {
                    let simplifier = ApiResponseSimplifier(request: actionData, response: data)
                    if let simplifiedBody = try simplifier.simplify() {
                        await gpt.sendEvent(event: AppApiCallResponseEvent(requestId: actionData.request_id, response: simplifiedBody), appState: self)
                        return
                    }
                } catch {
                    print("[error] Cannot simplify response \(body)")
                    print("[error] \(error)")
                }

                // Fallback
                await gpt.sendEvent(event: AppApiCallResponseEvent(requestId: actionData.request_id, response: body), appState: self)
            }
        }
    }
}

struct ApiResponseSimplifier {
    let request: GPTApiCallAction
    let response: Data

    // GPT api cannot produce huge responses of github api
    func simplify() throws -> String? {
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if request.url.hasSuffix("/repos") {
            var data = try decoder.decode(GitHubReposResponse.self, from: response)
            if data.count > 5 {
                data = Array(data.dropLast(data.count - 5))
            }
            let encoded = try encoder.encode(data)
            return String(data: encoded, encoding: .utf8)
        } else {
            return nil
        }
    }

    typealias GitHubReposResponse = [GitHubApiRepository]

    struct GitHubApiRepository: Codable {
        let id: Int?
        let name: String?
        let description: String?
        let url: URL?
        let watchers: Int?
    }
}

struct AppPageComponent {
    let identifier: String
    let description: String

    var spec: String { """
component: '\(identifier)', description: \(description)
"""
    }
}

protocol AppPage {
    var id: String { get }
    var view: AnyView { get }
}
