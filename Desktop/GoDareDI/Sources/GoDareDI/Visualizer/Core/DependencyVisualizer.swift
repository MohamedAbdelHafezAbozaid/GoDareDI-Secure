//
//  DependencyVisualizer.swift
//  GoDareAdvanced
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - Dependency Visualizer
@MainActor
public class DependencyVisualizer: Sendable {
    
    // MARK: - Properties
    private let container: AdvancedDIContainer
    private let config: VisualizationConfig
    private let token: String?
    
    // MARK: - Initialization
    public init(container: AdvancedDIContainer, config: VisualizationConfig = VisualizationConfig()) {
        self.container = container
        self.config = config
        
        // Automatically detect token from container
        if let containerImpl = container as? AdvancedDIContainerImpl {
            self.token = containerImpl.token
        } else {
            self.token = nil
        }
    }
    
    // MARK: - Token-based Initialization
    public init(container: AdvancedDIContainer, token: String, config: VisualizationConfig = VisualizationConfig()) {
        self.container = container
        self.config = config
        self.token = token
    }
    
    // MARK: - Main Visualization Methods
    public func visualize() async throws -> String {
        // Validate token for visualization
        try await validateTokenForVisualization()
        
        switch config.type {
        case .mermaid:
            return await generateMermaidDiagram()
        case .graphviz:
            return await generateGraphvizDiagram()
        case .json:
            return await generateJSONVisualization()
        case .tree:
            return await generateTreeVisualization()
        case .network:
            return await generateNetworkVisualization()
        case .hierarchical:
            return await generateHierarchicalVisualization()
        case .circular:
            return await generateCircularVisualization()
        case .layered:
            return await generateLayeredVisualization()
        case .interactive:
            return await generateInteractiveVisualization()
        case .dashboard:
            return await generateDashboardVisualization()
        case .heatmap:
            return await generateHeatmapVisualization()
        case .timeline:
            return await generateTimelineVisualization()
        case .cluster:
            return await generateClusterVisualization()
        @unknown default:
            return "Unsupported visualization type: \(config.type.rawValue)"
        }
    }
    
    // MARK: - Async Visualization Methods
    public func visualizeAsync(type: VisualizationType, progress: Progress? = nil) async throws -> String {
        // Validate token for visualization
        try await validateTokenForVisualization()
        
        switch type {
        case .mermaid:
            return await generateMermaidDiagramAsync(progress: progress)
        case .graphviz:
            return await generateGraphvizDiagramAsync(progress: progress)
        case .json:
            return await generateJSONVisualizationAsync(progress: progress)
        case .tree:
            return await generateTreeVisualizationAsync(progress: progress)
        case .network:
            return await generateNetworkVisualizationAsync(progress: progress)
        case .hierarchical:
            return await generateHierarchicalVisualizationAsync(progress: progress)
        case .circular:
            return await generateCircularVisualizationAsync(progress: progress)
        case .layered:
            return await generateLayeredVisualizationAsync(progress: progress)
        case .interactive:
            return await generateInteractiveVisualizationAsync(progress: progress)
        case .dashboard:
            return await generateDashboardVisualizationAsync(progress: progress)
        case .heatmap:
            return await generateHeatmapVisualizationAsync(progress: progress)
        case .timeline:
            return await generateTimelineVisualizationAsync(progress: progress)
        case .cluster:
            return await generateClusterVisualizationAsync(progress: progress)
        @unknown default:
            return "Unsupported visualization type: \(type.rawValue)"
        }
    }
    
    // MARK: - Diagram Generation Methods
    private func generateMermaidDiagram() async -> String {
        let graph = await container.getDependencyGraph()
        return DiagramGenerators.generateMermaidDiagram(from: graph)
    }
    
    private func generateMermaidDiagramAsync(progress: Progress?) async -> String {
        let graph = await container.getDependencyGraph()
        return DiagramGenerators.generateMermaidDiagramAsync(from: graph, progress: progress)
    }
    
    private func generateGraphvizDiagram() async -> String {
        let graph = await container.getDependencyGraph()
        return DiagramGenerators.generateGraphvizDiagram(from: graph)
    }
    
    private func generateGraphvizDiagramAsync(progress: Progress?) async -> String {
        let graph = await container.getDependencyGraph()
        return DiagramGenerators.generateGraphvizDiagramAsync(from: graph, progress: progress)
    }
    
