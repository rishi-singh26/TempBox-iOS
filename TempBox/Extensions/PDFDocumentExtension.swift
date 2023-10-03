//
//  PDFDocumentExtension.swift
//  TempBox
//
//  Created by Rishi Singh on 02/10/23.
//

import PDFKit
import CoreTransferable

extension PDFDocument: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .pdf) { pdf in
            if let data = pdf.dataRepresentation() {
                return data
            } else {
                return Data()
            }
        } importing: { data in
            if let pdf = PDFDocument(data: data) {
                return pdf
            } else {
                return PDFDocument()
            }
        }
        DataRepresentation(exportedContentType: .pdf) { pdf in
            if let data = pdf.dataRepresentation() {
                return data
            } else {
                return Data()
            }
        }
    }
}
