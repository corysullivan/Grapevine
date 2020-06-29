//
//  HTTPRequest.swift
//
//
//  Created by Cory Sullivan on 2020-06-28.
//

import Foundation

public struct HTTPRequest {
    private var urlComponents = URLComponents()
    public var method: HTTPMethod = .get
    public var headers: [String: String] = [:]
    public var body: Data?

    public init() {
        urlComponents.scheme = "https"
    }
}

public extension HTTPRequest {
    var scheme: String { urlComponents.scheme ?? "https" }

    var host: String? {
        get { urlComponents.host }
        set { urlComponents.host = newValue }
    }

    var path: String {
        get { urlComponents.path }
        set { urlComponents.path = newValue }
    }
}
