//
//  GraphTypes.swift
//  GoDareAdvanced
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation
import CoreGraphics

// MARK: - Graph Node and Edge Types
public struct GraphNode: Hashable, Codable, Sendable {
    public let id: String
    public let type: String
    public let scope: DependencyScope
    public let lifetime: DependencyLifetime
    
    public init(id: String, type: String, scope: DependencyScope, lifetime: DependencyLifetime) {
        self.id = id
        self.type = type
        self.scope = scope
        self.lifetime = lifetime
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: GraphNode, rhs: GraphNode) -> Bool {
        return lhs.id == rhs.id
    }
}

public struct GraphEdge: Hashable, Codable, Sendable {
    public let from: String
    public let to: String
    public let type: EdgeType
    
    public init(from: String, to: String, type: EdgeType = .dependency) {
        self.from = from
        self.to = to
        self.type = type
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(from)
        hasher.combine(to)
    }
    
    public static func == (lhs: GraphEdge, rhs: GraphEdge) -> Bool {
        return lhs.from == rhs.from && lhs.to == rhs.to
    }
}

public enum EdgeType: String, Codable, Sendable {
    case dependency = "dependency"
    case circular = "circular"
    case weak = "weak"
    case strong = "strong"
}

// MARK: - Dependency Graph Types
public struct DependencyNode: Hashable, Codable, Sendable {
    let id: String
    public let scope: DependencyScope
    let dependencies: [String]
    let layer: Int
    let isCircular: Bool
    let position: CGPoint
    
    // Enhanced metadata
    public let type: NodeType
    public let category: NodeCategory
    public let complexity: ComplexityLevel
    public let performanceMetrics: NodePerformanceMetrics
    public let metadata: [String: String]
    public let tags: [String]
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: DependencyNode, rhs: DependencyNode) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Enhanced Node Types
public enum NodeType: String, Codable, Sendable, CaseIterable {
    case service = "Service"
    case repository = "Repository"
    case useCase = "UseCase"
    case viewModel = "ViewModel"
    case controller = "Controller"
    case manager = "Manager"
    case factory = "Factory"
    case utility = "Utility"
    case model = "Model"
    case `protocol` = "Protocol"
    case unknown = "Unknown"
}

public enum NodeCategory: String, Codable, Sendable, CaseIterable {
    case infrastructure = "Infrastructure"
    case data = "Data"
    case domain = "Domain"
    case presentation = "Presentation"
    case crossCutting = "Cross-Cutting"
    case external = "External"
    case business = "Business"
    case unknown = "Unknown"
}

public enum ComplexityLevel: String, Codable, Sendable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
}

public struct NodePerformanceMetrics: Codable, Sendable {
    public let resolutionTime: TimeInterval
    public let memoryFootprint: Double
    public let cacheHitRate: Double
    public let resolutionCount: Int
    public let lastResolved: Date?
    
    public init(resolutionTime: TimeInterval, memoryFootprint: Double, cacheHitRate: Double, resolutionCount: Int, lastResolved: Date?) {
        self.resolutionTime = resolutionTime
        self.memoryFootprint = memoryFootprint
        self.cacheHitRate = cacheHitRate
        self.resolutionCount = resolutionCount
        self.lastResolved = lastResolved
    }
}

public struct DependencyEdge: Hashable, Codable, Sendable {
    let from: String
    let to: String
    let relationship: String
    let isCircular: Bool
    
    // Enhanced edge metadata
    public let relationshipType: RelationshipType
    public let strength: RelationshipStrength
    public let direction: EdgeDirection
    public let performanceImpact: PerformanceImpact
    public let metadata: [String: String]
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(from)
        hasher.combine(to)
    }
    
    public static func == (lhs: DependencyEdge, rhs: DependencyEdge) -> Bool {
        return lhs.from == rhs.from && lhs.to == rhs.to
    }
}

// MARK: - Enhanced Edge Types
public enum RelationshipType: String, Codable, Sendable, CaseIterable {
    case dependency = "Dependency"
    case composition = "Composition"
    case aggregation = "Aggregation"
    case inheritance = "Inheritance"
    case implementation = "Implementation"
    case association = "Association"
    case injection = "Injection"
    case factory = "Factory"
    case callback = "Callback"
    case event = "Event"
    case unknown = "Unknown"
}

