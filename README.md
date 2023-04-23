# GPT3-B-Logic
Use GPT 3.5-turbo as runtime business logic for iOS app

p.s. version was downgraded from GPT 4 to GPT 3.5-turbo

Example video (v1), please be patient. GPT api takes 5-25sec to generate a response:
https://user-images.githubusercontent.com/104061716/233751103-ccc82a5b-b6ff-497f-acb5-033452fc40df.mp4

Native iOS application uses GPT3.5-turbo as business logic engine. 
All navigation rules are specified in English in `AppSpec.swift`

App generate initial promt and define the communication protocol between App and GPT. 
GPT was able to understand app events (user interactions & api responses). 
GPT automatically generated error message when api call failed.

GPT had a problem to close correct page sometimes. The complete generated promt of app is at the end of README.md

The example what GPT is able to do is here. I put the following requirement in to the spec (v2):
```
* When user click on \(LandingPage.searchButton.identifier) to open the list of repositories ask the user what is the name of Earth's star using \(AlertPage.name) page. Propose two answers as titles for \(AlertPage.defaultButton.identifier) and \(AlertPage.cancelButton.identifier) buttons. If answer is correct, procceed with initial request. If answer is wrong, show the error.
```
And there is a video on how it is working: 
https://user-images.githubusercontent.com/104061716/233860415-d64413a7-a7ab-4361-a1d9-9ac67845d7d6.mp4
I did not code any string, questions or logic in the app. The only thing is `AppSpec.swift` promt.

There is an example of commnunication:
<initial prompt>

GPT: `Waiting for input`
App: 
```
Event='AppUserInterationEvent'
Page='LandingPage'
<start of parameters>
username_textfield='zaitsevyan'
<end of parameters>
Interaction: User clicked search_button
```

GPT:
```
[
  {
    "page_id" : "loading_page_123",
    "action" : "GPTOpenPageAction",
    "parameters" : {
      "loadingPageData" : {
        "description" : "Fetching repositories..."
      }
    }
  },
  {
    "method" : "GET",
    "request_id" : "repositories_request_123",
    "url" : "https:\/\/api.github.com\/users\/zaitsevyan\/repos",
    "action" : "GPTApiCallAction"
  }
]

```

App (api response is simplified by the app. gpt cannot process hude github api responses. See `ApiResponseSimplifier` in `AppState.swift`):
```
Event='AppApiCallResponseEvent'
request_id='repositories_request_123'
<start of response>
[
  {
    "watchers" : 0,
    "id" : 20158488,
    "name" : "angular-typeahead",
    "description" : "A very simple Angular.js wrapper around the Twitter Typeahead library.",
    "url" : "https:\/\/api.github.com\/repos\/zaitsevyan\/angular-typeahead"
  },
  {
    "watchers" : 1,
    "id" : 53786832,
    "name" : "AsyncAwaitClientServer",
    "description" : "C#",
    "url" : "https:\/\/api.github.com\/repos\/zaitsevyan\/AsyncAwaitClientServer"
  },
  {
    "id" : 1219059,
    "name" : "Battle-simulation",
    "url" : "https:\/\/api.github.com\/repos\/zaitsevyan\/Battle-simulation",
    "watchers" : 1
  },
  {
    "watchers" : 0,
    "id" : 7888664,
    "name" : "BuildCraft",
    "description" : "BuildCraft",
    "url" : "https:\/\/api.github.com\/repos\/zaitsevyan\/BuildCraft"
  },
  {
    "id" : 449811594,
    "name" : "firs",
    "url" : "https:\/\/api.github.com\/repos\/zaitsevyan\/firs",
    "watchers" : 0
  }
]
<end of response>
```

GPT:
```
[
  {
    "page_id" : "repositories_page_123",
    "action" : "GPTOpenPageAction",
    "parameters" : {
      "repositoriesPageData" : {
        "repositories" : [
          {
            "watchersCount" : "0",
            "id" : "20158488",
            "name" : "angular-typeahead",
            "description" : "A very simple Angular.js wrapper around the Twitter Typeahead library."
          },
          {
            "watchersCount" : "1",
            "id" : "53786832",
            "name" : "AsyncAwaitClientServer",
            "description" : "C#"
          },
          {
            "watchersCount" : "1",
            "id" : "1219059",
            "name" : "Battle-simulation",
            "description" : null
          },
          {
            "watchersCount" : "0",
            "id" : "7888664",
            "name" : "BuildCraft",
            "description" : "BuildCraft"
          },
          {
            "watchersCount" : "0",
            "id" : "449811594",
            "name" : "firs",
            "description" : null
          }
        ]
      }
    }
  }
]
```

App:
```
Event='AppUserInterationEvent'
Page='repositories_page_123'
<start of parameters>

<end of parameters>
Interaction: User clicked back_button
[info]: Actions received
[
  {
    "page_id" : "repositories_page_123",
    "action" : "GPTClosePageAction"
  }
]
```
GPT:
```
Event='AppUserInterationEvent'
Page='loading_page_123'
<start of parameters>

<end of parameters>
Interaction: User clicked back_button
[info]: Actions received
[
  {
    "page_id" : "loading_page_123",
    "action" : "GPTClosePageAction"
  }
]
```
App:
```
Event='AppUserInterationEvent'
Page='LandingPage'
<start of parameters>
username_textfield='kf$'
<end of parameters>
Interaction: User clicked search_button
```

GPT:
```
[
  {
    "page_id" : "alert_page_123",
    "action" : "GPTOpenPageAction",
    "parameters" : {
      "alertPageData" : {
        "message" : "Please enter a valid GitHub username.",
        "title" : "Invalid Username",
        "defaultButtonTitle" : "OK"
      }
    }
  }
]
```

