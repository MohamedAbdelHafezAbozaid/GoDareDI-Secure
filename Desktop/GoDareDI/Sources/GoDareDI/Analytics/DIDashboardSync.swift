//
//  DIDashboardSync.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - Dashboard Sync Provider
@MainActor
public protocol DIDashboardSyncProvider: Sendable {
    func updateDashboard(with dependencyInfo: DependencyInfo) async throws
    func getDashboardData() async throws -> DashboardData
}

// MARK: - Dependency Info
public struct DependencyInfo: Sendable, Codable {
    public let version: String
    public let dependencies: [DashboardDependencyNode]
    public let nodes: [GraphNode]
    public let edges: [GraphEdge]
    public let analysis: GraphAnalysis
    public let performanceMetrics: PerformanceMetrics
    public let timestamp: Date
    
    public init(
        version: String = "1.0.0",
        dependencies: [DashboardDependencyNode],
        nodes: [GraphNode],
        edges: [GraphEdge],
        analysis: GraphAnalysis,
        performanceMetrics: PerformanceMetrics,
        timestamp: Date = Date()
    ) {
        self.version = version
        self.dependencies = dependencies
        self.nodes = nodes
        self.edges = edges
        self.analysis = analysis
        self.performanceMetrics = performanceMetrics
        self.timestamp = timestamp
    }
}

// MARK: - Dashboard Dependency Node (for sync purposes)
public struct DashboardDependencyNode: Sendable, Codable {
    public let id: String
    public let type: String
    public let scope: String
    public let lifetime: String
    public let dependencies: [String]
    public let isRegistered: Bool
    public let resolutionTime: Double?
    
    public init(
        id: String,
        type: String,
        scope: String,
        lifetime: String,
        dependencies: [String],
        isRegistered: Bool,
        resolutionTime: Double? = nil
    ) {
        self.id = id
        self.type = type
        self.scope = scope
        self.lifetime = lifetime
        self.dependencies = dependencies
        self.isRegistered = isRegistered
        self.resolutionTime = resolutionTime
    }
}

// MARK: - Dashboard Data
public struct DashboardData: Sendable, Codable {
    public let hasData: Bool
    public let dependencyInfo: DependencyInfo?
    public let analytics: [AnalyticsData]
    public let recentEvents: [UsageEvent]
    public let lastUpdated: Date?
    
    public init(
        hasData: Bool,
        dependencyInfo: DependencyInfo? = nil,
        analytics: [AnalyticsData] = [],
        recentEvents: [UsageEvent] = [],
        lastUpdated: Date? = nil
    ) {
        self.hasData = hasData
        self.dependencyInfo = dependencyInfo
        self.analytics = analytics
        self.recentEvents = recentEvents
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Analytics Data
public struct AnalyticsData: Sendable, Codable {
    public let id: String
    public let date: String
    public let eventType: String
    public let count: Int
    public let data: [String: AnyCodable]?
    
    public init(
        id: String,
        date: String,
        eventType: String,
        count: Int,
        data: [String: AnyCodable]? = nil
    ) {
        self.id = id
        self.date = date
        self.eventType = eventType
        self.count = count
        self.data = data
    }
}

// MARK: - Usage Event
public struct UsageEvent: Sendable, Codable {
    public let id: String
    public let eventType: String
    public let eventData: [String: AnyCodable]?
    public let timestamp: Date
    
    public init(
        id: String,
        eventType: String,
        eventData: [String: AnyCodable]? = nil,
        timestamp: Date
    ) {
        self.id = id
        self.eventType = eventType
        self.eventData = eventData
        self.timestamp = timestamp
    }
}

// MARK: - Any Codable Helper
public struct AnyCodable: Sendable, Codable {
    public let value: Any
    
    public init<T>(_ value: T?) {
        self.value = value ?? ()
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.init(())
        } else if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let double = try? container.decode(Double.self) {
            self.init(double)
        } else if let string = try? container.decode(String.self) {
            self.init(string)
        } else if let array = try? container.decode([AnyCodable].self) {
            self.init(array.map { $0.value })
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.init(dictionary.mapValues { $0.value })
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case is Void:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable value cannot be encoded")
            throw EncodingError.invalidValue(value, context)
        }
    }
}

// MARK: - Default Dashboard Sync Provider
@MainActor
public class DefaultDashboardSyncProvider: DIDashboardSyncProvider {
    
