//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "Command.h"

@interface Command ()
@property(nonatomic) BOOL didStartExecution;
@property(nonatomic) BOOL didCompleteExecution;
@property(nonatomic) BOOL didGetCancelled;
@property(nonatomic) NSError *error;
//
@property(nonatomic, strong) NSTimer *timer;
@end

@implementation Command

- (id)init {
    self = [super init];
    if (self) {
        self.didExecuteDelay = 1.0/60;
    }

    return self;
}

- (void)execute {
    self.willExecuteCount++;

    self.didStartExecution = YES;
    self.didCompleteExecution = NO;
    self.didGetCancelled = NO;
    self.error = nil;

    [super execute];

    if (self.didExecuteDelay == 0)
        [self didAsyncStuff];
    else
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.didExecuteDelay target:self selector:@selector(didAsyncStuff) userInfo:nil repeats:NO];
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
    self.didCancelCount++;
    self.didGetCancelled = YES;
    [self.timer invalidate];
    [super cancel];
}

- (void)didExecuteWithError:(NSError *)error {
    if (self.resetExecuteWithErrorAfterDidExecute)
        self.executeWithError = NO;

    self.didExecuteCount++;
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