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

import Combine
import SwiftUI
import WebKit

#if os(macOS)
public struct MonacoEditor: NSViewRepresentable {
    private let actions: [MonacoEditorAction]?
    private let commands: [MonacoEditorCommand]?
    private let contentChanged: ((String) -> Void)?
    private let scriptMessageHandlers: [MonacoEditorScriptMessageHandler]?
    public let isReflushFun: () -> Bool
    public let editorView: MonacoEditorView
    
    @ObservedObject private var configuration: MonacoEditorConfiguration
    @Binding private var text: String
    
    public init(
        text: Binding<String>,
        configuration: MonacoEditorConfiguration,
        commands: [MonacoEditorCommand]? = nil,
        actions: [MonacoEditorAction]? = nil,
        scriptMessageHandlers: [MonacoEditorScriptMessageHandler]? = nil,
        navigationHandlerFun: ((WKWebView) -> WKNavigationDelegate)? = nil,
        otherMessageHandlerFun: ((WKWebView) -> WKScriptMessageHandler)? = nil,
        contentChanged: ((String) -> Void)? = nil,
        isReflushFun: @escaping () -> Bool = { return false }
    ) {
        self._text = text
        self.configuration = configuration
        self.contentChanged = contentChanged
        self.commands = commands
        self.actions = actions
        self.scriptMessageHandlers = scriptMessageHandlers
        self.isReflushFun = isReflushFun
        self.editorView = MonacoEditorView(
            frame: NSRect.zero,
            text: text.wrappedValue,
            configuration: configuration,
            scriptMessageHandlers: scriptMessageHandlers,
            navigationHandlerFun: navigationHandlerFun,
            otherMessageHandlerFun: otherMessageHandlerFun
        )
        self.editorView.contentChanged = contentChanged
    }
    
    public func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(commands: commands, actions: actions)
        return coordinator
    }

    public func makeNSView(context: Context) -> MonacoEditorView {
        self.editorView.ready = context.coordinator.configureEditor
        if self.editorView.text != self.text && self.isReflushFun() {
            self.editorView.text = self.text
        }
        self.editorView.contentChanged = self.contentChanged
        if self.editorView.firstLoadView {
            self.editorView.loadEditor()
            self.editorView.firstLoadView = false
        }
        return self.editorView
    }

    public func updateNSView(_ view: MonacoEditorView, context: Context) {
        view.updateConfiguration()
    }
}

#else

public struct MonacoEditor: UIViewRepresentable {
    private let actions: [MonacoEditorAction]?
    private let commands: [MonacoEditorCommand]?
    private let contentChanged: ((String) -> Void)?
    private let scriptMessageHandlers: [MonacoEditorScriptMessageHandler]?
    public let isReflushFun: () -> Bool
    public let editorView: MonacoEditorView
    
    @ObservedObject private var configuration: MonacoEditorConfiguration
    @Binding private var text: String
    
    public init(
        text: Binding<String>,
        configuration: MonacoEditorConfiguration,
        commands: [MonacoEditorCommand]? = nil,
        actions: [MonacoEditorAction]? = nil,
        scriptMessageHandlers: [MonacoEditorScriptMessageHandler]? = nil,
        navigationHandlerFun: ((WKWebView) -> WKNavigationDelegate)? = nil,
        otherMessageHandlerFun: ((WKWebView) -> WKScriptMessageHandler)? = nil,
        contentChanged: ((String) -> Void)? = nil,
        isReflushFun: @escaping () -> Bool = { return false }
    ) {
        self._text = text
        self.configuration = configuration
        self.contentChanged = contentChanged
        self.commands = commands
        self.actions = actions
        self.scriptMessageHandlers = scriptMessageHandlers
        self.isReflushFun = isReflushFun
        self.editorView = MonacoEditorView(
            frame: CGRect.zero,
            text: text.wrappedValue,
            configuration: configuration,
            scriptMessageHandlers: scriptMessageHandlers,
            navigationHandlerFun: navigationHandlerFun,
            otherMessageHandlerFun: otherMessageHandlerFun
        )
        self.editorView.contentChanged = contentChanged
    }
    
    public func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(commands: commands, actions: actions)
        return coordinator
    }

    public func makeUIView(context: Context) -> MonacoEditorView {
        self.editorView.ready = context.coordinator.configureEditor
        if self.editorView.text != self.text && self.isReflushFun() {
            self.editorView.text = self.text
        }
        self.editorView.contentChanged = self.contentChanged
        if self.editorView.firstLoadView {
            self.editorView.loadEditor()
            self.editorView.firstLoadView = false
        }
        return self.editorView
    }

    public func updateUIView(_ view: MonacoEditorView, context: Context) {
        view.updateConfiguration()
    }
}

#endif

extension MonacoEditor {
    public final class Coordinator {
        private let actions: [MonacoEditorAction]?
        private let commands: [MonacoEditorCommand]?
        
        init(commands: [MonacoEditorCommand]?, actions: [MonacoEditorAction]?) {
            self.commands = commands
            self.actions = actions
        }
        
        func configureEditor(editor: MonacoEditorView) {
            if let commands = self.commands {
                for command in commands {
                    editor.addCommand(command)
                }
            }
            
            if let actions = self.actions {
                for action in actions {
                    editor.addAction(action)
                }
            }
        }
    }
}
