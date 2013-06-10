//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "ConcurrentCommand.h"
@interface ConcurrentCommand ()
@property(nonatomic) BOOL didStartExecution;
@property(nonatomic) BOOL didCompleteExecution;
@property(nonatomic) BOOL didGetCancelled;
@property(nonatomic) NSError *error;
@end

@implementation ConcurrentCommand
- (void)execute {
    self.didStartExecution = YES;
    [super execute];
}

- (void)cancel {
    self.didGetCancelled = YES;
    [super cancel];
}

- (void)didExecuteWithError:(NSError *)error {
    self.didCompleteExecution = YES;
    self.error = error;
    [super didExecuteWithError:error];
}


#pragma mark test states

- (BOOL)isInInitialState {
    return !self.didStartExecution &&
            !self.didCompleteExecution &&
            self.error == nil &&
            !self.didGetCancelled;
}

- (BOOL)isInExecuteState {
    return self.didStartExecution &&
            !self.didCompleteExecution &&
            self.error == nil &&
            !self.didGetCancelled;
}

- (BOOL)isInDidExecuteWithoutErrorState {
    return self.didStartExecution &&
            self.didCompleteExecution &&
            self.error == nil &&
            !self.didGetCancelled;
}

- (BOOL)isInDidExecuteWithErrorState {
    return self.didStartExecution &&
            self.didCompleteExecution &&
            self.error != nil &&
            !self.didGetCancelled;
}

- (BOOL)isInCancelledState {
    return self.didStartExecution &&
            !self.didCompleteExecution &&
            self.error == nil &&
            self.didGetCancelled;
}
@end