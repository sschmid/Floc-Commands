//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLDelayCommand.h"

@interface FLDelayCommand ()
@property(nonatomic) double delay;
@end

@implementation FLDelayCommand

- (id)init {
    self = [self initWithDelay:0];
    return self;
}


- (id)initWithDelay:(double)delay {
    self = [super init];
    if (self) {
        self.delay = delay;
    }

    return self;
}

- (void)execute {
    [super execute];
    [self performSelector:@selector(didExecute) withObject:nil afterDelay:self.delay];
}

@end