//
//  LoadingPage.swift
//  GPT4-B-Logic
//
//  Created by Yan Zaitsev on 21.04.2023.
//

import Foundation
import SwiftUI

struct AlertPageData: Codable {
    let title: String
    let message: String
    let defaultButtonTitle: String
    let cancelButtonTitle: String?
}

struct AlertPage: AppPage {
    let id: String
    let data: AlertPageData

    var view: AnyView {
        return AnyView(AlertPageView(
            page: self
        ))
    }
}

extension AlertPage {
    static let name = String(describing: Self.self)

    static let titleLabel = AppPageComponent(
        identifier: "title_label",
        description: "Title of the alert view"
    )

    static let messageLabel = AppPageComponent(
        identifier: "message_label",
        description: "Details of the alert"
    )

    static let defaultButton = AppPageComponent(
        identifier: "default_button",
        description: "Default button of the alert. It is customizable."
    )

    static let cancelButton = AppPageComponent(
        identifier: "cancel_button",
        description: "Cancel button. It is customizable. It is optional button."
    )

    static var spec: String {
        let example = AlertPageData(
            title: "<Title of this alert>",
            message: "<Detailed message>",
            defaultButtonTitle: "<Title of default button>",
            cancelButtonTitle: "<Title of cancel button. It is optional>"
        )
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let json = String(data: try! jsonEncoder.encode(example), encoding: .utf8)!
        return """
Name: \(name)
Description: Show full screen alert to inform the user.
<start of components>
- \(titleLabel.spec)
- \(messageLabel.spec)
- \(defaultButton.spec)
- \(cancelButton.spec)
<end of components>
Acceptable parameters: data to show alert
<start of parameters json representation>
\(json)
<end of parameters json representation>
"""
    }
}

struct AlertPageView: View {
    @EnvironmentObject var gpt: GPT
    @EnvironmentObject var appState: AppState
    let page: AlertPage

    var body: some View {
        VStack {
            Text(page.data.title)
                .font(.headline)
                .padding()
            Text(page.data.message)
                .multilineTextAlignment(.center)
                .padding()
            HStack {
                Spacer()
                Button(page.data.defaultButtonTitle) {
                    Task {
                        await gpt.sendEvent(
                            event: AppUserInterationEvent(
                                page: page.id,
                                parameters: [:],
                                interation: "User clicked \(AlertPage.defaultButton.identifier)"),
                            appState: appState)
                    }
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                if let cancelButton = page.data.cancelButtonTitle {
                    Button(cancelButton) {
                        Task {
                            await gpt.sendEvent(
                                event: AppUserInterationEvent(
                                    page: page.id,
                                    parameters: [:],
                                    interation: "User clicked \(AlertPage.cancelButton.identifier)"),
                                appState: appState)
                        }
                    }
                    .padding()
                    .foregroundColor(.blue)
                }
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}
