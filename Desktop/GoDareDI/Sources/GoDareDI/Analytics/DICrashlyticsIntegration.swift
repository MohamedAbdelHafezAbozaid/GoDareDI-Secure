//
//  DICrashlyticsIntegration.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - Crashlytics Integration
@MainActor
public class DICrashlyticsIntegration: DIAnalyticsProvider {
    
    // MARK: - Properties
    private let analyticsProvider: DIAnalyticsProvider
    private let crashlyticsProvider: DICrashlyticsProvider
    private let token: String
    
    // MARK: - Initialization
    public init(token: String, analyticsProvider: DIAnalyticsProvider? = nil) {
        self.token = token
        self.analyticsProvider = analyticsProvider ?? DefaultAnalyticsProvider(token: token)
        self.crashlyticsProvider = DefaultCrashlyticsProvider(token: token)
    }
    
    // MARK: - DIAnalyticsProvider Implementation
    public func trackEvent(_ event: DIAnalyticsEvent) async {
        // Track with analytics provider
        await analyticsProvider.trackEvent(event)
        
        // Also track with crashlytics if it's an error or performance issue
        switch event {
        case .error(let error, let context):
            await crashlyticsProvider.trackDependencyError(error, context: context)
        case .performanceIssue(let issue):
            await crashlyticsProvider.trackPerformanceIssue(issue)
        case .circularDependency(let chain):
            await crashlyticsProvider.trackCircularDependency(chain)
        default:
            break
        }
    }
    
    public func trackDependencyResolution(_ type: String, duration: TimeInterval, success: Bool) async {
        await analyticsProvider.trackDependencyResolution(type, duration: duration, success: success)
        
        // Track performance issues if resolution is too slow
        if duration > 1.0 { // 1 second threshold
            let issue = PerformanceIssue(
                type: .slowResolution,
                severity: duration > 5.0 ? .critical : .high,
                details: [
                    "dependency_type": type,
                    "duration": duration,
                    "success": success
                ]
            )
            await crashlyticsProvider.trackPerformanceIssue(issue)
        }
    }
    
    public func trackDependencyRegistration(_ type: String, scope: DependencyScope) async {
        await analyticsProvider.trackDependencyRegistration(type, scope: scope)
    }
    
    public func trackPerformanceIssue(_ issue: PerformanceIssue) async {
        await analyticsProvider.trackPerformanceIssue(issue)
        await crashlyticsProvider.trackPerformanceIssue(issue)
    }
    
    public func trackCircularDependency(_ chain: [String]) async {
        await analyticsProvider.trackCircularDependency(chain)
        await crashlyticsProvider.trackCircularDependency(chain)
    }
    
    public func trackError(_ error: Error, context: DependencyContext) async {
        await analyticsProvider.trackError(error, context: context)
        await crashlyticsProvider.trackDependencyError(error, context: context)
    }
}

// MARK: - Crashlytics Provider Protocol
@MainActor
public protocol DICrashlyticsProvider: Sendable {
    func trackDependencyError(_ error: Error, context: DependencyContext) async
    func trackPerformanceIssue(_ issue: PerformanceIssue) async
    func trackCircularDependency(_ chain: [String]) async
    func trackContainerCrash(_ crash: ContainerCrash) async
}

// MARK: - Container Crash
public struct ContainerCrash: Sendable {
    public let crashType: ContainerCrashType
    public let error: Error
    public let context: DependencyContext
    public let stackTrace: [String]
    public let timestamp: Date
    
    public init(crashType: ContainerCrashType, error: Error, context: DependencyContext, stackTrace: [String] = []) {
        self.crashType = crashType
        self.error = error
        self.context = context
        self.stackTrace = stackTrace
        self.timestamp = Date()
    }
}

public enum ContainerCrashType: String, Sendable {
    case resolutionFailure = "resolution_failure"
    case circularDependency = "circular_dependency"
    case scopeLeak = "scope_leak"
    case memoryLeak = "memory_leak"
    case preloadingFailure = "preloading_failure"
    case validationFailure = "validation_failure"
}

// MARK: - Default Crashlytics Provider
@MainActor
public class DefaultCrashlyticsProvider: DICrashlyticsProvider {
    
    // MARK: - Properties
    private let token: String
    private let baseURL: String
    private let session: URLSession
    
    private let queue: DispatchQueue
    
    // MARK: - Initialization
    public init(token: String, baseURL: String = "https://us-central1-godaredi-60569.cloudfunctions.net") {
        self.token = token
        self.baseURL = baseURL
        self.session = URLSession.shared
        self.queue = DispatchQueue(label: "com.godaredi.crashlytics", qos: .utility)
    }
    
