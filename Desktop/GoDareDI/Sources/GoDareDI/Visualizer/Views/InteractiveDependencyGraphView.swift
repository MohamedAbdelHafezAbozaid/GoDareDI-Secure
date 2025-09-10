//
//  InteractiveDependencyGraphView.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif
#if os(iOS)
import UIKit
#endif

@MainActor
@available(macOS 13.0, iOS 15.0, *)
public struct InteractiveDependencyGraphView: View {
    let graph: DependencyGraph
    @State private var selectedNode: DependencyNode?
    @State private var showNodeDetails = false
    @State private var selectedFilter: GraphFilter = .all
    @State private var searchText = ""
    @State private var showOnlyCircular = false
    @State private var groupByLayer = true
    @State private var expandedLayers: Set<String> = []
    
    public init(graph: DependencyGraph) {
        self.graph = graph
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header with Statistics
            headerSection
            
            // Filter and Search Controls
            filterSection
            
            // Main Content
            if groupByLayer {
                layeredGraphView
            } else {
                flatGraphView
            }
        }
        .sheet(isPresented: $showNodeDetails) {
            if let selectedNode = selectedNode {
                NodeDetailView(node: selectedNode, graph: graph)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Title and Overview
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dependency Graph")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Interactive visualization of your app's dependency structure")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            // Statistics Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                EnhancedStatCard(
                    title: "Total Services",
                    value: "\(graph.nodes.count)",
                    icon: "cube.box.fill",
                    color: .blue
                )
                
                EnhancedStatCard(
                    title: "Dependencies",
                    value: "\(graph.edges.count)",
                    icon: "arrow.triangle.branch",
                    color: .green
                )
                
                EnhancedStatCard(
                    title: "Circular Issues",
                    value: "\(graph.analysis.circularDependencyChains.count)",
                    icon: "exclamationmark.triangle.fill",
                    color: .red
                )
                
