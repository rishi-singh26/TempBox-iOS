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
    
    @Published var selectedAccount: Account?
    @Published var selectedMessage: Message?
    
    @Published var loadingCompleteMessage = false
    
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
    
    func fetchCompleteMessage(of message: MTMessage, account: Account) {
        guard let token = account.token else { return } // handle user alert about any issues
        loadingCompleteMessage = true
        messageService.getMessage(id: message.id, token: token) { (result: Result<MTMessage, MTError>) in
            switch result {
            case .success(let message):
                self.selectedMessage = Message(isComplete: true, data: message)
            case .failure(let error):
                print("Error in getting complete message \(error)")
            }
            self.loadingCompleteMessage = false
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
            deleteAccount(account: account)
        }
    }
    
    func deleteAccount(account: Account) {
        guard let id = account.id, let token = account.token else { return } // handle user alert about any issues
        accountService.deleteAccount(id: id, token: token) { (result: Result<MTEmptyResult, MTError>) in
            if case let .failure(error) = result {
                print("Error Occurred while deleting account from mail.tm server: \(error)")
                return
            }
            self.container.viewContext.delete(account)
            self.saveContext()
        }
    }
    
    func deleteMessage(message: Message, account: Account) {
        guard let index = messagesStore[account]?.messages.firstIndex(where: { mes in
            mes.id == message.id
        }) else { return }
        guard let token = account.token else { return }
        messageService.deleteMessage(id: message.id, token: token) { (result: Result<MTEmptyResult, MTError>) in
            if case let .failure(error) = result {
                print("Error Occurred: \(error)")
                return
            }
            self.messagesStore[account]?.messages.remove(at: index)
        }
    }
    
    func deleteMessage(indexSet: IndexSet, account: Account) {
        for index in indexSet {
            let message = self.messagesStore[account]?.messages[index]
            guard let id = message?.id, let token = account.token else { return }
            messageService.deleteMessage(id: id, token: token) { (result: Result<MTEmptyResult, MTError>) in
                if case let .failure(error) = result {
                    print("Error Occurred: \(error)")
                    return
                }
                self.messagesStore[account]?.messages.remove(at: index)
            }
        }
    }
    
    func markMessageAsRead(messageData: Message, account: Account, seen: Bool = true) {
        guard let messageIndex = self.messagesStore[account]?.messages.firstIndex(where: { mes in
            mes.id == messageData.id
        }) else { return }
        guard let token = account.token else { return }
        messageService.markMessageAs(id: messageData.id, seen: seen, token: token) { (result: Result<MTMessage, MTError>) in
            switch result {
              case .success(let message):
                self.messagesStore[account]?.messages[messageIndex].data = message
              case .failure(let error):
                print("Error occurred \(error)")
            }
        }
    }
    
    func downloadMessageSource(message: Message, account: Account) {
        guard let token = account.token else { return }
        messageService.getSource(id: message.id, token: token) { (result: Result<MTMessageSource, MTError>) in
            switch result {
              case .success(let messageSource):
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let fileName: String
                if message.data.subject.isEmpty {
                    fileName = "message.eml"
                } else {
                    fileName = "\(message.data.subject).eml"
                }
                let file = paths[0].appendingPathComponent(fileName)
                do {
                    try messageSource.data.write(to: file, atomically: true, encoding: String.Encoding.utf8)
                } catch {
                    print("Error occurred \(error.localizedDescription)")
                    // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
                }
              case .failure(let error):
                print("Error occurred \(error)")
            }
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
