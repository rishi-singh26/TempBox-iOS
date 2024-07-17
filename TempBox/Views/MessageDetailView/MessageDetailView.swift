//
//  MessageDetailView.swift
//  TempBox
//
//  Created by Rishi Singh on 30/09/23.
//

import SwiftUI
import PDFKit

struct MessageDetailView: View {
    @EnvironmentObject private var dataController: DataController
    
    let message: Message
    let account: Account
        
    var body: some View {
        VStack(alignment: .leading) {
            MessageHeaderView(message: message)
            Text(message.data.subject)
                .font(.title2)
                .fontWeight(.bold)
            if let selectedMessage = dataController.selectedMessage, let html = selectedMessage.data.html?.first {
                WebView(html: html)
            }
            if dataController.loadingCompleteMessage {
                EmptyView()
            }
        }
        .onAppear(perform: {
            dataController.fetchCompleteMessage(of: message.data, account: account)
            dataController.markMessageAsRead(messageData: message, account: account)
        })
        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItemGroup {
//                Button {
//                    if let selectedMessage = dataController.selectedMessage, let html = selectedMessage.data.html?.first {
//                        guard let data = ShareService().createPDF(html: html) else { return }
//                        guard let pdf = PDFDocument(data: data) else { return }
//                        print(pdf)
//                        let result = ShareLink(item: pdf, preview: SharePreview("PDF"))
//                    }
//                } label: {
//                    Label("Share", systemImage: "square.and.arrow.up")
//                }
//                Button(role: .destructive) {
//                    dataController.deleteMessage(message: message, account: account)
//                } label: {
//                    Label("Delete", systemImage: "trash")
//                }
//            }
//        }
    }
}

//#Preview {
//    MessageDetailView()
//}

struct EmptyView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView()
                .frame(width: 25, height: 25)
                .tint(.red)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
