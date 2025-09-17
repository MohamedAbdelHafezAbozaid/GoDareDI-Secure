//
//  DICrashlyticsIntegration.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

@available(iOS 18.0, macOS 10.15, *)
public protocol DICrashlyticsProvider: Sendable {
    func logError(_ error: Error, context: [String: Any]?)
    func logEvent(_ event: String, parameters: [String: Any]?)
    func setUserIdentifier(_ identifier: String)
    func setCustomValue(_ value: Any, forKey key: String)
}

@available(iOS 18.0, macOS 10.15, *)
public final class DefaultDICrashlyticsProvider: DICrashlyticsProvider, Sendable {
    public static let shared = DefaultDICrashlyticsProvider()
    
    private init() {}
    
    public func logError(_ error: Error, context: [String: Any]?) {
        print("💥 [Crashlytics] Error: \(error.localizedDescription)")
        if let context = context {
            for (key, value) in context {
                print("💥 [Crashlytics]   \(key): \(value)")
            }
        }
    }
    
    public func logEvent(_ event: String, parameters: [String: Any]?) {
        print("📝 [Crashlytics] Event: \(event)")
        if let parameters = parameters {
            for (key, value) in parameters {
                print("📝 [Crashlytics]   \(key): \(value)")
            }
        }
    }
    
    public func setUserIdentifier(_ identifier: String) {
        print("👤 [Crashlytics] User ID: \(identifier)")
    }
    
    public func setCustomValue(_ value: Any, forKey key: String) {
        print("🔧 [Crashlytics] Custom Value: \(key) = \(value)")
    }
}

@available(iOS 18.0, macOS 10.15, *)
public struct DICrashlyticsConfig: Sendable {
    public let enabled: Bool
    public let logLevel: CrashlyticsLogLevel
    public let autoCrashReporting: Bool
    public let customKeys: [String: String]
    
    public init(
        enabled: Bool = true,
        logLevel: CrashlyticsLogLevel = .info,
        autoCrashReporting: Bool = true,
        customKeys: [String: String] = [:]
    ) {
        self.enabled = enabled
        self.logLevel = logLevel
        self.autoCrashReporting = autoCrashReporting
        self.customKeys = customKeys
    }
}

@available(iOS 18.0, macOS 10.15, *)
public enum CrashlyticsLogLevel: String, CaseIterable, Sendable {
    case debug = "debug"
    case info = "info"
    case warning = "warning"
    case error = "error"
    case fatal = "fatal"
}

@available(iOS 18.0, macOS 10.15, *)
public final class DICrashlyticsManager: Sendable {
    private let provider: DICrashlyticsProvider
    private let config: DICrashlyticsConfig
    
    public init(provider: DICrashlyticsProvider = DefaultDICrashlyticsProvider.shared, config: DICrashlyticsConfig = DICrashlyticsConfig()) {
        self.provider = provider
        self.config = config
    }
    
    public func logDependencyError(_ error: Error, dependencyType: String, context: [String: Any]? = nil) {
        var errorContext = context ?? [:]
        errorContext["dependency_type"] = dependencyType
        errorContext["component"] = "GoDareDI"
        
        provider.logError(error, context: errorContext)
    }
    
    public func logRegistrationEvent(_ event: String, dependencyType: String, parameters: [String: Any]? = nil) {
        var eventParams = parameters ?? [:]
        eventParams["dependency_type"] = dependencyType
        eventParams["component"] = "GoDareDI"
        
        provider.logEvent("di_registration_\(event)", parameters: eventParams)
    }
    
    public func logResolutionEvent(_ event: String, dependencyType: String, parameters: [String: Any]? = nil) {
        var eventParams = parameters ?? [:]
        eventParams["dependency_type"] = dependencyType
        eventParams["component"] = "GoDareDI"
        
        provider.logEvent("di_resolution_\(event)", parameters: eventParams)
    }
    
    public func logPerformanceIssue(_ issue: String, dependencyType: String, metrics: [String: Any]? = nil) {
        var issueParams = metrics ?? [:]
        issueParams["issue"] = issue
        issueParams["dependency_type"] = dependencyType
        issueParams["component"] = "GoDareDI"
        
        provider.logEvent("di_performance_issue", parameters: issueParams)
    }
}
