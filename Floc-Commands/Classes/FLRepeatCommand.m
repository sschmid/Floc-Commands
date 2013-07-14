//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLRepeatCommand.h"

@interface FLRepeatCommand ()
@property(nonatomic, strong, readwrite) FLCommand *command;
@property(nonatomic, readwrite) NSInteger repeatCount;
@property(nonatomic) NSInteger didRepeatCount;
@property(nonatomic) BOOL didCommandCancel;
@end

@implementation FLRepeatCommand
- (id)init {
    self = [self initWithCommand:nil repeat:0];
    return self;
}

- (id)initWithCommand:(FLCommand *)command repeat:(NSInteger)repeatCount {
    self = [super init];
    if (self) {
        if (!command)
            [[NSException exceptionWithName:[NSString stringWithFormat:@"%@Exception", [self class]]
                                     reason:@"Command must not be nil!"
                                   userInfo:nil] raise];

        self.command = command;
        self.repeatCount = repeatCount;
    }

    return self;
}

- (void)execute {
    [super execute];
    self.didRepeatCount = 0;
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
    if (!error && (self.repeatCount == -1 || self.didRepeatCount < self.repeatCount)) {
        self.didRepeatCount++;
        [self.command execute];
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