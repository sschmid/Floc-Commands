//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLParallelCommand+Floc.h"

@interface FLParallelCommand ()
@property(nonatomic, readwrite) BOOL stopOnError;
@property(nonatomic, readwrite) BOOL cancelOnCancel;
@end

@implementation FLParallelCommand (Floc)

- (FLParallelCommandOptionBlock)stopsOnError {
    return ^FLParallelCommand *(BOOL stopOnError) {
        self.stopOnError = stopOnError;
        return self;
    };
}

- (FLParallelCommandOptionBlock)cancelsOnCancel {
    return ^FLParallelCommand *(BOOL cancelOnCancel) {
        self.cancelOnCancel = cancelOnCancel;
        return self;
    };
}

@end
