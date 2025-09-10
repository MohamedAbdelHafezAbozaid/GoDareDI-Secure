//
//  DependencyVisualizationView.swift
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
public struct DependencyVisualizationView: View {
    let graph: DependencyGraph
    @State private var selectedVisualizationType: VisualizationType = .mermaid
    @State private var outputFormat: OutputFormat = .mermaid
    @State private var showScopes = true
    @State private var showLifetimes = true
    @State private var showDependencies = true
    @State private var groupByLayer = false
    @State private var colorizeByScope = true
    @State private var interactive = true
    @State private var maxDepth = 10
    @State private var includeCircular = true
    @State private var enableAsyncRendering = true
    @State private var enableProgressTracking = true
    @State private var generationProgress: Progress?
    @State private var isGenerating = false
    @State private var selectedTab = 0
    
    public init(graph: DependencyGraph) {
        self.graph = graph
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            // Tab Selection
            tabSection
            
            // Content based on selected tab
            TabView(selection: $selectedTab) {
                // Configuration Tab
                configurationTab
                    .tag(0)
                
                // Visualization Tab
                visualizationTab
                    .tag(1)
                
                // Interactive Tab
                interactiveTab
                    .tag(2)
            }
            .tabViewStyle(DefaultTabViewStyle())
        }
        .navigationTitle("Dependency Visualization")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("Generate and customize dependency diagrams")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Quick Stats
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                QuickStatView(title: "Services", value: "\(graph.nodes.count)", icon: "cube.box", color: .blue)
                QuickStatView(title: "Dependencies", value: "\(graph.edges.count)", icon: "arrow.triangle.branch", color: .green)
                QuickStatView(title: "Circular", value: "\(graph.analysis.circularDependencyChains.count)", icon: "exclamationmark.triangle", color: .red)
            }
        }
        .padding()
        .background(Color.controlBackground)
    }
    
    // MARK: - Tab Section
    private var tabSection: some View {
        HStack(spacing: 0) {
            TabButton(
                title: "Configuration",
                icon: "slider.horizontal.3",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            TabButton(
                title: "Visualization",
                icon: "chart.bar.doc.horizontal",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            TabButton(
                title: "Interactive",
                icon: "hand.tap",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }
        }
        .background(Color.controlBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Configuration Tab
    private var configurationTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Visualization Type Selection
                configurationCard(
                    title: "Visualization Type",
                    icon: "chart.bar.doc.horizontal"
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose how to visualize your dependencies")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(VisualizationType.allCases, id: \.self) { type in
                                VisualizationTypeButton(
                                    type: type,
                                    isSelected: selectedVisualizationType == type
                                ) {
                                    selectedVisualizationType = type
                                }
                            }
                        }
                    }
                }
                
                // Output Format Selection
                configurationCard(
                    title: "Output Format",
                    icon: "doc.text"
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select the output format for your visualization")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(OutputFormat.allCases, id: \.self) { format in
                                OutputFormatButton(
                                    format: format,
                                    isSelected: outputFormat == format
                                ) {
                                    outputFormat = format
                                }
                            }
                        }
                    }
                }
                
                // Display Options
                configurationCard(
                    title: "Display Options",
                    icon: "eye"
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Customize what information to show")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            Toggle("Show Scopes", isOn: $showScopes)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                            
                            Toggle("Show Lifetimes", isOn: $showLifetimes)
                                .toggleStyle(SwitchToggleStyle(tint: .green))
                            
                            Toggle("Show Dependencies", isOn: $showDependencies)
                                .toggleStyle(SwitchToggleStyle(tint: .orange))
                            
                            Toggle("Group by Layer", isOn: $groupByLayer)
                                .toggleStyle(SwitchToggleStyle(tint: .purple))
                            
                            Toggle("Colorize by Scope", isOn: $colorizeByScope)
                                .toggleStyle(SwitchToggleStyle(tint: .red))
                            
                            Toggle("Interactive", isOn: $interactive)
                                .toggleStyle(SwitchToggleStyle(tint: .indigo))
                        }
                    }
                }
                
                // Advanced Options
                configurationCard(
                    title: "Advanced Options",
                    icon: "gearshape"
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Fine-tune visualization parameters")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Max Depth: \(maxDepth)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Slider(value: .constant(Double(maxDepth)), in: 1...20, step: 1)
                                }
                                Spacer()
                            }
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Include Circular Dependencies")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Toggle("", isOn: $includeCircular)
                                        .toggleStyle(SwitchToggleStyle(tint: .red))
                                }
                                Spacer()
                            }
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Async Rendering")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Toggle("", isOn: $enableAsyncRendering)
                                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                                }
                                Spacer()
                            }
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Progress Tracking")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Toggle("", isOn: $enableProgressTracking)
                                        .toggleStyle(SwitchToggleStyle(tint: .green))
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Visualization Tab
    private var visualizationTab: some View {
        VStack(spacing: 20) {
            // Generate Button
            Button(action: {
                Task {
                    await generateVisualization()
                }
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Generate Visualization")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .disabled(isGenerating)
            .padding(.horizontal)
            
            // Progress Indicator
            if isGenerating {
                VStack(spacing: 12) {
                    ProgressView(value: generationProgress?.fractionCompleted ?? 0)
                        .progressViewStyle(LinearProgressViewStyle())
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                    
                    Text("Generating visualization... \(Int((generationProgress?.fractionCompleted ?? 0) * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            // Visualization Output
            if !isGenerating {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Generated Visualization")
                                .font(.headline)
                            Spacer()
                            Button("Copy to Clipboard") {
                                copyToClipboard()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        
                        let config = getCurrentConfig()
                        let visualization = generateVisualization(config: config)
                        
                        Text(visualization)
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                            .background(Color.controlBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.separator, lineWidth: 1)
                            )
                            .textSelection(.enabled)
                    }
                    .padding()
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Interactive Tab
    private var interactiveTab: some View {
        VStack(spacing: 20) {
            Text("Interactive Graph View")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Explore your dependency graph interactively with the enhanced view below")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            InteractiveDependencyGraphView(graph: graph)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
    }
    
    // MARK: - Helper Methods
    private func configurationCard<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            content()
        }
        .padding()
        .background(Color.controlBackground)
        .cornerRadius(16)
    }
    
    private func getCurrentConfig() -> VisualizationConfig {
        VisualizationConfig(
            type: selectedVisualizationType,
            format: outputFormat,
            showScopes: showScopes,
            showLifetimes: showLifetimes,
            showDependencies: showDependencies,
            groupByLayer: groupByLayer,
            colorizeByScope: colorizeByScope,
            interactive: interactive,
            maxDepth: maxDepth,
            includeCircular: includeCircular,
            enableAsyncRendering: enableAsyncRendering,
            enableProgressTracking: enableProgressTracking
        )
    }
    
    private func generateVisualization() async {
        isGenerating = true
        generationProgress = Progress()
        
        // Simulate generation time
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        isGenerating = false
        generationProgress = nil
    }
    
    private func generateVisualization(config: VisualizationConfig) -> String {
        // Filter graph based on configuration
        let filteredGraph = filterGraphForConfiguration(graph, config: config)
        
        let result: String
        
        switch config.type {
        case .mermaid:
            result = DiagramGenerators.generateMermaidDiagram(from: filteredGraph)
        case .graphviz:
            result = DiagramGenerators.generateGraphvizDiagram(from: filteredGraph)
        case .json:
            result = DiagramGenerators.generateJSONVisualization(from: filteredGraph, analysis: filteredGraph.analysis)
        case .tree:
            result = DiagramGenerators.generateTreeVisualization(from: filteredGraph, maxDepth: config.maxDepth)
        case .network:
            result = DiagramGenerators.generateNetworkVisualization(from: filteredGraph)
        case .hierarchical:
            result = DiagramGenerators.generateHierarchicalVisualization(from: filteredGraph)
        case .circular:
            result = DiagramGenerators.generateCircularVisualization(from: filteredGraph)
        case .layered:
            result = DiagramGenerators.generateLayeredVisualization(from: filteredGraph)
        case .interactive:
            result = DiagramGenerators.generateInteractiveVisualization(from: filteredGraph)
        case .dashboard:
            result = DiagramGenerators.generateDashboardVisualization(from: filteredGraph)
        case .heatmap:
            result = DiagramGenerators.generateHeatmapVisualization(from: filteredGraph)
        case .timeline:
            result = DiagramGenerators.generateTimelineVisualization(from: filteredGraph)
        case .cluster:
            result = DiagramGenerators.generateClusterVisualization(from: filteredGraph)
        @unknown default:
            result = "Unsupported visualization type: \(config.type.rawValue)"
        }
        
        return result
    }
    
    private func filterGraphForConfiguration(_ graph: DependencyGraph, config: VisualizationConfig) -> DependencyGraph {
        var filteredNodes = graph.nodes
        var filteredEdges = graph.edges
        
        // Filter by max depth if specified
        if config.maxDepth > 0 {
            filteredNodes = filteredNodes.filter { $0.layer <= config.maxDepth }
            let validNodeIds = Set(filteredNodes.map { $0.id })
            filteredEdges = filteredEdges.filter { validNodeIds.contains($0.from) && validNodeIds.contains($0.to) }
        }
        
        // Filter circular dependencies if disabled
        if !config.includeCircular {
            filteredNodes = filteredNodes.filter { !$0.isCircular }
            filteredEdges = filteredEdges.filter { !$0.isCircular }
        }
        
        // Create filtered graph
        let filteredGraph = DependencyGraph(
            nodes: filteredNodes,
            edges: filteredEdges,
            analysis: graph.analysis
        )
        
        return filteredGraph
    }
    
    private func copyToClipboard() {
        let config = getCurrentConfig()
        let visualization = generateVisualization(config: config)
        
        #if os(iOS)
        UIPasteboard.general.string = visualization
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(visualization, forType: .string)
        #endif
    }
}

// MARK: - Supporting Views
@MainActor
private struct QuickStatView: View {
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
private struct VisualizationTypeButton: View {
    let type: VisualizationType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: iconForType(type))
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(type.rawValue.capitalized)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.blue : Color.controlBackground)
            .cornerRadius(12)
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

@MainActor
private struct OutputFormatButton: View {
    let format: OutputFormat
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: iconForFormat(format))
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .green)
                
                Text(format.rawValue.capitalized)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.green : Color.controlBackground)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func iconForFormat(_ format: OutputFormat) -> String {
        switch format {
        case .mermaid: return "chart.bar.doc.horizontal"
        case .dot: return "doc.text"
        case .json: return "doc.text"
        case .html: return "doc.html"
        case .svg: return "doc.richtext"
        case .png: return "photo"
        case .pdf: return "doc.richtext"
        case .markdown: return "doc.text"
        case .csv: return "tablecells"
        case .excel: return "tablecells.fill"
        case .interactive: return "hand.tap"
        }
    }
}