    // MARK: - Public Methods
    public func trackDependencyError(_ error: Error, context: DependencyContext) async {
        let crash = ContainerCrash(
            crashType: .resolutionFailure,
            error: error,
            context: context,
            stackTrace: Thread.callStackSymbols
        )
        await trackContainerCrash(crash)
    }
    
    public func trackPerformanceIssue(_ issue: PerformanceIssue) async {
        await queue.async { [weak self] in
            Task {
                await self?.sendPerformanceIssue(issue)
            }
        }
    }
    
    public func trackCircularDependency(_ chain: [String]) async {
        await queue.async { [weak self] in
            Task {
                await self?.sendCircularDependency(chain)
            }
        }
    }
    
    public func trackContainerCrash(_ crash: ContainerCrash) async {
        await queue.async { [weak self] in
            Task {
                await self?.sendContainerCrash(crash)
            }
        }
    }
    
    // MARK: - Private Methods
    private func sendPerformanceIssue(_ issue: PerformanceIssue) async {
        do {
            let url = URL(string: "\(baseURL)/trackUsage")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let payload: [String: Any] = [
                "data": [
                    "token": token,
                    "eventType": "performance_issue",
                    "eventData": [
                        "issue_type": issue.type.rawValue,
                        "severity": issue.severity.rawValue,
                        "details": issue.details,
                        "timestamp": ISO8601DateFormatter().string(from: issue.timestamp)
                    ]
                ]
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("Failed to send performance issue to crashlytics")
                return
            }
            
        } catch {
            print("Error sending performance issue: \(error)")
        }
    }
    
    private func sendCircularDependency(_ chain: [String]) async {
        do {
            let url = URL(string: "\(baseURL)/trackUsage")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let payload: [String: Any] = [
                "data": [
                    "token": token,
                    "eventType": "circular_dependency",
                    "eventData": [
                        "chain": chain,
                        "timestamp": ISO8601DateFormatter().string(from: Date())
                    ]
                ]
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("Failed to send circular dependency to crashlytics")
                return
            }
            
        } catch {
            print("Error sending circular dependency: \(error)")
        }
    }
    
    private func sendContainerCrash(_ crash: ContainerCrash) async {
        do {
            let url = URL(string: "\(baseURL)/trackUsage")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let payload: [String: Any] = [
                "data": [
                    "token": token,
                    "eventType": "container_crash",
                    "eventData": [
                        "crash_type": crash.crashType.rawValue,
                        "error_type": String(describing: type(of: crash.error)),
                        "error_message": crash.error.localizedDescription,
                        "dependency_type": crash.context.dependencyType,
                        "scope": crash.context.scope.rawValue,
                        "lifetime": crash.context.lifetime.rawValue,
                        "resolution_stack": crash.context.resolutionStack,
                        "container_state": [
                            "registered_services_count": crash.context.containerState.registeredServicesCount,
                    "active_scopes": crash.context.containerState.activeScopes,
                    "memory_usage": crash.context.containerState.memoryUsage,
                    "current_scope": crash.context.containerState.currentScope,
                    "is_preloading": crash.context.containerState.isPreloading
                        ],
                        "stack_trace": crash.stackTrace,
                        "timestamp": ISO8601DateFormatter().string(from: crash.timestamp)
                    ]
                ]
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("Failed to send container crash to crashlytics")
                return
            }
            
        } catch {
            print("Error sending container crash: \(error)")
        }
    }
}

// MARK: - Crashlytics Configuration
public struct DICrashlyticsConfig: Sendable {
    public let token: String
    public let enableCrashlytics: Bool
    public let enableAnalytics: Bool
    public let enablePerformanceTracking: Bool
    public let enableCircularDependencyTracking: Bool
    public let baseURL: String
    
    public init(
        token: String,
        enableCrashlytics: Bool = true,
        enableAnalytics: Bool = true,
        enablePerformanceTracking: Bool = true,
        enableCircularDependencyTracking: Bool = true,
        baseURL: String = "https://us-central1-godaredi-60569.cloudfunctions.net"
    ) {
        self.token = token
        self.enableCrashlytics = enableCrashlytics
        self.enableAnalytics = enableAnalytics
        self.enablePerformanceTracking = enablePerformanceTracking
        self.enableCircularDependencyTracking = enableCircularDependencyTracking
        self.baseURL = baseURL
    }
}
