# RestLikeKit
![Tests](https://github.com/andyfinnell/RestLikeKit/workflows/Tests/badge.svg) [![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

RestLikeKit is my personal Swift API for building clients for REST-like APIs. The goal of RestLikeKit is to remove the need to copy-pasta this code from project to project, or have to re-invent the wheel for each new app. 

RestLikeKit supports iOS, macOS, and tvOS.

## Requirements

- Swift 5.1 or greater
- iOS/tvOS 13 or greater OR macOS 10.15 or greater

## Installation

Currently, RestLikeKit is only available as a Swift Package.

### ...using a Package.swift file

Open the Package.swift file and edit it:

1. Add RestLikeKit repo to the `dependencies` array.
1. Add RestLikeKit as a dependency of the target that will use it

```Swift
// swift-tools-version:5.1

import PackageDescription

let package = Package(
  // ...snip...
  dependencies: [
    .package(url: "https://github.com/andyfinnell/RestLikeKit.git", from: "0.0.1")
  ],
  targets: [
    .target(name: "MyTarget", dependencies: ["RestLikeKit"])
  ]
)
```

Then build to pull down the dependencies:

```Bash
$ swift build
```

### ...using Xcode

Use the Swift Packages tab on the project to add RestLikeKit:

1. Open the Xcode workspace or project that you want to add RestLikeKit to
1. In the file browser, select the project to show the list of projects/targets on the right
1. In the list of projects/targets on the right, select the project
1. Select the "Swift Packages" tab
1. Click on the "+" button to add a package
1. In the "Choose Package Repository" sheet, search for  "https://github.com/andyfinnell/RestLikeKit.git"
1. Click "Next"
1. Choose the version rule you want
1. Click "Next"
1. Choose the target you want to add RestLikeKit to
1. Click "Finish"

## Usage 

### Modeling a show request

To create a new type of resource request, create a new type that implements the `ResourceRequest`. 

For example:

```Swift
struct User: Decodable, Equatable {} // API model

struct ShowUserRequest: ResourceRequest {
    typealias ResourceType = User
    
    let verb = ResourceVerb.show
    let path: String
    let parameters = Empty()
    
    init(userId: String) {
        path = "/users/\(userId)/"
    }
}
```

The `ResourceType` defines the response payload. It has to be `Equatable` and `Decodable`, and by default is assumed to be encoded as JSON. `verb` is a required property that has to be `show`, `index`, `create`, `update`, or `delete`.  `path` is also required, and is a relative path for the resource. `parameters` describe the parameters sent out on the HTTP request. They are are required to be `Encodable` and `Equatable`, and for `.show` verb requests will be encoded as query parameters. In this example a special value called `Empty` is used to indicate there are no parameters.

### Modeling an update request

Update requests are similar to show requests, but typically have different values. For example:

```Swift

struct UpdateUserRequest: ResourceRequest {
    typealias ResourceType = Empty
    struct ParameterType: Encodable, Equatable {
        let firstName: String?
        let lastName: String?
    }
    let verb = ResourceVerb.update
    let path: String
    let parameters: ParameterType
    
    init(userId: String, firstName: String? = nil, lastName: String? = nil) {
        path = "/users/\(userId)/"
        parameters = ParameterType(firstName: firstName, lastName: lastName)
    }
}
```

In this case, the update operation doesn't return anything, so it's modeled with the special value `Empty`. However, update does take parameters, so they are created as an `Encodable`, `Equatable` struct nested inside the request type. Since the `update` verb is used, they'll be encoded as JSON in the body of the request.

### Creating an API instance

All requests are made through an `API` instance, which allows common API configuration like headers, base URL, and authentication. These are injected to the `API` through the `dependencies` init parameter, which leverages protocol composition based dependency injection.

First, we need to create the `APIConfig` value that we'll use in the dependencies:

```Swift
extension APIConfig {
    static let `default` = APIConfig(baseURL: URL(string: "https://myservice.example.com/api/")!,
                                     baseHeaders: [.apiKey: "super-secret-api-key"])
}
```

The API config defines the static parts of the API, namely the base URL and any common headers that should be set on all HTTP requests.

Next, we need to implement an authentication header storage. This will dynamically provide a value to put in the HTTP `Authentication` header. It conforms to the `AuthenticationStorageType` protocol. If not value is ever needed, it can just return `nil`:

```Swift
struct AuthenticationStorage: AuthenticationStorageType {
    func authenticationHeader(for service: String) -> String? {
        nil
    }
}
```

RestLikeKit also provides Keychain bindings, so pulling a value from the Keychain can be done like so:

```Swift
struct AuthenticationStorage: AuthenticationStorageType {
    private let keychain = Keychain()
    private let userId: String
    
    func authenticationHeader(for service: String) -> String? {
        keychain.password(service: service, account: userId).map { "Bearer \($0)" }
    }
}
```

With our API config and authentication storage created, we can now create our concrete dependencies to inject an API:

```Swift
final class APIDependencies: API.Dependencies {
    lazy var apiConfig: APIConfig = .default
    lazy var authenticationStorage: AuthenticationStorageType = AuthenticationStorage()
    lazy var httpClient: HTTPClientType = HTTPClient(logger: self.logger,
                                                     urlSession: self.urlSession,
                                                     httpRequestEncoder: self.requestEncoder,
                                                     httpResponseDecoder: self.responseDecoder)
    
    private lazy var logger = Logger()
    private lazy var urlSession = URLSession.shared
    private lazy var requestEncoder = HTTPRequestEncoder()
    private lazy var responseDecoder = HTTPResponseDecoder()
}
```

The `httpClient` is the only other dependency required by `API` that we haven't already created. There's no reason not to use the `HTTPClient` provided by RestLikeKit, however we may want to swap out a different logger, or more rarely a different encoder or decoder.

With the dependencies created, it's trivial to create the API:

```Swift
let api = API(dependencies: APIDependencies())
```

Typically the `api` instance is created once and put in the dependency injection system for anyone code that needs it.

### Making a request

After create the request type and instantiating an `API`, we can make request with the `call` method:

```Swift
func fetchUser(with id: String) -> AnyPublisher<User, Error> {
    api.call(ShowUserRequest(userId: id))
}
```

The result is a Combine `AnyPublisher` that will have at most one value. It also operates as a "cold" observable, meaning the request won't be made until someone is listening on the publisher.

### Logging

RestLikeKit provides a rudimentary logging system via the `Logger` type. It wraps `OSLog`, and the `LogTag` type gets mapped into the OSLog category. Logging is on in the `DEBUG` builds and off otherwise.

By default the `API` type will log requests and responses. Individual `ResourceRequest`s can opt-out of being logging by providing values for the `shouldRedactRequestBody` or `shouldRedactResponseBody` properties. This is useful for requests that contain sensitive information, like login tokens or passwords.

### Keychain

As mentioned earlier, RestLikeKit provides basic Keychain functionality through the `Keychain` type. It can fetch, update, or delete Keychain entries.
