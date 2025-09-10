# GoDareDI

A powerful, type-safe dependency injection framework for Swift with advanced features including dependency graph visualization, performance monitoring, and comprehensive scope management.

## ✨ Features

- **🔒 Type-Safe Registration**: Register dependencies with compile-time type safety
- **🎯 Multiple Scopes**: Singleton, Scoped, Transient, and Lazy scopes with lifetime management
- **⚡ Async Support**: Full async/await support for modern Swift applications
- **📊 Dependency Graph Visualization**: Generate Mermaid diagrams and interactive visualizations
- **📈 Performance Monitoring**: Track resolution times, cache hit rates, and memory usage
- **🔄 Circular Dependency Detection**: Automatic detection and prevention of circular dependencies
- **🎨 SwiftUI Integration**: Built-in SwiftUI views for dependency visualization
- **🌐 Cross-Platform**: Works on iOS, macOS, watchOS, and tvOS
- **🏗️ Modular Architecture**: Support for DI modules and container builders
- **🚀 Smart Preloading**: Intelligent dependency preloading strategies

## 📦 Installation

Add GoDareDI to your Swift Package Manager dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/GoDareDI.git", from: "1.0.0")
]
```

## 🚀 Quick Start

### Basic Usage

```swift
import GoDareDI

// 1. Create a container
let container = AdvancedDIContainerImpl()

// 2. Register your dependencies
await container.register(MyService.self, scope: .singleton) { container in
    return MyService()
}

await container.register(MyRepository.self, scope: .transient) { container in
    let service = try await container.resolve(MyService.self)
    return MyRepository(service: service)
}

// 3. Resolve dependencies
let repository = try await container.resolve(MyRepository.self)

// 4. Use in your app
let result = await repository.fetchData()
```

### Using Container Builder

```swift
let builder = await ContainerBuilder()
let container = try await builder
    .registerService(NetworkService.self) { _ in NetworkService() }
    .registerRepository(UserRepository.self) { container in
        let networkService = try await container.resolve(NetworkService.self)
        return UserRepository(networkService: networkService)
    }
    .registerUseCase(GetUserUseCase.self) { container in
        let repository = try await container.resolve(UserRepository.self)
        return GetUserUseCase(repository: repository)
    }
    .build()
```

### Using DI Modules

```swift
// Define a module
struct NetworkModule: DIModule {
    func configure(container: AdvancedDIContainer) async throws {
        await container.register(NetworkService.self, scope: .singleton) { _ in
            NetworkService()
        }
    }
}

// Use with container factory
let container = try await ContainerFactory.createWithModules(
    modules: [NetworkModule(), RepositoryModule(), UseCaseModule()]
)
```

## 🎯 Advanced Features

### Dependency Graph Visualization

```swift
// Generate Mermaid diagram
let visualizer = DependencyVisualizer(container: container)
let mermaidDiagram = await visualizer.visualizeAsync(type: .mermaid)

// Use in SwiftUI
SimpleDependencyGraphView(container: container)

// Multiple visualization types
let graphvizDiagram = await visualizer.visualizeAsync(type: .graphviz)
let jsonData = await visualizer.visualizeAsync(type: .json)
```

### Performance Monitoring

```swift
// Get comprehensive performance metrics
let metrics = await container.getPerformanceMetrics()
print("Cache hit rate: \(metrics.cacheHitRate)%")
print("Average resolution time: \(metrics.averageResolutionTime)ms")
print("Memory usage: \(metrics.memoryUsage)MB")
print("Total resolutions: \(metrics.totalResolutions)")
```

### Smart Preloading

```swift
// Preload all dependencies
try await container.preloadAllGeneric()

// Smart preloading (categorizes and preloads in dependency order)
try await container.preloadSmart()

// Preload only ViewModels and their dependencies
try await container.preloadViewModelsOnly()
```

### Scope Management

```swift
// Create and manage scopes
await container.createScope("user-session")
await container.setCurrentScope("user-session")

// Register scoped dependencies
await container.register(UserSession.self, scope: .scoped) { container in
    return UserSession()
}

// Clean up when done
await container.disposeScope("user-session")
```

### Configuration Options

```swift
let config = DIContainerConfig(
    maxCircularDependencyDepth: 3,
    enableCircularDependencyDetection: true,
    enableDependencyTracking: true,
    enablePerformanceMetrics: true,
    enableCaching: true
)

let container = AdvancedDIContainerImpl(config: config)
```

## 📱 Sample Projects

### Basic Sample
Check out the `Examples/SampleApp` for a simple demonstration of GoDareDI features.

### Comprehensive Sample
The `Examples/ComprehensiveSample` showcases:
- Multi-layered architecture (Services → Repositories → Use Cases → ViewModels)
- Caching strategies
- Network service simulation
- Performance monitoring
- Dependency graph visualization
- SwiftUI integration

## 🏗️ Architecture Patterns

### Clean Architecture with GoDareDI

```swift
// Infrastructure Layer (Singletons)
await container.register(NetworkService.self, scope: .singleton) { _ in
    NetworkService()
}

// Data Layer (Scoped)
await container.register(UserRepository.self, scope: .scoped) { container in
    let networkService = try await container.resolve(NetworkService.self)
    return UserRepository(networkService: networkService)
}

// Domain Layer (Transient)
await container.register(GetUserUseCase.self, scope: .transient) { container in
    let repository = try await container.resolve(UserRepository.self)
    return GetUserUseCase(repository: repository)
}

// Presentation Layer (Lazy)
await container.register(UserViewModel.self, scope: .lazy) { container in
    let useCase = try await container.resolve(GetUserUseCase.self)
    return UserViewModel(useCase: useCase)
}
```

## 🔧 API Reference

### Core Types

- `AdvancedDIContainer`: Main protocol for dependency injection
- `AdvancedDIContainerImpl`: Default implementation
- `DIContainerConfig`: Configuration options
- `DependencyScope`: Registration scopes (singleton, scoped, transient, lazy)
- `DependencyLifetime`: Lifetime management (application, session, request, custom)

### Visualization

- `DependencyVisualizer`: Generate dependency graphs
- `SimpleDependencyGraphView`: SwiftUI view for visualization
- `VisualizationType`: Supported visualization formats

### Performance

- `PerformanceMetrics`: Performance monitoring data
- `DependencyGraph`: Dependency graph structure
- `GraphAnalysis`: Graph analysis results

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests for any improvements.

## 📄 License

MIT License - see LICENSE file for details.

## 🙏 Acknowledgments

- Inspired by modern DI frameworks like Dagger and Koin
- Built with Swift's powerful type system and async/await
- Designed for clean architecture and testability