public enum RelationshipStrength: String, Codable, Sendable, CaseIterable {
    case weak = "Weak"
    case moderate = "Moderate"
    case strong = "Strong"
    case critical = "Critical"
}

public enum EdgeDirection: String, Codable, Sendable, CaseIterable {
    case unidirectional = "Unidirectional"
    case bidirectional = "Bidirectional"
    case circular = "Circular"
}

public enum PerformanceImpact: String, Codable, Sendable, CaseIterable {
    case none = "None"
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
}

public struct DependencyGraph: Codable, Sendable {
    let nodes: [DependencyNode]
    let edges: [DependencyEdge]
    let analysis: GraphAnalysis
}

public struct GraphAnalysis: Codable, Sendable {
    let hasCircularDependencies: Bool
    let totalNodes: Int
    let totalDependencies: Int
    let maxDepth: Int
    let circularDependencyChains: [[String]]
    let analysisTime: TimeInterval
    let memoryUsage: Double
    let cacheEfficiency: Double
    let isComplete: Bool
    
    // Enhanced analysis features
    public let complexityMetrics: ComplexityMetrics
    public let performanceMetrics: GraphPerformanceMetrics
    public let architectureMetrics: ArchitectureMetrics
    public let healthScore: HealthScore
    public let recommendations: [Recommendation]
    public let clusters: [NodeCluster]
    public let criticalPaths: [CriticalPath]
    
    public init(hasCircularDependencies: Bool, totalNodes: Int, totalDependencies: Int, maxDepth: Int, circularDependencyChains: [[String]], analysisTime: TimeInterval, memoryUsage: Double, cacheEfficiency: Double, isComplete: Bool, complexityMetrics: ComplexityMetrics, performanceMetrics: GraphPerformanceMetrics, architectureMetrics: ArchitectureMetrics, healthScore: HealthScore, recommendations: [Recommendation], clusters: [NodeCluster], criticalPaths: [CriticalPath]) {
        self.hasCircularDependencies = hasCircularDependencies
        self.totalNodes = totalNodes
        self.totalDependencies = totalDependencies
        self.maxDepth = maxDepth
        self.circularDependencyChains = circularDependencyChains
        self.analysisTime = analysisTime
        self.memoryUsage = memoryUsage
        self.cacheEfficiency = cacheEfficiency
        self.isComplete = isComplete
        self.complexityMetrics = complexityMetrics
        self.performanceMetrics = performanceMetrics
        self.architectureMetrics = architectureMetrics
        self.healthScore = healthScore
        self.recommendations = recommendations
        self.clusters = clusters
        self.criticalPaths = criticalPaths
    }
}

// MARK: - Enhanced Analysis Types
public struct ComplexityMetrics: Codable, Sendable {
    public let cyclomaticComplexity: Int
    public let couplingScore: Double
    public let cohesionScore: Double
    public let fanIn: Int
    public let fanOut: Int
    public let instability: Double
    public let abstractness: Double
    public let distanceFromMainSequence: Double
    
    public init(cyclomaticComplexity: Int, couplingScore: Double, cohesionScore: Double, fanIn: Int, fanOut: Int, instability: Double, abstractness: Double, distanceFromMainSequence: Double) {
        self.cyclomaticComplexity = cyclomaticComplexity
        self.couplingScore = couplingScore
        self.cohesionScore = cohesionScore
        self.fanIn = fanIn
        self.fanOut = fanOut
        self.instability = instability
        self.abstractness = abstractness
        self.distanceFromMainSequence = distanceFromMainSequence
    }
}

public struct GraphPerformanceMetrics: Codable, Sendable {
    public let averageResolutionTime: TimeInterval
    public let slowestResolution: TimeInterval
    public let fastestResolution: TimeInterval
    public let totalMemoryFootprint: Double
    public let cacheHitRate: Double
    public let bottleneckNodes: [String]
    public let performanceTrend: PerformanceTrend
    
