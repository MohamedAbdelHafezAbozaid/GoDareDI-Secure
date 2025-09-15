//
//  DependencyVisualizationView.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import SwiftUI

@available(iOS 17.0, macOS 10.15, *)
@MainActor
public struct DependencyVisualizationView: View {
    private let graph: DependencyGraph
    @State private var selectedNode: DependencyNode?
    @State private var zoomLevel: CGFloat = 1.0
    
    public init(graph: DependencyGraph) {
        self.graph = graph
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Dependency Graph")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(graph.nodes.count) nodes, \(graph.edges.count) edges")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Graph Visualization
            ScrollView([.horizontal, .vertical]) {
                ZStack {
                    // Background
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 800, height: 600)
                    
                    // Edges
                    ForEach(Array(graph.edges.enumerated()), id: \.offset) { index, edge in
                        EdgeView(edge: edge)
                    }
                    
                    // Nodes
                    ForEach(graph.nodes, id: \.id) { node in
                        NodeView(node: node, isSelected: selectedNode?.id == node.id)
                            .onTapGesture {
                                selectedNode = node
                            }
                    }
                }
                .scaleEffect(zoomLevel)
            }
            .frame(height: 400)
            
            // Controls
            HStack {
                Button("Zoom In") {
                    withAnimation {
                        zoomLevel = min(zoomLevel * 1.2, 3.0)
                    }
                }
                .buttonStyle(.bordered)
                
                Button("Zoom Out") {
                    withAnimation {
                        zoomLevel = max(zoomLevel / 1.2, 0.5)
                    }
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Reset") {
                    withAnimation {
                        zoomLevel = 1.0
                    }
                }
                .buttonStyle(.bordered)
            }
            
            // Node Details
            if let selectedNode = selectedNode {
                NodeDetailView(node: selectedNode)
            }
        }
        .padding()
    }
}

@available(iOS 17.0, macOS 10.15, *)
@MainActor
private struct NodeView: View {
    let node: DependencyNode
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(node.type.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Text(node.scope.rawValue)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.blue : Color.green)
        )
        .position(x: node.position.x, y: node.position.y)
    }
}

@available(iOS 17.0, macOS 10.15, *)
@MainActor
private struct EdgeView: View {
    let edge: DependencyEdge
    
    var body: some View {
        Path { path in
            // For now, use placeholder positions since we're using String IDs
            path.move(to: CGPoint(x: 100, y: 100))
            path.addLine(to: CGPoint(x: 200, y: 200))
        }
        .stroke(Color.gray.opacity(0.5), lineWidth: 2)
    }
}
