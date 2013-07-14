//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLSequenceCommand+Floc.h"

@interface FLSequenceCommand ()
@property(nonatomic, readwrite) BOOL stopOnError;
@property(nonatomic, readwrite) BOOL cancelOnCancel;
@end

@implementation FLSequenceCommand (Floc)

- (FLSequenceCommandOptionBlock)stopsOnError {
    return ^FLSequenceCommand *(BOOL stopOnError) {
        self.stopOnError = stopOnError;
        return self;
    };
}

- (FLSequenceCommandOptionBlock)cancelsOnCancel {
    return ^FLSequenceCommand *(BOOL cancelOnCancel) {
        self.cancelOnCancel = cancelOnCancel;
        return self;
    };
}

@end