    public init(averageResolutionTime: TimeInterval, slowestResolution: TimeInterval, fastestResolution: TimeInterval, totalMemoryFootprint: Double, cacheHitRate: Double, bottleneckNodes: [String], performanceTrend: PerformanceTrend) {
        self.averageResolutionTime = averageResolutionTime
        self.slowestResolution = slowestResolution
        self.fastestResolution = fastestResolution
        self.totalMemoryFootprint = totalMemoryFootprint
        self.cacheHitRate = cacheHitRate
        self.bottleneckNodes = bottleneckNodes
        self.performanceTrend = performanceTrend
    }
}

public enum PerformanceTrend: String, Codable, Sendable, CaseIterable {
    case improving = "Improving"
    case stable = "Stable"
    case degrading = "Degrading"
    case unknown = "Unknown"
}

public struct ArchitectureMetrics: Codable, Sendable {
    public let layerViolations: Int
    public let dependencyInversionViolations: Int
    public let singleResponsibilityViolations: Int
    public let openClosedViolations: Int
    public let liskovSubstitutionViolations: Int
    public let interfaceSegregationViolations: Int
    public let architectureCompliance: Double
    
    public init(layerViolations: Int, dependencyInversionViolations: Int, singleResponsibilityViolations: Int, openClosedViolations: Int, liskovSubstitutionViolations: Int, interfaceSegregationViolations: Int, architectureCompliance: Double) {
        self.layerViolations = layerViolations
        self.dependencyInversionViolations = dependencyInversionViolations
        self.singleResponsibilityViolations = singleResponsibilityViolations
        self.openClosedViolations = openClosedViolations
        self.liskovSubstitutionViolations = liskovSubstitutionViolations
        self.interfaceSegregationViolations = interfaceSegregationViolations
        self.architectureCompliance = architectureCompliance
    }
}

public struct HealthScore: Codable, Sendable {
    public let overall: Double
    public let performance: Double
    public let maintainability: Double
    public let testability: Double
    public let scalability: Double
    public let security: Double
    public let reliability: Double
    
    public init(overall: Double, performance: Double, maintainability: Double, testability: Double, scalability: Double, security: Double, reliability: Double) {
        self.overall = overall
        self.performance = performance
        self.maintainability = maintainability
        self.testability = testability
        self.scalability = scalability
        self.security = security
        self.reliability = reliability
    }
}

public struct Recommendation: Codable, Sendable {
    public let type: RecommendationType
    public let priority: RecommendationPriority
    public let title: String
    public let description: String
    public let affectedNodes: [String]
    public let estimatedImpact: String
    public let effort: EffortLevel
    
    public init(type: RecommendationType, priority: RecommendationPriority, title: String, description: String, affectedNodes: [String], estimatedImpact: String, effort: EffortLevel) {
        self.type = type
        self.priority = priority
        self.title = title
        self.description = description
        self.affectedNodes = affectedNodes
        self.estimatedImpact = estimatedImpact
        self.effort = effort
    }
}

public enum RecommendationType: String, Codable, Sendable, CaseIterable {
    case performance = "Performance"
    case architecture = "Architecture"
    case maintainability = "Maintainability"
    case security = "Security"
    case scalability = "Scalability"
    case testing = "Testing"
    case documentation = "Documentation"
}

public enum RecommendationPriority: String, Codable, Sendable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
}

public enum EffortLevel: String, Codable, Sendable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case veryHigh = "Very High"
}

public struct NodeCluster: Codable, Sendable {
    public let id: String
    public let name: String
    public let nodes: [String]
    public let cohesion: Double
    public let coupling: Double
    public let purpose: String
    
    public init(id: String, name: String, nodes: [String], cohesion: Double, coupling: Double, purpose: String) {
        self.id = id
        self.name = name
        self.nodes = nodes
        self.cohesion = cohesion
        self.coupling = coupling
        self.purpose = purpose
    }
}

public struct CriticalPath: Codable, Sendable {
    public let id: String
    public let nodes: [String]
    public let totalTime: TimeInterval
    public let bottleneck: String
    public let impact: PerformanceImpact
    
    public init(id: String, nodes: [String], totalTime: TimeInterval, bottleneck: String, impact: PerformanceImpact) {
        self.id = id
        self.nodes = nodes
        self.totalTime = totalTime
        self.bottleneck = bottleneck
        self.impact = impact
    }
}
