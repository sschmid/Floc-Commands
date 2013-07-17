//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>

@interface FLSwizzler : NSObject
+ (void)swizzleInstanceMethod:(Class)cls originalSelector:(SEL)originalSelector newSelector:(SEL)newSelector;
+ (void)swizzleClassMethod:(Class)cls originalSelector:(SEL)originalSelector newSelector:(SEL)newSelector;
@end