//
//  DetailRow.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import SwiftUI

@MainActor
public struct DetailRow: View {
    let label: String
    let value: String
    
    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
    
    public var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}
