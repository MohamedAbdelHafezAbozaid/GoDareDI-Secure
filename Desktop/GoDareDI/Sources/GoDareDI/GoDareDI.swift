//
//  GoDareDI.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - GoDareDI Package
// This is the main module file that exports all the public APIs

// Re-export all public types and protocols
@_exported import struct Foundation.UUID

// MARK: - Core DI Types
// All dependency injection types are available through this module

// MARK: - Container
// AdvancedDIContainer and AdvancedDIContainerImpl

// MARK: - Types
// DependencyTypes, GraphTypes, ErrorTypes

// MARK: - Extensions
// DependencyGraph+Extensions, GraphAnalysis+Extensions

// MARK: - Visualizer
// DependencyVisualizer, VisualizationTypes, DiagramGenerators, SimpleDependencyGraphView

// MARK: - Configuration
// DIContainerConfig

// MARK: - Analytics & Monitoring
// DIAnalyticsProvider, DICrashlyticsIntegration, DICrashlyticsConfig

// MARK: - Dashboard Sync
// DIDashboardSyncProvider, DependencyInfo, DashboardData, DefaultDashboardSyncProvider

// MARK: - Usage Example
/*
 
 // 1. Create a container (Freemium Mode - No Token Required)
 let container = AdvancedDIContainerImpl(
     config: DIContainerConfig(
         maxCircularDependencyDepth: 3,
         enableCircularDependencyDetection: true,
         enableDependencyTracking: true,
         enablePerformanceMetrics: true,
         enableCaching: true
     ),
     enableFreemium: true // This allows the SDK to work without a token
 )

 // OR create a container with token for Premium features
 do {
     let premiumContainer = try await AdvancedDIContainerImpl(
         config: DIContainerConfig(
             maxCircularDependencyDepth: 3,
             enableCircularDependencyDetection: true,
             enableDependencyTracking: true,
             enablePerformanceMetrics: true,
             enableCaching: true
         ),
         token: "your-sdk-token-here"
     )
     
     // 2. Register your dependencies (automatically tracked)
     await container.register(MyService.self, scope: .singleton) { container in
         return MyService()
     }
     
     await container.register(MyRepository.self, scope: .transient) { container in
         let service = try await container.resolve(MyService.self)
         return MyRepository(service: service)
     }
     
     // 3. Resolve dependencies (automatically tracked)
     let repository = try await container.resolve(MyRepository.self)
     
     // 4. Use in your app
     let result = await repository.fetchData()
     
 // 5. Visualize dependencies (SwiftUI) - automatically detects token from container
 SimpleDependencyGraphView(container: container)
 
 // 6. Generate Mermaid diagram - automatically detects token from container
 let visualizer = DependencyVisualizer(container: container)
 let mermaidDiagram = try await visualizer.visualizeAsync(type: .mermaid)
     
     // 7. All analytics and monitoring data is automatically sent to your dashboard!
     
 } catch DITokenValidationError.invalidToken {
     print("❌ Invalid token. Please check your token and try again.")
 } catch DITokenValidationError.invalidTokenFormat {
     print("❌ Invalid token format. Token must be 64 characters long.")
 } catch DITokenValidationError.tokenExpired {
     print("❌ Token has expired. Please generate a new token.")
 } catch {
     print("❌ Error initializing container: \(error)")
 }

 // FREEMIUM MODEL:
 // - Basic DI functionality works without a token
 // - Advanced features (visualization, dashboard sync) require a token
 // - Users can upgrade to premium by entering a token
 // - The DependencyGraphView shows a subscription prompt when no token is present
 // - All backend services are abstracted and hidden from users
 */
