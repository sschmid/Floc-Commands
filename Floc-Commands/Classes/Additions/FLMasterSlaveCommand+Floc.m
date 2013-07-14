//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLMasterSlaveCommand+Floc.h"

@interface FLMasterSlaveCommand ()
@property(nonatomic, readwrite) BOOL forwardMasterError;
@end

@implementation FLMasterSlaveCommand (Floc)

- (FLMasterSlaveCommandOptionBlock)forwardsMasterError {
    return ^FLMasterSlaveCommand *(BOOL forwardsMasterError) {
        self.forwardMasterError = forwardsMasterError;
        return self;
    };
}

@end