# GODareDI - Encrypted Dependency Injection Framework

🔐 **Encrypted Binary XCFramework** for iOS dependency injection with Swift Package Manager support.

## Features

- 🔒 **Encrypted Binary**: Source code is protected and encrypted
- 📱 **iOS Support**: iOS 13.0+ (device and simulator)
- 🏗️ **Dependency Injection**: Advanced DI container with multiple scopes
- 📊 **Visualization**: Built-in dependency graph visualization
- 🚀 **SPM Ready**: Swift Package Manager integration
- 📈 **Analytics**: Built-in analytics support
- ⚡ **Performance**: Optimized for production use

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/MohamedAbdelHafezAbozaid/GoDareDI-Secure.git", from: "2.0.0")
]
```

Or add it directly in Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/MohamedAbdelHafezAbozaid/GoDareDI-Secure.git`
3. Select version `2.0.0` or later

## Quick Start

### 1. Initialize the Container

```swift
import GODareDI

// Initialize the container
let container = SPMInitialization.initialize()

// Configure default modules
SPMInitialization.configureDefaultModules(container: container)
```

### 2. Register Dependencies

```swift
// Register a service as singleton
container.register(NetworkService.self, scope: .singleton) {
    NetworkService()
}

// Register with a tag
container.register(UserService.self, scope: .transient, tag: "api") {
    UserService()
}
```

### 3. Resolve Dependencies

```swift
// Resolve a service
let networkService: NetworkService = container.resolve(NetworkService.self)

// Resolve with tag
let userService: UserService = container.resolve(UserService.self, tag: "api")
```

### 4. Dependency Scopes

```swift
// Available scopes
.singleton    // Single instance for the entire app lifecycle
.transient    // New instance every time
.scoped       // Single instance per scope
.application  // Single instance per application session
.session      // Single instance per user session
.request      // Single instance per request
```

## Advanced Usage

### Dependency Graph Visualization

```swift
import SwiftUI
import GODareDI

struct ContentView: View {
    let container: AdvancedDIContainer
    
    var body: some View {
        VStack {
            // Your app content
            Text("My App")
            
            // Dependency graph visualization
            DependencyGraphView(container: container)
        }
    }
}
```

### Custom Modules

```swift
struct MyModule: DIModule {
    func configure(container: AdvancedDIContainer) {
        container.register(MyService.self, scope: .singleton) {
            MyService()
        }
    }
}

// Register the module
container.register(MyModule.self, scope: .singleton) {
    MyModule()
}
```

### Analytics Integration

```swift
// Register analytics provider
container.register(AnalyticsProvider.self, scope: .singleton) {
    DefaultAnalyticsProvider()
}

// Use analytics
let analytics: AnalyticsProvider = container.resolve(AnalyticsProvider.self)
analytics.track(event: "user_action", properties: ["action": "login"])
```

## Error Handling

```swift
do {
    let service: MyService = container.resolve(MyService.self)
    // Use service
} catch DIError.typeNotFound {
    print("Service not registered")
} catch DIError.resolutionFailed {
    print("Failed to resolve service")
} catch {
    print("Unknown error: \(error)")
}
```

## Requirements

- iOS 13.0+
- Xcode 12.0+
- Swift 5.3+

## Architecture

The framework provides:

- **AdvancedDIContainer**: Main dependency injection container
- **DIModule**: Protocol for modular configuration
- **DependencyScope**: Enumeration of dependency scopes
- **SPMInitialization**: Helper for Swift Package Manager integration
- **DependencyGraphView**: SwiftUI view for dependency visualization
- **AnalyticsProvider**: Protocol for analytics integration

## Security

🔐 **This framework uses encrypted binary artifacts to protect the source code.** The implementation details are not accessible, ensuring your intellectual property remains secure while providing a robust dependency injection solution.

## Migration from v1.x

If you're upgrading from v1.x:

1. **Package Name**: Change from `GoDareDI` to `GODareDI`
2. **Import Statement**: Update your imports
3. **Initialization**: Use `SPMInitialization.initialize()` for new projects
4. **iOS Version**: Minimum iOS version is now 13.0

## Support

For issues and feature requests, please use the GitHub Issues page.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Version**: 2.0.0  
**Last Updated**: September 2024  
**Author**: Mohamed Abdel Hafez Abozaid