//
//  DetailRow.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import SwiftUI

@available(iOS 17.0, macOS 10.15, *)
@MainActor
public struct DetailRow: View {
    private let title: String
    private let value: String
    private let icon: String
    private let color: Color
    
    public init(title: String, value: String, icon: String, color: Color = .primary) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            Text("🔧")
                .foregroundColor(color)
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(value)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

@available(iOS 17.0, macOS 10.15, *)
@MainActor
public struct InfoRow: View {
    private let title: String
    private let description: String
    private let icon: String
    
    public init(title: String, description: String, icon: String) {
        self.title = title
        self.description = description
        self.icon = icon
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            Text("🔧")
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}