    private func generateJSONVisualization() async -> String {
        async let graph = container.getDependencyGraph()
        async let analysis = container.analyzeDependencyGraph()
        
        let (dependencyGraph, graphAnalysis) = await (graph, analysis)
        return DiagramGenerators.generateJSONVisualization(from: dependencyGraph, analysis: graphAnalysis)
    }
    
    private func generateJSONVisualizationAsync(progress: Progress?) async -> String {
        async let graph = container.getDependencyGraph()
        async let analysis = container.analyzeDependencyGraph()
        
        progress?.completedUnitCount = 30
        
        let (dependencyGraph, graphAnalysis) = await (graph, analysis)
        
        progress?.completedUnitCount = 80
        
        let result = DiagramGenerators.generateJSONVisualization(from: dependencyGraph, analysis: graphAnalysis)
        
        progress?.completedUnitCount = 100
        
        return result
    }
    
    private func generateTreeVisualization() async -> String {
        let graph = await container.getDependencyGraph()
        return DiagramGenerators.generateTreeVisualization(from: graph, maxDepth: config.maxDepth)
    }
    
    private func generateTreeVisualizationAsync(progress: Progress?) async -> String {
        let graph = await container.getDependencyGraph()
        progress?.completedUnitCount = 50
        let result = DiagramGenerators.generateTreeVisualization(from: graph, maxDepth: config.maxDepth)
        progress?.completedUnitCount = 100
        return result
    }
    
    private func generateNetworkVisualization() async -> String {
        let graph = await container.getDependencyGraph()
        return DiagramGenerators.generateNetworkVisualization(from: graph)
    }
    
    private func generateNetworkVisualizationAsync(progress: Progress?) async -> String {
        let graph = await container.getDependencyGraph()
        progress?.completedUnitCount = 50
        let result = DiagramGenerators.generateNetworkVisualization(from: graph)
        progress?.completedUnitCount = 100
        return result
    }
    
    private func generateHierarchicalVisualization() async -> String {
        let graph = await container.getDependencyGraph()
        return DiagramGenerators.generateHierarchicalVisualization(from: graph)
    }
    
    private func generateHierarchicalVisualizationAsync(progress: Progress?) async -> String {
        let graph = await container.getDependencyGraph()
        progress?.completedUnitCount = 50
        let result = DiagramGenerators.generateHierarchicalVisualization(from: graph)
        progress?.completedUnitCount = 100
        return result
    }
    
    private func generateCircularVisualization() async -> String {
        let graph = await container.getDependencyGraph()
        return DiagramGenerators.generateCircularVisualization(from: graph)
    }
    
    private func generateCircularVisualizationAsync(progress: Progress?) async -> String {
        let graph = await container.getDependencyGraph()
        progress?.completedUnitCount = 50
        let result = DiagramGenerators.generateCircularVisualization(from: graph)
        progress?.completedUnitCount = 100
        return result
    }
    
    private func generateLayeredVisualization() async -> String {
        let graph = await container.getDependencyGraph()
        return DiagramGenerators.generateLayeredVisualization(from: graph)
    }
    
    private func generateLayeredVisualizationAsync(progress: Progress?) async -> String {
        let graph = await container.getDependencyGraph()
        progress?.completedUnitCount = 50
        let result = DiagramGenerators.generateLayeredVisualization(from: graph)
        progress?.completedUnitCount = 100
        return result
    }
    
    // MARK: - Enhanced Visualization Methods
    private func generateInteractiveVisualization() async -> String {
        let graph = await container.getDependencyGraph()
        return DiagramGenerators.generateInteractiveVisualization(from: graph)
    }
    
    private func generateInteractiveVisualizationAsync(progress: Progress?) async -> String {
        let graph = await container.getDependencyGraph()
        progress?.completedUnitCount = 50
        let result = DiagramGenerators.generateInteractiveVisualization(from: graph)
        progress?.completedUnitCount = 100
        return result
    }
    
    private func generateDashboardVisualization() async -> String {
        let graph = await container.getDependencyGraph()
        return DiagramGenerators.generateDashboardVisualization(from: graph)
    }
    
    private func generateDashboardVisualizationAsync(progress: Progress?) async -> String {
        let graph = await container.getDependencyGraph()
        progress?.completedUnitCount = 50
        let result = DiagramGenerators.generateDashboardVisualization(from: graph)
        progress?.completedUnitCount = 100
        return result
    }
    
    private func generateHeatmapVisualization() async -> String {
        let graph = await container.getDependencyGraph()
        return DiagramGenerators.generateHeatmapVisualization(from: graph)
    }
    
