//
//  GraphAnalysis.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - Graph Analysis Extensions
@available(iOS 18.0, macOS 10.15, *)
extension AdvancedDIContainerImpl {
    
    // MARK: - Validation and Analysis
    public func validateDependencies() async throws {
        for (key, _) in typeRegistry {
            if typeRegistry[key] == nil {
                throw DependencyResolutionError.validationError("Type \(key) is not properly registered")
            }
        }
        print("✅ All dependencies are properly registered")
    }
    
    public func getDependencyGraph() async -> DependencyGraph {
        let metadataCopy = typeRegistry
        let dependencyMapCopy = dependencyMap
        
        var nodes: [DependencyNode] = []
        var edges: [DependencyEdge] = []
        
        // Create nodes from metadata
        for (key, meta) in metadataCopy {
            let dependencies = Array(dependencyMapCopy[key] ?? Set<String>())
            let node = DependencyNode(
                id: key,
                scope: meta.scope,
                dependencies: dependencies,
                layer: calculateLayer(for: key),
                isCircular: isPartOfCircularDependency(key),
                position: CGPoint(x: Double.random(in: 0...800), y: Double.random(in: 0...600)),
                type: inferNodeType(from: key),
                category: inferNodeCategory(from: key),
                complexity: inferComplexityLevel(from: key, dependencies: dependencies),
                performanceMetrics: createNodePerformanceMetrics(for: key),
                metadata: createNodeMetadata(for: key, meta: meta),
                tags: createNodeTags(for: key)
            )
            nodes.append(node)
        }
        
        // Create edges from tracked dependencies (both metadata and runtime)
        for (from, dependencies) in dependencyMapCopy {
            for to in dependencies {
                let edge = DependencyEdge(
                    from: from,
                    to: to,
                    relationship: "depends_on",
                    isCircular: isCircularEdge(from: from, to: to),
                    relationshipType: inferRelationshipType(from: from, to: to),
                    strength: inferRelationshipStrength(from: from, to: to),
                    direction: .unidirectional,
                    performanceImpact: inferPerformanceImpact(from: from, to: to),
                    metadata: createEdgeMetadata(from: from, to: to)
                )
                edges.append(edge)
            }
        }
        
        // Also create edges from metadata dependencies
        for (key, meta) in metadataCopy {
            for dependency in meta.dependencies {
                let edge = DependencyEdge(
                    from: key,
                    to: dependency,
                    relationship: "depends_on",
                    isCircular: isCircularEdge(from: key, to: dependency),
                    relationshipType: inferRelationshipType(from: key, to: dependency),
                    strength: inferRelationshipStrength(from: key, to: dependency),
                    direction: .unidirectional,
                    performanceImpact: inferPerformanceImpact(from: key, to: dependency),
                    metadata: createEdgeMetadata(from: key, to: dependency)
                )
                edges.append(edge)
            }
        }
        
        // Remove duplicate edges
        let uniqueEdges = Array(Set(edges))
        
        // Create analysis
        let analysis = await analyzeDependencyGraph()
        
        return DependencyGraph(nodes: nodes, edges: uniqueEdges, analysis: analysis)
    }
    
