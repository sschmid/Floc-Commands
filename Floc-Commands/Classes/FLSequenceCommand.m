//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLSequenceCommand.h"

@interface FLSequenceCommand ()
@property(nonatomic, readwrite) BOOL stopOnError;
@property(nonatomic, readwrite) BOOL cancelOnCancel;
@property(nonatomic, strong, readwrite) NSArray *commands;
@property(nonatomic) uint commandIndex;
@property(nonatomic, strong) FLCommand *currentCommand;
@end

@implementation FLSequenceCommand

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
    self.commandIndex = 0;
    [self executeNextCommand];
}

- (void)cancel {
    self.currentCommand.delegate = nil;
    [self.currentCommand cancel];
    [super cancel];
}

- (void)executeNextCommand {
    if (self.commandIndex < self.commands.count) {
        self.currentCommand = self.commands[self.commandIndex++];
        self.currentCommand.delegate = self;
        [self.currentCommand execute];
    } else {
        [self didExecute];
    }
}

- (void)command:(FLCommand *)command didExecuteWithError:(NSError *)error {
    self.currentCommand = nil;
    command.delegate = nil;

    if (self.stopOnError && error) {
        NSLog(@"Command '%@' did execute with an error: %@'\nStopping sequence '%@'",
                command, error.localizedDescription, self);
        [self didExecuteWithError:error];
    } else {
        [self executeNextCommand];
    }
}

- (void)commandCancelled:(FLCommand *)command {
    self.currentCommand = nil;
    command.delegate = nil;

    if (self.cancelOnCancel) {
        NSLog(@"Command '%@' got cancelled.\nCancelling sequence '%@'", command, self);
        [self cancel];
    } else {
        [self executeNextCommand];
    }
}

@end