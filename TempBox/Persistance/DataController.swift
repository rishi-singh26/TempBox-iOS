//
//  DataController.swift
//  TempBox
//
//  Created by Rishi Singh on 20/09/23.
//

import Foundation
import CoreData
import MailTMSwift

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "TempBox")
    
    @Published var accounts: [Account] = [Account]()
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core data failed to load \(error.localizedDescription)")
            }
            return
        }
        
        self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
//        fetchAccounts()
    }
    
    func fetchAccounts() {
        let request = NSFetchRequest<Account>(entityName: "Account")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            accounts = try container.viewContext.fetch(request)
        } catch {
            print("Error in fetching accounts \(error.localizedDescription)")
        }
    }
    
    func addAccount(account: MTAccount, token: String, password: String) {
        let newAccount = Account(context: container.viewContext)
        newAccount.id = account.id
        newAccount.address = account.address
        newAccount.createdAt = account.createdAt
        newAccount.isArchived = false
        newAccount.isDisabled = account.isDisabled
        newAccount.password = password
        newAccount.quotaLimit = Int32(account.quotaLimit)
        newAccount.quotaUsed = Int32(account.quotaUsed)
        newAccount.updatedAt = account.updatedAt
        newAccount.token = token
        saveContext()
    }
    
    func deleteAccount(indexSet: IndexSet) {
        for index in indexSet {
            let account = accounts[index]
            container.viewContext.delete(account)
        }
        saveContext()
    }
    
    func saveContext() {
        do {
            try container.viewContext.save()
            fetchAccounts()
        } catch {
            print("Error in saving context \(error.localizedDescription)")
        }
    }
}
