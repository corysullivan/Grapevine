//
//  HTTPResult.swift
//
//
//  Created by Cory Sullivan on 2020-06-28.
//

import Foundation

public typealias HTTPResult = Result<HTTPResponse, HTTPError>

public struct HTTPError: Error {
    /// The high-level classification of this error
    public let code: Code

    /// The HTTPRequest that resulted in this error
    public let request: HTTPRequest

    /// Any HTTPResponse (partial or otherwise) that we might have
    public let response: HTTPResponse?

    /// If we have more information about the error that caused this, stash it here
    public let underlyingError: Error?

    public enum Code {
        case invalidRequest // the HTTPRequest could not be turned into a URLRequest
        case cannotConnect // some sort of connectivity problem
        case cancelled // the user cancelled the request
        case insecureConnection // couldn't establish a secure connection to the server
        case invalidResponse // the system did not receive a valid HTTP response
        case unknown // we have no idea what the problem is
    }
}

extension HTTPResult {
    init(request: HTTPRequest, responseData: Data?, response: URLResponse?, error: Error?) {
        var httpResponse: HTTPResponse?
        if let r = response as? HTTPURLResponse {
            httpResponse = HTTPResponse(request: request, response: r, body: responseData ?? Data())
        }

        if let e = error as? URLError {
            let code: HTTPError.Code
            switch e.code {
                case .badURL: code = .invalidRequest
                default: code = .unknown
            }
            self = .failure(HTTPError(code: code, request: request, response: httpResponse, underlyingError: e))
        } else if let someError = error {
            // an error, but not a URL error
            self = .failure(HTTPError(code: .unknown, request: request, response: httpResponse, underlyingError: someError))
        } else if let r = httpResponse {
            // not an error, and an HTTPURLResponse
            self = .success(r)
        } else {
            // not an error, but also not an HTTPURLResponse
            self = .failure(HTTPError(code: .invalidResponse, request: request, response: nil, underlyingError: error))
        }
    }
}