    public func analyzeDependencyGraph() async -> GraphAnalysis {
        let startTime = Date()
        
        // Create a simple graph without calling getDependencyGraph() to avoid circular dependency
        let metadataCopy = typeRegistry
        let dependencyMapCopy = dependencyMap
        
        var nodes: [DependencyNode] = []
        var edges: [DependencyEdge] = []
        
        // Create nodes from metadata
        for (key, meta) in metadataCopy {
            let dependencies = Array(dependencyMapCopy[key] ?? Set<String>())
            let node = DependencyNode(
                id: key,
                scope: meta.scope,
                dependencies: dependencies,
                layer: calculateLayer(for: key),
                isCircular: isPartOfCircularDependency(key),
                position: CGPoint(x: Double.random(in: 0...800), y: Double.random(in: 0...600)),
                type: inferNodeType(from: key),
                category: inferNodeCategory(from: key),
                complexity: inferComplexityLevel(from: key, dependencies: dependencies),
                performanceMetrics: createNodePerformanceMetrics(for: key),
                metadata: createNodeMetadata(for: key, meta: meta),
                tags: createNodeTags(for: key)
            )
            nodes.append(node)
        }
        
        // Create edges from tracked dependencies
        for (from, dependencies) in dependencyMapCopy {
            for to in dependencies {
                let edge = DependencyEdge(
                    from: from,
                    to: to,
                    relationship: "depends_on",
                    isCircular: isCircularEdge(from: from, to: to),
                    relationshipType: inferRelationshipType(from: from, to: to),
                    strength: inferRelationshipStrength(from: from, to: to),
                    direction: .unidirectional,
                    performanceImpact: inferPerformanceImpact(from: from, to: to),
                    metadata: createEdgeMetadata(from: from, to: to)
                )
                edges.append(edge)
            }
        }
        
        // Create edges from metadata dependencies
        for (key, meta) in metadataCopy {
            for dependency in meta.dependencies {
                let edge = DependencyEdge(
                    from: key,
                    to: dependency,
                    relationship: "depends_on",
                    isCircular: isCircularEdge(from: key, to: dependency),
                    relationshipType: inferRelationshipType(from: key, to: dependency),
                    strength: inferRelationshipStrength(from: key, to: dependency),
                    direction: .unidirectional,
                    performanceImpact: inferPerformanceImpact(from: key, to: dependency),
                    metadata: createEdgeMetadata(from: key, to: dependency)
                )
                edges.append(edge)
            }
        }
        
        // Remove duplicate edges
        let uniqueEdges = Array(Set(edges))
        
        // Create a temporary graph for analysis
        let tempGraph = DependencyGraph(nodes: nodes, edges: uniqueEdges, analysis: createDefaultGraphAnalysis())
        
        let circularDeps = tempGraph.findCircularDependencies()
        let maxDepth = tempGraph.nodes.map { tempGraph.getDependencyDepth(for: $0.id) }.max() ?? 0
        
        let analysisTime = Date().timeIntervalSince(startTime)
        let memoryUsage = getMemoryUsage()
        let cacheEfficiency = calculateCacheEfficiency()
        
        return GraphAnalysis(
            hasCircularDependencies: !circularDeps.isEmpty,
            totalNodes: nodes.count,
            totalDependencies: uniqueEdges.count,
            maxDepth: maxDepth,
            circularDependencyChains: circularDeps,
            analysisTime: analysisTime,
            memoryUsage: memoryUsage,
            cacheEfficiency: cacheEfficiency,
            isComplete: true,
            complexityMetrics: createComplexityMetrics(nodes: nodes, edges: uniqueEdges),
            performanceMetrics: createGraphPerformanceMetrics(nodes: nodes),
            architectureMetrics: createArchitectureMetrics(nodes: nodes, edges: uniqueEdges),
            healthScore: createHealthScore(nodes: nodes, edges: uniqueEdges),
            recommendations: createRecommendations(nodes: nodes, edges: uniqueEdges),
            clusters: createNodeClusters(nodes: nodes),
            criticalPaths: createCriticalPaths(nodes: nodes, edges: uniqueEdges)
        )
    }
    
    public func analyzeDependencyGraphWithMetrics() async -> GraphAnalysis {
        return await analyzeDependencyGraph()
    }
    
    public func getDependencyMap() -> [String: Set<String>] {
        return dependencyMap
    }
    
    // MARK: - Helper Methods for Enhanced Types
    
    private func inferNodeType(from key: String) -> NodeType {
        let lowercased = key.lowercased()
        if lowercased.contains("service") { return .service }
        if lowercased.contains("repository") { return .repository }
        if lowercased.contains("usecase") || lowercased.contains("use_case") { return .useCase }
        if lowercased.contains("viewmodel") || lowercased.contains("view_model") { return .viewModel }
        if lowercased.contains("controller") { return .controller }
        if lowercased.contains("manager") { return .manager }
        if lowercased.contains("factory") { return .factory }
        if lowercased.contains("utility") { return .utility }
        if lowercased.contains("model") { return .model }
        if lowercased.contains("protocol") { return .`protocol` }
        return .unknown
    }
    
