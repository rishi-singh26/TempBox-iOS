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

    var body: some View {
        NavigationView {
            List {
                Section("Active") {
                    ForEach(dataController.accounts) { account in
                        NavigationLink {
                            MessagesView(account: account)
                        } label: {
                            AccountItemView(account: account, controller: controller)
                                .environmentObject(controller)
                        }
                    }
                    .onDelete(perform: dataController.deleteAccount)
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
                        Text("\(dataController.accounts.count) \(dataController.accounts.count < 2 ? "Account" : "Accounts")")
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
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
