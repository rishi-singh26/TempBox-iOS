//
//  AccountItemView.swift
//  TempBox
//
//  Created by Rishi Singh on 27/09/23.
//

import SwiftUI

struct AccountItemView: View {
    let account: Account
    @EnvironmentObject private var dataController: DataController
    @ObservedObject var controller: ContentViewModel
    
    var isMessagesFetching: Bool {
        dataController.messagesStore[account]?.isFetching ?? false
    }
    
    var isMessagesFetchingFailed: Bool {
        dataController.messagesStore[account]?.error != nil
    }
    
    var unreadMessagesCount: Int {
        dataController.messagesStore[account]?.unreadMessagesCount ?? 0
    }
    
    var body: some View {
        HStack {
            Image(systemName: "tray")
                .foregroundColor(.accentColor)
            HStack {
                Text(account.accountName ?? account.address ?? "No address")
//                VStack(alignment: .leading) {
//                    Text(account.accountName ?? account.address ?? "No address")
//                    if account.accountName != nil {
//                        Text(account.address ?? "No address")
//                            .foregroundColor(.secondary)
//                    }
//                }
                Spacer()
                if !account.isArchived {
                    if isMessagesFetching {
                        ProgressView()
                            .controlSize(.small)
                    } else if isMessagesFetchingFailed {
                        Image(systemName: "exclamationmark.triangle.fill")
                    } else if unreadMessagesCount != 0 {
                        Text("\(unreadMessagesCount)")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
            .swipeActions(edge: .leading) {
                Button {
                    controller.selectedAccForInfoSheet = account
                    controller.isAccountInfoSheetOpen = true
                } label: {
                    Label("Account Info", systemImage: "info.square")
                }
                .tint(.blue)
                Button {
                } label: {
                    Label("Archive", systemImage: "archivebox")
                }
                .tint(.indigo)
            }
    }
}

//struct AccountItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        AccountItemView()
//    }
//}
