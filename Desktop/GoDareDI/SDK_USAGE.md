# GoDareDI SDK Usage Guide

## 🚀 Quick Start

The sample apps have been disabled to prevent interference with your main app. Here's how to use the GoDareDI SDK in your own app:

### 1. Basic Usage (Without Token)

```swift
import GoDareDI

// Create container with basic configuration
let container = try await AdvancedDIContainerImpl(
    config: DIContainerConfig(
        maxCircularDependencyDepth: 3,
        enableCircularDependencyDetection: true,
        enableDependencyTracking: true,
        enablePerformanceMetrics: true,
        enableCaching: true
    )
)

// Register your dependencies
container.register(MyService.self) { _ in
    MyService()
}

// Resolve dependencies
let myService = try container.resolve(MyService.self)
```

### 2. Advanced Usage (With Token for Analytics & Dashboard)

```swift
import GoDareDI

// Create container with token for analytics and dashboard features
let container = try await AdvancedDIContainerImpl(
    config: DIContainerConfig(
        maxCircularDependencyDepth: 3,
        enableCircularDependencyDetection: true,
        enableDependencyTracking: true,
        enablePerformanceMetrics: true,
        enableCaching: true
    ),
    token: "YOUR_SDK_TOKEN_HERE" // Get this from your dashboard
)

// Register your dependencies
container.register(MyService.self) { _ in
    MyService()
}

// Resolve dependencies
let myService = try container.resolve(MyService.self)
```

### 3. Using Dependency Visualization

```swift
import SwiftUI
import GoDareDI

struct MyApp: App {
    @State private var container: AdvancedDIContainer?
    
    var body: some Scene {
        WindowGroup {
            if let container = container {
                // Your main app content
                ContentView()
                
                // Add dependency visualization (optional)
                SimpleDependencyGraphView(container: container)
                    .frame(height: 300)
            } else {
                ProgressView("Initializing...")
                    .task {
                        await initializeContainer()
                    }
            }
        }
    }
    
    private func initializeContainer() async {
        do {
            container = try await AdvancedDIContainerImpl(
                config: DIContainerConfig(
                    maxCircularDependencyDepth: 3,
                    enableCircularDependencyDetection: true,
                    enableDependencyTracking: true,
                    enablePerformanceMetrics: true,
                    enableCaching: true
                ),
                token: "YOUR_SDK_TOKEN_HERE" // Optional
            )
        } catch {
            print("Failed to initialize container: \(error)")
        }
    }
}
```

## 🔑 Getting Your SDK Token

1. Visit your [GoDareDI Dashboard](https://godaredi-60569.web.app)
2. Register/Login to your account
3. Create a new application
4. Generate a token for your app
5. Use the token in your SDK initialization

## 📊 Features Available

### With Token:
- ✅ Analytics tracking
- ✅ Performance monitoring
- ✅ Error reporting
- ✅ Dashboard visualization
- ✅ "Update Dashboard" button
- ✅ Dependency graph export

### Without Token:
- ✅ Basic dependency injection
- ✅ Circular dependency detection
- ✅ Performance metrics
- ✅ Local visualization

## 🚫 Sample Apps Disabled

The sample apps (`ComprehensiveSampleApp` and `SampleApp`) have been disabled by removing their `@main` attributes to prevent them from interfering with your main app.

## 📝 Notes

- The SDK will work perfectly without a token for basic functionality
- Token is only required for advanced features like analytics and dashboard sync
- All visualization features work locally regardless of token status
- The "Update Dashboard" button only appears when a valid token is provided

## 🆘 Need Help?

- Check the [Documentation](DOCUMENTATION.md)
- Visit the [Dashboard](https://godaredi-60569.web.app)
- Review the [Crashlytics Integration Guide](CRASHLYTICS_INTEGRATION.md)
