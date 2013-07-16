//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLCommand.h"
#import "CommandDelegate.h"

@interface CommandDelegate ()
@property(nonatomic) BOOL didStartExecution;
@property(nonatomic) BOOL didExecute;
@property(nonatomic, strong) NSError *error;
@property(nonatomic) BOOL cancelled;
@end

@implementation CommandDelegate

- (void)commandWillExecute:(FLCommand *)command {
    self.didStartExecution = YES;
}

- (void)command:(FLCommand *)command didExecuteWithError:(NSError *)error {
    self.didExecute = YES;
    self.error = error;
}

- (void)commandCancelled:(FLCommand *)command {
    self.cancelled = YES;
}


#pragma mark test states

- (BOOL)isInInitialState {
    return !self.didStartExecution &&
            !self.didExecute &&
            self.error == nil &&
            !self.cancelled;
}

- (BOOL)isInExecuteState {
    return self.didStartExecution &&
            !self.didExecute &&
            self.error == nil &&
            !self.cancelled;
}

- (BOOL)isInDidExecuteWithoutErrorState {
    return self.didStartExecution &&
            self.didExecute &&
            self.error == nil &&
            !self.cancelled;
}

- (BOOL)isInDidExecuteWithErrorState {
    return self.didStartExecution &&
            self.didExecute &&
            self.error != nil &&
            !self.cancelled;
}

- (BOOL)isInCancelledState {
    return !self.didExecute &&
            self.error == nil &&
            self.cancelled;
}

@end