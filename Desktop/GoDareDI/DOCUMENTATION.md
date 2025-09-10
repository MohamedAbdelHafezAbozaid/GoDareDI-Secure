# GoDareDI Documentation

## Overview

GoDareDI is a powerful, type-safe Dependency Injection framework for Swift applications. It provides a clean, modern API for managing dependencies with full support for Swift's async/await concurrency model.

## Architecture

### Core Components

1. **AdvancedDIContainer** - The main container interface
2. **AdvancedDIContainerImpl** - The concrete implementation
3. **DependencyScope** - Defines how instances are managed
4. **DependencyLifetime** - Defines how long instances live
5. **DependencyGraph** - Represents the dependency relationships

### Dependency Scopes

#### Singleton
- **Behavior**: One instance per container
- **Use Case**: Shared services, configuration, caches
- **Example**: Network services, database connections

```swift
container.register(NetworkService.self, scope: .singleton) { container in
    return NetworkService()
}
```

#### Transient
- **Behavior**: New instance every time
- **Use Case**: Stateless services, data processors
- **Example**: Validators, formatters, calculators

```swift
container.register(DataValidator.self, scope: .transient) { container in
    return DataValidator()
}
```

#### Scoped
- **Behavior**: One instance per scope
- **Use Case**: Request-specific services, user sessions
- **Example**: User contexts, request handlers

```swift
container.register(UserContext.self, scope: .scoped, lifetime: .session) { container in
    return UserContext()
}
```

#### Lazy
- **Behavior**: Created only when first accessed
- **Use Case**: Expensive resources, optional services
- **Example**: Heavy computations, external integrations

```swift
container.register(ExpensiveService.self, scope: .lazy) { container in
    return ExpensiveService()
}
```

### Lifetime Management

#### Application
- **Duration**: Entire app lifecycle
- **Use Case**: Core services, configuration

#### Session
- **Duration**: User session
- **Use Case**: User-specific data, authentication

#### Request
- **Duration**: Single request/operation
- **Use Case**: Request handlers, temporary data

#### Custom
- **Duration**: Defined by developer
- **Use Case**: Specialized scenarios

## API Reference

### Container Interface

```swift
@MainActor
public protocol AdvancedDIContainer: Sendable {
    // Registration
    func register<T: Sendable>(
        _ type: T.Type,
        scope: DependencyScope,
        lifetime: DependencyLifetime,
        factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T
    )
    
    // Resolution
    func resolve<T: Sendable>() async throws -> T
    func resolve<T: Sendable>(_ type: T.Type) async throws -> T
    
    // Analysis
    func getDependencyGraph() async -> DependencyGraph
    func analyzeDependencyGraph() async -> GraphAnalysis
    func validateDependencies() async throws
    
    // Performance
    func preloadDependencies() async
    func getPerformanceMetrics() async -> PerformanceMetrics
}
```

### Dependency Types

```swift
public enum DependencyScope: String, CaseIterable, Sendable {
    case singleton
    case transient
    case scoped
    case lazy
}

public enum DependencyLifetime: String, CaseIterable, Sendable {
    case application
    case session
    case request
    case custom
}
```

### Error Handling

```swift
public enum DependencyResolutionError: Error, Sendable {
    case notRegistered(String)
    case circularDependency(String)
    case resolutionFailed(String)
    case scopeNotFound(String)
    case lifetimeExpired(String)
}
```

## Best Practices

### 1. Organize by Layers

```swift
class DependencyRegistration {
    static func registerDependencies(in container: AdvancedDIContainer) async throws {
        // Infrastructure Layer
        try await registerInfrastructureServices(in: container)
        
        // Repository Layer
        try await registerRepositories(in: container)
        
        // Use Case Layer
        try await registerUseCases(in: container)
        
        // Presentation Layer
        try await registerViewModels(in: container)
    }
}
```

### 2. Use Protocols for Testability

```swift
// Define protocol
protocol UserRepositoryProtocol {
    func getUser(id: String) async throws -> User
}

// Production implementation
container.register(UserRepository.self, scope: .transient) { container in
    let networkService = try await container.resolve(NetworkService.self)
    return UserRepository(networkService: networkService)
}

// Test implementation
container.register(MockUserRepository.self, scope: .transient) { container in
    return MockUserRepository()
}
```

