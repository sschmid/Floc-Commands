//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "SequenceCommand.h"
@interface SequenceCommand ()
@property(nonatomic) BOOL didStartExecution;
@property(nonatomic) BOOL didCompleteExecution;
@property(nonatomic) BOOL didGetCancelled;
@property(nonatomic) NSError *error;
@end

@implementation SequenceCommand

- (void)execute {
    self.willExecuteCount++;

    self.didStartExecution = YES;
    self.didCompleteExecution = NO;
    self.didGetCancelled = NO;
    self.error = nil;

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
            !self.didGetCancelled &&
            !self.isRunning;
}

- (BOOL)isInExecuteState {
    return self.didStartExecution &&
            !self.didCompleteExecution &&
            self.error == nil &&
            !self.didGetCancelled &&
            self.isRunning;
}

- (BOOL)isInDidExecuteWithoutErrorState {
    return self.didStartExecution &&
            self.didCompleteExecution &&
            self.error == nil &&
            !self.didGetCancelled &&
            !self.isRunning;
}

- (BOOL)isInDidExecuteWithErrorState {
    return self.didStartExecution &&
            self.didCompleteExecution &&
            self.error != nil &&
            !self.didGetCancelled &&
            !self.isRunning;
}

- (BOOL)isInCancelledState {
    return self.didStartExecution &&
            !self.didCompleteExecution &&
            self.error == nil &&
            self.didGetCancelled &&
            !self.isRunning;
}

@end