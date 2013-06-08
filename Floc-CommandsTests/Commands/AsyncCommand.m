//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "AsyncCommand.h"

@interface AsyncCommand ()
@property(nonatomic) BOOL didStartExecution;
@property(nonatomic) BOOL didCompleteExecution;
@property(nonatomic) BOOL didGetCancelled;
@property(nonatomic) NSError *error;
//
@property(nonatomic, strong) NSTimer *timer;
@end

@implementation AsyncCommand

- (void)execute {
    [super execute];
    self.didStartExecution = YES;

    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(didAsyncStuff:) userInfo:self.asyncResult repeats:NO];
}

- (void)didAsyncStuff:(NSTimer *)timer {
    if (timer.userInfo == nil)
        [self didExecuteWithError];
    else
        [self didExecute];
}

- (void)cancel {
    self.didGetCancelled = YES;
    [self.timer invalidate];
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