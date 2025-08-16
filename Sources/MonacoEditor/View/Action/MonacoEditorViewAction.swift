//
//  File.swift
//  
//
//  Created by Oyjie on 3/15/24.
//

import Foundation
import WebKit
import SwiftUI

extension MonacoEditorView {
    public func enableUTF8() {
        evaluateJavascript(
"""
window.atob = (function(originalAtob) {
    return function(input) {
        return decodeURIComponent(originalAtob(input).split('').map(function(c) {
            return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
        }).join(''));
    };
})(window.atob);

window.btoa = (function(originalBtoa) {
    return function(str) {
        return originalBtoa(encodeURIComponent(str).replace(/%([0-9A-F]{2})/g, function(match, p1) {
            return String.fromCharCode('0x' + p1);
        }));
    };
})(window.btoa);
"""
        )
    }
    
    public func createEditor() {
        let options = StandaloneEditorConstructionOptions(
            text: text,
            configuration: configuration
        )
        let javascript =
"""
(function() {
  let options = \(options.javascript);
  if (options.value) {
    options.value = atob(options.value);
  }

  editor.create(options);
  return true;
})();
"""
        if #available(macOS 11.0, iOS 14.0, *) {
            webView.evaluateJavaScript(javascript, in: nil, in: WKContentWorld.page) {
                result in
                switch result {
                case .success(_): self.ready?(self)
                case .failure(let error): print("ERROR: \(error)")
                }
            }
        } else {
            webView.evaluateJavaScript(javascript) { (result, error) in
                if let error = error {
                    print("ERROR: \(error)")
                    return
                }
                
                self.ready?(self)
            }
        }
    }
    
    public func addAction(_ action: MonacoEditorAction) {
        var builder = JavaScriptObjectBuilder()
        builder.append(key: "contextMenuGroupId", value: action.contextMenuGroupID)
        builder.append(key: "contextMenuOrder", value: action.contextMenuOrder)
        builder.append(key: "id", value: action.id)
        builder.append(key: "keybindingContext", value: action.keybindingContext)
        builder.append(key: "keybindings", value: action.keybindings)
        builder.append(key: "label", value: action.label)
        builder.append(key: "precondition", value: action.precondition);
        builder.append(key: "run", javascript: action.run)
        let actionDescriptor = builder.build()
        
        let javascript =
"""
(function() {
  editor.addAction(function(monaco, editor) {
    editor.addAction(\(actionDescriptor));
  });
  return true;
})();
"""
        evaluateJavascript(javascript)
    }
    
    public func addCommand(_ command: MonacoEditorCommand) {
        let keybindingString = command.keyBinding.keybinding
        
        var contextString: String?
        if let context = command.context {
            contextString = ",\n\t\t\(context)"
        }
        
        let javascript =
"""
(function() {
  editor.addCommand(function(monaco, editor) {
    editor.addCommand(\(keybindingString),\(command.command)\(contextString ?? ""));
  });
  return true;
})();
"""
        evaluateJavascript(javascript)
    }
    
    public func createContextKey<T: MonacoEditorContextKeyValue>(
        _ key: String,
        defaultValue: T
    ) -> MonacoEditorContextKey<T> {
        let javascript =
"""
(function() {
  editor.createContextKey('\(key)', \(defaultValue.javascript));
  return true;
})();
"""
        evaluateJavascript(javascript)
        
        return MonacoEditorContextKey(webView: webView, key: key)
    }
    
    public func updateConfiguration(text: String? = nil) {
        guard isLoaded else {
            return
        }
        
        let options = StandaloneEditorConstructionOptions(
            text: text,
            configuration: configuration
        )
        let javascript =
"""
(function() {
  let options = \(options.javascript);
  if (options.value) {
    options.value = atob(options.value);
  }

  editor.updateOptions(options);
  return true;
})();
"""
        evaluateJavascript(javascript)
    }
    
    public func resizeLayout() {
        
        let javascript =
"""
(function() {
  document.body.style.width = '100%';
  document.body.style.height = '100%';
  var editorElement = document.getElementById('editor');
  if (editorElement) {
    editorElement.style.width = '100%';
    editorElement.style.height = '100%';
  } else {
    console.log('Element with id "editor" not found');
  }
  editor.editor.layout();
  return true;
})();
"""
        evaluateJavascript(javascript)
    }
    
    func evaluateJavascript(_ javascript: String) {
        if #available(macOS 11.0, iOS 14.0, *) {
            self.webView.evaluateJavaScript(javascript, in: nil, in: WKContentWorld.page) { result in
                guard case .failure(let error) = result else {
                    return
                }
                
                print("ERROR: \(error)")
            }
        } else {
            self.webView.evaluateJavaScript(javascript) { (result, error) in
                guard let error = error else {
                    return
                }
                
                print("ERROR: \(error)")
            }
        }
    }
}
