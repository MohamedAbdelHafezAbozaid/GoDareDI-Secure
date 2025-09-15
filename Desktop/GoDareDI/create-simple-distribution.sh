#!/bin/bash

# GoDareDI Simple Distribution Creator
# Creates a distribution-ready package for developers

set -e

echo "🚀 Creating GoDareDI Distribution Package"
echo "=========================================="

# Configuration
DISTRIBUTION_DIR="GoDareDI-Distribution"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "$DISTRIBUTION_DIR"
mkdir -p "$DISTRIBUTION_DIR"

# Copy source files
echo "📦 Copying source files..."
cp -r Sources "$DISTRIBUTION_DIR/"
cp -r Tests "$DISTRIBUTION_DIR/"
cp Package.swift "$DISTRIBUTION_DIR/"

# Create developer-friendly README
cat > "$DISTRIBUTION_DIR/README.md" << 'EOF'
# GoDareDI - Advanced Dependency Injection Framework

A powerful, type-safe dependency injection framework for Swift with advanced features like analytics, visualization, and monitoring.

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
    .package(url: "https://github.com/MohamedAbdelHafezAbozaid/GoDareDI.git", from: "1.0.0")
]
```

### Xcode Integration

1. Open your Xcode project
2. Go to **File** → **Add Package Dependencies**
3. Enter the repository URL: `https://github.com/MohamedAbdelHafezAbozaid/GoDareDI.git`
4. Click **Add Package**
5. Select **GoDareDI** and click **Add Package**

## 🎯 Quick Start

### Basic Usage

```swift
import GoDareDI

// Create a container
let container = AdvancedDIContainerImpl()

// Register a service
try await container.register(NetworkService.self, scope: .singleton) { container in
    return NetworkService()
}

// Resolve the service
let networkService = try await container.resolve(NetworkService.self)
```

### Advanced Usage with Analytics

```swift
import GoDareDI

// Initialize with analytics
let container = AdvancedDIContainerImpl()
container.enableAnalytics(token: "your-token")

// Register services
try await container.register(UserService.self, scope: .singleton) { container in
    return UserService()
}

// Use the container
let userService = try await container.resolve(UserService.self)
```

## 📚 Documentation

- [Getting Started Guide](docs/getting-started.md)
- [API Reference](docs/api-reference.md)
- [Advanced Features](docs/advanced-features.md)
- [Analytics Integration](docs/analytics.md)
- [Visualization Guide](docs/visualization.md)

## 🔧 Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 5.9+
- Xcode 15.0+

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details.

## 📞 Support

- [GitHub Issues](https://github.com/MohamedAbdelHafezAbozaid/GoDareDI/issues)
- [Documentation](https://github.com/MohamedAbdelHafezAbozaid/GoDareDI/wiki)
- Email: bota78336@gmail.com

## 🎉 Acknowledgments

- Built with ❤️ for the Swift community
- Inspired by modern DI patterns
- Powered by Swift's type system
EOF

# Create installation guide
cat > "$DISTRIBUTION_DIR/INSTALLATION.md" << 'EOF'
# GoDareDI Installation Guide

## 📦 Swift Package Manager (Recommended)

### 1. Add to Xcode Project

1. Open your Xcode project
2. Go to **File** → **Add Package Dependencies**
3. Enter the repository URL: `https://github.com/MohamedAbdelHafezAbozaid/GoDareDI.git`
4. Click **Add Package**
5. Select **GoDareDI** and click **Add Package**

### 2. Add to Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/MohamedAbdelHafezAbozaid/GoDareDI.git", from: "1.0.0")
]
```

## 🎯 Basic Setup

### 1. Import the Framework

```swift
import GoDareDI
```

### 2. Create a Container

```swift
let container = AdvancedDIContainerImpl()
```

### 3. Register Services

```swift
// Register a singleton service
try await container.register(NetworkService.self, scope: .singleton) { container in
    return NetworkService()
}

// Register a transient service
try await container.register(DataProcessor.self, scope: .transient) { container in
    return DataProcessor()
}
```

### 4. Resolve Services

```swift
// Resolve services
let networkService = try await container.resolve(NetworkService.self)
let dataProcessor = try await container.resolve(DataProcessor.self)
```

## 🔧 Advanced Setup

### Enable Analytics

```swift
// Enable analytics with your token
container.enableAnalytics(token: "your-analytics-token")
```

### Enable Crashlytics

```swift
// Enable crashlytics integration
container.enableCrashlytics()
```

### Enable Dashboard Sync

```swift
// Enable dashboard synchronization
container.enableDashboardSync(token: "your-dashboard-token")
```

## 📱 Platform-Specific Setup

### iOS

```swift
import GoDareDI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var container: AdvancedDIContainer!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        container = AdvancedDIContainerImpl()
        return true
    }
}
```

### macOS

```swift
import GoDareDI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var container: AdvancedDIContainer!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        container = AdvancedDIContainerImpl()
    }
}
```

## 🧪 Testing

### Unit Tests

```swift
import XCTest
import GoDareDI

class GoDareDITests: XCTestCase {
    var container: AdvancedDIContainer!
    
    override func setUp() {
        super.setUp()
        container = AdvancedDIContainerImpl()
    }
    
