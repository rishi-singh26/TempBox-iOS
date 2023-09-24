//
//  AccountService.swift
//  TempBox
//
//  Created by Rishi Singh on 23/09/23.

import Foundation
import Combine
import MailTMSwift
import CoreData

protocol AccountServiceProtocol {
    var activeAccountsPublisher: AnyPublisher<[Account], Never> { get }
    var archivedAccountsPublisher: AnyPublisher<[Account], Never> { get }
    var availableDomainsPublisher: AnyPublisher<[MTDomain], Never> { get }
    
    var activeAccounts: [Account] { get }
    var archivedAccounts: [Account] { get }
    var availableDomains: [MTDomain] { get }
    var isDomainsLoading: Bool { get }
    
    func archiveAccount(account: Account)
    func activateAccount(account: Account)
    func removeAccount(account: Account)
    func deleteAndRemoveAccount(account: Account) -> AnyPublisher<Never, MTError>
}

class AccountService: NSObject, AccountServiceProtocol {
    // MARK: Account properties
    var activeAccountsPublisher: AnyPublisher<[Account], Never> {
        $activeAccounts.eraseToAnyPublisher()
    }
    
    var archivedAccountsPublisher: AnyPublisher<[Account], Never> {
        $archivedAccounts.eraseToAnyPublisher()
    }
    
    var availableDomainsPublisher: AnyPublisher<[MTDomain], Never> {
        $availableDomains.eraseToAnyPublisher()
    }
    
    var isDomainsLoadingPublisher: AnyPublisher<Bool, Never> {
        $isDomainsLoading.eraseToAnyPublisher()
    }
    
    var totalAccountsCount = 0
    @Published var activeAccounts: [Account] = []
    @Published var archivedAccounts: [Account] = []
    
    // MARK: Domain properties
    @Published var availableDomains: [MTDomain] = []
    @Published var isDomainsLoading = false
    
    private var mtAccountService: MTAccountService
    private var domainService: MTDomainService
    
    var subscriptions = Set<AnyCancellable>()
    
    init(
        accountService: MTAccountService,
        domainService: MTDomainService
    ) {
        
        self.domainService = domainService
        self.mtAccountService = accountService
        super.init()
        
        self.getDomains()
    }
    
    private func getDomains() {
        isDomainsLoading = true
        domainService.getAllDomains()
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isDomainsLoading = false
                //                if case let .failure(error) = completion {
                //                    Self.logger.error("\(#function) \(#line): \(error.localizedDescription)")
                //                }
            } receiveValue: { [weak self] domains in
                guard let self = self else { return }
                self.availableDomains = domains
                    .filter { $0.isActive && !$0.isPrivate }
            }
            .store(in: &subscriptions)
        
    }
    
    func archiveAccount(account: Account) {
        account.isArchived = true
        //        repository.update(account: account)
    }
    
    func activateAccount(account: Account) {
        account.isArchived = false
        //        repository.update(account: account)
    }
    
    func removeAccount(account: Account) {
        //        repository.delete(account: account)
    }
    
    func deleteAndRemoveAccount(account: Account) -> AnyPublisher<Never, MTError> {
        self.mtAccountService.deleteAccount(id: account.id ?? "", token: account.token ?? "")
            .share()
            .ignoreOutput()
            .handleEvents(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .finished = completion {
                    self.removeAccount(account: account)
                }
            })
            .eraseToAnyPublisher()
    }
    
    //    private func accountsdidChange() {
    //        guard let results = fetchController.fetchedObjects else {
    //            return
    //        }
    //        var tempActiveAccounts = [Account]()
    //        var tempArchivedAccounts = [Account]()
    //        for result in results where !result.isDeleted {
    //            if result.isArchived {
    //                tempArchivedAccounts.append(result)
    //            } else {
    //                tempActiveAccounts.append(result)
    //            }
    //        }
    //
    //        activeAccounts = tempActiveAccounts
    //        archivedAccounts = tempArchivedAccounts
    //        self.totalAccountsCount = results.count
    //    }
    
}

//extension AccountService:  NSFetchedResultsControllerDelegate {
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        accountsdidChange()
//    }
//
//}
