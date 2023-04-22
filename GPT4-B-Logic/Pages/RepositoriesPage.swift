//
//  ListOrRepositoriesPageView.swift
//  GPT4-B-Logic
//
//  Created by Yan Zaitsev on 21.04.2023.
//

import Foundation
import SwiftUI

struct Repository: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let watchersCount: String
}

struct RepositoriesPageData: Codable {
    let repositories: [Repository]
}

struct RepositoriesPage: AppPage {
    let id: String
    let data: RepositoriesPageData

    var view: AnyView {
        return AnyView(RepositoriesPageView(page: self))
    }
}

extension RepositoriesPage {
    static let name = String(describing: Self.self)

    static let listView = AppPageComponent(
        identifier: "list_view",
        description: "Scrollable list view of repositories. Each item is represented using '\(repositoryCell.identifier)' component"
    )

    static let repositoryCell = AppPageComponent(
        identifier: "repository_cell",
        description: "Single cell to represent repository record."
    )

    static let backButton = AppPageComponent(
        identifier: "back_button",
        description: "Back button"
    )

    static var spec: String {
        let example = RepositoriesPageData(
            repositories: [
                Repository(
                    id: "<unique identifier of repository. String value>",
                    name: "<repository name>",
                    description: "<repository description. Optional value>",
                    watchersCount: "<number of watchers. String value>"
                )
            ]
        )
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let json = String(data: try! jsonEncoder.encode(example), encoding: .utf8)!
        return """
Name: \(name)
Description: Starting page of application
<start of components>
- \(listView.spec)
- \(repositoryCell.spec)
- \(backButton.spec)
<end of components>
Acceptable parameters: array of repository records
<start of parameters json representation>
\(json)
<end of parameters json representation>
"""
    }
}

struct RepositoryCell: View {
    let repository: Repository

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(repository.name)
                .font(.headline)
            Text(repository.description ?? "")
                .font(.subheadline)
                .foregroundColor(.gray)
            HStack {
                Image(systemName: "eye")
                Text(repository.watchersCount)
            }
            .foregroundColor(.gray)
        }
    }
}

struct RepositoriesPageView: View {
    @EnvironmentObject var gpt: GPT
    @EnvironmentObject var appState: AppState
    let page: RepositoriesPage

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            List(page.data.repositories) { repository in
                RepositoryCell(repository: repository)
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
        }
        .navigationTitle("Repositories")
    }
}