    private func generateHeatmapVisualizationAsync(progress: Progress?) async -> String {
        let graph = await container.getDependencyGraph()
        progress?.completedUnitCount = 50
        let result = DiagramGenerators.generateHeatmapVisualization(from: graph)
        progress?.completedUnitCount = 100
        return result
    }
    
    private func generateTimelineVisualization() async -> String {
        let graph = await container.getDependencyGraph()
        return DiagramGenerators.generateTimelineVisualization(from: graph)
    }
    
    private func generateTimelineVisualizationAsync(progress: Progress?) async -> String {
        let graph = await container.getDependencyGraph()
        progress?.completedUnitCount = 50
        let result = DiagramGenerators.generateTimelineVisualization(from: graph)
        progress?.completedUnitCount = 100
        return result
    }
    
    private func generateClusterVisualization() async -> String {
        let graph = await container.getDependencyGraph()
        return DiagramGenerators.generateClusterVisualization(from: graph)
    }
    
    private func generateClusterVisualizationAsync(progress: Progress?) async -> String {
        let graph = await container.getDependencyGraph()
        progress?.completedUnitCount = 50
        let result = DiagramGenerators.generateClusterVisualization(from: graph)
        progress?.completedUnitCount = 100
        return result
    }
    
    // MARK: - Token Validation
    private func validateTokenForVisualization() async throws {
        guard let token = token else {
            throw VisualizationError.tokenRequired
        }
        
        // Validate token format
        guard token.count == 64 && token.allSatisfy({ $0.isHexDigit }) else {
            throw VisualizationError.invalidTokenFormat
        }
        
        // Validate token with Firebase
        do {
            let isValid = try await validateTokenWithFirebase(token)
            if !isValid {
                throw VisualizationError.invalidToken
            }
        } catch {
            throw VisualizationError.tokenValidationFailed(error)
        }
    }
    
    private func validateTokenWithFirebase(_ token: String) async throws -> Bool {
        let url = URL(string: "https://us-central1-godaredi-60569.cloudfunctions.net/validateToken")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = ["data": ["token": token]]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw VisualizationError.networkError
        }
        
        switch httpResponse.statusCode {
        case 200:
            let result = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            if let result = result, let resultData = result["result"] as? [String: Any] {
                return resultData["valid"] as? Bool ?? false
            }
            return false
        case 404:
            return false // Token not found
        case 410:
            throw VisualizationError.tokenExpired
        case 403:
            throw VisualizationError.tokenInactive
        default:
            throw VisualizationError.serverError(httpResponse.statusCode)
        }
    }
}

// MARK: - Visualization Error
public enum VisualizationError: Error, Sendable, LocalizedError {
    case tokenRequired
    case invalidTokenFormat
    case invalidToken
    case tokenExpired
    case tokenInactive
    case tokenValidationFailed(Error)
    case networkError
    case serverError(Int)
    
    public var errorDescription: String? {
        switch self {
        case .tokenRequired:
            return "A valid token is required for dependency visualization. Please provide a token when initializing the visualizer."
        case .invalidTokenFormat:
            return "Invalid token format. Token must be a 64-character hexadecimal string."
        case .invalidToken:
            return "Invalid token. Please check your token and try again."
        case .tokenExpired:
            return "Token has expired. Please generate a new token from your dashboard."
        case .tokenInactive:
            return "Token is inactive. Please activate your token from your dashboard."
        case .tokenValidationFailed(let error):
            return "Token validation failed: \(error.localizedDescription)"
        case .networkError:
            return "Network error during token validation. Please check your internet connection."
        case .serverError(let code):
            return "Server error during token validation (HTTP \(code)). Please try again later."
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .tokenRequired:
            return "Initialize the visualizer with a valid token: DependencyVisualizer(container: container, token: \"your-token-here\")"
        case .invalidTokenFormat:
            return "Please ensure your token is exactly 64 characters long and contains only hexadecimal characters (0-9, a-f)."
        case .invalidToken:
            return "Please visit the GoDareDI dashboard to generate a new token or verify your existing token."
        case .tokenExpired:
            return "Please visit the GoDareDI dashboard to generate a new token."
        case .tokenInactive:
            return "Please visit the GoDareDI dashboard to activate your token."
        case .tokenValidationFailed:
            return "Please check your internet connection and try again. If the problem persists, contact support."
        case .networkError:
            return "Please check your internet connection and try again."
        case .serverError:
            return "The server is temporarily unavailable. Please try again later."
        }
    }
}

