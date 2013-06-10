//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLConcurrentCommand.h"

@interface FLConcurrentCommand ()
@property(nonatomic, readwrite) BOOL stopOnError;
@property(nonatomic, readwrite) BOOL cancelOnCancel;
@property(nonatomic, strong, readwrite) NSArray *commands;
@property(nonatomic, strong) NSMutableArray *asyncCommands;
@end

@implementation FLConcurrentCommand

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
        self.asyncCommands = [[NSMutableArray alloc] init];
        self.stopOnError = stopOnError;
        self.cancelOnCancel = cancelOnCancel;
    }

    return self;
}


- (void)execute {
    [super execute];

    for (FLCommand *command in self.commands) {
        if ([command isKindOfClass:[FLAsyncCommand class]]) {
            ((FLAsyncCommand *) command).delegate = self;
            [self.asyncCommands addObject:command];
        }
        [command execute];
    }

    if (self.asyncCommands.count == 0)
        [self didExecute];
}

- (void)cancel {
    [self cancelAllExecutingCommands];
    [super cancel];
}

- (void)cancelAllExecutingCommands {
    for (FLAsyncCommand *asyncCommand in self.asyncCommands) {
        asyncCommand.delegate = nil;
        [asyncCommand cancel];
    }
    [self.asyncCommands removeAllObjects];
}

- (void)command:(FLAsyncCommand *)command didExecuteWithError:(NSError *)error {
    command.delegate = nil;
    [self.asyncCommands removeObject:command];

    if (self.stopOnError && error) {
        NSLog(@"Command '%@' did execute with an error: %@'\nStopping command '%@'",
                command, error.localizedDescription, self);

        [self cancelAllExecutingCommands];
        [self didExecuteWithError:error];
    } else if (self.asyncCommands.count == 0) {
        [self didExecute];
    }
}

- (void)commandCancelled:(FLAsyncCommand *)command {
    command.delegate = nil;
    [self.asyncCommands removeObject:command];

    if (self.cancelOnCancel) {
        NSLog(@"Command '%@' got cancelled.\nCancelling command '%@'", command, self);
        [self cancel];
    }
}

@end