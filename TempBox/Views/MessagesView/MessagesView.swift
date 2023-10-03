//
//  MessagesView.swift
//  TempBox
//
//  Created by Rishi Singh on 25/09/23.
//

import SwiftUI

struct MessagesView: View {
    @EnvironmentObject private var dataController: DataController
    @StateObject private var viewModel: MessagesViewModel
    
    let account: Account
    
    init(account: Account) {
        self.account = account
        _viewModel = StateObject(wrappedValue: MessagesViewModel(account: account))
    }
    
    var messages: [Message] {
        return dataController.messagesStore[account]?.messages ?? []
    }
    
    var body: some View {
        Group {
            if messages.isEmpty {
                VStack {
                    Spacer()
                    Text("No messages")
                    Spacer()
                }
            } else {
                List(selection: $dataController.selectedMessage) {
                    ForEach(messages) { message in
                        NavigationLink {
                            MessageDetailView(message: message, account: account)
                        } label: {
                            MessageItemView(message: message, account: account)
                        }
                    }
                    .onDelete { indexSet in
                        dataController.deleteMessage(indexSet: indexSet, account: account)
                    }
                }
                .listStyle(.plain)
                .searchable(text: $viewModel.searchText)
            }
        }
        .navigationTitle(account.accountName ?? account.address ?? "Mailbox")
    }
}

//struct MessagesView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            MessagesView()
//                .navigationTitle("MailBox")
//        }
//    }
//}
