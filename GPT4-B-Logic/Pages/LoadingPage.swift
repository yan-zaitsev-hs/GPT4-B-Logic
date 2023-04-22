//
//  LoadingPage.swift
//  GPT4-B-Logic
//
//  Created by Yan Zaitsev on 21.04.2023.
//

import Foundation
import SwiftUI

struct LoadingPageData: Codable {
    let description: String
}

struct LoadingPage: AppPage {
    let id: String
    let data: LoadingPageData

    var view: AnyView {
        return AnyView(LoadingPageView(page: self))
    }
}

extension LoadingPage {
    static let name = String(describing: Self.self)

    static let descriptionLabel = AppPageComponent(
        identifier: "description_label",
        description: "Details of this loading activity."
    )

    static let loadingIndicator = AppPageComponent(
        identifier: "loading_indicator",
        description: "Loading indicator"
    )

    static let backButton = AppPageComponent(
        identifier: "back_button",
        description: "Back button"
    )

    static var spec: String {
        let example = LoadingPageData(
            description: "<Provide detailed description why loading is displayed and what we are waiting for?>"
        )
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let json = String(data: try! jsonEncoder.encode(example), encoding: .utf8)!
        return """
Name: \(name)
Description: Show loading indicator while we are waiting for anything.
<start of components>
- \(descriptionLabel.spec)
- \(loadingIndicator.spec)
- \(backButton.spec)
<end of components>
Acceptable parameters: description string
<start of parameters json representation>
\(json)
<end of parameters json representation>
"""
    }
}

struct LoadingPageView: View {
    @EnvironmentObject var gpt: GPT
    @EnvironmentObject var appState: AppState
    @State var isLoading: Bool = false
    let page: LoadingPage

    var body: some View {
        ZStack {
            // Background color
            Color.white

            VStack(alignment: .center, spacing: 0) {
                Spacer()
                Text(page.data.description)
                    .font(.body)
                if isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2.0, anchor: .center)
                }
                Spacer()
                Button("Go Back") {
                    Task {
                        await gpt.sendEvent(
                            event:
                                AppUserInterationEvent(
                                    page: page.id,
                                    parameters: [:],
                                    interation: "User clicked \(LoadingPage.backButton.identifier)"),
                            appState: appState
                        )
                    }
                }

                Spacer()
            }
        }
        .opacity(isLoading ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.3))
        .onAppear {
            isLoading = true
        }
    }
}
