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

final class NavigationHandler: NSObject, WKNavigationDelegate {
    var ready: (() -> Void)?
    var extNavigationDelegate: WKNavigationDelegate?
    init(extNavigationDelegate:WKNavigationDelegate? = nil, ready: (() -> Void)? = nil) {
        self.ready = ready
        self.extNavigationDelegate = extNavigationDelegate
    }
    
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        print(#function)
        self.extNavigationDelegate?.webViewWebContentProcessDidTerminate?(webView)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print(#function)
        self.extNavigationDelegate?.webView?(webView, didCommit: navigation)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(#function)
        self.extNavigationDelegate?.webView?(webView, didFinish: navigation)
        ready?()
    }
    
    func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation!
    ) {
        print(#function)
        self.extNavigationDelegate?.webView?(webView, didStartProvisionalNavigation: navigation)
    }
    
    func webView(
        _ webView: WKWebView,
        didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!
    ) {
        print(#function)
        self.extNavigationDelegate?.webView?(webView, didReceiveServerRedirectForProvisionalNavigation: navigation)
    }
    
    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        print("\(#function): \(error)")
        self.extNavigationDelegate?.webView?(webView, didFail: navigation, withError: error)
    }
    
    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        print("\(#function): \(error)")
        self.extNavigationDelegate?.webView?(webView, didFailProvisionalNavigation: navigation, withError: error)
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        print(#function)
        if let extNavigationDelegate = self.extNavigationDelegate {
            extNavigationDelegate.webView?(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler) ?? decisionHandler(.allow)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        print(#function)
        if let extNavigationDelegate = self.extNavigationDelegate {
            extNavigationDelegate.webView?(webView, decidePolicyFor: navigationResponse, decisionHandler: decisionHandler) ?? decisionHandler(.allow)
        } else {
            decisionHandler(.allow)
        }
    }
    
    @available(iOS 14.0, macOS 11.0, *)
    func webView(
        _ webView: WKWebView,
        authenticationChallenge challenge: URLAuthenticationChallenge,
        shouldAllowDeprecatedTLS decisionHandler: @escaping (Bool) -> Void
    ) {
        print(#function)
        if let extNavigationDelegate = self.extNavigationDelegate {
            extNavigationDelegate.webView?(webView, authenticationChallenge: challenge, shouldAllowDeprecatedTLS: decisionHandler) ?? decisionHandler(false)
        } else {
            decisionHandler(false)
        }
    }
    
    func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        print(#function)
        if let extNavigationDelegate = self.extNavigationDelegate {
            extNavigationDelegate.webView?(webView, didReceive: challenge, completionHandler: completionHandler) ?? completionHandler(.performDefaultHandling, nil)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        preferences: WKWebpagePreferences,
        decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void
    ) {
        print(#function)
        if let extNavigationDelegate = self.extNavigationDelegate {
            extNavigationDelegate.webView?(webView, decidePolicyFor: navigationAction, preferences: preferences, decisionHandler: decisionHandler) ?? decisionHandler(.allow, preferences)
        } else {
            decisionHandler(.allow, preferences)
        }
        
    }
}
