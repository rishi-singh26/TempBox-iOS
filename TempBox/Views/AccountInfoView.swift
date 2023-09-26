//
//  AccountInfoView.swift
//  TempBox
//
//  Created by Rishi Singh on 24/09/23.
//

import SwiftUI

struct AccountInfoView: View {
    @Environment(\.dismiss) var dismiss
    let account: Account
    
    @State private var isPasswordBlurred = true
    
    var body: some View {
        NavigationView {
            List {
                Section(footer: Text("If you wish to use this account on Web browser, You can copy the credentials to use on [mail.tm](https://www.mail.tm) official website. Please note, the password cannot be reset or changed.")) {
                    HStack {
                        Text("Status: ")
                            .font(.headline)
                        Circle()
                            .fill(account.isDisabled ? .red : .green)
                            .frame(width: 10, height: 10)
                        Text(account.isDisabled ? "Disabled" : "Active")
                    }
                    HStack {
                        Text("Address: ")
                            .font(.headline)
                        Text(account.address ?? "No address")
                        Spacer()
                        Button {
                            copyToClipboard(value: account.address ?? "No address")
                        } label: {
                            Image(systemName: "doc.on.doc")
                        }
                    }
                    HStack {
                        Text("Password: ")
                            .font(.headline)
                        Text(account.password ?? "No password")
                            .blur(radius: isPasswordBlurred ? 5 : 0)
                            .onTapGesture {
                                withAnimation {
                                    isPasswordBlurred.toggle()
                                }
                            }
                        Spacer()
                        Button {
                            copyToClipboard(value: account.password ?? "No password")
                        } label: {
                            Image(systemName: "doc.on.doc")
                        }
                    }
                }
                
                Section(footer: Text("Once you reach your Quota limit, you cannot receive any more messages. Deleting your previous messages will free up your used Quota.")) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Quota usage")
                                .font(.headline)
                            Spacer()
                            Text("\(getQuotaStering(from: account.quotaUsed, unit: SizeUnit.KB))/\(getQuotaStering(from: account.quotaLimit, unit: SizeUnit.MB))")
                                .font(.footnote)
                        }
                        .padding(.bottom, 6)
                        ProgressView(value: (Double(account.quotaUsed) / 100.0), total: (Double(account.quotaLimit) / 100.0))
                    }
                }
            }
            .navigationTitle(account.accountName ?? "Account Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.headline)
                    }
                }
            }
        }
    }
    
    func copyToClipboard(value: String) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = value
    }
    
    func getQuotaStering(from bytes: Int32, unit: SizeUnit) -> String {
        ByteConverterService(bytes: Double(bytes)).toHumanReadable(unit: unit)
    }
}

struct AccountInfoView_Previews: PreviewProvider {
    
    static var previews: some View {
        List {
            Section(footer: Text("If you wish to use this account on Web browser, You can copy the credentials to use on [mail.tm](https://www.mail.tm) official website. Please note, the password cannot be reset or changed.")) {
                HStack {
                    Text("Status")
                    Text("Data")
                        .blur(radius: 5)
                }
            }
            VStack {
                ProgressView(value: 50.0, total: 100.0) {
                    Text("20.0 MB / 40.0 MB")
                        .font(.footnote)
                }
                .padding(.vertical)
            }
        }
    }
}
