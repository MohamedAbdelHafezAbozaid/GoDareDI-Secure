//
//  DIAnalyticsProvider.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation
import Network

// MARK: - Analytics Provider Protocol
@MainActor
public protocol DIAnalyticsProvider: Sendable {
    func trackEvent(_ event: DIAnalyticsEvent) async
    func trackDependencyResolution(_ type: String, duration: TimeInterval, success: Bool) async
    func trackDependencyRegistration(_ type: String, scope: DependencyScope) async
    func trackPerformanceIssue(_ issue: PerformanceIssue) async
    func trackCircularDependency(_ chain: [String]) async
    func trackError(_ error: Error, context: DependencyContext) async
}

// MARK: - Analytics Event Types
public enum DIAnalyticsEvent: Sendable {
    case dependencyResolution(type: String, duration: TimeInterval, success: Bool)
    case dependencyRegistration(type: String, scope: DependencyScope)
    case performanceIssue(issue: PerformanceIssue)
    case circularDependency(chain: [String])
    case error(error: Error, context: DependencyContext)
    case containerInitialization(duration: TimeInterval)
    case containerCleanup(duration: TimeInterval)
    case scopeCreation(scopeId: String)
    case scopeDisposal(scopeId: String)
    case preloadingStarted(strategy: PreloadingStrategy)
    case preloadingCompleted(strategy: PreloadingStrategy, duration: TimeInterval)
}

// MARK: - Performance Issue
public struct PerformanceIssue: @unchecked Sendable {
    public let type: PerformanceIssueType
    public let severity: PerformanceSeverity
    public let details: [String: Any] // @unchecked Sendable - Any is not Sendable but we assume it's safe here
    public let timestamp: Date
    
    public init(type: PerformanceIssueType, severity: PerformanceSeverity, details: [String: Any] = [:]) {
        self.type = type
        self.severity = severity
        self.details = details
        self.timestamp = Date()
    }
}

public enum PerformanceIssueType: String, Sendable {
    case slowResolution = "slow_resolution"
    case highMemoryUsage = "high_memory_usage"
    case circularDependency = "circular_dependency"
    case cacheMiss = "cache_miss"
    case scopeLeak = "scope_leak"
    case preloadingFailure = "preloading_failure"
}

public enum PerformanceSeverity: String, Sendable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
}

// MARK: - Dependency Context
public struct DependencyContext: Sendable {
    public let dependencyType: String
    public let scope: DependencyScope
    public let lifetime: DependencyLifetime
    public let resolutionStack: [String]
    public let containerState: ContainerState
    public let timestamp: Date
    
    public init(dependencyType: String, scope: DependencyScope, lifetime: DependencyLifetime, resolutionStack: [String], containerState: ContainerState) {
        self.dependencyType = dependencyType
        self.scope = scope
        self.lifetime = lifetime
        self.resolutionStack = resolutionStack
        self.containerState = containerState
        self.timestamp = Date()
    }
}

// MARK: - Container State
public struct ContainerState: Sendable {
    public let registeredServicesCount: Int
    public let activeScopes: [String]
    public let memoryUsage: Double
    public let currentScope: String
    public let isPreloading: Bool
    
    public init(registeredServicesCount: Int, activeScopes: [String], memoryUsage: Double, currentScope: String, isPreloading: Bool) {
        self.registeredServicesCount = registeredServicesCount
        self.activeScopes = activeScopes
        self.memoryUsage = memoryUsage
        self.currentScope = currentScope
        self.isPreloading = isPreloading
    }
}

// MARK: - Preloading Strategy
public enum PreloadingStrategy: String, Sendable {
    case all = "all"
    case smart = "smart"
    case viewModelsOnly = "view_models_only"
    case custom = "custom"
}

// MARK: - Event Buffer Actor
actor EventBuffer {
    private var events: [DIAnalyticsEvent] = []
    private let maxSize: Int
    
    init(maxSize: Int = 50) {
        self.maxSize = maxSize
    }
    
    func append(_ event: DIAnalyticsEvent) -> Bool {
        events.append(event)
        return events.count >= maxSize
    }
    
    func removeAll() -> [DIAnalyticsEvent] {
        let result = events
        events.removeAll()
        return result
    }
    
    func insertAtBeginning(_ newEvents: [DIAnalyticsEvent]) {
        events.insert(contentsOf: newEvents, at: 0)
    }
}

// MARK: - Default Analytics Provider
@MainActor
public class DefaultAnalyticsProvider: DIAnalyticsProvider {
    
    // MARK: - Properties
    private let token: String
    private let baseURL: String
    private let session: URLSession
    private let eventBuffer: EventBuffer
    private let flushInterval: TimeInterval = 30.0
    private var flushTimer: Timer?
    
    // MARK: - Initialization
    public init(token: String, baseURL: String = "https://us-central1-godaredi-60569.cloudfunctions.net") {
        self.token = token
        self.baseURL = baseURL
        self.session = URLSession.shared
        self.eventBuffer = EventBuffer()
        
        startFlushTimer()
    }
    
