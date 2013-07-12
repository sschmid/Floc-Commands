//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLCommand+KeepAlive.h"

static NSMutableSet *sKeepAliveCommands;

@implementation FLCommand (KeepAlive)

+ (NSMutableSet *)keepAliveCommands {
    if (!sKeepAliveCommands) sKeepAliveCommands = [[NSMutableSet alloc] init];
    return sKeepAliveCommands;
}

- (FLCommand *)keepAlive {
    NSLog(@"FLCommand: Keeping alive: %@", self);
    [[FLCommand keepAliveCommands] addObject:self];
    return self;
}

- (void)cancel {
    if ([self.delegate respondsToSelector:@selector(commandCancelled:)])
        [self.delegate commandCancelled:self];
    if ([[FLCommand keepAliveCommands] containsObject:self]) {
        NSLog(@"FLCommand: Releasing: %@", self);
        [[FLCommand keepAliveCommands] removeObject:self];
    }
}

- (void)didExecuteWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(command:didExecuteWithError:)])
        [self.delegate command:self didExecuteWithError:error];
    if ([[FLCommand keepAliveCommands] containsObject:self]) {
        NSLog(@"FLCommand: Releasing: %@", self);
        [[FLCommand keepAliveCommands] removeObject:self];
    }
}

@end