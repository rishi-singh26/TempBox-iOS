//
//  ContentView.swift
//  TempBox
//
//  Created by Rishi Singh on 20/09/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest<Account>(sortDescriptors: [
        SortDescriptor(\.createdAt)
    ]) var accounts: FetchedResults<Account>
    
    @StateObject var controller = ContentViewModel()

    var body: some View {
        NavigationView {
            List {
                Section("Active") {
                    ForEach(accounts) { account in
                        NavigationLink {
                            Text(account.address ?? "No address")
                        } label: {
                            Text(account.accountName ?? account.address ?? "No address")
                                .swipeActions(edge: .leading) {
                                    Button {
                                        controller.selectedAccForInfoSheet = account
                                        controller.isAccountInfoSheetOpen = true
                                    } label: {
                                        Label("Account Info", systemImage: "info.square")
                                    }
                                    .tint(.yellow)
                                }
                        }
                    }
                    .onDelete { indexSet in
                        if let index = indexSet.first {
                            controller.deleteAccount(account: accounts[index], moc: moc)
                        }
                    }
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
                        Text("Accounts: \(accounts.count)")
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
