//
//  GoDareDI.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation
import SwiftUI

// MARK: - GoDareDI Package
// This is the main module file that exports all the public APIs

// Re-export all public types and protocols
// Note: Scoped imports not supported in module interfaces

// MARK: - Core DI Types
// All dependency injection types are available through this module

// MARK: - Container
// AdvancedDIContainer and AdvancedDIContainerImpl

// MARK: - Types
// DependencyTypes, GraphTypes, ErrorTypes

// MARK: - Extensions
// DependencyGraph+Extensions, GraphAnalysis+Extensions

// MARK: - Visualizer
// DependencyVisualizer, VisualizationTypes, DiagramGenerators, DependencyGraphView

// MARK: - Configuration
// DIContainerConfig

// MARK: - Analytics & Monitoring
// DIAnalyticsProvider, DIDashboardSync, DICrashlyticsIntegration, DITokenValidation

// MARK: - Dashboard Sync
// DIDashboardSyncProvider, DependencyInfo, DashboardData, DefaultDashboardSyncProvider

// MARK: - Security & License
// GoDareDILicense, GoDareDILicenseError, GoDareDISecureInit

// MARK: - Container Builder
// ContainerBuilder, ContainerFactory, DIModule

// MARK: - Usage Example
/*
 
 // 1. Set your GoDareDI token (REQUIRED)
 GoDareDILicense.setToken("your-64-character-hex-token-here")
 
 // 2. Initialize GoDareDI with secure token validation
 do {
     let container = try await GoDareDISecureInit.initialize()
     
     // 3. Register your dependencies (automatically tracked)
     await container.register(MyService.self, scope: .singleton) { container in
         return MyService()
     }
     
     await container.register(MyRepository.self, scope: .transient) { container in
         let service = try await container.resolve(MyService.self)
         return MyRepository(service: service)
     }
     
     // 4. Resolve dependencies (automatically tracked)
     let repository = try await container.resolve(MyRepository.self)
     
     // 5. Use in your app
     let result = await repository.fetchData()
     
     // 6. Alternative: Use ContainerBuilder for complex setups
     let container2 = try await ContainerFactory.create { builder in
         await builder
             .registerService(MyService.self) { _ in MyService() }
             .registerRepository(MyRepository.self) { container in
                 let service = try await container.resolve(MyService.self)
                 return MyRepository(service: service)
             }
     }
     
     // 7. Use DIModule for organized registration
     struct MyAppModule: DIModule {
         func configure(container: AdvancedDIContainer) async throws {
             await container.register(MyService.self, scope: .singleton) { _ in
                 return MyService()
             }
         }
     }
     
     let container3 = try await ContainerFactory.createWithModules(
         modules: [MyAppModule()]
     )
     
     // 8. Synchronous resolution for cached instances
     let cachedService = try container.resolveSync(MyService.self)
     
 } catch {
     print("Failed to initialize GoDareDI: \(error)")
 }
     
    // 6. Visualize dependencies (SwiftUI) - requires valid token and iOS 17.0+
    DependencyGraphView(container: container)
    
    // 7. Generate Mermaid diagram - requires valid token
    // let visualizer = DependencyVisualizer(container: container)
    // let mermaidDiagram = try await visualizer.visualizeAsync(type: .mermaid)
     
     // 8. Analytics and monitoring (requires valid token)
    // container.configureAnalytics()
    // let dashboardData = try await DefaultDashboardSyncProvider.shared.getDashboardData()
     
 } catch GoDareDILicenseError.noLicenseKey {
     print("❌ No token found. Please set your GoDareDI token. Get your token from https://godare.app/")
 } catch GoDareDILicenseError.invalidLicense {
     print("❌ Invalid token. Please check your token or generate a new one from https://godare.app/")
 } catch GoDareDILicenseError.licenseExpired {
     print("❌ Token has expired. Please generate a new token from https://godare.app/")
 } catch {
     print("❌ Error initializing GoDareDI: \(error)")
 }

 // TOKEN-REQUIRED MODEL:
 // - Token is MANDATORY for all functionality
 // - Get your token from https://godare.app/
 // - All features require a valid token
 // - Token validation happens on every initialization
 // - All analytics and monitoring data is sent to your dashboard
 */