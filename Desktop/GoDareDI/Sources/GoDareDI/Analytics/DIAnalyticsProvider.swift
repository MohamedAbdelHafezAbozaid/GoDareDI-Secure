//
//  DIAnalyticsProvider.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

@available(iOS 18.0, macOS 10.15, *)
public protocol DIAnalyticsProvider: Sendable {
    func trackEvent(_ event: String, parameters: [String: Any]?)
    func trackError(_ error: Error, context: [String: Any]?)
    func trackPerformance(_ metric: String, value: Double, unit: String?)
}

@available(iOS 18.0, macOS 10.15, *)
public final class DefaultDIAnalyticsProvider: DIAnalyticsProvider, Sendable {
    public static let shared = DefaultDIAnalyticsProvider()
    
    private init() {}
    
    public func trackEvent(_ event: String, parameters: [String: Any]?) {
        print("📊 Analytics Event: \(event)")
        if let parameters = parameters {
            print("📊 Parameters: \(parameters)")
        }
    }
    
    public func trackError(_ error: Error, context: [String: Any]?) {
        print("❌ Analytics Error: \(error.localizedDescription)")
        if let context = context {
            print("❌ Context: \(context)")
        }
    }
    
    public func trackPerformance(_ metric: String, value: Double, unit: String?) {
        let unitString = unit ?? "ms"
        print("⚡ Performance: \(metric) = \(value) \(unitString)")
    }
}

@available(iOS 18.0, macOS 10.15, *)
public final class ConsoleDIAnalyticsProvider: DIAnalyticsProvider, Sendable {
    public static let shared = ConsoleDIAnalyticsProvider()
    
    private init() {}
    
    public func trackEvent(_ event: String, parameters: [String: Any]?) {
        print("🔍 [DI Analytics] Event: \(event)")
        if let parameters = parameters {
            for (key, value) in parameters {
                print("🔍 [DI Analytics]   \(key): \(value)")
            }
        }
    }
    
    public func trackError(_ error: Error, context: [String: Any]?) {
        print("🚨 [DI Analytics] Error: \(error.localizedDescription)")
        if let context = context {
            for (key, value) in context {
                print("🚨 [DI Analytics]   \(key): \(value)")
            }
        }
    }
    
    public func trackPerformance(_ metric: String, value: Double, unit: String?) {
        let unitString = unit ?? "ms"
        print("📈 [DI Analytics] Performance: \(metric) = \(value) \(unitString)")
    }
}
