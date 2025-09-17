//
//  ErrorTypes.swift
//  GoDareAdvanced
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - Error Types
public struct CircularDependencyException: LocalizedError, Codable, Sendable {
    public let message: String
    public let cycle: [String]
    
    public init(_ message: String, cycle: [String] = []) {
        self.message = message
        self.cycle = cycle
    }
    
    public var errorDescription: String? {
        return "Circular Dependency: \(message)"
    }
}

public enum DependencyResolutionError: LocalizedError, Codable, Sendable {
    case notRegistered(String)
    case circularDependency([String])
    case scopeNotFound(String)
    case factoryError(String)
    case validationError(String)
    case typeMismatch(String)
    
    public var errorDescription: String? {
        switch self {
        case .notRegistered(let type):
            return "Type not registered: \(type)"
        case .circularDependency(let cycle):
            return "Circular dependency detected: \(cycle.joined(separator: " -> "))"
        case .scopeNotFound(let scope):
            return "Scope not found: \(scope)"
        case .factoryError(let error):
            return "Factory error: \(error)"
        case .validationError(let error):
            return "Validation error: \(error)"
        case .typeMismatch(let error):
            return "Type mismatch: \(error)"
        }
    }
}
