//
//  NodeDetailView.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import SwiftUI

@available(iOS 17.0, macOS 10.15, *)
@MainActor
public struct NodeDetailView: View {
    private let node: DependencyNode
    
    public init(node: DependencyNode) {
        self.node = node
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Node Details")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                MetadataRow(
                    label: "Type",
                    value: node.type.rawValue,
                    icon: "tag"
                )
                
                MetadataRow(
                    label: "Scope",
                    value: node.scope.rawValue,
                    icon: "scope"
                )
                
                // Lifetime information not available in current node structure
                if false {
                    MetadataRow(
                        label: "Lifetime",
                        value: "N/A",
                        icon: "clock"
                    )
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
}

@available(iOS 17.0, macOS 10.15, *)
@MainActor
private struct MetadataRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text("🔧")
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
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
private struct MetricRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text("🔧")
                .foregroundColor(.purple)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
