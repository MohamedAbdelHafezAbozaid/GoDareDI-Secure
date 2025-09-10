//
//  VisualizationTypes.swift
//  GoDareAdvanced
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - Visualization Types
public enum VisualizationType: String, CaseIterable, Codable, Sendable {
    case mermaid
    case graphviz
    case json
    case tree
    case network
    case hierarchical
    case circular
    case layered
    case interactive
    case dashboard
    case heatmap
    case timeline
    case cluster
}

// MARK: - Output Formats
public enum OutputFormat: String, CaseIterable, Codable, Sendable {
    case mermaid
    case dot
    case json
    case html
    case svg
    case png
    case pdf
    case markdown
    case csv
    case excel
    case interactive
}

// MARK: - Enhanced Visualization Types
public enum VisualizationTheme: String, CaseIterable, Codable, Sendable {
    case modern
    case classic
    case dark
    case light
    case colorful
    case minimal
    case corporate
    case playful
}

public enum LayoutAlgorithm: String, CaseIterable, Codable, Sendable {
    case hierarchical
    case forceDirected
    case circular
    case grid
    case tree
    case layered
    case cluster
    case timeline
    case radial
    case organic
}

public enum NodeShape: String, CaseIterable, Codable, Sendable {
    case rectangle
    case circle
    case diamond
    case hexagon
    case triangle
    case rounded
    case custom
}

public enum EdgeStyle: String, CaseIterable, Codable, Sendable {
    case solid
    case dashed
    case dotted
    case thick
    case curved
    case straight
    case custom
}

// MARK: - Configuration
public struct VisualizationConfig: Codable, Sendable {
    let type: VisualizationType
    let format: OutputFormat
    let showScopes: Bool
    let showLifetimes: Bool
    let showDependencies: Bool
    let groupByLayer: Bool
    let colorizeByScope: Bool
    let interactive: Bool
    let maxDepth: Int
    let includeCircular: Bool
    let enableAsyncRendering: Bool
    let enableProgressTracking: Bool
    
    // Enhanced configuration options
    public let theme: VisualizationTheme
    public let layout: LayoutAlgorithm
    public let nodeShape: NodeShape
    public let edgeStyle: EdgeStyle
    public let showLabels: Bool
    public let showTooltips: Bool
    public let showLegend: Bool
    public let showMetrics: Bool
    public let showRecommendations: Bool
    public let animationEnabled: Bool
    public let exportOptions: ExportOptions
    
    public init(
        type: VisualizationType = .mermaid,
        format: OutputFormat = .mermaid,
        showScopes: Bool = true,
        showLifetimes: Bool = true,
        showDependencies: Bool = true,
        groupByLayer: Bool = true,
        colorizeByScope: Bool = true,
        interactive: Bool = false,
        maxDepth: Int = 10,
        includeCircular: Bool = true,
        enableAsyncRendering: Bool = true,
        enableProgressTracking: Bool = true,
        theme: VisualizationTheme = .modern,
        layout: LayoutAlgorithm = .hierarchical,
        nodeShape: NodeShape = .rounded,
        edgeStyle: EdgeStyle = .solid,
        showLabels: Bool = true,
        showTooltips: Bool = true,
        showLegend: Bool = true,
        showMetrics: Bool = true,
        showRecommendations: Bool = true,
        animationEnabled: Bool = true,
        exportOptions: ExportOptions = ExportOptions()
    ) {
        self.type = type
        self.format = format
        self.showScopes = showScopes
        self.showLifetimes = showLifetimes
        self.showDependencies = showDependencies
        self.groupByLayer = groupByLayer
        self.colorizeByScope = colorizeByScope
        self.interactive = interactive
        self.maxDepth = maxDepth
        self.includeCircular = includeCircular
        self.enableAsyncRendering = enableAsyncRendering
        self.enableProgressTracking = enableProgressTracking
        self.theme = theme
        self.layout = layout
        self.nodeShape = nodeShape
        self.edgeStyle = edgeStyle
        self.showLabels = showLabels
        self.showTooltips = showTooltips
        self.showLegend = showLegend
        self.showMetrics = showMetrics
        self.showRecommendations = showRecommendations
        self.animationEnabled = animationEnabled
        self.exportOptions = exportOptions
    }
}

// MARK: - Export Options
public struct ExportOptions: Codable, Sendable {
    public let includeMetadata: Bool
    public let includePerformance: Bool
    public let includeAnalysis: Bool
    public let includeRecommendations: Bool
    public let compressionLevel: Int
    public let watermark: String?
    public let customStyles: [String: String]
    
    public init(includeMetadata: Bool = true, includePerformance: Bool = true, includeAnalysis: Bool = true, includeRecommendations: Bool = true, compressionLevel: Int = 6, watermark: String? = nil, customStyles: [String: String] = [:]) {
        self.includeMetadata = includeMetadata
        self.includePerformance = includePerformance
        self.includeAnalysis = includeAnalysis
        self.includeRecommendations = includeRecommendations
        self.compressionLevel = compressionLevel
        self.watermark = watermark
        self.customStyles = customStyles
    }
}

// MARK: - Visualization Data Structures
public struct VisualizationNode: Codable, Sendable {
    let id: String
    let label: String
    let type: String
    let scope: String
    let layer: String
    let isCircular: Bool
    let dependencies: [String]
    let metadata: [String: String]
    
