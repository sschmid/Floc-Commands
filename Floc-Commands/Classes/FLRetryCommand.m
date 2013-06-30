//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLRetryCommand.h"

@interface FLRetryCommand ()
@property(nonatomic, strong) FLCommand *command;
@property(nonatomic, readwrite) NSUInteger retryCount;
@property(nonatomic) NSUInteger didRetryCount;
@property(nonatomic) BOOL didCommandCancel;
@end

@implementation FLRetryCommand

- (id)init {
    self = [self initWithCommand:nil retry:0];
    return self;
}

- (id)initWithCommand:(FLCommand *)command retry:(NSUInteger)retryCount {
    self = [super init];
    if (self) {
        if (!command)
            [[NSException exceptionWithName:[NSString stringWithFormat:@"%@Exception", [self class]]
                                     reason:@"Command must not be nil!"
                                   userInfo:nil] raise];

        self.command = command;
        self.retryCount = retryCount;
    }

    return self;
}

- (void)execute {
    [super execute];
    self.didRetryCount = 0;
    self.didCommandCancel = NO;
    self.command.delegate = self;
    [self.command execute];
}

- (void)cancel {
    if (!self.didCommandCancel) {
        self.didCommandCancel = YES;
        self.command.delegate = nil;
        [self.command cancel];
    }
    [super cancel];
}

- (void)command:(FLCommand *)command didExecuteWithError:(NSError *)error {
    if (error && self.didRetryCount < self.retryCount) {
        self.didRetryCount++;
        [command execute];
    } else {
        command.delegate = nil;
        [self didExecuteWithError:error];
    }
}

- (void)commandCancelled:(FLCommand *)command {
    self.didCommandCancel = YES;
    [self cancel];
}

@end