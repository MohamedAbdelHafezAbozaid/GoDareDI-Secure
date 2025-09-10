//
//  GraphAnalysis+Extensions.swift
//  GoDareAdvanced
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - GraphAnalysis Extensions
extension GraphAnalysis {
    var mermaidFormat: String {
        return """
        GraphAnalysis(
            hasCircularDependencies: \(hasCircularDependencies),
            totalNodes: \(totalNodes),
            totalDependencies: \(totalDependencies),
            maxDepth: \(maxDepth),
            analysisTime: \(String(format: "%.2f", analysisTime))ms,
            memoryUsage: \(String(format: "%.2f", memoryUsage))MB,
            cacheEfficiency: \(String(format: "%.1f", cacheEfficiency))%
        )
        """
    }
    
    var summary: String {
        return """
        📊 Analysis Summary:
        • Nodes: \(totalNodes)
        • Dependencies: \(totalDependencies)
        • Max Depth: \(maxDepth)
        • Circular Dependencies: \(hasCircularDependencies ? "YES" : "NO")
        • Analysis Time: \(String(format: "%.2f", analysisTime))ms
        • Memory Usage: \(String(format: "%.2f", memoryUsage))MB
        • Cache Efficiency: \(String(format: "%.1f", cacheEfficiency))%
        """
    }
}