                EnhancedStatCard(
                    title: "Max Depth",
                    value: "\(graph.analysis.maxDepth)",
                    icon: "layers.fill",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color.controlBackground)
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search services...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            // Filter Controls - Restructured for better spacing
            VStack(spacing: 12) {
                // Filter Picker Row
                HStack {
                    Text("Filter by Scope:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(GraphFilter.allCases, id: \.self) { filter in
                            Text(filter.displayName).tag(filter)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .buttonStyle(.bordered)
                    
                    Spacer()
                }
                
                // Toggle Controls Row
                HStack(spacing: 20) {
                    // Toggle for circular dependencies
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Show Circular Only")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Toggle("", isOn: $showOnlyCircular)
                            .toggleStyle(SwitchToggleStyle(tint: .red))
                    }
                    
                    // Toggle for layer grouping
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Group by Layer")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Toggle("", isOn: $groupByLayer)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.controlBackground)
    }
    
    // MARK: - Layered Graph View
    private var layeredGraphView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(getLayeredNodes(), id: \.layer) { layerGroup in
                    LayerSectionView(
                        layer: layerGroup.layer,
                        nodes: layerGroup.nodes,
                        graph: graph,
                        isExpanded: expandedLayers.contains(layerGroup.layer),
                        onToggle: { toggleLayer(layerGroup.layer) },
                        onNodeTap: { node in
                            selectedNode = node
                            showNodeDetails = true
                        }
                    )
                }
            }
            .padding()
        }
    }
    
    // MARK: - Flat Graph View
    private var flatGraphView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(filteredNodes, id: \.id) { node in
                    EnhancedNodeRowView(
                        node: node,
                        graph: graph,
                        onTap: {
                            selectedNode = node
                            showNodeDetails = true
                        }
                    )
                }
            }
            .padding()
        }
    }
    
    // MARK: - Helper Methods
    private var filteredNodes: [DependencyNode] {
        var nodes = graph.nodes
        
        // Apply search filter
        if !searchText.isEmpty {
            nodes = nodes.filter { $0.id.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Apply scope filter
        switch selectedFilter {
        case .all:
            break
        case .singleton:
            nodes = nodes.filter { $0.scope == .singleton }
        case .transient:
            nodes = nodes.filter { $0.scope == .transient }
        case .scoped:
            nodes = nodes.filter { $0.scope == .scoped }
        case .lazy:
            nodes = nodes.filter { $0.scope == .lazy }
        }
        
        // Apply circular filter
        if showOnlyCircular {
            nodes = nodes.filter { $0.isCircular }
        }
        
        return nodes
    }
    
    private func getLayeredNodes() -> [LayerGroup] {
        let filtered = filteredNodes
        let grouped = Dictionary(grouping: filtered) { node in
            getLayerName(for: node)
        }
        
        return grouped.map { layer, nodes in
            LayerGroup(layer: layer, nodes: nodes.sorted { $0.id < $1.id })
        }.sorted { $0.layer < $1.layer }
    }
    
    private func getLayerName(for node: DependencyNode) -> String {
        if node.id.contains("API") || node.id.contains("Protocol") {
            return "🌐 API Layer"
        } else if node.id.contains("Repository") {
            return "🗄️ Repository Layer"
        } else if node.id.contains("UseCase") {
            return "🎯 Use Case Layer"
        } else if node.id.contains("ViewModel") {
            return "📱 Presentation Layer"
        } else if node.id.contains("Service") {
            return "⚙️ Service Layer"
        } else {
            return "🔧 Infrastructure Layer"
        }
    }
    
    private func toggleLayer(_ layer: String) {
        if expandedLayers.contains(layer) {
            expandedLayers.remove(layer)
        } else {
            expandedLayers.insert(layer)
        }
    }
}

// MARK: - Supporting Types
private enum GraphFilter: CaseIterable {
    case all, singleton, transient, scoped, lazy
    
    var displayName: String {
        switch self {
        case .all: return "All Services"
        case .singleton: return "Singletons"
        case .transient: return "Transient"
        case .scoped: return "Scoped"
        case .lazy: return "Lazy"
        }
    }
}

private struct LayerGroup {
    let layer: String
    let nodes: [DependencyNode]
}

// MARK: - Enhanced Stat Card
@MainActor
private struct EnhancedStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.controlBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Layer Section View
@MainActor
private struct LayerSectionView: View {
    let layer: String
    let nodes: [DependencyNode]
    let graph: DependencyGraph
    let isExpanded: Bool
    let onToggle: () -> Void
    let onNodeTap: (DependencyNode) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Layer Header
            Button(action: onToggle) {
                HStack {
                    Text(layer)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(nodes.count) services")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding()
                .background(Color.controlBackground)
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Layer Content
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(nodes, id: \.id) { node in
                        EnhancedNodeRowView(
                            node: node,
                            graph: graph,
                            onTap: { onNodeTap(node) }
                        )
                    }
                }
                .padding(.leading, 16)
                .padding(.top, 8)
            }
        }
    }
}

// MARK: - Enhanced Node Row View
@MainActor
private struct EnhancedNodeRowView: View {
    let node: DependencyNode
    let graph: DependencyGraph
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Scope Indicator
                Circle()
                    .fill(scopeColor(node.scope))
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(color: scopeColor(node.scope).opacity(0.3), radius: 2)
                
                // Node Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(node.id)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if node.isCircular {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    
                    HStack(spacing: 8) {
                        Text(node.scope.rawValue.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(scopeColor(node.scope).opacity(0.2))
                            .foregroundColor(scopeColor(node.scope))
                            .cornerRadius(4)
                        
                        Text("Layer \(node.layer)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Dependency Counts
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("\(dependenciesCount)")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("\(dependentsCount)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                // Chevron
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(Color.controlBackground)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.separator, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var dependenciesCount: Int {
        graph.edges.filter { $0.from == node.id }.count
    }
    
    private var dependentsCount: Int {
        graph.edges.filter { $0.to == node.id }.count
    }
    
    private func scopeColor(_ scope: DependencyScope) -> Color {
        switch scope {
        case .singleton:
            return .purple
        case .transient:
            return .blue
        case .scoped:
            return .green
        case .lazy:
            return .orange
        }
    }
}
