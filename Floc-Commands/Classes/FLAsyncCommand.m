//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLAsyncCommand.h"

@implementation FLAsyncCommand
- (void)cancel {
    [self.delegate commandCancelled:self];
}

- (void)didExecuteWithError:(NSError *)error {
    [self.delegate command:self didExecuteWithError:error];
}

- (void)didExecuteWithError {
    [self didExecuteWithError:[NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:nil]];
}

- (void)didExecute {
    [self didExecuteWithError:nil];
}
@end