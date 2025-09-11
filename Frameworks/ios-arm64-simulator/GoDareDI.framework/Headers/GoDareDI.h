#import <Foundation/Foundation.h>

//! Project version number for GoDareDI.
FOUNDATION_EXPORT double GoDareDIVersionNumber;

//! Project version string for GoDareDI.
FOUNDATION_EXPORT const unsigned char GoDareDIVersionString[];

// Binary Framework - Source code is protected and compiled
// Only public interfaces are available through this header

@interface GoDareDI : NSObject
+ (NSString *)frameworkVersion;
+ (NSString *)buildNumber;
+ (void)initializeFramework;
@end

@interface GoDareDIEntry : NSObject
+ (NSString *)getFrameworkVersion;
@end