    // Enhanced node properties
    public let position: NodePosition?
    public let style: NodeStyle?
    public let performance: NodePerformanceData?
    public let category: String?
    public let complexity: String?
    public let tags: [String]
    
    public init(
        id: String,
        label: String,
        type: String,
        scope: String,
        layer: String,
        isCircular: Bool,
        dependencies: [String],
        metadata: [String: String],
        position: NodePosition? = nil,
        style: NodeStyle? = nil,
        performance: NodePerformanceData? = nil,
        category: String? = nil,
        complexity: String? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.label = label
        self.type = type
        self.scope = scope
        self.layer = layer
        self.isCircular = isCircular
        self.dependencies = dependencies
        self.metadata = metadata
        self.position = position
        self.style = style
        self.performance = performance
        self.category = category
        self.complexity = complexity
        self.tags = tags
    }
}

// MARK: - Enhanced Node Properties
public struct NodePosition: Codable, Sendable {
    public let x: Double
    public let y: Double
    public let z: Double?
    
    public init(x: Double, y: Double, z: Double? = nil) {
        self.x = x
        self.y = y
        self.z = z
    }
}

public struct NodeStyle: Codable, Sendable {
    public let backgroundColor: String
    public let borderColor: String
    public let borderWidth: Double
    public let textColor: String
    public let fontSize: Double
    public let shape: String
    public let opacity: Double
    public let shadow: Bool
    
    public init(backgroundColor: String, borderColor: String, borderWidth: Double, textColor: String, fontSize: Double, shape: String, opacity: Double = 1.0, shadow: Bool = false) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.textColor = textColor
        self.fontSize = fontSize
        self.shape = shape
        self.opacity = opacity
        self.shadow = shadow
    }
}

public struct NodePerformanceData: Codable, Sendable {
    public let resolutionTime: TimeInterval
    public let memoryUsage: Double
    public let cacheHitRate: Double
    public let resolutionCount: Int
    public let lastResolved: Date?
    
    public init(resolutionTime: TimeInterval, memoryUsage: Double, cacheHitRate: Double, resolutionCount: Int, lastResolved: Date?) {
        self.resolutionTime = resolutionTime
        self.memoryUsage = memoryUsage
        self.cacheHitRate = cacheHitRate
        self.resolutionCount = resolutionCount
        self.lastResolved = lastResolved
    }
}

public struct VisualizationEdge: Codable, Sendable {
    let from: String
    let to: String
    let type: String
    let label: String
    let isCircular: Bool
    
    // Enhanced edge properties
    public let style: EdgeStyle?
    public let performance: EdgePerformanceData?
    public let relationshipType: String?
    public let strength: String?
    public let direction: String?
    public let impact: String?
    
    public init(
        from: String,
        to: String,
        type: String,
        label: String,
        isCircular: Bool,
        style: EdgeStyle? = nil,
        performance: EdgePerformanceData? = nil,
        relationshipType: String? = nil,
        strength: String? = nil,
        direction: String? = nil,
        impact: String? = nil
    ) {
        self.from = from
        self.to = to
        self.type = type
        self.label = label
        self.isCircular = isCircular
        self.style = style
        self.performance = performance
        self.relationshipType = relationshipType
        self.strength = strength
        self.direction = direction
        self.impact = impact
    }
}

// MARK: - Enhanced Edge Properties
public struct EdgePerformanceData: Codable, Sendable {
    public let traversalTime: TimeInterval
    public let frequency: Int
    public let impact: String
    
    public init(traversalTime: TimeInterval, frequency: Int, impact: String) {
        self.traversalTime = traversalTime
        self.frequency = frequency
        self.impact = impact
    }
}

public struct VisualizationData: Codable, Sendable {
    let nodes: [VisualizationNode]
    let edges: [VisualizationEdge]
    let metadata: [String: String]
    
    // Enhanced visualization data
    public let analysis: GraphAnalysis?
    public let recommendations: [Recommendation]?
    public let clusters: [NodeCluster]?
    public let criticalPaths: [CriticalPath]?
    public let healthScore: HealthScore?
    public let performanceMetrics: GraphPerformanceMetrics?
    public let complexityMetrics: ComplexityMetrics?
    public let architectureMetrics: ArchitectureMetrics?
    
    public init(
        nodes: [VisualizationNode],
        edges: [VisualizationEdge],
        metadata: [String: String],
        analysis: GraphAnalysis? = nil,
        recommendations: [Recommendation]? = nil,
        clusters: [NodeCluster]? = nil,
        criticalPaths: [CriticalPath]? = nil,
        healthScore: HealthScore? = nil,
        performanceMetrics: GraphPerformanceMetrics? = nil,
        complexityMetrics: ComplexityMetrics? = nil,
        architectureMetrics: ArchitectureMetrics? = nil
    ) {
        self.nodes = nodes
        self.edges = edges
        self.metadata = metadata
        self.analysis = analysis
        self.recommendations = recommendations
        self.clusters = clusters
        self.criticalPaths = criticalPaths
        self.healthScore = healthScore
        self.performanceMetrics = performanceMetrics
        self.complexityMetrics = complexityMetrics
        self.architectureMetrics = architectureMetrics
    }
}
