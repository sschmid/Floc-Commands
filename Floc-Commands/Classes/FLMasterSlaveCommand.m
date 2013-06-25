//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLMasterSlaveCommand.h"

@interface FLMasterSlaveCommand ()
@property(nonatomic, strong) FLCommand *masterCommand;
@property(nonatomic, strong) FLCommand *slaveCommand;
@property(nonatomic, readwrite) BOOL forwardMasterError;
@property(nonatomic, strong) NSMutableArray *executingCommands;
@end

@implementation FLMasterSlaveCommand

- (id)init {
    self = [self initWithMaster:nil slave:nil];
    return self;
}

- (id)initWithMaster:(FLCommand *)masterCommand slave:(FLCommand *)slaveCommand {
    self = [self initWithMaster:masterCommand slave:slaveCommand forwardMasterError:NO];
    return self;
}

- (id)initWithMaster:(FLCommand *)masterCommand slave:(FLCommand *)slaveCommand forwardMasterError:(BOOL)forwardMasterError {
    self = [super init];
    if (self) {
        if (!masterCommand || ! slaveCommand)
            [[NSException exceptionWithName:[NSString stringWithFormat:@"%@Exception", [self class]]
                                     reason:@"Master or slave command must not be nil!"
                                   userInfo:nil] raise];

        self.masterCommand = masterCommand;
        self.slaveCommand = slaveCommand;
        self.forwardMasterError = forwardMasterError;
    }

    return self;
}

- (void)execute {
    [super execute];
    self.executingCommands = [[NSMutableArray alloc] initWithObjects:self.slaveCommand, self.masterCommand, nil];
    for (FLCommand *command in [self.executingCommands copy]) {
        command.delegate = self;
        [command execute];
    }
 }

- (void)cancel {
    [self cancelAllExecutingCommands];
    [super cancel];
}

- (void)cancelAllExecutingCommands {
    for (FLCommand *command in self.executingCommands) {
        command.delegate = nil;
        [command cancel];
    }
    [self.executingCommands removeAllObjects];
}


- (void)command:(FLCommand *)command didExecuteWithError:(NSError *)error {
    [self.executingCommands removeObject:command];
    command.delegate = nil;

    if (command == self.masterCommand) {
        [self cancelAllExecutingCommands];
        [self didExecuteWithError:self.forwardMasterError ? error : nil];
    }
}

- (void)commandCancelled:(FLCommand *)command {
    [self.executingCommands removeObject:command];
    command.delegate = nil;

    if (command == self.masterCommand)
        [self cancel];
}

@end