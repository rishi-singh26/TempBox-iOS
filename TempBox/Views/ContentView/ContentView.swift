//
//  ContentView.swift
//  TempBox
//
//  Created by Rishi Singh on 20/09/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject private var dataController: DataController
    @StateObject var controller = ContentViewModel()
    
    var filteredAccounts: [Account] {
        if controller.searchText.isEmpty {
            return dataController.accounts
        } else {
            return dataController.accounts.filter { acc in
                guard let accountName = acc.accountName else { return false }
                if accountName.lowercased().contains(controller.searchText.lowercased()) {
                    return true
                } else {
                    guard let accountAddress = acc.address else { return false }
                    return accountAddress.lowercased().contains(controller.searchText.lowercased())
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(filteredAccounts) { account in
                        NavigationLink {
                            MessagesView(account: account)
                        } label: {
                            AccountItemView(account: account, controller: controller)
                                .environmentObject(controller)
                        }
                    }
                    .onDelete(perform: dataController.deleteAccount)
                } header: {
                    Text("Active")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .textCase(nil)
                }
            }
            .navigationTitle("TempBox")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button(action: controller.openNewAddressSheet) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("New Address")
                            }
                            .fontWeight(.bold)
                        }
                        Spacer()
                        Text("Powered by [mail.tm](https://www.mail.tm)")
                            .font(.footnote)
                    }
                }
            }
            .searchable(text: $controller.searchText)
            .listStyle(.sidebar)
            .sheet(isPresented: $controller.isNewAddressSheetOpen) {
                AddAddressView()
            }
            .sheet(isPresented: $controller.isAccountInfoSheetOpen) {
                AccountInfoView(account: controller.selectedAccForInfoSheet!)
            }
            .refreshable {
                dataController.fetchAccounts()
            }
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button {
//                        dataController.fetchAccounts()
//                    } label: {
//                        Label("Refresh", systemImage: "arrow.clockwise.circle")
//                    }
//                }
//            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
