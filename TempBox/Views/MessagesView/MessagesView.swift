//
//  MessagesView.swift
//  TempBox
//
//  Created by Rishi Singh on 25/09/23.
//

import SwiftUI

struct MessagesView: View {
    @EnvironmentObject private var dataController: DataController
    @StateObject private var controller: MessagesViewModel
    
    let account: Account
    
    init(account: Account) {
        self.account = account
        _controller = StateObject(wrappedValue: MessagesViewModel(account: account))
    }
    
    var messages: [Message] {
        return dataController.messagesStore[account]?.messages ?? []
    }
    
    var body: some View {
        VStack {
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
                            MessageItemView(
                                controller: controller, message: message,
                                account: account
                            )
                            .environmentObject(controller)
                        }
                    }
                    .onDelete { indexSet in
                        dataController.deleteMessage(indexSet: indexSet, account: account)
                    }
                }
                .listStyle(.plain)
                .searchable(text: $controller.searchText)
                .alert("Alert!", isPresented: $controller.showDeleteMessageAlert) {
                    Button("Cancel", role: .cancel) {
                        
                    }
                    Button("Delete", role: .destructive) {
                        guard let messForDeletion = controller.selectedMessForDeletion else { return }
                        dataController.deleteMessage(message: messForDeletion, account: account)
                        controller.selectedMessForDeletion = nil
                    }
                } message: {
                    Text("Are you sure you want to delete this account?")
                }
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
