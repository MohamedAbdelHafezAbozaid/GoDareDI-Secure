# GoDareDI

**Professional Dependency Injection Framework for Swift**

A powerful, type-safe dependency injection framework designed for modern Swift applications. GoDareDI provides a clean, intuitive API for managing dependencies with advanced features like circular dependency detection, performance metrics, and comprehensive analytics.

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
    .package(url: "https://github.com/MohamedAbdelHafezAbozaid/GoDareDI-Secure.git", from: "1.0.15")
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

### Advanced Configuration

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

// Register with different scopes
try await container.register(UserService.self, scope: .singleton) { container in
    return UserService()
}

try await container.register(APIClient.self, scope: .transient) { container in
    return APIClient()
}
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

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/MohamedAbdelHafezAbozaid/GoDareDI-Secure/issues)
- **Email**: bota78336@gmail.com
- **Documentation**: See inline code documentation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎉 Acknowledgments

Built with ❤️ for the Swift community. GoDareDI is designed to make dependency injection simple, safe, and powerful for modern Swift applications.

---

**Ready to get started?** Add GoDareDI to your project and experience the power of clean dependency management! 🚀