    // MARK: - Properties
    private let token: String
    private let baseURL: String
    private let session: URLSession
    
    // MARK: - Initialization
    public init(token: String, baseURL: String = "https://us-central1-godaredi-60569.cloudfunctions.net") {
        self.token = token
        self.baseURL = baseURL
        self.session = URLSession.shared
    }
    
    // MARK: - Public Methods
    public func updateDashboard(with dependencyInfo: DependencyInfo) async throws {
        let url = URL(string: "\(baseURL)/updateUserDashboard")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "data": [
                "token": token,
                "dependencyInfo": try encodeDependencyInfo(dependencyInfo)
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DashboardSyncError.networkError
        }
        
        switch httpResponse.statusCode {
        case 200:
            let result = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            // Handle Firebase callable function response format
            if let resultData = result?["result"] as? [String: Any] {
                if let success = resultData["success"] as? Bool, success {
                    return
                } else {
                    throw DashboardSyncError.updateFailed
                }
            }
            // Fallback to direct success check for backward compatibility
            else if let success = result?["success"] as? Bool, success {
                return
            } else {
                throw DashboardSyncError.updateFailed
            }
        case 403:
            throw DashboardSyncError.invalidToken
        case 404:
            throw DashboardSyncError.tokenNotFound
        default:
            throw DashboardSyncError.serverError(httpResponse.statusCode)
        }
    }
    
    public func getDashboardData() async throws -> DashboardData {
        let url = URL(string: "\(baseURL)/getUserDashboardData")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "data": [
                "token": token
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DashboardSyncError.networkError
        }
        
        switch httpResponse.statusCode {
        case 200:
            let result = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            // Handle Firebase callable function response format
            if let resultData = result?["result"] as? [String: Any] {
                return try decodeDashboardData(from: resultData)
            }
            // Fallback to direct result for backward compatibility
            else {
                return try decodeDashboardData(from: result!)
            }
        case 401:
            throw DashboardSyncError.unauthorized
        default:
            throw DashboardSyncError.serverError(httpResponse.statusCode)
        }
    }
    
    // MARK: - Private Methods
    private func encodeDependencyInfo(_ info: DependencyInfo) throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(info)
        return try JSONSerialization.jsonObject(with: data) as! [String: Any]
    }
    
    private func decodeDashboardData(from result: [String: Any]) throws -> DashboardData {
        // This is a simplified implementation
        // In a real implementation, you'd properly decode the JSON
        let hasData = result["hasData"] as? Bool ?? false
        
        return DashboardData(
            hasData: hasData,
            lastUpdated: Date()
        )
    }
}

// MARK: - Dashboard Sync Error
public enum DashboardSyncError: Error, Sendable, LocalizedError {
    case networkError
    case invalidToken
    case tokenNotFound
    case updateFailed
    case fetchFailed
    case unauthorized
    case serverError(Int)
    
    public var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network error during dashboard sync. Please check your internet connection."
        case .invalidToken:
            return "Invalid token. Please check your token and try again."
        case .tokenNotFound:
            return "Token not found. Please generate a new token from your dashboard."
        case .updateFailed:
            return "Failed to update dashboard. Please try again."
        case .fetchFailed:
            return "Failed to fetch dashboard data. Please try again."
        case .unauthorized:
            return "Unauthorized access. Please login again."
        case .serverError(let code):
            return "Server error during dashboard sync (HTTP \(code)). Please try again later."
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Please check your internet connection and try again."
        case .invalidToken:
            return "Please visit the GoDareDI dashboard to verify your token."
        case .tokenNotFound:
            return "Please visit the GoDareDI dashboard to generate a new token."
        case .updateFailed, .fetchFailed:
            return "Please try again. If the problem persists, contact support."
        case .unauthorized:
            return "Please login to your dashboard and try again."
        case .serverError:
            return "The server is temporarily unavailable. Please try again later."
        }
    }
}
