# 🔥 GoDareDI Crashlytics Integration

## Overview

GoDareDI now includes a comprehensive crashlytics and analytics system that automatically tracks dependency injection events, performance issues, and errors. This data is sent to your Firebase project and displayed in a beautiful web dashboard.

## 🚀 Features

### **Automatic Tracking**
- ✅ Dependency registrations
- ✅ Dependency resolutions (success/failure)
- ✅ Performance bottlenecks
- ✅ Circular dependencies
- ✅ Container errors
- ✅ Memory usage
- ✅ Container state

### **Real-time Dashboard**
- 📊 Live analytics
- 🎯 Performance metrics
- 🚨 Error tracking
- 📈 Usage statistics
- 🔍 Dependency graphs

### **Firebase Integration**
- 🔥 Cloud Functions
- 📱 Firestore database
- 🌐 Web dashboard
- 🔐 Secure authentication

## 📦 Installation

### 1. Get Your SDK Token

1. Visit the [GoDareDI Dashboard](https://godaredi-60569.firebaseapp.com)
2. Register your application
3. Generate your SDK token
4. Copy the token for use in your app

### 2. Add to Your Project

```swift
// In your Package.swift
dependencies: [
    .package(url: "https://github.com/yourusername/GoDareDI.git", from: "1.0.0")
]
```

## 🎯 Usage

### Basic Setup

```swift
import GoDareDI

// 1. Create crashlytics configuration
let crashlyticsConfig = DICrashlyticsConfig(
    token: "your-sdk-token-here",
    enableCrashlytics: true,
    enableAnalytics: true,
    enablePerformanceTracking: true,
    enableCircularDependencyTracking: true
)

// 2. Create container with crashlytics
let container = AdvancedDIContainerImpl(crashlyticsConfig: crashlyticsConfig)

// 3. Use normally - everything is automatically tracked!
await container.register(MyService.self, scope: .singleton) { container in
    return MyService()
}

let service = try await container.resolve(MyService.self)
```

### Advanced Configuration

```swift
let crashlyticsConfig = DICrashlyticsConfig(
    token: "your-sdk-token-here",
    enableCrashlytics: true,
    enableAnalytics: true,
    enablePerformanceTracking: true,
    enableCircularDependencyTracking: true,
    baseURL: "https://us-central1-godaredi-60569.cloudfunctions.net"
)
```

## 📊 Dashboard Features

### **User Dashboard**
- **My Apps**: Manage your registered applications
- **Analytics**: View detailed usage statistics
- **Tokens**: Manage your SDK tokens
- **Real-time Metrics**: Live performance data

### **Super Admin Dashboard**
- **Global Stats**: Total users, apps, tokens, usage
- **Platform Analytics**: Cross-platform insights
- **User Management**: Monitor all registered users

## 🔍 What Gets Tracked

### **Dependency Events**
```json
{
  "type": "dependency_resolution",
  "dependency_type": "UserService",
  "duration": 0.045,
  "success": true,
  "timestamp": "2025-01-01T12:00:00Z"
}
```

### **Performance Issues**
```json
{
  "type": "performance_issue",
  "issue_type": "slow_resolution",
  "severity": "high",
  "details": {
    "dependency_type": "DatabaseService",
    "duration": 2.5,
    "threshold_exceeded": true
  },
  "timestamp": "2025-01-01T12:00:00Z"
}
```

### **Circular Dependencies**
```json
{
  "type": "circular_dependency",
  "chain": ["ServiceA", "ServiceB", "ServiceA"],
  "timestamp": "2025-01-01T12:00:00Z"
}
```

### **Container Errors**
```json
{
  "type": "error",
  "error_type": "DependencyResolutionError",
  "error_message": "Service not registered",
  "dependency_type": "MissingService",
  "scope": "transient",
  "resolution_stack": ["UserViewModel", "UserService"],
  "container_state": {
    "registered_services_count": 15,
    "active_scopes": ["user-session"],
    "memory_usage": 12.5,
    "current_scope": "user-session",
    "is_preloading": false
  },
  "timestamp": "2025-01-01T12:00:00Z"
}
```

## 🛠️ Firebase Setup

### **Project Structure**
```
godaredi-60569/
├── Firestore Collections:
│   ├── users/ (client registrations)
│   ├── apps/ (registered applications)
│   ├── tokens/ (SDK tokens)
│   ├── analytics/ (usage data)
│   └── admin/ (super admin data)
├── Cloud Functions:
│   ├── generateToken
│   ├── trackUsage
│   ├── getAnalytics
│   └── getGlobalStats
└── Storage:
    └── sdk-files/ (SPM packages)
```

### **Security Rules**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == userId;
    }
    
    // Apps belong to users
    match /apps/{appId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Super admin access
    match /admin/{document} {
      allow read, write: if request.auth != null && 
        request.auth.token.email == "bota78336@gmail.com";
    }
  }
}
```

## 🔐 Authentication

### **Super Admin**
- **Email**: bota78336@gmail.com
- **Password**: S1234s12
- **Access**: Global analytics, user management, platform stats

### **Regular Users**
- **Registration**: Open registration
- **Access**: Own apps, tokens, and analytics
- **Dashboard**: Personal analytics and management

## 📱 SDK Token System

### **Token Generation**
1. User registers application
2. System generates unique 64-character token
3. Token is linked to user and application
4. Token is used for all analytics tracking

### **Token Usage**
```swift
// Token is embedded in your app
let crashlyticsConfig = DICrashlyticsConfig(token: "your-token-here")
let container = AdvancedDIContainerImpl(crashlyticsConfig: crashlyticsConfig)

