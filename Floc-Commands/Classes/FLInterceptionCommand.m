//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLInterceptionCommand.h"

@interface FLInterceptionCommand ()
@property(nonatomic, readwrite) BOOL cancelOnCancel;
@property(nonatomic, readwrite) BOOL forwardTargetError;
@property(nonatomic, strong) FLCommand *targetCommand;
@property(nonatomic, strong) FLCommand *successCommand;
@property(nonatomic, strong) FLCommand *errorCommand;
@property(nonatomic, strong) FLCommand *currentCommand;
@property(nonatomic, strong) NSError *targetError;
@end

@implementation FLInterceptionCommand

- (id)init {
    self = [self initWithTarget:nil success:nil error:nil];
    return self;
}

- (id)initWithTarget:(FLCommand *)targetCommand success:(FLCommand *)successCommand error:(FLCommand *)errorCommand {
    self = [self initWithTarget:targetCommand success:successCommand error:errorCommand cancelOnCancel:NO forwardTargetError:NO];
    return self;
}

- (id)initWithTarget:(FLCommand *)targetCommand success:(FLCommand *)successCommand error:(FLCommand *)errorCommand cancelOnCancel:(BOOL)cancelOnCancel forwardTargetError:(BOOL)forwardTargetError {
    self = [super init];
    if (self) {
        if (!targetCommand)
            [[NSException exceptionWithName:[NSString stringWithFormat:@"%@Exception", [self class]]
                                     reason:@"Target command must not be nil!"
                                   userInfo:nil] raise];

        if (!successCommand && !errorCommand)
            [[NSException exceptionWithName:[NSString stringWithFormat:@"%@Exception", [self class]]
                                     reason:@"You must specify a command for success or error!"
                                   userInfo:nil] raise];

        self.targetCommand = targetCommand;
        self.successCommand = successCommand;
        self.errorCommand = errorCommand;
        self.cancelOnCancel = cancelOnCancel;
        self.forwardTargetError = forwardTargetError;
    }

    return self;
}

- (void)execute {
    [super execute];
    self.targetError = nil;
    self.currentCommand = self.targetCommand;
    self.currentCommand.delegate = self;
    [self.currentCommand execute];
}

- (void)cancel {
    self.currentCommand.delegate = nil;
    [self.currentCommand cancel];
    [super cancel];
}

- (void)command:(FLCommand *)command didExecuteWithError:(NSError *)error {
    self.currentCommand = nil;
    command.delegate = nil;

    if (command == self.targetCommand) {
        self.targetError = error;
        self.currentCommand = error ? self.errorCommand : self.successCommand;
        if (self.currentCommand) {
            self.currentCommand.delegate = self;
            [self.currentCommand execute];
        } else {
            [self didExecuteWithError:error];
        }
    } else {
        [self didExecuteWithError:self.forwardTargetError ? self.targetError : error];
    }
}

- (void)commandCancelled:(FLCommand *)command {
    self.currentCommand = nil;
    command.delegate = nil;

    if (self.cancelOnCancel)
        [self cancel];
    else
        [self didExecute];
}

@end
