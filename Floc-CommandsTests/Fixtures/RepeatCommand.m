//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "RepeatCommand.h"

@interface RepeatCommand ()
@property(nonatomic) BOOL didStartExecution;
@property(nonatomic) BOOL didCompleteExecution;
@property(nonatomic) BOOL didGetCancelled;
@property(nonatomic) NSError *error;
@property(nonatomic, strong) NSTimer *timer;
@end

@implementation RepeatCommand

- (void)execute {
    self.willExecuteCount ++;

    self.didStartExecution = YES;
    self.didCompleteExecution = NO;
    self.didGetCancelled = NO;
    self.error = nil;

    if (self.cancelDelay != 0)
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.cancelDelay target:self selector:@selector(cancel) userInfo:nil repeats:NO];

    [super execute];
}

- (void)cancel {
    self.didCancelCount++;
    self.didGetCancelled = YES;
    [super cancel];
}

- (void)didExecuteWithError:(NSError *)error {
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
