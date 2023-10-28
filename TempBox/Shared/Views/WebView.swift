//
//  WebView.swift
//  TempBox
//
//  Created by Rishi Singh on 30/09/23.
//

import SwiftUI
import WebKit
import PDFKit

struct WebView: UIViewRepresentable {
    let html: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.loadHTMLString(html, baseURL: nil)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(html, baseURL: nil)
    }
}

#Preview {
    WebView(html: "<html><body><h1>123</h1><h2>345</h2></body><html>")
}