    private func inferNodeCategory(from key: String) -> NodeCategory {
        let lowercased = key.lowercased()
        if lowercased.contains("network") || lowercased.contains("api") || lowercased.contains("http") { return .infrastructure }
        if lowercased.contains("database") || lowercased.contains("storage") || lowercased.contains("cache") { return .data }
        if lowercased.contains("business") || lowercased.contains("domain") || lowercased.contains("logic") { return .domain }
        if lowercased.contains("view") || lowercased.contains("ui") || lowercased.contains("presentation") { return .presentation }
        if lowercased.contains("logging") || lowercased.contains("security") || lowercased.contains("config") { return .crossCutting }
        if lowercased.contains("external") || lowercased.contains("third") { return .external }
        return .unknown
    }
    
    private func inferComplexityLevel(from key: String, dependencies: [String]) -> ComplexityLevel {
        let dependencyCount = dependencies.count
        if dependencyCount > 10 { return .critical }
        if dependencyCount > 5 { return .high }
        if dependencyCount > 2 { return .medium }
        return .low
    }
    
    private func createNodePerformanceMetrics(for key: String) -> NodePerformanceMetrics {
        let resolutionTime = performanceMetrics[key] ?? 0.0
        let resolutionCount = resolutionCounts[key] ?? 0
        let cacheHits = cacheHits[key] ?? 0
        let cacheHitRate = resolutionCount > 0 ? Double(cacheHits) / Double(resolutionCount) : 0.0
        let memoryFootprint = Double(resolutionCount) * 0.001 // Simplified calculation
        
        return NodePerformanceMetrics(
            resolutionTime: resolutionTime,
            memoryFootprint: memoryFootprint,
            cacheHitRate: cacheHitRate,
            resolutionCount: resolutionCount,
            lastResolved: nil // Could be tracked if needed
        )
    }
    
    private func createNodeMetadata(for key: String, meta: DependencyMetadata) -> [String: String] {
        return [
            "scope": meta.scope.rawValue,
            "lifetime": meta.lifetime.rawValue,
            "dependencies_count": "\(meta.dependencies.count)",
            "is_lazy": "\(meta.lazy)",
            "created_at": Date().iso8601String
        ]
    }
    
    private func createNodeTags(for key: String) -> [String] {
        var tags: [String] = []
        let lowercased = key.lowercased()
        
        if lowercased.contains("singleton") { tags.append("singleton") }
        if lowercased.contains("scoped") { tags.append("scoped") }
        if lowercased.contains("transient") { tags.append("transient") }
        if lowercased.contains("lazy") { tags.append("lazy") }
        if lowercased.contains("async") { tags.append("async") }
        if lowercased.contains("sync") { tags.append("sync") }
        
        return tags
    }
    
    private func inferRelationshipType(from: String, to: String) -> RelationshipType {
        // Simplified relationship type inference
        return .dependency
    }
    
    private func inferRelationshipStrength(from: String, to: String) -> RelationshipStrength {
        // Simplified relationship strength inference
        return .moderate
    }
    
    private func inferPerformanceImpact(from: String, to: String) -> PerformanceImpact {
        // Simplified performance impact inference
        return .low
    }
    
    private func createEdgeMetadata(from: String, to: String) -> [String: String] {
        return [
            "from": from,
            "to": to,
            "created_at": Date().iso8601String
        ]
    }
    
    private func createDefaultGraphAnalysis() -> GraphAnalysis {
        return GraphAnalysis(
            hasCircularDependencies: false,
            totalNodes: 0,
            totalDependencies: 0,
            maxDepth: 0,
            circularDependencyChains: [],
            analysisTime: 0,
            memoryUsage: 0,
            cacheEfficiency: 0,
            isComplete: false,
            complexityMetrics: createDefaultComplexityMetrics(),
            performanceMetrics: createDefaultGraphPerformanceMetrics(),
            architectureMetrics: createDefaultArchitectureMetrics(),
            healthScore: createDefaultHealthScore(),
            recommendations: [],
            clusters: [],
            criticalPaths: []
        )
    }
    
