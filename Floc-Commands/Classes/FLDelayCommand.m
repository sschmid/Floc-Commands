//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLDelayCommand.h"

@interface FLDelayCommand ()
@property(nonatomic) double delay;
@property(nonatomic, strong) NSTimer *timer;
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
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.delay target:self selector:@selector(didExecute) userInfo:nil repeats:NO];
}

- (void)cancel {
    [self.timer invalidate];
    [super cancel];
}

@end