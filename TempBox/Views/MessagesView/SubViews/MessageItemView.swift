//
//  MessageItemView.swift
//  TempBox
//
//  Created by Rishi Singh on 26/09/23.
//

import SwiftUI
//import MailTMSwift

struct MessageItemView: View {
    @EnvironmentObject private var dataController: DataController
    @ObservedObject var controller: MessagesViewModel
    
    let message: Message
    let account: Account
    
    var messageHeader: String {
        message.data.from.name == "" ? message.data.from.address : message.data.from.name
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Circle()
                .fill(.blue.opacity(message.data.seen ? 0 : 1))
                .frame(width: 12)
                .padding(0)
            VStack(alignment: .leading) {
                HStack {
                    Text(messageHeader)
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineSpacing(1)
                    Spacer()
                    Text(message.data.createdAt.formatRelativeString(useTwentyFourHour: true))
                        .foregroundColor(.secondary)
                }
                Text(message.data.subject)
                    .lineLimit(1, reservesSpace: true)
                Text(message.data.intro ?? "")
                    .foregroundColor(.secondary)
                    .lineLimit(2, reservesSpace: true)
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                dataController.markMessageAsRead(messageData: message, account: account, seen: !message.data.seen)
            } label: {
                Label(message.data.seen ? "Unread" : "Read", systemImage: message.data.seen ? "envelope.badge.fill" : "envelope.open.fill")
            }
            .tint(.blue)
        }
        .swipeActions(edge: .trailing) {
            Button {
                controller.showDeleteMessageAlert = true
                controller.selectedMessForDeletion = message
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
        .contextMenu {
            Button {
                dataController.markMessageAsRead(messageData: message, account: account)
            } label: {
                Label(message.data.seen ? "Mark as unread" : "Mark as read", systemImage: message.data.seen ? "envelope.badge" : "envelope.open")
            }
            Divider()
            Button(role: .destructive) {
                controller.showDeleteMessageAlert = true
                controller.selectedMessForDeletion = message
            } label: {
                Label("Delete message", systemImage: "trash")
            }
        }
    }
}

//struct MessageItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageItemView()
//    }
//}
