# GoDareDI - Advanced Dependency Injection Framework

A powerful, type-safe dependency injection framework for Swift with advanced features like analytics, visualization, and monitoring.

## 🔒 **SECURE BINARY DISTRIBUTION**

**Important**: This framework is distributed as a **compiled binary** to protect intellectual property while providing full functionality to developers.

### What This Means for You

- ✅ **Full Functionality**: All features work exactly as documented
- ✅ **Type Safety**: Complete Swift type system integration  
- ✅ **Performance**: Optimized compiled code
- ✅ **Security**: Source code is protected and cannot be reverse-engineered
- ✅ **Updates**: Easy updates through Swift Package Manager

### What You Get

- **Complete API**: Full access to all framework features
- **Documentation**: Comprehensive guides and examples
- **Support**: Developer support and community
- **Updates**: Regular updates and security patches

### What's Protected

- **Implementation Details**: Core algorithms and optimizations
- **Internal Architecture**: Framework's internal structure
- **Proprietary Logic**: Business logic and advanced features
- **Performance Optimizations**: Compiled optimizations

## 🚀 Features

- **Type-Safe DI**: Compile-time dependency resolution
- **Multiple Scopes**: Singleton, Transient, Scoped lifetimes
- **Analytics Integration**: Built-in usage tracking and analytics
- **Visualization**: Dependency graph visualization
- **Performance Monitoring**: Built-in performance metrics
- **Crashlytics Integration**: Automatic crash reporting
- **Dashboard Sync**: Real-time dashboard synchronization

## 📦 Installation

### Swift Package Manager

Add GoDareDI to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/MohamedAbdelHafezAbozaid/GoDareDI-Secure.git", from: "1.0.0")
]
```

### Xcode Integration

1. Open your Xcode project
2. Go to **File** → **Add Package Dependencies**
3. Enter the repository URL: `https://github.com/MohamedAbdelHafezAbozaid/GoDareDI-Secure.git`
4. Click **Add Package**
5. Select **GoDareDI** and click **Add Package**

## 🎯 Quick Start

### Freemium Usage (No Token Required)

```swift
import GoDareDI

// Create container
let container = AdvancedDIContainerImpl()

// Register services
try await container.register(NetworkService.self, scope: .singleton) { container in
    return NetworkService()
}

// Resolve services
let networkService = try await container.resolve(NetworkService.self)
```

### Premium Usage (With Token)

```swift
import GoDareDI

// Initialize with analytics
let container = AdvancedDIContainerImpl()
container.enableAnalytics(token: "your-premium-token")

// Enable premium features
container.enableCrashlytics()
container.enableDashboardSync(token: "your-premium-token")

// Register and use services
try await container.register(UserService.self, scope: .singleton) { container in
    return UserService()
}

let userService = try await container.resolve(UserService.self)
```

## 🔧 Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 5.9+
- Xcode 15.0+

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🛡️ Security & Privacy

- **Source Code Protection**: Implementation details are compiled and protected
- **License Compliance**: Enforces proper usage and licensing
- **Quality Control**: Ensures consistent, tested implementations
- **Update Control**: Manages framework updates and security patches

## 📞 Support

- [GitHub Issues](https://github.com/MohamedAbdelHafezAbozaid/GoDareDI-Secure/issues)
- Email: bota78336@gmail.com
- [Web Dashboard](https://godaredi-60569.web.app)

## 🎉 Acknowledgments

- Built with ❤️ for the Swift community
- Inspired by modern DI patterns
- Powered by Swift's type system
