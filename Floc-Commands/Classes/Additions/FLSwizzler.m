//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <objc/runtime.h>
#import "FLSwizzler.h"

@implementation FLSwizzler

+ (void)swizzleInstanceMethod:(Class)cls originalSelector:(SEL)originalSelector newSelector:(SEL)newSelector {
    [self swizzle:cls
 originalSelector:originalSelector
      newSelector:newSelector
   originalMethod:class_getInstanceMethod(cls, originalSelector)
        newMethod:class_getInstanceMethod(cls, newSelector)];
}

+ (void)swizzleClassMethod:(Class)cls originalSelector:(SEL)originalSelector newSelector:(SEL)newSelector {
    [self swizzle:cls
 originalSelector:originalSelector
      newSelector:newSelector
   originalMethod:class_getClassMethod(cls, originalSelector)
        newMethod:class_getClassMethod(cls, newSelector)];
}

+ (void)swizzle:(Class)cls
        originalSelector:(SEL)originalSelector
        newSelector:(SEL)newSelector
 originalMethod:(Method)originalMethod
        newMethod:(Method)newMethod {

    BOOL methodAdded = class_addMethod(cls, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (methodAdded)
        class_replaceMethod(cls, newSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    else
        method_exchangeImplementations(originalMethod, newMethod);
}

@end