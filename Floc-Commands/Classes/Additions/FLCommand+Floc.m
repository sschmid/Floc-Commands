//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLCommand+Floc.h"
#import "FLRepeatCommand.h"
#import "FLRetryCommand.h"
#import "FLParallelCommand.h"
#import "FLSequenceCommand.h"
#import "FLInterceptionCommand.h"
#import "FLMasterSlaveCommand.h"

@implementation FLCommand (Floc)

- (FLCFInterceptionCommandBlock)intercept {
    return ^FLInterceptionCommand *(FLCommand *success, FLCommand *error) {
        return [[FLInterceptionCommand alloc] initWithTarget:self success:success error:error];
    };
}

- (FLCFMasterSlaveCommandBlock)slave {
    return ^FLMasterSlaveCommand *(FLCommand *slave) {
        return [[FLMasterSlaveCommand alloc] initWithMaster:self slave:slave];
    };
}

- (FLCFParallelCommandBlock)parallel {
    return ^FLSequenceCommand *(FLCommand *firstCommand, ...) {
        va_list args;
        va_start(args, firstCommand);
        NSMutableArray *commands = [[NSMutableArray alloc] init];
        for (FLCommand *command = firstCommand; command != nil; command = va_arg(args, FLCommand *))
            [commands addObject:command];
        va_end(args);
        return [[FLSequenceCommand alloc] initWithCommands:@[self,
                [[FLParallelCommand alloc] initWithCommands:commands]]];
    };
}

- (FLCFRepeatBlock)repeat {
    return ^FLRepeatCommand *(NSInteger repeat) {
        return [[FLRepeatCommand alloc] initWithCommand:self repeat:repeat];
    };
}

- (FLCFRetryBlock)retry {
    return ^FLRetryCommand *(NSInteger retry) {
        return [[FLRetryCommand alloc] initWithCommand:self retry:retry];
    };
}

- (FLCFSequenceCommandBlock)sequence {
    return ^FLSequenceCommand *(FLCommand *firstCommand, ...) {
        va_list args;
        va_start(args, firstCommand);
        NSMutableArray *commands = [[NSMutableArray alloc] init];
        for (FLCommand *command = firstCommand; command != nil; command = va_arg(args, FLCommand *))
            [commands addObject:command];
        va_end(args);
        return [[FLSequenceCommand alloc] initWithCommands:@[self,
                [[FLSequenceCommand alloc] initWithCommands:commands]]];
    };
}

@end
