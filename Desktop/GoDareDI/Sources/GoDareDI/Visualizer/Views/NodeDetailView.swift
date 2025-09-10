//
//  NodeDetailView.swift
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
public struct NodeDetailView: View {
    let node: DependencyNode
    let graph: DependencyGraph
    @Environment(\.dismiss) private var dismiss
    
    public init(node: DependencyNode, graph: DependencyGraph) {
        self.node = node
        self.graph = graph
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Enhanced Node Header
                    enhancedNodeHeaderView
                    
                    // Dependencies Section
                    dependenciesSection
                    
                    // Dependents Section
                    dependentsSection
                    
                    // Enhanced Metadata Section
                    enhancedMetadataSection
                    
                    // Performance Metrics (always available since graph.analysis is not optional)
                    performanceMetricsSection(analysis: graph.analysis)
                }
                .padding()
            }
            .navigationTitle("Service Details")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                #elseif os(macOS)
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                #endif
            }
        }
    }
    
    // MARK: - Enhanced Node Header
    private var enhancedNodeHeaderView: some View {
        VStack(spacing: 16) {
            // Main Info Card
            HStack(spacing: 16) {
                // Scope Indicator
                ZStack {
                    Circle()
                        .fill(scopeColor(node.scope))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: scopeIcon(node.scope))
                        .foregroundColor(.white)
                        .font(.title2)
//                        .fontWeight(.medium)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(node.id)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(2)
                    
                    HStack(spacing: 12) {
                        // Scope Badge
                        Text(node.scope.rawValue.capitalized)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(scopeColor(node.scope).opacity(0.2))
                            .foregroundColor(scopeColor(node.scope))
                            .cornerRadius(20)
                        
                        // Layer Badge
                        Text("Layer \(node.layer)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(20)
                        
                        // Circular Dependency Warning
                        if node.isCircular {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text("Circular")
                            }
                            .font(.caption)
//                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(20)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.controlBackground)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            
            // Quick Stats Row
            HStack(spacing: 16) {
                QuickStatCard(
                    title: "Dependencies",
                    value: "\(dependenciesCount)",
                    icon: "arrow.down",
                    color: .green
                )
                
                QuickStatCard(
                    title: "Dependents",
                    value: "\(dependentsCount)",
                    icon: "arrow.up",
                    color: .orange
                )
                
                QuickStatCard(
                    title: "Depth",
                    value: "\(node.layer)",
                    icon: "layers",
                    color: .blue
                )
            }
        }
    }
    
    // MARK: - Dependencies Section
    private var dependenciesSection: some View {
        let dependencies = graph.edges.filter { $0.from == node.id }
        
        if dependencies.isEmpty {
            return AnyView(
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dependencies")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("This service has no dependencies")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
                .padding()
                .background(Color.controlBackground)
                .cornerRadius(12)
            )
        }
        
        return AnyView(
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "arrow.down")
                        .foregroundColor(.green)
                    Text("Dependencies (\(dependencies.count))")
                        .font(.headline)
                    Spacer()
                }
                
                LazyVStack(spacing: 8) {
                    ForEach(dependencies, id: \.to) { edge in
                        DependencyRowView(
                            id: edge.to,
                            relationship: edge.relationship,
                            isCircular: edge.isCircular,
                            color: .green
                        )
                    }
                }
            }
            .padding()
            .background(Color.controlBackground)
            .cornerRadius(12)
        )
    }
    
    // MARK: - Dependents Section
    private var dependentsSection: some View {
        let dependents = graph.edges.filter { $0.to == node.id }
        
        if dependents.isEmpty {
            return AnyView(
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dependents")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("This service is not used by any other service")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
                .padding()
                .background(Color.controlBackground)
                .cornerRadius(12)
            )
        }
        
        return AnyView(
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "arrow.up")
                        .foregroundColor(.orange)
                    Text("Dependents (\(dependents.count))")
                        .font(.headline)
                    Spacer()
                }
                
                LazyVStack(spacing: 8) {
                    ForEach(dependents, id: \.from) { edge in
                        DependencyRowView(
                            id: edge.from,
                            relationship: edge.relationship,
                            isCircular: edge.isCircular,
                            color: .orange
                        )
                    }
                }
            }
            .padding()
            .background(Color.controlBackground)
            .cornerRadius(12)
        )
    }
    
    // MARK: - Enhanced Metadata Section
    private var enhancedMetadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("Service Information")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                MetadataRow(label: "Service Type", value: getServiceType(), icon: "cube.box")
                MetadataRow(label: "Scope", value: node.scope.rawValue.capitalized, icon: "circle.fill")
                MetadataRow(label: "Layer", value: "\(node.layer)", icon: "layers")
                MetadataRow(label: "Circular", value: node.isCircular ? "Yes" : "No", icon: "arrow.clockwise")
                MetadataRow(label: "Dependencies", value: "\(dependenciesCount)", icon: "arrow.down")
                MetadataRow(label: "Dependents", value: "\(dependentsCount)", icon: "arrow.up")
            }
        }
        .padding()
        .background(Color.controlBackground)
        .cornerRadius(12)
    }
    
    // MARK: - Performance Metrics Section
    private func performanceMetricsSection(analysis: GraphAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar")
                    .foregroundColor(.purple)
                    .font(.title2)
                Text("Performance Metrics")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                MetricRow(label: "Analysis Time", value: String(format: "%.2fms", analysis.analysisTime * 1000), icon: "clock")
                MetricRow(label: "Memory Usage", value: String(format: "%.2fMB", analysis.memoryUsage), icon: "memorychip")
                MetricRow(label: "Cache Efficiency", value: String(format: "%.1f%%", analysis.cacheEfficiency), icon: "bolt")
                MetricRow(label: "Total Nodes", value: "\(analysis.totalNodes)", icon: "circle.grid.2x2")
            }
        }
        .padding()
        .background(Color.controlBackground)
        .cornerRadius(12)
    }
    
    // MARK: - Helper Methods
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
    
    private func scopeIcon(_ scope: DependencyScope) -> String {
        switch scope {
        case .singleton:
            return "1.circle"
        case .transient:
            return "arrow.clockwise"
        case .scoped:
            return "scope"
        case .lazy:
            return "bed.double"
        }
    }
    
    private func getServiceType() -> String {
        if node.id.contains("API") {
            return "API Service"
        } else if node.id.contains("Repository") {
            return "Repository"
        } else if node.id.contains("UseCase") {
            return "Use Case"
        } else if node.id.contains("ViewModel") {
            return "View Model"
        } else if node.id.contains("Service") {
            return "Service"
        } else {
            return "Component"
        }
    }
}

// MARK: - Supporting Views
@MainActor
private struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            Text(value)
                .font(.title2)
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
    }
}

@MainActor
private struct DependencyRowView: View {
    let id: String
    let relationship: String
    let isCircular: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(id)
                .font(.body)
                .fontWeight(.medium)
            
            if isCircular {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Spacer()
            
            Text(relationship)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(color.opacity(0.1))
                .cornerRadius(8)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.controlBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

@MainActor
private struct MetadataRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
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
        .background(Color.controlBackground)
        .cornerRadius(8)
    }
}

@MainActor
private struct MetricRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
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
        .background(Color.controlBackground)
        .cornerRadius(8)
    }
}
