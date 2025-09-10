//
//  DependencyGraph+Extensions.swift
//  GoDareAdvanced
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - DependencyGraph Extensions
extension DependencyGraph {
    var mermaidFormat: String {
        var mermaid = "graph TD\n"
        
        // Add nodes
        for node in nodes {
            let scopeClass = node.scope.rawValue
            let circularIndicator = node.isCircular ? " 🔄" : ""
            mermaid += "    \(node.id)[\"\(node.id)<br/><small>\(node.scope.rawValue)</small>\(circularIndicator)\"]:::\(scopeClass)\n"
        }
        
        // Add edges
        for edge in edges {
            let circularStyle = edge.isCircular ? ":::circular" : ""
            mermaid += "    \(edge.from) --> \(edge.to)\(circularStyle)\n"
        }
        
        // Add class definitions
        mermaid += "    classDef singleton fill:#4CAF50,stroke:#2E7D32,stroke-width:2px,color:#fff\n"
        mermaid += "    classDef scoped fill:#2196F3,stroke:#1565C0,stroke-width:2px,color:#fff\n"
        mermaid += "    classDef transient fill:#FF9800,stroke:#E65100,stroke-width:2px,color:#fff\n"
        mermaid += "    classDef lazy fill:#9C27B0,stroke:#6A1B9A,stroke-width:2px,color:#fff\n"
        mermaid += "    classDef circular fill:#F44336,stroke:#D32F2F,stroke-width:3px,color:#fff,stroke-dasharray: 5 5\n"
        
        return mermaid
    }
}
