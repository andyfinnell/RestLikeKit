import Foundation
@testable import RestLikeKit

final class FakeURLSession: URLSessionType {
    
    var dataTask_wasCalled = false
    var dataTask_wasCalled_withArgs: (request: URLRequest, completion: (Data?, URLResponse?, Error?) -> Void)?
    var dataTask_stubbed = FakeURLSessionDataTask()
    func dataTask(request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskType {
        dataTask_wasCalled = true
        dataTask_wasCalled_withArgs = (request: request, completion: completion)
        return dataTask_stubbed
    }

    func fulfillJson(string: String, status: Int = 200) {
        guard let request = dataTask_wasCalled_withArgs?.request else {
            return
        }
        let response = HTTPURLResponse(url: request.url!,
                                       statusCode: status,
                                       httpVersion: "1.1",
                                       headerFields: ["content-type": "application/json"])!

        let data = string.data(using: .utf8)!
        fulfill(response: response, data: data)
    }
    
    func fulfill(response: URLResponse, data: Data?) {
        guard let completion = dataTask_wasCalled_withArgs?.completion else {
            return
        }
        completion(data, response, nil)
    }
    
    func reject(error: Error) {
        guard let completion = dataTask_wasCalled_withArgs?.completion else {
            return
        }
        completion(nil, nil, error)
    }
}

