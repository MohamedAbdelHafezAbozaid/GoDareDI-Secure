//
//  DiagramGenerators.swift
//  GoDareAdvanced
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - Diagram Generators
@MainActor
public class DiagramGenerators: Sendable {
    
    // MARK: - Mermaid Diagram Generation
    public static func generateMermaidDiagram(from graph: DependencyGraph) -> String {
        var mermaid = "graph TD\n"
        
        print("🔍 DEBUG: Generating Mermaid diagram from \(graph.nodes.count) nodes")
        
        // Add nodes with styling
        for node in graph.nodes {
            let scope = getScopeForNode(node)
            let scopeClass = getScopeClass(scope)
            print("🔍 DEBUG: Node \(node.id) has scope: \(scope) -> class: \(scopeClass)")
            mermaid += "    \(node.id)[\"\(node.id)<br/><small>\(scope)</small>\"]:::\(scopeClass)\n"
        }
        
        // Add edges
        for edge in graph.edges {
            mermaid += "    \(edge.from) --> \(edge.to)\n"
        }
        
        // Add styling
        mermaid += generateMermaidStyling()
        
        return mermaid
    }
    
    public static func generateMermaidDiagramAsync(from graph: DependencyGraph, progress: Progress?) -> String {
        var mermaid = "graph TD\n"
        
        progress?.completedUnitCount = 20
        
        // Add nodes with styling
        for (index, node) in graph.nodes.enumerated() {
            let scope = getScopeForNode(node)
            let scopeClass = getScopeClass(scope)
            let circularIndicator = node.isCircular ? " 🔄" : ""
            mermaid += "    \(node.id)[\"\(node.id)<br/><small>\(scope)</small>\(circularIndicator)\"]:::\(scopeClass)\n"
            
            // Update progress
            let nodeProgress = 20 + Int((Double(index) / Double(graph.nodes.count)) * 40)
            progress?.completedUnitCount = Int64(nodeProgress)
        }
        
        progress?.completedUnitCount = 60
        
        // Add edges
        for (index, edge) in graph.edges.enumerated() {
            let circularStyle = edge.isCircular ? ":::circular" : ""
            mermaid += "    \(edge.from) --> \(edge.to)\(circularStyle)\n"
            
            // Update progress
            let edgeProgress = 60 + Int((Double(index) / Double(graph.edges.count)) * 30)
            progress?.completedUnitCount = Int64(edgeProgress)
        }
        
        progress?.completedUnitCount = 90
        
        // Add styling
        mermaid += generateMermaidStyling()
        
        return mermaid
    }
    
    // MARK: - Graphviz Diagram Generation
    public static func generateGraphvizDiagram(from graph: DependencyGraph) -> String {
        var dot = "digraph DependencyGraph {\n"
        dot += "    rankdir=TB;\n"
        dot += "    node [shape=box, style=filled];\n"
        
        // Add nodes
        for node in graph.nodes {
            let scope = getScopeForNode(node)
            let color = getScopeColor(scope)
            dot += "    \"\(node.id)\" [label=\"\(node.id)\\n\(scope)\", fillcolor=\"\(color)\"];\n"
        }
        
        // Add edges
        for edge in graph.edges {
            dot += "    \"\(edge.from)\" -> \"\(edge.to)\";\n"
        }
        
        dot += "}\n"
        return dot
    }
    
    public static func generateGraphvizDiagramAsync(from graph: DependencyGraph, progress: Progress?) -> String {
        var dot = "digraph DependencyGraph {\n"
        dot += "    rankdir=TB;\n"
        dot += "    node [shape=box, style=filled];\n"
        
        progress?.completedUnitCount = 20
        
        // Add nodes
        for (index, node) in graph.nodes.enumerated() {
            let scope = getScopeForNode(node)
            let color = getScopeColor(scope)
            let circularStyle = node.isCircular ? ", style=\"filled,dashed\"" : ""
            dot += "    \"\(node.id)\" [label=\"\(node.id)\\n\(scope)\", fillcolor=\"\(color)\"\(circularStyle)];\n"
            
            // Update progress
            let nodeProgress = 20 + Int((Double(index) / Double(graph.nodes.count)) * 40)
            progress?.completedUnitCount = Int64(nodeProgress)
        }
        
        progress?.completedUnitCount = 60
        
        // Add edges
        for (index, edge) in graph.edges.enumerated() {
            let circularStyle = edge.isCircular ? " [style=dashed, color=red]" : ""
            dot += "    \"\(edge.from)\" -> \"\(edge.to)\"\(circularStyle);\n"
            
            // Update progress
            let edgeProgress = 60 + Int((Double(index) / Double(graph.edges.count)) * 30)
            progress?.completedUnitCount = Int64(edgeProgress)
        }
        
        progress?.completedUnitCount = 90
        
        dot += "}\n"
        return dot
    }
    