App:
```
Event='AppUserInterationEvent'
Page='alert_page_123'
<start of parameters>

<end of parameters>
Interaction: User clicked default_button
```

GPT:
```
[
  {
    "page_id" : "alert_page_123",
    "action" : "GPTClosePageAction"
  }
]
```


Generated initial promt (`AppSpec.swift`):
```
Act as a business logic engine for mobile application.

-This is start of your specification-
Application Description: Provide the user functionality to interact with GitHub.

Application has predefined list of pages and its components.
Components are UI elements displayed to the user. You don't need to know how components are displayed.
Application can use public github APIs.
You are responsible for page navigation, api calls and data validation only.

List of supported pages:
* Name: LandingPage
Description: Starting page of application
<start of components>
- component: 'username_textfield', description: text field to enter github user name
- component: 'search_button', description: button to see list of repositories
<end of components>
Parameters: nothing
* Name: RepositoriesPage
Description: Starting page of application
<start of components>
- component: 'list_view', description: Scrollable list view of repositories. Each item is represented using 'repository_cell' component
- component: 'repository_cell', description: Single cell to represent repository record.
- component: 'back_button', description: Back button
<end of components>
Acceptable parameters: array of repository records
<start of parameters json representation>
{
  "repositories" : [
    {
      "watchersCount" : "<number of watchers. String value>",
      "id" : "<unique identifier of repository. String value>",
      "name" : "<repository name>",
      "description" : "<repository description. Optional value>"
    }
  ]
}
<end of parameters json representation>
* Name: LoadingPage
Description: Show loading indicator while we are waiting for anything.
<start of components>
- component: 'description_label', description: Details of this loading activity.
- component: 'loading_indicator', description: Loading indicator
- component: 'back_button', description: Back button
<end of components>
Acceptable parameters: description string
<start of parameters json representation>
{
  "description" : "<Provide detailed description why loading is displayed and what we are waiting for?>"
}
<end of parameters json representation>
* Name: AlertPage
Description: Show full screen alert to inform the user.
<start of components>
- component: 'title_label', description: Title of the alert view
- component: 'message_label', description: Details of the alert
- component: 'default_button', description: Default button of the alert. It is customizable.
- component: 'cancel_button', description: Cancel button. It is customizable. It is optional button.
<end of components>
Acceptable parameters: data to show alert
<start of parameters json representation>
{
  "message" : "<Detailed message>",
  "title" : "<Title of this alert>",
  "defaultButtonTitle" : "<Title of default button>",
  "cancelButtonTitle" : "<Title of cancel button. It is optional>"
}
<end of parameters json representation>

Each your input will be one of the predefined events:
* Name: AppUserInterationEvent
Description: User interacted with application
<Start of example>
Event='AppUserInterationEvent'
Page='<page name or page id>'
<start of parameters>
<Parameter0>='<Value0>'
<ParameterN>='<ValueN>'
<end of parameters>
Interaction: <user interaction description>
<End of example>
* Name: AppApiCallResponseEvent
Description: Api response is received
<Start of example>
Event='AppApiCallResponseEvent'
request_id='<request id of api call>'
<start of response>
<string representation of the api response>
<end of response>
<End of example>

Your possible actions:
* Name: 'GPTOpenPageAction'
Description: push new page to navigation stack of application.
<start of json representation>
{
  "page_id" : "<Your generated unique string identifier. You will use it to manipulate the page in future.>",
  "action" : "GPTOpenPageAction",
  "parameters" : {

  }
}
<end of json representation>
property 'parameters' should contain one of the next properties:
- key: 'repositoriesPageData', value: data for 'RepositoriesPage' page
- key: 'loadingPageData', value: data for 'LoadingPage' page
- key: 'alertPageData', value: data for 'AlertPage' page
* Name: 'GPTClosePageAction'
Description: Close the page.
<start of json representation>
{
  "page_id" : "<page identifier of closing page. This page will be removed from navigation stack>",
  "action" : "GPTClosePageAction"
}
<end of json representation>
* Name: 'GPTApiCallAction'
Description: Call the REST api with provided parameters.
<start of json representation>
{
  "method" : "<http method, can be GET or POST>",
  "request_id" : "<Your generated unique string identifier. Api response will contain this identifier>",
  "url" : "<full url address of requisted resource>",
  "action" : "GPTApiCallAction"
}
<end of json representation>

Application requirements:
* When user click on search_button to open the list of repositories ask the user what is the name of Earth's star using AlertPage page. Propose two answers as titles for default_button and cancel_button buttons. If answer is correct, procceed with initial request. If answer is wrong, show the error.
* If user tap on back button, page should be closed immediately.
* App can use any supported GitHub API.
* When user want to see list of repositories: show loading page and start the github api call to fetch list of repositories. When api response is received display the repositories page with required data.
* The GitHub API response with list of repositories will include the user's repositories as an array of objects, with each object containing information about a single repository.
* All loading pages should be closed before showing the next page.
* All generated identifiers should contain some characters and random number

Process input in context of provided application requirements and generate json array of actions for the application. You should always generate array of action, even there is only one action is required. Example of output: '[{<data for action0>}, {<data for action1>}, {<data for action2>, ...}]'
You should strictly follow the json representations of the actions, application will not be able to process unknown or invalid output.

-This is end of specification-

Your only possible output is json. You cannot use English and ask any clarification questions. Don't provide any explanations. Wait for input and reply with a json structure with required actions that can be processed by application. Reply to this message with 'Waiting for input'
```
