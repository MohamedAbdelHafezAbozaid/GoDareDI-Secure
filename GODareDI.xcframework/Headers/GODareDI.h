#ifndef GODareDI_h
#define GODareDI_h

#import <Foundation/Foundation.h>

//! Project version number for GODareDI.
FOUNDATION_EXPORT double GODareDIVersionNumber;

//! Project version string for GODareDI.
FOUNDATION_EXPORT const unsigned char GODareDIVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <GODareDI/PublicHeader.h>

// GODareDI Framework
// This is a binary framework - source code is protected

// Core DI Types
@protocol AdvancedDIContainer <NSObject>
@end

// Dependency Scopes
typedef NS_ENUM(NSInteger, DependencyScope) {
    DependencyScopeSingleton = 0,
    DependencyScopeScoped = 1,
    DependencyScopeTransient = 2,
    DependencyScopeLazy = 3
};

// Dependency Lifetimes
typedef NS_ENUM(NSInteger, DependencyLifetime) {
    DependencyLifetimeApplication = 0,
    DependencyLifetimeSession = 1,
    DependencyLifetimeRequest = 2,
    DependencyLifetimeCustom = 3
};

// Performance Metrics
@interface PerformanceMetrics : NSObject
@property (nonatomic, assign) NSTimeInterval averageResolutionTime;
@property (nonatomic, assign) double cacheHitRate;
@property (nonatomic, assign) double memoryUsage;
@property (nonatomic, assign) NSInteger totalResolutions;
@property (nonatomic, assign) NSInteger circularDependencyCount;
@end

// Dependency Metadata
@interface DependencyMetadata : NSObject
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) DependencyScope scope;
@property (nonatomic, assign) DependencyLifetime lifetime;
@property (nonatomic, assign) BOOL lazy;
@property (nonatomic, strong) NSArray<NSString *> *dependencies;
@property (nonatomic, strong) NSDate *registrationTime;
@property (nonatomic, strong) NSDate *lastAccessed;
@end

// SwiftUI Integration (if available)
#if __has_include(<SwiftUI/SwiftUI.h>)
@import SwiftUI;
#endif

// Main initialization function
void godare_init(void);
int godare_version(void);

#endif /* GODareDI_h */
