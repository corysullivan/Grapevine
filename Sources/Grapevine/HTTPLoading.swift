//
//  File.swift
//
//
//  Created by Cory Sullivan on 2020-07-03.
//
import Foundation

public protocol HTTPLoading {
    func load(request: HTTPRequest, completion: @escaping (HTTPResult) -> Void) -> Cancelable?
}

public protocol Cancelable {
    func cancel()
}

extension URLSessionDataTask: Cancelable {}

extension URLSession: HTTPLoading {
    public func load(request: HTTPRequest, completion: @escaping (HTTPResult) -> Void) -> Cancelable? {
        guard let url = request.url else {
            // we couldn't construct a proper URL out of the request's URLComponents
            completion(HTTPResult(request: request, responseData: nil, response: nil, error: nil))
            return nil
        }

        // construct the URLRequest
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue

        // copy over any custom HTTP headers
        for (header, value) in request.headers {
            urlRequest.addValue(value, forHTTPHeaderField: header)
        }

        if request.body.isEmpty == false {
            // if our body defines additional headers, add them
            for (header, value) in request.body.additionalHeaders {
                urlRequest.addValue(value, forHTTPHeaderField: header)
            }

            // attempt to retrieve the body data
            do {
                urlRequest.httpBody = try request.body.encode()
            } catch {
                // something went wrong creating the body; stop and report back
                completion(HTTPResult(request: request, responseData: nil, response: nil, error: error))
                return nil
            }
        }

        let dataTask = self.dataTask(with: urlRequest) { data, response, error in
            // construct a Result<HTTPResponse, HTTPError> out of the triplet of data, url response, and url error
            let result = HTTPResult(request: request, responseData: data, response: response, error: error)
            completion(result)
        }
        dataTask.resume()
        return dataTask
    }
}