### 3. Handle Errors Gracefully

```swift
do {
    let service = try await container.resolve(MyService.self)
    // Use service
} catch DependencyResolutionError.notRegistered(let type) {
    print("Service \(type) is not registered")
} catch DependencyResolutionError.circularDependency(let chain) {
    print("Circular dependency detected: \(chain)")
} catch {
    print("Unexpected error: \(error)")
}
```

### 4. Use Appropriate Scopes

```swift
// Singleton for shared resources
container.register(DatabaseService.self, scope: .singleton) { ... }

// Transient for stateless services
container.register(DataValidator.self, scope: .transient) { ... }

// Scoped for request-specific data
container.register(UserContext.self, scope: .scoped, lifetime: .request) { ... }

// Lazy for expensive resources
container.register(MLModel.self, scope: .lazy) { ... }
```

## Performance Considerations

### 1. Preload Dependencies

```swift
// Preload all dependencies at app startup
try await container.preloadDependencies()
```

### 2. Use Appropriate Scopes

- **Singleton**: For services that are expensive to create
- **Transient**: For lightweight, stateless services
- **Scoped**: For services that need to be shared within a context
- **Lazy**: For services that might not be used

### 3. Monitor Performance

```swift
let metrics = await container.getPerformanceMetrics()
print("Average resolution time: \(metrics.averageResolutionTime)ms")
print("Total resolutions: \(metrics.totalResolutions)")
```

## Testing

### 1. Unit Testing

```swift
func testUserService() async throws {
    let container = AdvancedDIContainerImpl()
    
    // Register test dependencies
    container.register(MockUserRepository.self, scope: .transient) { container in
        return MockUserRepository()
    }
    
    // Test the service
    let service = try await container.resolve(UserService.self)
    let user = try await service.getUser(id: "123")
    
    XCTAssertEqual(user.id, "123")
}
```

### 2. Integration Testing

```swift
func testDependencyGraph() async throws {
    let container = AdvancedDIContainerImpl()
    
    // Register all dependencies
    try await DependencyRegistration.registerDependencies(in: container)
    
    // Validate the dependency graph
    try await container.validateDependencies()
    
    // Check for circular dependencies
    let analysis = await container.analyzeDependencyGraph()
    XCTAssertEqual(analysis.circularDependencyChains.count, 0)
}
```

## Migration Guide

### From Manual DI

```swift
// Before: Manual dependency injection
class UserService {
    private let repository: UserRepository
    private let validator: UserValidator
    
    init(repository: UserRepository, validator: UserValidator) {
        self.repository = repository
        self.validator = validator
    }
}

// After: Using GoDareDI
container.register(UserService.self, scope: .transient) { container in
    let repository = try await container.resolve(UserRepository.self)
    let validator = try await container.resolve(UserValidator.self)
    return UserService(repository: repository, validator: validator)
}
```

### From Other DI Frameworks

GoDareDI provides a modern, Swift-native approach to dependency injection. The main differences:

1. **Async/Await Support**: Full support for Swift concurrency
2. **Type Safety**: Compile-time dependency resolution
3. **Performance**: Optimized for Swift's runtime
4. **Analysis**: Built-in dependency analysis and validation

## Troubleshooting

### Common Issues

#### 1. Service Not Registered

```swift
// Error: DependencyResolutionError.notRegistered
// Solution: Register the service before resolving
container.register(MyService.self, scope: .singleton) { container in
    return MyService()
}
```

#### 2. Circular Dependencies

```swift
// Error: DependencyResolutionError.circularDependency
// Solution: Use lazy resolution or restructure dependencies
container.register(ServiceA.self, scope: .lazy) { container in
    return ServiceA()
}
```

#### 3. Scope Not Found

```swift
// Error: DependencyResolutionError.scopeNotFound
// Solution: Create the scope before using scoped services
await container.createScope("user-session")
```

### Debug Tips

1. **Enable Logging**: Use debug prints to track dependency resolution
2. **Analyze Graph**: Use `getDependencyGraph()` to visualize dependencies
3. **Validate Dependencies**: Use `validateDependencies()` to check for issues
4. **Monitor Performance**: Use `getPerformanceMetrics()` to identify bottlenecks

## Contributing

We welcome contributions! Please see our contributing guidelines for details.

## License

MIT License - see LICENSE file for details.
