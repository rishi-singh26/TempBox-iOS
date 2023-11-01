//
//  MessagesViewModel.swift
//  TempBox
//
//  Created by Rishi Singh on 25/09/23.
//

import Foundation
import MailTMSwift

class MessagesViewModel: ObservableObject {
    @Published var messagesLoading = true
    @Published var messages = [Message]()
    
    @Published var showingErrorAlert = false
    @Published var errorAlertMessage = ""
    
    @Published var searchText = ""
    
    @Published var showDeleteMessageAlert = false
    @Published var selectedMessForDeletion: Message?
    
    let messageService = MTMessageService()
    
    init(account: Account) {
//        fetchMessages(for: account)
    }
    
//    func fetchMessages(for account: Account) {
//        guard let token = account.token else { return }
//        messageService.getAllMessages(token: token) { (result: Result<[MTMessage], MTError>) in
//            switch result {
//              case .success(let messages):
//                self.messages = messages
//              case .failure(let error):
//                self.showingErrorAlert = true
//                self.errorAlertMessage = "Error occured while getting messages\n\(error.localizedDescription)"
//            }
//            self.messagesLoading = false
//        }
//    }
}