    // MARK: - Cleanup
    public func cleanup() {
        flushTimer?.invalidate()
        flushTimer = nil
    }
    
    // MARK: - Public Methods
    public func trackEvent(_ event: DIAnalyticsEvent) async {
        let shouldFlush = await eventBuffer.append(event)
        
        if shouldFlush {
            Task {
                await flushEvents()
            }
        }
    }
    
    public func trackDependencyResolution(_ type: String, duration: TimeInterval, success: Bool) async {
        let event = DIAnalyticsEvent.dependencyResolution(type: type, duration: duration, success: success)
        await trackEvent(event)
    }
    
    public func trackDependencyRegistration(_ type: String, scope: DependencyScope) async {
        let event = DIAnalyticsEvent.dependencyRegistration(type: type, scope: scope)
        await trackEvent(event)
    }
    
    public func trackPerformanceIssue(_ issue: PerformanceIssue) async {
        let event = DIAnalyticsEvent.performanceIssue(issue: issue)
        await trackEvent(event)
    }
    
    public func trackCircularDependency(_ chain: [String]) async {
        let event = DIAnalyticsEvent.circularDependency(chain: chain)
        await trackEvent(event)
    }
    
    public func trackError(_ error: Error, context: DependencyContext) async {
        let event = DIAnalyticsEvent.error(error: error, context: context)
        await trackEvent(event)
    }
    
    // MARK: - Private Methods
    private func startFlushTimer() {
        flushTimer = Timer.scheduledTimer(withTimeInterval: flushInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.flushEvents()
            }
        }
    }
    
    private func flushEvents() async {
        let eventsToFlush = await eventBuffer.removeAll()
        
        guard !eventsToFlush.isEmpty else { return }
        
        do {
            try await sendEvents(eventsToFlush)
        } catch {
            // Re-add events to buffer if sending fails
            await eventBuffer.insertAtBeginning(eventsToFlush)
        }
    }
    
    private func sendEvents(_ events: [DIAnalyticsEvent]) async throws {
        let url = URL(string: "\(baseURL)/trackUsage")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let eventData = events.map { event in
            convertEventToDictionary(event)
        }
        
        let payload: [String: Any] = [
            "data": [
                "token": token,
                "eventType": "batch_events",
                "eventData": eventData
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AnalyticsError.networkError
        }
    }
    
    private func convertEventToDictionary(_ event: DIAnalyticsEvent) -> [String: Any] {
        switch event {
        case .dependencyResolution(let type, let duration, let success):
            return [
                "type": "dependency_resolution",
                "dependency_type": type,
                "duration": duration,
                "success": success,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
            
        case .dependencyRegistration(let type, let scope):
            return [
                "type": "dependency_registration",
                "dependency_type": type,
                "scope": scope.rawValue,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
            
        case .performanceIssue(let issue):
            return [
                "type": "performance_issue",
                "issue_type": issue.type.rawValue,
                "severity": issue.severity.rawValue,
                "details": issue.details,
                "timestamp": ISO8601DateFormatter().string(from: issue.timestamp)
            ]
            
        case .circularDependency(let chain):
            return [
                "type": "circular_dependency",
                "chain": chain,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
            
        case .error(let error, let context):
            return [
                "type": "error",
                "error_type": String(describing: type(of: error)),
                "error_message": error.localizedDescription,
                "dependency_type": context.dependencyType,
                "scope": context.scope.rawValue,
                "lifetime": context.lifetime.rawValue,
                "resolution_stack": context.resolutionStack,
                "container_state": [
                    "registered_services_count": context.containerState.registeredServicesCount,
                    "active_scopes": context.containerState.activeScopes,
                    "memory_usage": context.containerState.memoryUsage,
                    "current_scope": context.containerState.currentScope,
                    "is_preloading": context.containerState.isPreloading
                ],
                "timestamp": ISO8601DateFormatter().string(from: context.timestamp)
            ]
            
        case .containerInitialization(let duration):
            return [
                "type": "container_initialization",
                "duration": duration,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
            
        case .containerCleanup(let duration):
            return [
                "type": "container_cleanup",
                "duration": duration,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
            
        case .scopeCreation(let scopeId):
            return [
                "type": "scope_creation",
                "scope_id": scopeId,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
            
        case .scopeDisposal(let scopeId):
            return [
                "type": "scope_disposal",
                "scope_id": scopeId,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
            
        case .preloadingStarted(let strategy):
            return [
                "type": "preloading_started",
                "strategy": strategy.rawValue,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
            
        case .preloadingCompleted(let strategy, let duration):
            return [
                "type": "preloading_completed",
                "strategy": strategy.rawValue,
                "duration": duration,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
        }
    }
}

// MARK: - Analytics Error
public enum AnalyticsError: Error, Sendable {
    case networkError
    case invalidToken
    case serializationError
    case unknown
}
