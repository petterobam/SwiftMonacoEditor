// Copyright 2020 Michael F. Collins, III
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import WebKit

import Gzip

final class MonacoEditorURLSchemeHandler: NSObject, WKURLSchemeHandler {
  private enum RequestError: Error {
    case badRequest
    case notFound
  }

  func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
    guard let requestURL = urlSchemeTask.request.url else {
      urlSchemeTask.didFailWithError(RequestError.badRequest)
      return
    }

    var resourceExtension = requestURL.pathExtension
    var resourceName = requestURL.deletingPathExtension().lastPathComponent
    if resourceName.isEmpty {
      resourceName = "index"
      resourceExtension = "html"
    }

    let directoryURL = requestURL.deletingLastPathComponent()
    let subdirectory = "Editor\(directoryURL.path)"
    guard let resourceURL = Bundle.module.url(
            forResource: resourceName,
            withExtension: resourceExtension,
            subdirectory: subdirectory
    ) else {
      let errorResponse = HTTPURLResponse(
        url: requestURL,
        statusCode: 404,
        httpVersion: "1.1",
        headerFields: [String : String]()
      )!
      urlSchemeTask.didReceive(errorResponse)
      return
    }

    var contentType: String
    switch resourceExtension {
    case "html": contentType = "text/html"
    case "js": contentType = "application/json"
    default: contentType = "application/octet-stream"
    }

    do {
      let compressedData = try Data(contentsOf: resourceURL)
      let resourceData = try compressedData.gunzipped()
      let response = HTTPURLResponse(
        url: requestURL,
        statusCode: 200,
        httpVersion: "1.1",
        headerFields: [
          "Content-Length": String(format: "%d", resourceData.count),
          "Content-Type": contentType
        ]
      )!
      urlSchemeTask.didReceive(response)
      urlSchemeTask.didReceive(resourceData)
      urlSchemeTask.didFinish()
    } catch {
      urlSchemeTask.didFailWithError(error)
    }
  }

  func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
    print(#function)
  }
}
