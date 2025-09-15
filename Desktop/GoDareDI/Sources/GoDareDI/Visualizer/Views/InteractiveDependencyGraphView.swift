//
//  InteractiveDependencyGraphView.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import SwiftUI

@available(iOS 17.0, macOS 10.15, *)
@MainActor
public struct InteractiveDependencyGraphView: View {
    private let graph: DependencyGraph
    @State private var selectedNode: DependencyNode?
    @State private var zoomLevel: CGFloat = 1.0
    @State private var panOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    
    public init(graph: DependencyGraph) {
        self.graph = graph
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // Header with controls
            HStack {
                Text("Interactive Graph")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(graph.nodes.count) nodes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(graph.edges.count) edges")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Interactive Graph Canvas
            GeometryReader { geometry in
                ZStack {
                    // Background
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: max(geometry.size.width, 800), height: max(geometry.size.height, 600))
                    
                    // Edges
                    ForEach(Array(graph.edges.enumerated()), id: \.offset) { index, edge in
                        InteractiveEdgeView(edge: edge)
                    }
                    
                    // Nodes
                    ForEach(graph.nodes, id: \.id) { node in
                        InteractiveNodeView(
                            node: node,
                            isSelected: selectedNode?.id == node.id,
                            onTap: {
                                selectedNode = node
                            }
                        )
                    }
                }
                .scaleEffect(zoomLevel)
                .offset(panOffset)
                .gesture(
                    SimultaneousGesture(
                        // Pan gesture
                        DragGesture()
                            .onChanged { value in
                                panOffset = value.translation
                                isDragging = true
                            }
                            .onEnded { _ in
                                isDragging = false
                            },
                        
                        // Zoom gesture
                        MagnificationGesture()
                            .onChanged { value in
                                zoomLevel = max(0.5, min(value, 3.0))
                            }
                    )
                )
            }
            .frame(height: 400)
            .clipped()
            
            // Control Panel
            HStack(spacing: 16) {
                Button("Zoom In") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        zoomLevel = min(zoomLevel * 1.2, 3.0)
                    }
                }
                .buttonStyle(.bordered)
                
                Button("Zoom Out") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        zoomLevel = max(zoomLevel / 1.2, 0.5)
                    }
                }
                .buttonStyle(.bordered)
                
                Button("Reset View") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        zoomLevel = 1.0
                        panOffset = .zero
                    }
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                if let selectedNode = selectedNode {
                    Text("Selected: \(selectedNode.type)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Node Details Panel
            if let selectedNode = selectedNode {
                NodeDetailView(node: selectedNode)
            }
        }
        .padding()
    }
}

@available(iOS 17.0, macOS 10.15, *)
@MainActor
private struct InteractiveNodeView: View {
    let node: DependencyNode
    let isSelected: Bool
    let onTap: () -> Void
    
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
                .shadow(color: .black.opacity(0.2), radius: isSelected ? 4 : 2, x: 0, y: 2)
        )
        .position(x: node.position.x, y: node.position.y)
        .onTapGesture {
            onTap()
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

@available(iOS 17.0, macOS 10.15, *)
@MainActor
private struct InteractiveEdgeView: View {
    let edge: DependencyEdge
    
    var body: some View {
        Path { path in
            // For now, use placeholder positions since we're using String IDs
            path.move(to: CGPoint(x: 100, y: 100))
            path.addLine(to: CGPoint(x: 200, y: 200))
        }
        .stroke(
            Color.gray.opacity(0.5),
            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
        )
    }
}
