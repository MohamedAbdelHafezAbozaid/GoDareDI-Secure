# GoDareDI - Binary Framework Distribution

## 🔒 **BINARY FRAMEWORK - SOURCE CODE PROTECTED**

This is a **compiled binary framework** distribution. The source code is **protected and encrypted** in the compiled libraries.

### What You Get:
- ✅ **Full Functionality**: All features work exactly as documented
- ✅ **Type Safety**: Complete Swift type system integration
- ✅ **Performance**: Optimized compiled code
- ✅ **Security**: Source code is protected and cannot be reverse-engineered

### What's Protected:
- ❌ **Source Code**: Implementation details are compiled and hidden
- ❌ **Internal Architecture**: Framework's internal structure is encrypted
- ❌ **Proprietary Logic**: Business logic and advanced features are protected
- ❌ **Performance Optimizations**: Compiled optimizations are hidden

## 📦 Installation

### Swift Package Manager

Add GoDareDI to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/MohamedAbdelHafezAbozaid/GoDareDI-Secure.git", from: "1.0.12")
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
let container = try await AdvancedDIContainerImpl(
    config: DIContainerConfig(),
    token: "your-premium-token"
)

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

This project is licensed under the MIT License - see the LICENSE file for details.

## 🛡️ Security & Privacy

- **Source Code Protection**: Implementation details are compiled and protected
- **License Compliance**: Enforces proper usage and licensing
- **Quality Control**: Ensures consistent, tested implementations
- **Update Control**: Manages framework updates and security patches

## 📞 Support

- GitHub Issues
- Email: bota78336@gmail.com
- Web Dashboard

## 🎉 Acknowledgments

- Built with ❤️ for the Swift community
- Inspired by modern DI patterns
- Powered by Swift's type system

## 🔒 Security Notice

This framework is distributed as compiled binary libraries to protect intellectual property. Source code is not available and cannot be reverse-engineered.