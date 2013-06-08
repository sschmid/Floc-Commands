//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLAsyncCommand.h"
#import "AsyncCommandDelegate.h"

@interface AsyncCommandDelegate ()
@property(nonatomic) BOOL didExecute;
@property(nonatomic, strong) NSError *error;
@property(nonatomic) BOOL cancelled;
@end

@implementation AsyncCommandDelegate

- (void)command:(FLAsyncCommand *)command didExecuteWithError:(NSError *)error {
    self.didExecute = YES;
    self.error = error;
}

- (void)commandCancelled:(FLAsyncCommand *)command {
    self.cancelled = YES;
}


#pragma mark test states

- (BOOL)isInInitialState {
    return !self.didExecute &&
            self.error == nil &&
            !self.cancelled;
}

- (BOOL)isInDidExecuteWithoutErrorState {
    return self.didExecute &&
            self.error == nil &&
            !self.cancelled;
}

- (BOOL)isInDidExecuteWithErrorState {
    return self.didExecute &&
            self.error != nil &&
            !self.cancelled;
}

- (BOOL)isInCancelState {
    return !self.didExecute &&
            self.error == nil &&
            self.cancelled;
}

@end