//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLCommand.h"

@implementation FLCommand

- (void)execute {
    if ([self.delegate respondsToSelector:@selector(commandWillExecute:)])
        [self.delegate commandWillExecute:self];
}

- (void)cancel {
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
    if ([self.delegate respondsToSelector:@selector(command:didExecuteWithError:)])
        [self.delegate command:self didExecuteWithError:error];
}

@end