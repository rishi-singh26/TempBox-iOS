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
    private let messageService = MTMessageService()
    private let accountService = MTAccountService()
    let container = NSPersistentContainer(name: "TempBox")
    
    @Published var accounts: [Account] = [Account]()
    @Published var messagesStore: [Account: MessageStore] = [Account: MessageStore]()
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core data failed to load \(error.localizedDescription)")
            }
            return
        }
        
        self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        fetchAccounts()
    }
    
    func fetchAccounts() {
        let request = NSFetchRequest<Account>(entityName: "Account")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        DispatchQueue.main.async {
            do {
                self.accounts = try self.container.viewContext.fetch(request)
                for account in self.accounts {
                    self.messagesStore[account] = MessageStore(isFetching: true, error: nil, messages: [])
                    self.fetchMessages(for: account)
                }
            } catch {
                print("Error in fetching accounts \(error.localizedDescription)")
            }
        }
    }
    
    func fetchMessages(for account: Account) {
        guard let token = account.token else { return }
        messageService.getAllMessages(token: token) { (result: Result<[MTMessage], MTError>) in
            switch result {
              case .success(let messages):
                var messagesArr = [Message]()
                for message in messages {
                    messagesArr.append(Message(isComplete: true, data: message))
                }
                self.messagesStore[account] = MessageStore(isFetching: false, error: nil, messages: messagesArr)
              case .failure(let error):
                self.messagesStore[account] = MessageStore(isFetching: false, error: error, messages: [])
            }
        }
    }
    
    func addAccount(account: MTAccount, token: String, password: String, accountName: String) {
        let newAccount = Account(context: container.viewContext)
        newAccount.id = account.id
        newAccount.accountName = accountName.isEmpty ? nil : accountName
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
            guard let id = account.id, let token = account.token else { return } // handle user alert about
            accountService.deleteAccount(id: id, token: token) { (result: Result<MTEmptyResult, MTError>) in
                if case let .failure(error) = result {
                    print("Error Occurred while deleting account from mail.tm server: \(error)")
                    return
                }
                self.saveContext()
            }
            container.viewContext.delete(account)
        }
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