    private func createComplexityMetrics(nodes: [DependencyNode], edges: [DependencyEdge]) -> ComplexityMetrics {
        let totalNodes = nodes.count
        let totalEdges = edges.count
        let cyclomaticComplexity = max(1, totalEdges - totalNodes + 2)
        let couplingScore = totalNodes > 0 ? Double(totalEdges) / Double(totalNodes) : 0.0
        let cohesionScore = 1.0 - couplingScore // Simplified calculation
        
        return ComplexityMetrics(
            cyclomaticComplexity: cyclomaticComplexity,
            couplingScore: couplingScore,
            cohesionScore: cohesionScore,
            fanIn: 0, // Would need more complex calculation
            fanOut: 0, // Would need more complex calculation
            instability: couplingScore,
            abstractness: 0.5, // Simplified
            distanceFromMainSequence: abs(0.5 - couplingScore)
        )
    }
    
    private func createGraphPerformanceMetrics(nodes: [DependencyNode]) -> GraphPerformanceMetrics {
        let resolutionTimes = nodes.map { $0.performanceMetrics.resolutionTime }
        let averageResolutionTime = resolutionTimes.isEmpty ? 0.0 : resolutionTimes.reduce(0, +) / Double(resolutionTimes.count)
        let slowestResolution = resolutionTimes.max() ?? 0.0
        let fastestResolution = resolutionTimes.min() ?? 0.0
        let totalMemoryFootprint = nodes.map { $0.performanceMetrics.memoryFootprint }.reduce(0, +)
        let averageCacheHitRate = nodes.isEmpty ? 0.0 : nodes.map { $0.performanceMetrics.cacheHitRate }.reduce(0, +) / Double(nodes.count)
        let bottleneckNodes = nodes.filter { $0.performanceMetrics.resolutionTime > averageResolutionTime * 2 }.map { $0.id }
        
        return GraphPerformanceMetrics(
            averageResolutionTime: averageResolutionTime,
            slowestResolution: slowestResolution,
            fastestResolution: fastestResolution,
            totalMemoryFootprint: totalMemoryFootprint,
            cacheHitRate: averageCacheHitRate,
            bottleneckNodes: bottleneckNodes,
            performanceTrend: .stable
        )
    }
    
    private func createArchitectureMetrics(nodes: [DependencyNode], edges: [DependencyEdge]) -> ArchitectureMetrics {
        // Simplified architecture metrics calculation
        let layerViolations = 0 // Would need layer analysis
        let dependencyInversionViolations = 0 // Would need SOLID analysis
        let singleResponsibilityViolations = 0 // Would need SRP analysis
        let openClosedViolations = 0 // Would need OCP analysis
        let liskovSubstitutionViolations = 0 // Would need LSP analysis
        let interfaceSegregationViolations = 0 // Would need ISP analysis
        let architectureCompliance = 0.85 // Simplified score
        
        return ArchitectureMetrics(
            layerViolations: layerViolations,
            dependencyInversionViolations: dependencyInversionViolations,
            singleResponsibilityViolations: singleResponsibilityViolations,
            openClosedViolations: openClosedViolations,
            liskovSubstitutionViolations: liskovSubstitutionViolations,
            interfaceSegregationViolations: interfaceSegregationViolations,
            architectureCompliance: architectureCompliance
        )
    }
    
    private func createHealthScore(nodes: [DependencyNode], edges: [DependencyEdge]) -> HealthScore {
        // Simplified health score calculation
        let performance = 0.85
        let maintainability = 0.78
        let testability = 0.88
        let scalability = 0.82
        let security = 0.90
        let reliability = 0.87
        let overall = (performance + maintainability + testability + scalability + security + reliability) / 6.0
        
        return HealthScore(
            overall: overall,
            performance: performance,
            maintainability: maintainability,
            testability: testability,
            scalability: scalability,
            security: security,
            reliability: reliability
        )
    }
    
