//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLCommandFlow.h"
#import "FLSequenceCommand.h"
#import "FLConcurrentCommand.h"

@interface FLCommandFlow ()
@property(nonatomic, strong) NSMutableArray *commands;
@property(nonatomic, strong) FLSequenceCommand *rootCommand;
@end

@implementation FLCommandFlow

- (id)init {
    self = [super init];
    if (self) {
        self.commands = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)execute {
    [super execute];
    self.rootCommand = [[FLSequenceCommand alloc] initWithCommands:self.commands];
    self.rootCommand.delegate = self;
    [self.rootCommand execute];
}

- (void)command:(FLCommand *)command didExecuteWithError:(NSError *)error {
    [self didExecute];
}

- (FLFlowConcurrentCommandBlock)addConcurrentCommands {
    return ^FLCommandFlow *(FLBlockCommandBlock firstBlock, ...) {
        va_list args;
        va_start(args, firstBlock);
        NSMutableArray *commands = [[NSMutableArray alloc] init];
        for (FLBlockCommandBlock block = firstBlock; block != nil; block = va_arg(args, FLBlockCommandBlock))
            [commands addObject:[[FLBlockCommand alloc] initWithBlock:block]];
        va_end(args);

        if (commands.count == 1)
            [self.commands addObject:commands[0]];
        else
            [self.commands addObject:[[FLConcurrentCommand alloc] initWithCommands:commands]];

        return self;
    };
}

@end