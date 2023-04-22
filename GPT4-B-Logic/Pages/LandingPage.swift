//
//  LandingPageView.swift
//  GPT4-B-Logic
//
//  Created by Yan Zaitsev on 21.04.2023.
//

import Foundation
import SwiftUI

struct LandingPage: AppPage {
    let id: String = "landing"
    
    var view: AnyView {
        return AnyView(LandingPageView())
    }
}

extension LandingPage {
    static let name = String(describing: Self.self)

    static let usernameTextField = AppPageComponent(
        identifier: "username_textfield",
        description: "text field to enter github user name")

    static let searchButton = AppPageComponent(
        identifier: "search_button",
        description: "button to see list of repositories")
    
    static var spec: String = """
Name: \(name)
Description: Starting page of application
<start of components>
- \(usernameTextField.spec)
- \(searchButton.spec)
<end of components>
Parameters: nothing
"""
}

struct LandingPageView: View {
    @EnvironmentObject var gpt: GPT
    @EnvironmentObject var appState: AppState
    private let usernameKey = "\(LandingPage.name)>\(LandingPage.usernameTextField.identifier)"
    @State private var username: String = ""

    var body: some View {
        VStack(spacing: 20) {
            if gpt.token == nil {
                GPT4TokenView() {
                    gpt.token = $0
                    Task {
                        await gpt.start()
                    }
                }
            } else {
                VStack(spacing: 20) {
                    TextField("Enter GitHub Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .textContentType(.username)
                        .autocorrectionDisabled()
                        .keyboardType(.asciiCapable)
                        .padding()
                        .onAppear {
                            username = UserDefaults.standard.string(forKey: usernameKey) ?? ""
                        }

                    Button(action: {
                        Task {
                            UserDefaults.standard.set(username, forKey: usernameKey)
                            UserDefaults.standard.synchronize()
                            await gpt.sendEvent(
                                event: AppUserInterationEvent(
                                    page: LandingPage.name,
                                    parameters: [LandingPage.usernameTextField.identifier: username],
                                    interation: "User clicked \(LandingPage.searchButton.identifier)"
                                ),
                                appState: appState
                            )
                        }
                    }, label: {
                        Text("See Repositories")
                    })
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}
struct GPT4TokenView: View {
    @State private var token: String
    private let onSave: ((String) -> Void)?

    init(onSave: ((String) -> Void)? = nil) {
        // Read previous value from UserDefaults
        self.token = UserDefaults.standard.string(forKey: "AuthToken") ?? ""
        self.onSave = onSave
    }

    var body: some View {
        VStack(spacing: 20) {
            SecureField("Enter GPT-4 Token", text: $token)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                UserDefaults.standard.set(token, forKey: "AuthToken")
                onSave?(token)
            }, label: {
                Text("Save")
            })
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
        }
        .padding()
    }
}

struct LangingPageView_Previews: PreviewProvider {
    static var previews: some View {
        LandingPageView()
    }
}
