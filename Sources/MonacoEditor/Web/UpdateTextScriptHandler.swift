//
//  File.swift
//  
//
//  Created by Oyjie on 3/15/24.
//

import Foundation
import WebKit

class UpdateTextScriptHandler: NSObject, WKScriptMessageHandler {
    private let parent: MonacoEditorView
    
    init(_ parent: MonacoEditorView) {
        self.parent = parent
    }
    
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard let encodedText = message.body as? String,
              let data = Data(base64Encoded: encodedText),
              let text = String(data: data, encoding: .utf8) else {
            print("Unexpected message body： \(message.body as? String)")
            return
        }
        
        parent.contentChanged?(text)
    }
}
