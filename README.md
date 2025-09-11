# GoDareDI

**Professional Dependency Injection Framework for Swift**

A powerful, type-safe dependency injection framework designed for modern Swift applications. GoDareDI provides a clean, intuitive API for managing dependencies with advanced features like circular dependency detection, performance metrics, and comprehensive analytics.

## 🎯 GoDareDI Dashboard

**Monitor, Analyze & Optimize Your Dependencies**

[![GoDareDI Dashboard](https://img.shields.io/badge/GoDareDI-Dashboard-blue?style=for-the-badge&logo=swift)](https://godare.app/)

**🔗 [https://godare.app/](https://godare.app/)**

### What You'll Get:

- 📊 **Real-time Dependency Analysis** - Monitor your app's dependency injection patterns in real-time
- 🎨 **12 Visualization Types** - Mermaid, Graphviz, JSON, Tree, Network, and more
- 📈 **Performance Metrics** - Track complexity, coupling, and circular dependencies
- 🔐 **Token Management** - Secure API tokens for each application
- 📱 **iOS Platform Support** - Native iOS dependency injection analytics

### 🚀 Get Started with Dashboard:

1. **Sign up** at [https://godare.app/](https://godare.app/)
2. **Create your first app** and generate an API token
3. **Enable analytics** in your GoDareDI implementation
4. **Monitor and optimize** your dependency architecture

> **💡 Pro Tip**: The dashboard provides advanced analytics, dependency visualization, and performance insights that help you build better, more maintainable applications.

## ✨ Features

- 🔒 **Type-Safe**: Full Swift type system integration
- 🚀 **High Performance**: Optimized dependency resolution
- 🔄 **Circular Dependency Detection**: Automatic detection and prevention
- 📊 **Analytics & Metrics**: Built-in performance monitoring
- 🎯 **Multiple Scopes**: Singleton, transient, and custom scopes
- 🔧 **Easy Integration**: Simple Swift Package Manager integration
- 📱 **Cross-Platform**: iOS, macOS, tvOS, watchOS support

## 📦 Installation

### Swift Package Manager

Add GoDareDI to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/MohamedAbdelHafezAbozaid/GoDareDI-Secure.git", from: "1.0.28")
]
```

### Xcode Integration

1. Open your Xcode project
2. Go to **File** → **Add Package Dependencies**
3. Enter the repository URL: `https://github.com/MohamedAbdelHafezAbozaid/GoDareDI-Secure.git`
4. Click **Add Package**
5. Select **GoDareDI** and click **Add Package**

## 🚀 Quick Start

### Basic Usage

```swift
import GoDareDI

// Create a container
let container = AdvancedDIContainerImpl()

// Register services
try await container.register(NetworkService.self, scope: .singleton) { container in
    return NetworkService()
}

// Resolve services
let networkService = try await container.resolve(NetworkService.self)
```

### Advanced Configuration with Dashboard Integration

```swift
import GoDareDI

// Create container with custom configuration
let container = try await AdvancedDIContainerImpl(
    config: DIContainerConfig(
        maxCircularDependencyDepth: 3,
        enableCircularDependencyDetection: true,
        enableDependencyTracking: true,
        enablePerformanceMetrics: true,
        enableCaching: true
    )
)

// Enable Dashboard Analytics (Premium Feature)
// Get your token from: https://godare.app/
container.enableAnalytics(token: "your-dashboard-token-here")
container.enableDashboardSync(token: "your-dashboard-token-here")

// Register with different scopes
try await container.register(UserService.self, scope: .singleton) { container in
    return UserService()
}

try await container.register(APIClient.self, scope: .transient) { container in
    return APIClient()
}
```

### Dashboard Integration Examples

#### Freemium Usage (No Token Required)
```swift
import GoDareDI

// Basic usage without dashboard
let container = AdvancedDIContainerImpl()

// Register services
try await container.register(NetworkService.self, scope: .singleton) { container in
    return NetworkService()
}

// Resolve services
let networkService = try await container.resolve(NetworkService.self)
```

#### Premium Usage (With Dashboard Token)
```swift
import GoDareDI

// Premium usage with dashboard analytics
let container = AdvancedDIContainerImpl()

// Enable premium features with your dashboard token
container.enableAnalytics(token: "your-premium-token-here")
container.enableCrashlytics()
container.enableDashboardSync(token: "your-premium-token-here")

// Register complex service hierarchy
try await container.register(NetworkService.self, scope: .singleton) { container in
    return NetworkService()
}

try await container.register(DatabaseService.self, scope: .singleton) { container in
    let networkService = try await container.resolve(NetworkService.self)
    return DatabaseService(networkService: networkService)
}

// All dependencies will be tracked and visualized in your dashboard
let databaseService = try await container.resolve(DatabaseService.self)
```

## 🎯 Usage Examples

### Service Registration

```swift
// Singleton service
try await container.register(DatabaseService.self, scope: .singleton) { container in
    return DatabaseService()
}

// Transient service
try await container.register(HTTPClient.self, scope: .transient) { container in
    return HTTPClient()
}

// Custom scope
try await container.register(CacheService.self, scope: .custom("session")) { container in
    return CacheService()
}
```

### Service Resolution

```swift
// Resolve services
let database = try await container.resolve(DatabaseService.self)
let httpClient = try await container.resolve(HTTPClient.self)

// Resolve with custom scope
let sessionCache = try await container.resolve(CacheService.self, scope: .custom("session"))
```

### Dependency Graph Visualization

```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var container = AdvancedDareDI()
    
    var body: some View {
        NavigationView {
            DependencyGraphView(container: container.container)
                .navigationTitle("Dependencies")
        }
    }
}
```

## 🔧 Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 5.9+
- Xcode 15.0+

## 📚 Documentation

### Core Concepts

- **Container**: Manages all registered dependencies
- **Scope**: Defines the lifetime of a dependency
- **Resolution**: The process of creating and returning dependencies
- **Registration**: The process of defining how to create dependencies

### Scopes

- **`.singleton`**: Single instance shared across the application
- **`.transient`**: New instance created for each resolution
- **`.custom(String)`**: Custom scope for specific use cases

## 🎨 Dashboard Features

### Freemium vs Premium

| Feature | Freemium | Premium |
|---------|----------|---------|
| Basic Dependency Injection | ✅ | ✅ |
| Type-safe Service Resolution | ✅ | ✅ |
| Multiple Scopes | ✅ | ✅ |
| Circular Dependency Detection | ✅ | ✅ |
| Up to 10 Services | ✅ | ❌ |
| Analytics & Usage Tracking | ❌ | ✅ |
| Performance Monitoring | ❌ | ✅ |
| Dashboard Visualization | ❌ | ✅ |
| Dependency Graph Export | ❌ | ✅ |
| Unlimited Services | ❌ | ✅ |
| Priority Support | ❌ | ✅ |

### Dashboard Capabilities

- **📊 Real-time Analytics**: Monitor dependency resolution performance
- **🎨 12 Visualization Types**: Multiple ways to view your dependency graph
- **📈 Performance Metrics**: Track complexity, coupling, and circular dependencies
- **🔐 Secure Token Management**: Enterprise-grade security for your applications
- **📱 Cross-Platform Support**: iOS, Android, Web, and Desktop (coming soon)

## 🆘 Support

- **Dashboard**: [https://godare.app/](https://godare.app/) - Sign up for analytics and support
- **Issues**: [GitHub Issues](https://github.com/MohamedAbdelHafezAbozaid/GoDareDI-Secure/issues)
- **Email**: bota78336@gmail.com
- **Documentation**: See inline code documentation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎉 Acknowledgments

Built with ❤️ for the Swift community. GoDareDI is designed to make dependency injection simple, safe, and powerful for modern Swift applications.

---

## 🚀 Ready to Get Started?

1. **📦 Install GoDareDI** using Swift Package Manager
2. **🎯 Sign up** at [https://godare.app/](https://godare.app/) for advanced analytics
3. **🔧 Integrate** the framework into your project
4. **📊 Monitor** your dependencies with the dashboard
5. **🎨 Visualize** your architecture with 12 different visualization types

**Experience the power of clean dependency management with professional analytics!** 🚀

[![GoDareDI Dashboard](https://img.shields.io/badge/Get_Started-Dashboard-green?style=for-the-badge&logo=swift)](https://godare.app/)