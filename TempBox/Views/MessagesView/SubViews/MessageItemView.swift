//
//  MessageItemView.swift
//  TempBox
//
//  Created by Rishi Singh on 26/09/23.
//

import SwiftUI
//import MailTMSwift

struct MessageItemView: View {
    let message: Message
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Circle()
                .fill(.gray)
                .frame(width: 12)
            VStack(alignment: .leading) {
                HStack {
                    Text(message.data.from.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .lineSpacing(1)
                    Spacer()
                    Text(message.data.createdAt.formatRelativeString(useTwentyFourHour: true))
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                Text(message.data.subject)
                Text(message.data.intro ?? "")
                    .foregroundColor(.secondary)
                    .lineLimit(2, reservesSpace: true)
            }
        }
    }
}

//struct MessageItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageItemView()
//    }
//}