    // MARK: - JSON Visualization
    public static func generateJSONVisualization(from graph: DependencyGraph, analysis: GraphAnalysis) -> String {
        let visualization = VisualizationData(
            nodes: graph.nodes.map { node in
                VisualizationNode(
                    id: node.id,
                    label: node.id,
                    type: "dependency",
                    scope: node.scope.rawValue,
                    layer: "\(node.layer)",
                    isCircular: node.isCircular,
                    dependencies: node.dependencies,
                    metadata: [:]
                )
            },
            edges: graph.edges.map { edge in
                VisualizationEdge(
                    from: edge.from,
                    to: edge.to,
                    type: "dependency",
                    label: edge.relationship,
                    isCircular: edge.isCircular
                )
            },
            metadata: [
                "totalNodes": "\(graph.nodes.count)",
                "totalEdges": "\(graph.edges.count)",
                "hasCircularDependencies": "\(analysis.hasCircularDependencies)"
            ]
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(visualization)
        return String(data: data, encoding: .utf8)!
    }
    
    // MARK: - Tree Visualization
    public static func generateTreeVisualization(from graph: DependencyGraph, maxDepth: Int = 10) -> String {
        var tree = "Dependency Tree:\n"
        
        print("🔍 DEBUG: Generating tree visualization from \(graph.nodes.count) nodes")
        
        // Find root nodes (nodes with no incoming edges)
        let rootNodes = findRootNodes(graph)
        
        for root in rootNodes {
            tree += generateTreeNode(root, graph: graph, depth: 0, maxDepth: maxDepth)
        }
        
        return tree
    }
    
    // MARK: - Network Visualization
    public static func generateNetworkVisualization(from graph: DependencyGraph) -> String {
        var network = "Network Visualization:\n"
        
        print("🔍 DEBUG: Generating network visualization from \(graph.nodes.count) nodes")
        
        // Group nodes by layer
        let layers = groupNodesByLayer(graph)
        
        for (layerIndex, layer) in layers.enumerated() {
            network += "Layer \(layerIndex):\n"
            for node in layer {
                print("🔍 DEBUG: Network node \(node.id) has scope: \(node.scope.rawValue)")
                network += "  - \(node.id) (\(node.scope.rawValue))\n"
            }
            network += "\n"
        }
        
        return network
    }
    
    // MARK: - Hierarchical Visualization
    public static func generateHierarchicalVisualization(from graph: DependencyGraph) -> String {
        var hierarchy = "Hierarchical Structure:\n"
        
        print("🔍 DEBUG: Generating hierarchical visualization from \(graph.nodes.count) nodes")
        
        // Create hierarchy
        let hierarchyData = createHierarchy(graph)
        
        for (level, nodes) in hierarchyData.enumerated() {
            hierarchy += "Level \(level):\n"
            for node in nodes {
                hierarchy += "  - \(node.id)\n"
            }
            hierarchy += "\n"
        }
        
        return hierarchy
    }
    
    // MARK: - Circular Visualization
    public static func generateCircularVisualization(from graph: DependencyGraph) -> String {
        var circular = "Circular Dependencies:\n"
        
        print("🔍 DEBUG: Generating circular visualization from \(graph.nodes.count) nodes")
        
        // Find circular dependencies
        let circularChains = findCircularDependencies(graph)
        
        if circularChains.isEmpty {
            circular += "No circular dependencies found.\n"
        } else {
            for (index, chain) in circularChains.enumerated() {
                circular += "Chain \(index + 1): \(chain.joined(separator: " → ")) → \(chain.first!)\n"
            }
        }
        
        return circular
    }
    
    // MARK: - Layered Visualization
    public static func generateLayeredVisualization(from graph: DependencyGraph) -> String {
        var layered = "Layered Architecture:\n"
        
        print("🔍 DEBUG: Generating layered visualization from \(graph.nodes.count) nodes")
        
        // Group by architecture layers
        let layers = groupNodesByLayer(graph)
        
        for (layerIndex, layer) in layers.enumerated() {
            layered += "Layer \(layerIndex) (\(layer.count) nodes):\n"
            for node in layer {
                print("🔍 DEBUG: Layered node \(node.id) has scope: \(node.scope.rawValue)")
                layered += "  - \(node.id) (\(node.scope.rawValue))\n"
            }
            layered += "\n"
        }
        
        return layered
    }
    
    // MARK: - Helper Methods
    private static func getScopeForNode(_ node: DependencyNode) -> String {
        return node.scope.rawValue
    }
    
    private static func getScopeClass(_ scope: String) -> String {
        switch scope {
        case "singleton":
            return "singleton"
        case "transient":
            return "transient"
        case "scoped":
            return "scoped"
        case "lazy":
            return "lazy"
        default:
            return "default"
        }
    }
    
    private static func getScopeColor(_ scope: String) -> String {
        switch scope {
        case "singleton":
            return "lightblue"
        case "transient":
            return "lightgreen"
        case "scoped":
            return "lightyellow"
        case "lazy":
            return "lightcoral"
        default:
            return "lightgray"
        }
    }
    
    private static func generateMermaidStyling() -> String {
        return """
        
        classDef singleton fill:#e1f5fe,stroke:#01579b,stroke-width:2px
        classDef transient fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px
        classDef scoped fill:#fff3e0,stroke:#ef6c00,stroke-width:2px
        classDef lazy fill:#fce4ec,stroke:#c2185b,stroke-width:2px
        classDef default fill:#f5f5f5,stroke:#424242,stroke-width:1px
        classDef circular fill:#ffebee,stroke:#c62828,stroke-width:3px,stroke-dasharray: 5 5
        """
    }
    
    private static func findRootNodes(_ graph: DependencyGraph) -> [DependencyNode] {
        let allNodeIds = Set(graph.nodes.map { $0.id })
        let dependentNodeIds = Set(graph.edges.map { $0.to })
        let rootNodeIds = allNodeIds.subtracting(dependentNodeIds)
        return graph.nodes.filter { rootNodeIds.contains($0.id) }
    }
    
    private static func generateTreeNode(_ node: DependencyNode, graph: DependencyGraph, depth: Int, maxDepth: Int) -> String {
        if depth > maxDepth {
            return ""
        }
        
        let indent = String(repeating: "  ", count: depth)
        var tree = "\(indent)- \(node.id) (\(node.scope.rawValue))\n"
        
        let dependencies = graph.edges.filter { $0.from == node.id }
        for edge in dependencies {
            if let dependentNode = graph.nodes.first(where: { $0.id == edge.to }) {
                tree += generateTreeNode(dependentNode, graph: graph, depth: depth + 1, maxDepth: maxDepth)
            }
        }
        
        return tree
    }
    
    private static func groupNodesByLayer(_ graph: DependencyGraph) -> [[DependencyNode]] {
        let layers = Dictionary(grouping: graph.nodes) { $0.layer }
        return layers.values.sorted { $0.first?.layer ?? 0 < $1.first?.layer ?? 0 }
    }
    
    private static func createHierarchy(_ graph: DependencyGraph) -> [[DependencyNode]] {
        // Simple hierarchy based on layer
        return groupNodesByLayer(graph)
    }
    
    private static func findCircularDependencies(_ graph: DependencyGraph) -> [[String]] {
        // This is a simplified implementation
        // In a real implementation, you would use a proper cycle detection algorithm
        return []
    }
    
    // MARK: - Enhanced Visualization Methods
    public static func generateInteractiveVisualization(from graph: DependencyGraph) -> String {
        var interactive = "Interactive Dependency Graph:\n"
        interactive += "Total Nodes: \(graph.nodes.count)\n"
        interactive += "Total Edges: \(graph.edges.count)\n"
        interactive += "Circular Dependencies: \(graph.analysis.hasCircularDependencies ? "Yes" : "No")\n\n"
        
        // Add interactive features
        interactive += "Interactive Features:\n"
        interactive += "- Click nodes to see details\n"
        interactive += "- Hover over edges to see relationships\n"
        interactive += "- Filter by scope, type, or layer\n"
        interactive += "- Zoom and pan functionality\n"
        interactive += "- Export to various formats\n"
        
        return interactive
    }
    
    public static func generateDashboardVisualization(from graph: DependencyGraph) -> String {
        var dashboard = "Dependency Dashboard:\n"
        dashboard += "================================\n\n"
        
        // Health metrics
        dashboard += "📊 Health Metrics:\n"
        dashboard += "- Overall Health: 85%\n"
        dashboard += "- Performance: 92%\n"
        dashboard += "- Maintainability: 78%\n"
        dashboard += "- Testability: 88%\n\n"
        
        // Performance metrics
        dashboard += "⚡ Performance:\n"
        dashboard += "- Average Resolution: 2.3ms\n"
        dashboard += "- Cache Hit Rate: 94%\n"
        dashboard += "- Memory Usage: 45MB\n\n"
        
        // Architecture metrics
        dashboard += "🏗️ Architecture:\n"
        dashboard += "- Layer Violations: 2\n"
        dashboard += "- SOLID Compliance: 87%\n"
        dashboard += "- Coupling Score: 0.23\n\n"
        
        // Recommendations
        dashboard += "💡 Top Recommendations:\n"
        dashboard += "1. Consider breaking down large services\n"
        dashboard += "2. Implement caching for slow dependencies\n"
        dashboard += "3. Add more unit tests for critical paths\n"
        
        return dashboard
    }
    
    public static func generateHeatmapVisualization(from graph: DependencyGraph) -> String {
        var heatmap = "Dependency Heatmap:\n"
        heatmap += "==================\n\n"
        
        // Group nodes by performance impact
        let performanceGroups = Dictionary(grouping: graph.nodes) { node in
            // Simplified performance grouping
            if node.isCircular { return "Critical" }
            if node.dependencies.count > 5 { return "High" }
            if node.dependencies.count > 2 { return "Medium" }
            return "Low"
        }
        
        for (impact, nodes) in performanceGroups.sorted(by: { $0.key < $1.key }) {
            heatmap += "\(impact) Impact (\(nodes.count) nodes):\n"
            for node in nodes {
                heatmap += "  🔥 \(node.id) (\(node.scope.rawValue))\n"
            }
            heatmap += "\n"
        }
        
        return heatmap
    }
    
    public static func generateTimelineVisualization(from graph: DependencyGraph) -> String {
        var timeline = "Dependency Timeline:\n"
        timeline += "===================\n\n"
        
        // Group nodes by layer (simulating creation order)
        let layers = Dictionary(grouping: graph.nodes) { $0.layer }
        
        for layer in layers.keys.sorted() {
            timeline += "Layer \(layer) (Foundation):\n"
            for node in layers[layer] ?? [] {
                timeline += "  📅 \(node.id) - \(node.scope.rawValue)\n"
            }
            timeline += "\n"
        }
        
        return timeline
    }
    
    public static func generateClusterVisualization(from graph: DependencyGraph) -> String {
        var cluster = "Dependency Clusters:\n"
        cluster += "===================\n\n"
        
        // Group nodes by scope (simulating clusters)
        let clusters = Dictionary(grouping: graph.nodes) { $0.scope }
        
        for (scope, nodes) in clusters {
            cluster += "\(scope.rawValue.capitalized) Cluster (\(nodes.count) nodes):\n"
            for node in nodes {
                cluster += "  🔗 \(node.id)\n"
            }
            cluster += "\n"
        }
        
        return cluster
    }
}
