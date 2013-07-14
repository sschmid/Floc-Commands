//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLInterceptionCommand+Floc.h"

@interface FLInterceptionCommand ()
@property(nonatomic, readwrite) BOOL cancelOnCancel;
@property(nonatomic, readwrite) BOOL forwardTargetError;
@end

@implementation FLInterceptionCommand (Floc)

- (FLInterceptionCommandOptionBlock)cancelsOnCancel {
    return ^FLInterceptionCommand *(BOOL cancelOnCancel) {
        self.cancelOnCancel = cancelOnCancel;
        return self;
    };
}

- (FLInterceptionCommandOptionBlock)forwardsTargetError {
    return ^FLInterceptionCommand *(BOOL forwardTargetError) {
        self.forwardTargetError = forwardTargetError;
        return self;
    };
}

@end