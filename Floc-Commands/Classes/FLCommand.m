//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLCommand.h"

@interface FLCommand ()
@property(nonatomic, readwrite) BOOL isRunning;
@end

@implementation FLCommand

- (void)execute {
    self.isRunning = YES;
    if ([self.delegate respondsToSelector:@selector(commandWillExecute:)])
        [self.delegate commandWillExecute:self];
}

- (void)cancel {
    self.isRunning = NO;
    if ([self.delegate respondsToSelector:@selector(commandCancelled:)])
        [self.delegate commandCancelled:self];
}

- (void)didExecute {
    [self didExecuteWithError:nil];
}

- (void)didExecuteWithError {
    [self didExecuteWithError:[NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:nil]];
}

- (void)didExecuteWithError:(NSError *)error {
    self.isRunning = NO;
    if ([self.delegate respondsToSelector:@selector(command:didExecuteWithError:)])
        [self.delegate command:self didExecuteWithError:error];
}

@end