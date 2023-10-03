//
//  ShareService.swift
//  TempBox
//
//  Created by Rishi Singh on 02/10/23.
//

import SwiftUI
import WebKit
import PDFKit

class ShareService {
    func convertHTMLToPDF(html: String) -> PDFDocument? {
        let webView = WKWebView()
        webView.loadHTMLString(html, baseURL: nil)
        
        var pdfDoc: PDFDocument?
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let config = WKPDFConfiguration()
            config.rect = .init(origin: .zero, size: .init(width: 595.28, height: 841.89))
            webView.createPDF(configuration: config) { result in
                switch result {
                case .success(let data):
                    pdfDoc = PDFDocument(data: data)
                case .failure(let error):
                    print("Error creating PDF \(error)")
                }
            }
//        }
        
        return pdfDoc
    }
}
