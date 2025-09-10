//
//  DependencyGraphSupportingViews.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import SwiftUI

// MARK: - Tab Button
@MainActor
public struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    public init(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Error Card
@MainActor
public struct ErrorCard: View {
    let message: String
    
    public init(message: String) {
        self.message = message
    }
    
    public var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            
            Text(message)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Loading Card
@MainActor
public struct LoadingCard: View {
    public init() {}
    
    public var body: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            
            Text("Loading dependency graph...")
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Statistics Card
@MainActor
public struct StatisticsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    public init(title: String, value: String, icon: String, color: Color) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .padding(.horizontal, 8)
        .background(Color.controlBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Visualization Type Card
@MainActor
public struct VisualizationTypeCard: View {
    let type: VisualizationType
    let isSelected: Bool
    let action: () -> Void
    
    public init(type: VisualizationType, isSelected: Bool, action: @escaping () -> Void) {
        self.type = type
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: iconForType(type))
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(type.rawValue.capitalized)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .padding(.horizontal, 8)
            .background(isSelected ? Color.blue : Color.controlBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func iconForType(_ type: VisualizationType) -> String {
        switch type {
        case .mermaid: return "chart.bar.doc.horizontal"
        case .graphviz: return "chart.bar.doc.horizontal.fill"
        case .json: return "doc.text"
        case .tree: return "tree"
        case .network: return "network"
        case .hierarchical: return "chart.tree"
        case .circular: return "arrow.clockwise"
        case .layered: return "layers"
        case .interactive: return "hand.tap"
        case .dashboard: return "chart.bar"
        case .heatmap: return "thermometer"
        case .timeline: return "clock"
        case .cluster: return "circle.grid.2x2"
        }
    }
}

