//
//  DashboardUpdateView.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import SwiftUI

@MainActor
public struct DashboardUpdateView: View {
    private let container: AdvancedDIContainer
    private let graph: DependencyGraph?
    private let analysis: GraphAnalysis?
    
    @State private var isUpdatingDashboard = false
    @State private var dashboardUpdateMessage: String?
    
    public init(container: AdvancedDIContainer, graph: DependencyGraph?, analysis: GraphAnalysis?) {
        self.container = container
        self.graph = graph
        self.analysis = analysis
    }
    
    // Computed property to get token from container
    private var token: String? {
        if let containerImpl = container as? AdvancedDIContainerImpl {
            return containerImpl.token
        }
        return nil
    }
    
    // Computed property to check if container has valid token
    private var hasValidToken: Bool {
        if let containerImpl = container as? AdvancedDIContainerImpl {
            return containerImpl.hasValidToken
        }
        return false
    }
    
    public var body: some View {
        if hasValidToken {
            VStack(spacing: 12) {
                HStack {
                    Text("📊 Dashboard Sync")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                Button(action: {
                    Task {
                        await updateDashboard()
                    }
                }) {
                    HStack {
                        if isUpdatingDashboard {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.up.circle.fill")
                        }
                        Text(isUpdatingDashboard ? "Updating..." : "Update Dashboard")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isUpdatingDashboard ? Color.gray : Color.blue)
                    .cornerRadius(10)
                }
                .disabled(isUpdatingDashboard)
                
                if let message = dashboardUpdateMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(message.contains("✅") ? .green : .red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Dashboard Update Function
    private func updateDashboard() async {
        guard let token = token, let graph = graph, let analysis = analysis else {
            dashboardUpdateMessage = "❌ Missing required data for dashboard update"
            return
        }
        
        isUpdatingDashboard = true
        dashboardUpdateMessage = nil
        
        do {
            // Get performance metrics
            let metrics = await container.getPerformanceMetrics()
            
            // Create dependency info
            let dependencyInfo = DependencyInfo(
                version: "1.0.0",
                dependencies: createDependencyNodes(from: graph),
                nodes: convertToGraphNodes(graph.nodes),
                edges: convertToGraphEdges(graph.edges),
                analysis: analysis,
                performanceMetrics: metrics
            )
            
            // Update dashboard
            let syncProvider = DefaultDashboardSyncProvider(token: token)
            try await syncProvider.updateDashboard(with: dependencyInfo)
            
            dashboardUpdateMessage = "✅ Dashboard updated successfully!"
            
        } catch {
            dashboardUpdateMessage = "❌ Failed to update dashboard: \(error.localizedDescription)"
        }
        
        isUpdatingDashboard = false
        
        // Clear message after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            dashboardUpdateMessage = nil
        }
    }
    
    private func createDependencyNodes(from graph: DependencyGraph) -> [DashboardDependencyNode] {
        return graph.nodes.map { node in
            let dependencies = graph.edges
                .filter { $0.from == node.id }
                .map { $0.to }
            
            return DashboardDependencyNode(
                id: node.id,
                type: node.type.rawValue,
                scope: node.scope.rawValue,
                lifetime: "application", // Default lifetime since DependencyNode doesn't have lifetime
                dependencies: dependencies,
                isRegistered: true,
                resolutionTime: nil
            )
        }
    }
    
    private func convertToGraphNodes(_ dependencyNodes: [DependencyNode]) -> [GraphNode] {
        return dependencyNodes.map { node in
            GraphNode(
                id: node.id,
                type: node.type.rawValue,
                scope: node.scope,
                lifetime: .application // Default lifetime
            )
        }
    }
    
    private func convertToGraphEdges(_ dependencyEdges: [DependencyEdge]) -> [GraphEdge] {
        return dependencyEdges.map { edge in
            GraphEdge(
                from: edge.from,
                to: edge.to,
                type: .dependency
            )
        }
    }
}
