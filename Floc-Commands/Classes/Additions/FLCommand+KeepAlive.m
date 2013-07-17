//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLCommand+KeepAlive.h"
#import "FLSwizzler.h"

@implementation FLCommand (KeepAlive)

+ (void)load {
    [FLSwizzler swizzleInstanceMethod:self originalSelector:@selector(cancel) newSelector:@selector(keepAliveCancelHook)];
    [FLSwizzler swizzleInstanceMethod:self originalSelector:@selector(didExecuteWithError:) newSelector:@selector(keepAliveCompletionHook:)];
}

+ (NSMutableSet *)keepAliveCommands {
    static NSMutableSet *sKeepAliveCommands = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sKeepAliveCommands = [[NSMutableSet alloc] init];
    });

    return sKeepAliveCommands;
}

- (FLCommand *)keepAlive {
    NSLog(@"FLCommand+KeepAlive: Keeping alive: %@", self);
    [[FLCommand keepAliveCommands] addObject:self];
    return self;
}

- (void)releaseCommand {
    if ([[FLCommand keepAliveCommands] containsObject:self]) {
        NSLog(@"FLCommand+KeepAlive: Releasing: %@", self);
        [[FLCommand keepAliveCommands] removeObject:self];
    }
}

- (void)keepAliveCancelHook {
    [self keepAliveCancelHook];
    [self releaseCommand];
}

- (void)keepAliveCompletionHook:(NSError *)error {
    [self keepAliveCompletionHook:error];
    [self releaseCommand];
}

@end