//
//  DashboardUpdateView.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import SwiftUI

@available(iOS 18.0, macOS 10.15, *)
@MainActor
public struct DashboardUpdateView: View {
    private let container: AdvancedDIContainer
    private let graph: DependencyGraph?
    private let analysis: GraphAnalysis?
    
    public init(container: AdvancedDIContainer, graph: DependencyGraph?, analysis: GraphAnalysis?) {
        self.container = container
        self.graph = graph
        self.analysis = analysis
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dashboard Update")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let graph = graph, let analysis = analysis {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dependencies: \(graph.nodes.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Connections: \(graph.edges.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Analysis Complete: \(analysis.isComplete ? "Yes" : "No")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("No graph data available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
}
