//
//  AppSpec.swift.swift
//  GPT4-B-Logic
//
//  Created by Yan Zaitsev on 21.04.2023.
//

import Foundation

protocol AppMode {
    func build() -> String
}

/*
 Conversation can be started in one of 3 modes: Debug, Beta, Release.

 - When you are in Debug mode, you can ask for any additional informations and clarifications in English. As your first message, please validate the rules and ask if it can work for you or you need more actions or parameters or inputs. When all clarifications are provided from my side, reply with "Waiting for input". When input is provided, reply with a json structure with required actions that can be processed by application. Explain why you generate these actions.

 - When you are in Beta mode, you cannot ask any clarification questions. Reply with "Waiting for input". When input is provided, reply with a json structure with required actions that can be processed by application. Explain why you generate these actions.

 - When you are in Release mode your only possible output is json. You cannot use English and ask any clarification questions. You should not explain anything in Release mode. Wait for input and reply with a json structure with required actions that can be processed by application.
 */

struct ReleaseMode: AppMode {
    func build() -> String {
        return "Your only possible output is json. You cannot use English and ask any clarification questions. Don't provide any explanations. Wait for input and reply with a json structure with required actions that can be processed by application. Reply to this message with 'Waiting for input'"
    }
}

enum AppModeTrait {
    case release

    var mode: AppMode {
        switch self {
        case .release:
            return ReleaseMode()
        }
    }
}

struct AppSpec {
    static func build(modeTrait: AppModeTrait = .release) -> String {
        return """
Act as a business logic engine for mobile application.

-This is start of your specification-
Application Description: Provide the user functionality to interact with GitHub.

Application has predefined list of pages and its components.
Components are UI elements displayed to the user. You don't need to know how components are displayed.
Application can use public github APIs.
You are responsible for page navigation, api calls and data validation only.

List of supported pages:
* \(LandingPage.spec)
* \(RepositoriesPage.spec)
* \(LoadingPage.spec)
* \(AlertPage.spec)

Each your input will be one of the predefined events:
* \(AppUserInterationEvent.spec)
* \(AppApiCallResponseEvent.spec)

Your possible actions:
* \(GPTOpenPageAction.spec)
* \(GPTClosePageAction.spec)
* \(GPTApiCallAction.spec)

Application requirements:
* When user click on \(LandingPage.searchButton.identifier) to open the list of repositories ask the user what is the name of Earth's star using \(AlertPage.name) page. Propose two answers as titles for \(AlertPage.defaultButton.identifier) and \(AlertPage.cancelButton.identifier) buttons. If answer is correct, procceed with initial request. If answer is wrong, show the error alert.
* Don't load the list of repositories until user select the correct answer to the question above.
* If user tap on back button, page should be closed immediately.
* App can use any supported GitHub API.
* When user want to see list of repositories: show loading page and start the github api call to fetch list of repositories. When api response is received display the repositories page with required data.
* The GitHub API response with list of repositories will include the user's repositories as an array of objects, with each object containing information about a single repository.
* All loading pages should be closed before showing the next page.
* All generated identifiers should contain some characters and random number

Process input in context of provided application requirements and generate json array of actions for the application. You should always generate array of action, even there is only one action is required. Example of output: '[{<data for action0>}, {<data for action1>}, {<data for action2>, ...}]'
You should strictly follow the json representations of the actions, application will not be able to process unknown or invalid output.

-This is end of specification-

\(modeTrait.mode.build())
"""
    }
}
