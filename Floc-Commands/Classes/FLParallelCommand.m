//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLParallelCommand.h"

@interface FLParallelCommand ()
@property(nonatomic, readwrite) BOOL stopOnError;
@property(nonatomic, readwrite) BOOL cancelOnCancel;
@property(nonatomic, strong, readwrite) NSArray *commands;
@property(nonatomic, strong) NSMutableArray *executingCommands;
@end

@implementation FLParallelCommand

- (id)init {
    self = [self initWithCommands:nil];
    return self;
}

- (id)initWithCommands:(NSArray *)commands {
    self = [self initWithCommands:commands stopOnError:NO cancelOnCancel:NO];
    return self;
}

- (id)initWithCommands:(NSArray *)commands stopOnError:(BOOL)stopOnError cancelOnCancel:(BOOL)cancelOnCancel {
    self = [super init];
    if (self) {
        self.commands = [commands copy];
        self.stopOnError = stopOnError;
        self.cancelOnCancel = cancelOnCancel;
    }

    return self;
}

- (void)execute {
    [super execute];

    if (self.commands.count == 0) {
        [self didExecute];
    } else {
        self.executingCommands = [self.commands mutableCopy];
        for (FLCommand *command in self.commands) {
            command.delegate = self;
            [command execute];
        }
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

    if (self.stopOnError && error) {
        NSLog(@"Command '%@' did execute with an error: %@'\nStopping command '%@'",
                command, error.localizedDescription, self);

        [self cancelAllExecutingCommands];
        [self didExecuteWithError:error];
    } else if (self.executingCommands.count == 0) {
        [self didExecute];
    }
}

- (void)commandCancelled:(FLCommand *)command {
    [self.executingCommands removeObject:command];
    command.delegate = nil;

    if (self.cancelOnCancel) {
        NSLog(@"Command '%@' got cancelled.\nCancelling command '%@'", command, self);
        [self cancel];
    }
}

@end