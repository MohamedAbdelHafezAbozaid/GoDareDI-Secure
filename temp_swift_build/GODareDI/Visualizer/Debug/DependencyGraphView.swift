//
//  DependencyGraphView.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import SwiftUI

@available(iOS 17.0, macOS 10.15, *)
@MainActor
public struct DependencyGraphView: View {
    private let container: AdvancedDIContainer
    
    @State private var graph: DependencyGraph?
    @State private var analysis: GraphAnalysis?
    @State private var selectedTab: Int = 0
    @State private var showInteractiveView: Bool = false
    
    public init(container: AdvancedDIContainer) {
        self.container = container
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("View", selection: $selectedTab) {
                    Text("Overview").tag(0)
                    Text("Visualization").tag(1)
                    Text("Interactive").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content
                    TabView(selection: $selectedTab) {
                        overviewTab
                            .tag(0)
                        
                        visualizationTab
                            .tag(1)
                        
                        interactiveTab
                            .tag(2)
                }
                // TabView style removed for iOS 13 compatibility
            }
            // Navigation title removed for iOS 13 compatibility
        .onAppear {
                loadGraphData()
            }
        }
    }
    
    // MARK: - Overview Tab
    private var overviewTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Container Status
                VStack(alignment: .leading, spacing: 16) {
                    Text("Container Status")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Status: Active")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Registered Types: N/A")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                
                // Graph Information
                if graph != nil {
                    graphInfoSection(graph: graph!)
                }
                
                // Dashboard Update Section
                DashboardUpdateView(container: container, graph: graph, analysis: analysis)
            }
            .padding()
        }
    }
    
    // MARK: - Visualization Tab
    private var visualizationTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let graph = graph {
                    DependencyVisualizationView(graph: graph)
                } else {
                    VStack(spacing: 16) {
                        Text("📊")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("No Graph Data")
                        .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Load dependency graph to see visualization")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
            .padding()
        }
    }
    
    // MARK: - Interactive Tab
    private var interactiveTab: some View {
        VStack {
            if showInteractiveView {
                if let graph = graph {
                    #if os(macOS)
                    if #available(macOS 13.0, *) {
                        InteractiveDependencyGraphView(graph: graph)
                    } else {
                        Text("Interactive view requires macOS 13.0 or later")
                            .foregroundColor(.secondary)
                    }
                    #else
                    InteractiveDependencyGraphView(graph: graph)
                    #endif
                }
            } else {
                VStack(spacing: 20) {
                    Text("👆")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Interactive View")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Tap to enable interactive dependency graph visualization")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Enable Interactive View") {
                        showInteractiveView = true
                    }
                    .buttonStyle(DefaultButtonStyle())
                }
                .padding()
            }
        }
    }
    
    // MARK: - Helper Views
    private func graphInfoSection(graph: DependencyGraph) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Graph Information")
                .font(.headline)
                    .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Nodes: \(graph.nodes.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Edges: \(graph.edges.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let analysis = analysis {
                    Text("Analysis: \(analysis.isComplete ? "Complete" : "In Progress")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
    
    // MARK: - Data Loading
    private func loadGraphData() {
        // Simulate loading graph data
        // In a real implementation, this would load from the container
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: DispatchWorkItem {
            // Create sample graph data
            let sampleNodes = [
                DependencyNode(
                    id: "1", 
                    scope: .singleton, 
                    dependencies: ["2"], 
                    layer: 0, 
                    isCircular: false, 
                    position: CGPoint(x: 100, y: 100),
                    type: .service,
                    category: .business,
                    complexity: .low,
                    performanceMetrics: NodePerformanceMetrics(resolutionTime: 0.1, memoryFootprint: 1024, cacheHitRate: 0.8, resolutionCount: 1, lastResolved: Date()),
                    metadata: [:],
                    tags: []
                ),
                DependencyNode(
                    id: "2", 
                    scope: .scoped, 
                    dependencies: ["3"], 
                    layer: 1, 
                    isCircular: false, 
                    position: CGPoint(x: 200, y: 150),
                    type: .service,
                    category: .business,
                    complexity: .medium,
                    performanceMetrics: NodePerformanceMetrics(resolutionTime: 0.2, memoryFootprint: 2048, cacheHitRate: 0.9, resolutionCount: 2, lastResolved: Date()),
                    metadata: [:],
                    tags: []
                ),
                DependencyNode(
                    id: "3", 
                    scope: .transient, 
                    dependencies: [], 
                    layer: 2, 
                    isCircular: false, 
                    position: CGPoint(x: 150, y: 200),
                    type: .repository,
                    category: .data,
                    complexity: .low,
                    performanceMetrics: NodePerformanceMetrics(resolutionTime: 0.05, memoryFootprint: 512, cacheHitRate: 0.95, resolutionCount: 5, lastResolved: Date()),
                    metadata: [:],
                    tags: []
                )
            ]
            
            let sampleEdges = [
                DependencyEdge(
                    from: "1", 
                    to: "2", 
                    relationship: "depends_on", 
                    isCircular: false,
                    relationshipType: .dependency,
                    strength: .strong,
                    direction: .bidirectional,
                    performanceImpact: .low,
                    metadata: [:]
                ),
                DependencyEdge(
                    from: "2", 
                    to: "3", 
                    relationship: "uses", 
                    isCircular: false,
                    relationshipType: .dependency,
                    strength: .strong,
                    direction: .bidirectional,
                    performanceImpact: .low,
                    metadata: [:]
                )
            ]
            
            // Create a simple analysis with minimal data
            let analysis = GraphAnalysis(
                hasCircularDependencies: false,
                totalNodes: 3,
                totalDependencies: 2,
                maxDepth: 2,
                circularDependencyChains: [],
                analysisTime: 0.1,
                memoryUsage: 1024.0,
                cacheEfficiency: 0.8,
                isComplete: true,
                complexityMetrics: createDefaultComplexityMetrics(),
                performanceMetrics: createDefaultGraphPerformanceMetrics(),
                architectureMetrics: createDefaultArchitectureMetrics(),
                healthScore: createDefaultHealthScore(),
                recommendations: [],
                clusters: [],
                criticalPaths: []
            )
            
            self.graph = DependencyGraph(nodes: sampleNodes, edges: sampleEdges, analysis: analysis)
            self.analysis = analysis
        })
    }
    
    // MARK: - Helper Functions
    private func createDefaultComplexityMetrics() -> ComplexityMetrics {
        // Create a simple JSON structure for ComplexityMetrics
        let json = """
        {
            "cyclomaticComplexity": 1,
            "cognitiveComplexity": 1,
            "maintainabilityIndex": 85
        }
        """.data(using: .utf8)!
        return try! JSONDecoder().decode(ComplexityMetrics.self, from: json)
    }
    
    private func createDefaultGraphPerformanceMetrics() -> GraphPerformanceMetrics {
        let json = """
        {
            "averageResolutionTime": 0.1,
            "slowestResolution": 0.5,
            "fastestResolution": 0.01,
            "totalMemoryFootprint": 1024,
            "cacheHitRate": 0.8,
            "bottleneckNodes": [],
            "performanceTrend": "stable"
        }
        """.data(using: .utf8)!
        return try! JSONDecoder().decode(GraphPerformanceMetrics.self, from: json)
    }
    
    private func createDefaultArchitectureMetrics() -> ArchitectureMetrics {
        let json = """
        {
            "couplingScore": 0.3,
            "cohesionScore": 0.7,
            "layeredArchitecture": true,
            "dependencyInversion": true
        }
        """.data(using: .utf8)!
        return try! JSONDecoder().decode(ArchitectureMetrics.self, from: json)
    }
    
    private func createDefaultHealthScore() -> HealthScore {
        let json = """
        {
            "overall": 85,
            "performance": 90,
            "maintainability": 80,
            "testability": 85,
            "scalability": 75,
            "security": 90,
            "reliability": 85
        }
        """.data(using: .utf8)!
        return try! JSONDecoder().decode(HealthScore.self, from: json)
    }
}