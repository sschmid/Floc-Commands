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

- (id)init {
    self = [super init];
    if (self) {
        self.delay = 1.0/60;
    }

    return self;
}

- (void)execute {
    [super execute];
    self.didStartExecution = YES;
    self.didCompleteExecution = NO;
    self.didGetCancelled = NO;
    self.error = nil;

    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.delay target:self selector:@selector(didAsyncStuff) userInfo:nil repeats:NO];
}

- (void)didAsyncStuff {
    if (self.executeAndCancel)
        [self cancel];
    else if (self.executeWithError)
        [self didExecuteWithError];
    else
        [self didExecute];
}

- (void)cancel {
    self.didGetCancelled = YES;
    self.didGetCancelledCount++;
    [self.timer invalidate];
    [super cancel];
}

- (void)didExecuteWithError:(NSError *)error {
    self.didStartExecution = YES;
    self.didGetCancelled = NO;
    self.didCompleteExecution = YES;
    self.error = error;
    self.didCompleteExecutionCount++;
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