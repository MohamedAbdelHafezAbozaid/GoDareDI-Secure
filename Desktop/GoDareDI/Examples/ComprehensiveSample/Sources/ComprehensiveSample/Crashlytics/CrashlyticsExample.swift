//
//  CrashlyticsExample.swift
//  ComprehensiveSample
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation
import GoDareDI

// MARK: - Crashlytics Example
@MainActor
public class CrashlyticsExample {
    
    // MARK: - Properties
    private let container: AdvancedDIContainer
    
    // MARK: - Initialization
    public init(token: String) async throws {
        // Create crashlytics configuration
        let crashlyticsConfig = DICrashlyticsConfig(
            token: token,
            enableCrashlytics: true,
            enableAnalytics: true,
            enablePerformanceTracking: true,
            enableCircularDependencyTracking: true
        )
        
        // Create container with crashlytics (now validates token)
        self.container = try await AdvancedDIContainerImpl(crashlyticsConfig: crashlyticsConfig)
    }
    
    // MARK: - Example Usage
    public func demonstrateCrashlyticsIntegration() async {
        print("🔥 Starting Crashlytics Integration Demo...")
        
        // Register some dependencies
        await registerDependencies()
        
        // Demonstrate normal resolution (will be tracked)
        await demonstrateNormalResolution()
        
        // Demonstrate error tracking
        await demonstrateErrorTracking()
        
        // Demonstrate performance tracking
        await demonstratePerformanceTracking()
        
        // Demonstrate circular dependency tracking
        await demonstrateCircularDependencyTracking()
        
        print("✅ Crashlytics Integration Demo completed!")
    }
    
    // MARK: - Private Methods
    private func registerDependencies() async {
        print("🔧 Registering dependencies...")
        
        // Register a normal service
        await container.register(NetworkService.self, scope: .singleton) { container in
            return NetworkService()
        }
        
        // Register a service that might fail
        await container.register(FailingService.self, scope: .transient) { container in
            return FailingService()
        }
        
        // Register a slow service for performance tracking
        await container.register(SlowService.self, scope: .transient) { container in
            return SlowService()
        }
        
        // Register services that create circular dependencies
        await container.register(ServiceA.self, scope: .transient) { container in
            return ServiceA()
        }
        
        await container.register(ServiceB.self, scope: .transient) { container in
            let serviceA = try await container.resolve(ServiceA.self)
            return ServiceB(serviceA: serviceA)
        }
        
        print("✅ Dependencies registered")
    }
    
    private func demonstrateNormalResolution() async {
        print("🔍 Demonstrating normal resolution tracking...")
        
        do {
            let networkService = try await container.resolve(NetworkService.self)
            print("✅ NetworkService resolved successfully")
        } catch {
            print("❌ Failed to resolve NetworkService: \(error)")
        }
    }
    
    private func demonstrateErrorTracking() async {
        print("🚨 Demonstrating error tracking...")
        
        do {
            let failingService = try await container.resolve(FailingService.self)
            try await failingService.performFailingOperation()
        } catch {
            print("❌ Expected error caught: \(error)")
        }
    }
    
    private func demonstratePerformanceTracking() async {
        print("⏱️ Demonstrating performance tracking...")
        
        do {
            let slowService = try await container.resolve(SlowService.self)
            try await slowService.performSlowOperation()
        } catch {
            print("❌ Failed to perform slow operation: \(error)")
        }
    }
    
    private func demonstrateCircularDependencyTracking() async {
        print("🔄 Demonstrating circular dependency tracking...")
        
        // This will create a circular dependency
        await container.register(ServiceA.self, scope: .transient) { container in
            let serviceB = try await container.resolve(ServiceB.self)
            return ServiceA(serviceB: serviceB)
        }
        
        do {
            let serviceA = try await container.resolve(ServiceA.self)
            print("✅ ServiceA resolved successfully")
        } catch {
            print("❌ Expected circular dependency error: \(error)")
        }
    }
}

// MARK: - Example Services
public class NetworkService: Sendable {
    public init() {
        print("📡 NetworkService initialized")
    }
    
    public func fetchData() async throws -> String {
        // Simulate network call
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        return "Network data"
    }
}

public class FailingService: Sendable {
    public init() {
        print("💥 FailingService initialized")
    }
    
    public func performFailingOperation() async throws {
        throw NSError(domain: "FailingService", code: 1, userInfo: [NSLocalizedDescriptionKey: "This operation always fails"])
    }
}

public class SlowService: Sendable {
    public init() {
        print("🐌 SlowService initialized")
    }
    
    public func performSlowOperation() async throws {
        // Simulate slow operation
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        print("✅ Slow operation completed")
    }
}

public class ServiceA: Sendable {
    private let serviceB: ServiceB?
    
    public init(serviceB: ServiceB? = nil) {
        self.serviceB = serviceB
        print("🔗 ServiceA initialized")
    }
}

public class ServiceB: Sendable {
    private let serviceA: ServiceA?
    
    public init(serviceA: ServiceA? = nil) {
        self.serviceA = serviceA
        print("🔗 ServiceB initialized")
    }
}

// MARK: - Usage Example
/*
// How to use in your app:
do {
    let crashlyticsExample = try await CrashlyticsExample(token: "your-sdk-token-here")
    await crashlyticsExample.demonstrateCrashlyticsIntegration()
} catch DITokenValidationError.invalidToken {
    print("❌ Invalid token. Please check your token and try again.")
} catch DITokenValidationError.invalidTokenFormat {
    print("❌ Invalid token format. Token must be 64 characters long.")
} catch DITokenValidationError.tokenExpired {
    print("❌ Token has expired. Please generate a new token.")
} catch {
    print("❌ Error initializing crashlytics: \(error)")
}

// The crashlytics integration will automatically track:
// 1. All dependency registrations
// 2. All dependency resolutions (success and failure)
// 3. Performance issues (slow resolutions)
// 4. Circular dependencies
// 5. Container errors
// 6. Memory usage and container state

// All this data will be sent to your Firebase project and appear in your dashboard!
*/
