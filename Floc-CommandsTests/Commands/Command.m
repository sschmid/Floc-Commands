//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "Command.h"

@interface Command ()
@property(nonatomic) BOOL didStartExecution;
@end

@implementation Command

- (void)execute {
    [super execute];
    self.didStartExecution = YES;
}

- (BOOL)isInInitialState {
    return !self.didStartExecution;
}

- (BOOL)isInExecuteState {
    return self.didStartExecution;
}

@end