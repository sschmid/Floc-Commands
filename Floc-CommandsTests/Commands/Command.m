//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "Command.h"

@interface Command ()
@property(nonatomic) BOOL didStartExecute;
@end

@implementation Command

- (void)execute {
    [super execute];
    self.didStartExecute = YES;
}

- (BOOL)isInInitialState {
    return self.didStartExecute == NO;
}

- (BOOL)isInExecuteState {
    return self.didStartExecute == YES;;
}

@end