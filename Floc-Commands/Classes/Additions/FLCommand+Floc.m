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

- (FLCFCommandsBlock)parallel {
    return ^FLCommand *(FLCommand *firstCommand, ...) {
        va_list args;
        va_start(args, firstCommand);
        NSMutableArray *commands = [[NSMutableArray alloc] initWithObjects:self, nil];
        for (FLCommand *command = firstCommand; command != nil; command = va_arg(args, FLCommand *))
            [commands addObject:command];
        va_end(args);
        return [[FLParallelCommand alloc] initWithCommands:commands];
    };
}

- (FLCFCommandsBlock)sequence {
    return ^FLCommand *(FLCommand *firstCommand, ...) {
        va_list args;
        va_start(args, firstCommand);
        NSMutableArray *commands = [[NSMutableArray alloc] initWithObjects:self, nil];
        for (FLCommand *command = firstCommand; command != nil; command = va_arg(args, FLCommand *))
            [commands addObject:command];
        va_end(args);
        return [[FLSequenceCommand alloc] initWithCommands:commands];
    };
}

- (FLCFCommandBlock)then {
    return ^FLCommand *(FLCommand *command) {
        return [[FLSequenceCommand alloc] initWithCommands:@[self, command] stopOnError:YES cancelOnCancel:YES];
    };
}

- (FLCFCountBlock)repeat {
    return ^FLCommand *(NSInteger repeat) {
        return [[FLRepeatCommand alloc] initWithCommand:self repeat:repeat];
    };
}

- (FLCFCountBlock)retry {
    return ^FLCommand *(NSInteger retry) {
        return [[FLRetryCommand alloc] initWithCommand:self retry:retry];
    };
}

- (FLCFChoiceBlock)intercept {
    return ^FLCommand *(FLCommand *success, FLCommand *error) {
        return [[FLInterceptionCommand alloc] initWithTarget:self success:success error:error];
    };
}

- (FLCFCommandBlock)slave {
    return ^FLCommand *(FLCommand *slave) {
        return [[FLMasterSlaveCommand alloc] initWithMaster:self slave:slave];
    };
}

@end