// All analytics are automatically tagged with your token
// Data appears in your dashboard under your account
```

## 🚨 Error Handling

### **Network Issues**
- Events are buffered locally
- Automatic retry on network recovery
- Graceful degradation if Firebase is unavailable

### **Invalid Tokens**
- Clear error messages
- Automatic token validation
- Fallback to local logging

### **Rate Limiting**
- Built-in rate limiting
- Batch event sending
- Efficient data transmission

## 📈 Performance Impact

### **Minimal Overhead**
- Asynchronous event tracking
- Local buffering
- Batch transmission
- Background processing

### **Memory Usage**
- Lightweight event objects
- Automatic cleanup
- Configurable buffer sizes

## 🔧 Configuration Options

```swift
public struct DICrashlyticsConfig: Sendable {
    public let token: String
    public let enableCrashlytics: Bool
    public let enableAnalytics: Bool
    public let enablePerformanceTracking: Bool
    public let enableCircularDependencyTracking: Bool
    public let baseURL: String
}
```

## 🎨 Dashboard Screenshots

### **User Dashboard**
- Clean, modern interface
- Real-time metrics
- Interactive charts
- Mobile-responsive design

### **Analytics View**
- Dependency resolution times
- Error rates
- Performance trends
- Usage patterns

### **Token Management**
- Token generation
- Usage statistics
- Active/inactive status
- Copy to clipboard

## 🚀 Getting Started

1. **Visit Dashboard**: Go to [GoDareDI Dashboard](https://godaredi-60569.firebaseapp.com)
2. **Register**: Create your account
3. **Add App**: Register your application
4. **Get Token**: Generate your SDK token
5. **Integrate**: Add crashlytics to your GoDareDI container
6. **Monitor**: View real-time analytics in your dashboard

## 🤝 Support

- **Documentation**: [GoDareDI Docs](https://github.com/yourusername/GoDareDI)
- **Issues**: [GitHub Issues](https://github.com/yourusername/GoDareDI/issues)
- **Dashboard**: [GoDareDI Dashboard](https://godaredi-60569.firebaseapp.com)

## 📄 License

MIT License - see LICENSE file for details.

---

**🔥 Start tracking your dependency injection performance today!**
