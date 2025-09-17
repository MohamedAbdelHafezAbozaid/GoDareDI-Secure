//
//  DependencyGraphSupportingViews.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import SwiftUI

@available(iOS 17.0, macOS 10.15, *)
@MainActor
public struct DependencyGraphSupportingViews: View {
    private let container: AdvancedDIContainer
    
    public init(container: AdvancedDIContainer) {
        self.container = container
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dependency Graph Support")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Container Status: Active")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Graph Visualization: Available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
}

@available(iOS 17.0, macOS 10.15, *)
@MainActor
public struct GraphLegendView: View {
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Legend")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 12, height: 12)
                Text("Dependency")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 12, height: 12)
                Text("Service")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
}