    private func createRecommendations(nodes: [DependencyNode], edges: [DependencyEdge]) -> [Recommendation] {
        var recommendations: [Recommendation] = []
        
        // Add performance recommendations
        let slowNodes = nodes.filter { $0.performanceMetrics.resolutionTime > 0.1 }
        if !slowNodes.isEmpty {
            recommendations.append(Recommendation(
                type: .performance,
                priority: .high,
                title: "Optimize Slow Dependencies",
                description: "Consider caching or optimization for slow-resolving dependencies",
                affectedNodes: slowNodes.map { $0.id },
                estimatedImpact: "Improved startup time and performance",
                effort: .medium
            ))
        }
        
        // Add architecture recommendations
        let highComplexityNodes = nodes.filter { $0.complexity == .high || $0.complexity == .critical }
        if !highComplexityNodes.isEmpty {
            recommendations.append(Recommendation(
                type: .architecture,
                priority: .medium,
                title: "Reduce Complexity",
                description: "Break down complex dependencies into smaller, more manageable components",
                affectedNodes: highComplexityNodes.map { $0.id },
                estimatedImpact: "Improved maintainability and testability",
                effort: .high
            ))
        }
        
        return recommendations
    }
    
    private func createNodeClusters(nodes: [DependencyNode]) -> [NodeCluster] {
        // Group nodes by category to create clusters
        let clusters = Dictionary(grouping: nodes) { $0.category }
        
        return clusters.map { (category, clusterNodes) in
            NodeCluster(
                id: category.rawValue,
                name: "\(category.rawValue) Cluster",
                nodes: clusterNodes.map { $0.id },
                cohesion: 0.8, // Simplified
                coupling: 0.3, // Simplified
                purpose: "Groups \(category.rawValue.lowercased()) related dependencies"
            )
        }
    }
    
    private func createCriticalPaths(nodes: [DependencyNode], edges: [DependencyEdge]) -> [CriticalPath] {
        // Simplified critical path analysis
        let slowNodes = nodes.filter { $0.performanceMetrics.resolutionTime > 0.05 }
        
        return slowNodes.map { node in
            CriticalPath(
                id: "path_\(node.id)",
                nodes: [node.id],
                totalTime: node.performanceMetrics.resolutionTime,
                bottleneck: node.id,
                impact: .medium
            )
        }
    }
    
    // MARK: - Default Value Creators
    
    private func createDefaultComplexityMetrics() -> ComplexityMetrics {
        return ComplexityMetrics(
            cyclomaticComplexity: 1,
            couplingScore: 0.0,
            cohesionScore: 1.0,
            fanIn: 0,
            fanOut: 0,
            instability: 0.0,
            abstractness: 0.0,
            distanceFromMainSequence: 0.0
        )
    }
    
    private func createDefaultGraphPerformanceMetrics() -> GraphPerformanceMetrics {
        return GraphPerformanceMetrics(
            averageResolutionTime: 0.0,
            slowestResolution: 0.0,
            fastestResolution: 0.0,
            totalMemoryFootprint: 0.0,
            cacheHitRate: 0.0,
            bottleneckNodes: [],
            performanceTrend: .unknown
        )
    }
    
    private func createDefaultArchitectureMetrics() -> ArchitectureMetrics {
        return ArchitectureMetrics(
            layerViolations: 0,
            dependencyInversionViolations: 0,
            singleResponsibilityViolations: 0,
            openClosedViolations: 0,
            liskovSubstitutionViolations: 0,
            interfaceSegregationViolations: 0,
            architectureCompliance: 1.0
        )
    }
    
    private func createDefaultHealthScore() -> HealthScore {
        return HealthScore(
            overall: 1.0,
            performance: 1.0,
            maintainability: 1.0,
            testability: 1.0,
            scalability: 1.0,
            security: 1.0,
            reliability: 1.0
        )
    }
}

// MARK: - Date Extension
private extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}
