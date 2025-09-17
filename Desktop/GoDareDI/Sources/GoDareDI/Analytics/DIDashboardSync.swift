//
//  DIDashboardSync.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

@available(iOS 18.0, macOS 10.15, *)
public protocol DIDashboardSyncProvider: Sendable {
    func syncDependencyInfo(_ info: DependencyInfo) async throws
    func syncDashboardData(_ data: DashboardData) async throws
    func getDashboardData() async throws -> DashboardData
}

@available(iOS 18.0, macOS 10.15, *)
public struct DependencyInfo: Sendable, Codable {
    public let id: String
    public let type: String
    public let scope: String
    public let lifetime: String?
    public let dependencies: [String]
    public let timestamp: Date
    
    public init(id: String, type: String, scope: String, lifetime: String? = nil, dependencies: [String] = []) {
        self.id = id
        self.type = type
        self.scope = scope
        self.lifetime = lifetime
        self.dependencies = dependencies
        self.timestamp = Date()
    }
}

@available(iOS 18.0, macOS 10.15, *)
public struct DashboardData: Sendable, Codable {
    public let totalDependencies: Int
    public let scopedDependencies: Int
    public let singletonDependencies: Int
    public let transientDependencies: Int
    public let circularDependencies: [String]
    public let performanceIssues: [String]
    public let lastUpdated: Date
    
    public init(
        totalDependencies: Int,
        scopedDependencies: Int,
        singletonDependencies: Int,
        transientDependencies: Int,
        circularDependencies: [String] = [],
        performanceIssues: [String] = []
    ) {
        self.totalDependencies = totalDependencies
        self.scopedDependencies = scopedDependencies
        self.singletonDependencies = singletonDependencies
        self.transientDependencies = transientDependencies
        self.circularDependencies = circularDependencies
        self.performanceIssues = performanceIssues
        self.lastUpdated = Date()
    }
}

@available(iOS 18.0, macOS 10.15, *)
public final class DefaultDashboardSyncProvider: DIDashboardSyncProvider, Sendable {
    public static let shared = DefaultDashboardSyncProvider()
    
    private let baseURL = "https://api.godare.app"
    private let session = URLSession.shared
    
    private init() {}
    
    public func syncDependencyInfo(_ info: DependencyInfo) async throws {
        guard let url = URL(string: "\(baseURL)/dependencies") else {
            throw DIAnalyticsError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let data = try JSONEncoder().encode(info)
            request.httpBody = data
            
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw DIAnalyticsError.syncFailed
            }
        } catch {
            throw DIAnalyticsError.networkError(error)
        }
    }
    
    public func syncDashboardData(_ data: DashboardData) async throws {
        guard let url = URL(string: "\(baseURL)/dashboard") else {
            throw DIAnalyticsError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let data = try JSONEncoder().encode(data)
            request.httpBody = data
            
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw DIAnalyticsError.syncFailed
            }
        } catch {
            throw DIAnalyticsError.networkError(error)
        }
    }
    
    public func getDashboardData() async throws -> DashboardData {
        guard let url = URL(string: "\(baseURL)/dashboard") else {
            throw DIAnalyticsError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw DIAnalyticsError.syncFailed
            }
            
            return try JSONDecoder().decode(DashboardData.self, from: data)
        } catch {
            throw DIAnalyticsError.networkError(error)
        }
    }
}

@available(iOS 18.0, macOS 10.15, *)
public enum DIAnalyticsError: Error, Sendable {
    case invalidURL
    case syncFailed
    case networkError(Error)
    case encodingError(Error)
    case decodingError(Error)
}
