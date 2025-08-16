// Copyright 2020 Naked Software, LLC
//
// This program is confidential and proprietary to Naked Software, LLC,
// and may not be reproduced, published, or disclosed to others without
// company authorization.

import WebKit
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

#if os(macOS)
public final class MonacoEditorView: NSView {
    public let configuration: MonacoEditorConfiguration
    
    public var contentChanged: ((String) -> Void)?
    public var ready: ((MonacoEditorView) -> Void)?
    
    public var text: String {
        didSet {
            guard isLoaded else {
                return
            }
            
            let encodedText = text.data(using: .utf8)?.base64EncodedString() ?? ""
            let javascript =
"""
(function() {
  let text = atob('\(encodedText)');
  editor.setText(text);
  return true
})();
"""
            evaluateJavascript(javascript)
        }
    }
    
    var isLoaded = false
    var firstLoadView = true
    var navigationHandler: NavigationHandler!
    var uiHandler: UIHandler!
    public var otherMessageHandler: WKScriptMessageHandler?
    public weak var webView: WKWebView!
    
    public init(
        frame: NSRect,
        text: String? = nil,
        configuration: MonacoEditorConfiguration,
        scriptMessageHandlers: [MonacoEditorScriptMessageHandler]?,
        navigationHandlerFun: ((WKWebView) -> WKNavigationDelegate)? = nil,
        otherMessageHandlerFun: ((WKWebView) -> WKScriptMessageHandler)? = nil
    ) {
        self.configuration = configuration
        self.text = text ?? ""
        
        super.init(frame: frame)
        
        setupWebView(scriptMessageHandlers: scriptMessageHandlers, navigationHandlerFun: navigationHandlerFun, otherMessageHandlerFun: otherMessageHandlerFun)
        loadEditor()
    }
    
    func setupWebView(
        scriptMessageHandlers: [MonacoEditorScriptMessageHandler]?,
        navigationHandlerFun: ((WKWebView) -> WKNavigationDelegate)? = nil,
        otherMessageHandlerFun: ((WKWebView) -> WKScriptMessageHandler)? = nil
    ) {
        uiHandler = UIHandler()
        
        let configuration = WKWebViewConfiguration()
        configuration.setURLSchemeHandler(
            MonacoEditorURLSchemeHandler(),
            forURLScheme: "monacoeditor"
        )
        configuration.userContentController.add(
            UpdateTextScriptHandler(self),
            name: "updateText"
        )
        
        if let scriptMessageHandlers = scriptMessageHandlers {
            for scriptMessageHandler in scriptMessageHandlers {
                if let handler = scriptMessageHandler.scriptMessageHandler {
                    configuration.userContentController.add(
                        handler,
                        name: scriptMessageHandler.name
                    )
                    continue
                }
                
                if let handler = scriptMessageHandler.scriptMessageHandlerWithReply {
                    if #available(macOS 11.0, *) {
                        configuration.userContentController.addScriptMessageHandler(
                            handler,
                            contentWorld: WKContentWorld.page,
                            name: scriptMessageHandler.name
                        )
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        }
        
        let webView = WKWebView(frame: NSRect.zero, configuration: configuration)
        self.navigationHandler = NavigationHandler(extNavigationDelegate: navigationHandlerFun?(webView)) {
            self.isLoaded = true
            self.enableUTF8()
            self.createEditor()
        }
        if let otherMessageHandler = otherMessageHandlerFun?(webView) {
            webView.configuration.userContentController.add(otherMessageHandler, name: "OtherMessageHandler")
            self.otherMessageHandler = otherMessageHandler
        }
        
        webView.navigationDelegate = navigationHandler
        webView.uiDelegate = uiHandler
        webView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        self.webView = webView
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
}

#else

public final class MonacoEditorView: UIView {
    public let configuration: MonacoEditorConfiguration
    
    public var contentChanged: ((String) -> Void)?
    public var ready: ((MonacoEditorView) -> Void)?
    
    public var text: String {
        didSet {
            guard isLoaded else {
                return
            }
            
            let encodedText = text.data(using: .utf8)?.base64EncodedString() ?? ""
            let javascript =
"""
(function() {
  let text = atob('\(encodedText)');
  editor.setText(text);
  return true
})();
"""
            evaluateJavascript(javascript)
        }
    }
    
    var isLoaded = false
    var firstLoadView = true
    var navigationHandler: NavigationHandler!
    var uiHandler: UIHandler!
    public var otherMessageHandler: WKScriptMessageHandler?
    public weak var webView: WKWebView!
    
    public init(
        frame: CGRect,
        text: String? = nil,
        configuration: MonacoEditorConfiguration,
        scriptMessageHandlers: [MonacoEditorScriptMessageHandler]?,
        navigationHandlerFun: ((WKWebView) -> WKNavigationDelegate)? = nil,
        otherMessageHandlerFun: ((WKWebView) -> WKScriptMessageHandler)? = nil
    ) {
        self.configuration = configuration
        self.text = text ?? ""
        
        super.init(frame: frame)
        
        setupWebView(scriptMessageHandlers: scriptMessageHandlers, navigationHandlerFun: navigationHandlerFun, otherMessageHandlerFun: otherMessageHandlerFun)
        loadEditor()
    }
    
    func setupWebView(
        scriptMessageHandlers: [MonacoEditorScriptMessageHandler]?,
        navigationHandlerFun: ((WKWebView) -> WKNavigationDelegate)? = nil,
        otherMessageHandlerFun: ((WKWebView) -> WKScriptMessageHandler)? = nil
    ) {
        uiHandler = UIHandler()
        
        let configuration = WKWebViewConfiguration()
        configuration.setURLSchemeHandler(
            MonacoEditorURLSchemeHandler(),
            forURLScheme: "monacoeditor"
        )
        configuration.userContentController.add(
            UpdateTextScriptHandler(self),
            name: "updateText"
        )
        
        if let scriptMessageHandlers = scriptMessageHandlers {
            for scriptMessageHandler in scriptMessageHandlers {
                if let handler = scriptMessageHandler.scriptMessageHandler {
                    configuration.userContentController.add(
                        handler,
                        name: scriptMessageHandler.name
                    )
                    continue
                }
                
                if let handler = scriptMessageHandler.scriptMessageHandlerWithReply {
                    if #available(iOS 14.0, *) {
                        configuration.userContentController.addScriptMessageHandler(
                            handler,
                            contentWorld: WKContentWorld.page,
                            name: scriptMessageHandler.name
                        )
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        }
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        self.navigationHandler = NavigationHandler(extNavigationDelegate: navigationHandlerFun?(webView)) {
            self.isLoaded = true
            self.enableUTF8()
            self.createEditor()
        }
        if let otherMessageHandler = otherMessageHandlerFun?(webView) {
            webView.configuration.userContentController.add(otherMessageHandler, name: "OtherMessageHandler")
            self.otherMessageHandler = otherMessageHandler
        }
        
        webView.navigationDelegate = navigationHandler
        webView.uiDelegate = uiHandler
        webView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        self.webView = webView
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
}

#endif

extension MonacoEditorView {
    public func loadEditor(_ cachePolicy: URLRequest.CachePolicy? = nil) {
        let url = URL(string: "monacoeditor://editor")!
        let request = URLRequest(
            url: url,
            cachePolicy: cachePolicy ?? .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 10.0
        )
        webView.load(request)
    }
}
