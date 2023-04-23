//
//  GPT4.swift
//  GPT4-B-Logic
//
//  Created by Yan Zaitsev on 21.04.2023.
//

import Foundation
import OpenAIKit
import NIO
import AsyncHTTPClient

class GPT: ObservableObject {
    let appSpec = AppSpec.build(modeTrait: .release)
    let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)

    deinit {
        // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
        try? httpClient.syncShutdown()
    }
    
    @Published var token: String?

    lazy var firstMessage: Chat.Message = .system(content: appSpec)
    var messages: [Chat.Message] = []
    var client: OpenAIKit.Client?


    init() {
        print("Final app specification: ")
        print(appSpec)
    }

    func start() async {
        let startPRequest = await GPTHelper.shared.gptStarted()
        defer {
            startPRequest.finish()
        }
        do {
            guard let token = token else {
                fatalError("No token or promt provided")
            }

            let configuration = Configuration(apiKey: token)

            client = OpenAIKit.Client(httpClient: httpClient, configuration: configuration)

            let result = try await client!.chats.create(
                model: Model.GPT3.gpt3_5Turbo,
                messages: [firstMessage],
                temperature: 0,
                maxTokens: 100
            )

            dump(result)
            let response = result.choices.first!.message
            if !response.content.contains("Waiting for input") {
                print("[error]: invalid first response")
            }
            messages.append(response)
        } catch {
            print("[error]: \(error)")
        }
    }

    func sendEvent(event: AppEvent, appState: AppState) async {
        let eventPRequest = await GPTHelper.shared.addEvent(event)
        defer {
            eventPRequest.finish()
        }
        do {
            guard let client = client else {
                fatalError("No client started")
            }
            let message = event.createGPTMessage()
            messages.append(message)
//            dump(message)
            let promts = [firstMessage] + messages

            print("[info]: Sending...")
            print(message.content)

            let result = try await client.chats.create(
                model: Model.GPT3.gpt3_5Turbo,
                messages: promts,
                temperature: 0,
                maxTokens: 1000
            )

//            dump(result)

            let response = result.choices.first!.message
            messages.append(response)

            let jsonString = response.content
            if let jsonData = jsonString.data(using: .utf8) {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    print("[info]: Actions received")
                    print(String(data: try! JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]), encoding: .utf8)!)
                    if let array = jsonObject as? [[String: Any]] {
                        array.forEach { try? processAction(json: $0, appState: appState) }
                    } else if let object = jsonObject as? [String: Any] {
                        try? processAction(json: object, appState: appState)
                    } else {
                        print("[error]: unknown JSON format \(jsonObject)")
                    }
                } catch {
                    print("[error]: decoding JSON failed \(error)")
                }
            }
        } catch {
            print("[error]: \(error)")
        }
    }

    private func processAction(json: [String: Any], appState: AppState) throws {
        guard let action = json["action"] as? String else {
            print("[error]: no action property \(json)")
            return
        }

        let jsonData = try JSONSerialization.data(withJSONObject: json)
        let decoder = JSONDecoder()

        Task {
            do {
                await GPTHelper.shared.addAction(name: action)
                switch action {
                case GPTOpenPageAction.name:
                    let action = try decoder.decode(GPTOpenPageAction.self, from: jsonData)
                    await appState.processAction(.openPage(action), gpt: self)
                case GPTClosePageAction.name:
                    let action = try decoder.decode(GPTClosePageAction.self, from: jsonData)
                    await appState.processAction(.closePage(action), gpt: self)
                case GPTApiCallAction.name:
                    let action = try decoder.decode(GPTApiCallAction.self, from: jsonData)
                    await appState.processAction(.apiCall(action), gpt: self)

                default:
                    print("[error]: unknown action \(json)")
                    return
                }
            } catch {
                print("[error]: unknown error \(error)")
            }
        }
    }

    private static func readInitialPrompt() -> String? {
        guard let filePath = Bundle.main.path(forResource: "AppSpec", ofType: "txt") else { return nil }
        do {
            let contents = try String(contentsOfFile: filePath)
            return contents
        } catch {
            print("Error: Could not read initial prompt from file")
            return nil
        }
    }
}
