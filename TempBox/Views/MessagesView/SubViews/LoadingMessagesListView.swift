//
//  LoadingMessagesListView.swift
//  TempBox
//
//  Created by Rishi Singh on 26/09/23.
//

import SwiftUI

struct LoadingMessagesListView: View {
    var body: some View {
        List {
            ForEach(0..<10) { _ in
                HStack(alignment: .firstTextBaseline) {
                    Circle()
                        .fill(.gray)
                        .frame(width: 12)
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Rame@emailcom")
                                .font(.title3)
                                .fontWeight(.bold)
                                .lineSpacing(1)
                            Spacer()
                            Text("19:23")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                        Text("This is the subject of a email")
                        Text("This is the message This is the message This is the message This is the message This is the message This is the message")
                            .foregroundColor(.secondary)
                            .lineLimit(2, reservesSpace: true)
                    }
                }
                .redacted(reason: .placeholder)
                .shimmering()
            }
        }
        .listStyle(.plain)
    }
}

struct LoadingMessagesListView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingMessagesListView()
    }
}