    func testServiceRegistration() async throws {
        try await container.register(TestService.self, scope: .singleton) { container in
            return TestService()
        }
        
        let service = try await container.resolve(TestService.self)
        XCTAssertNotNil(service)
    }
}
```

## 🚨 Troubleshooting

### Common Issues

1. **Import Error**: Make sure you've added GoDareDI to your target
2. **Build Error**: Check that your deployment target is iOS 13.0+ or macOS 10.15+
3. **Runtime Error**: Ensure you're using `await` for async operations

### Getting Help

- Check the [GitHub Issues](https://github.com/MohamedAbdelHafezAbozaid/GoDareDI/issues)
- Read the [Documentation](https://github.com/MohamedAbdelHafezAbozaid/GoDareDI/wiki)
- Contact support: bota78336@gmail.com
EOF

# Create examples directory
mkdir -p "$DISTRIBUTION_DIR/Examples"

# Create a simple example
cat > "$DISTRIBUTION_DIR/Examples/BasicExample.swift" << 'EOF'
import GoDareDI

// Example: Basic dependency injection setup
class BasicExample {
    private let container: AdvancedDIContainer
    
    init() {
        container = AdvancedDIContainerImpl()
        setupServices()
    }
    
    private func setupServices() {
        Task {
            // Register a network service
            try await container.register(NetworkService.self, scope: .singleton) { container in
                return NetworkService()
            }
            
            // Register a data service
            try await container.register(DataService.self, scope: .transient) { container in
                return DataService()
            }
        }
    }
    
    func useServices() async throws {
        // Resolve and use services
        let networkService = try await container.resolve(NetworkService.self)
        let dataService = try await container.resolve(DataService.self)
        
        // Use the services
        let data = try await networkService.fetchData()
        try await dataService.processData(data)
    }
}

// Example services
class NetworkService {
    func fetchData() async throws -> Data {
        // Simulate network call
        return Data()
    }
}

class DataService {
    func processData(_ data: Data) async throws {
        // Process the data
        print("Processing data...")
    }
}
EOF

# Create LICENSE file
cat > "$DISTRIBUTION_DIR/LICENSE" << 'EOF'
MIT License

Copyright (c) 2025 Mohamed Ahmed

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# Create CHANGELOG
cat > "$DISTRIBUTION_DIR/CHANGELOG.md" << 'EOF'
# Changelog

All notable changes to GoDareDI will be documented in this file.

## [1.0.0] - 2025-01-10

### Added
- Initial release of GoDareDI
- Advanced dependency injection container
- Multiple scope support (Singleton, Transient, Scoped)
- Analytics integration
- Crashlytics integration
- Dashboard synchronization
- Dependency graph visualization
- Performance monitoring
- Type-safe dependency resolution
- Swift Package Manager support

### Features
- **Core DI**: Type-safe dependency injection
- **Scopes**: Singleton, Transient, Scoped lifetimes
- **Analytics**: Built-in usage tracking
- **Visualization**: Dependency graph visualization
- **Monitoring**: Performance metrics and monitoring
- **Integration**: Firebase and Crashlytics support
- **Cross-platform**: iOS, macOS, tvOS, watchOS support

### Requirements
- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 5.9+
- Xcode 15.0+
EOF

# Create a deployment script
cat > "$DISTRIBUTION_DIR/deploy-to-github.sh" << 'EOF'
#!/bin/bash

# Deploy GoDareDI to GitHub for public distribution
echo "🚀 Deploying GoDareDI to GitHub..."

# Initialize git if not already done
if [ ! -d ".git" ]; then
    git init
    git remote add origin https://github.com/MohamedAbdelHafezAbozaid/GoDareDI-Public.git
fi

# Add all files
git add .

# Commit changes
git commit -m "Release GoDareDI v1.0.0 - Advanced Dependency Injection Framework

Features:
- Type-safe dependency injection
- Multiple scope support (Singleton, Transient, Scoped)
- Analytics integration
- Crashlytics integration
- Dashboard synchronization
- Dependency graph visualization
- Performance monitoring
- Cross-platform support (iOS, macOS, tvOS, watchOS)

Requirements:
- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 5.9+
- Xcode 15.0+"

# Create and push tag
git tag v1.0.0
git push -u origin main --tags

echo "✅ GoDareDI deployed successfully!"
echo "📦 Repository: https://github.com/MohamedAbdelHafezAbozaid/GoDareDI-Public"
echo "🏷️  Version: v1.0.0"
echo ""
echo "🎯 Developers can now install using:"
echo "   .package(url: \"https://github.com/MohamedAbdelHafezAbozaid/GoDareDI-Public.git\", from: \"1.0.0\")"
EOF

chmod +x "$DISTRIBUTION_DIR/deploy-to-github.sh"

echo ""
echo "🎉 Distribution package created successfully!"
echo "📁 Output directory: $DISTRIBUTION_DIR"
echo ""
echo "📦 Package contents:"
echo "   • Sources/ - Complete source code"
echo "   • Tests/ - Unit tests"
echo "   • Package.swift - Swift Package Manager configuration"
echo "   • README.md - Developer documentation"
echo "   • INSTALLATION.md - Installation guide"
echo "   • Examples/ - Usage examples"
echo "   • LICENSE - MIT License"
echo "   • CHANGELOG.md - Version history"
echo "   • deploy-to-github.sh - Deployment script"
echo ""
echo "🚀 Next steps to make it available to developers:"
echo ""
echo "1. Create a new public GitHub repository:"
echo "   gh repo create GoDareDI-Public --public"
echo ""
echo "2. Navigate to the distribution directory:"
echo "   cd $DISTRIBUTION_DIR"
echo ""
echo "3. Deploy to GitHub:"
echo "   ./deploy-to-github.sh"
echo ""
echo "4. Share with developers:"
echo "   Repository URL: https://github.com/MohamedAbdelHafezAbozaid/GoDareDI-Public"
echo "   SPM URL: https://github.com/MohamedAbdelHafezAbozaid/GoDareDI-Public.git"
echo ""
echo "📋 Developers will be able to install using:"
echo "   .package(url: \"https://github.com/MohamedAbdelHafezAbozaid/GoDareDI-Public.git\", from: \"1.0.0\")"
