//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "BatmanTheme.h"
#import "FLCommand+Floc.h"
#import "FLCommand+KeepAlive.h"
#import "FLBlockCommand.h"
#import "FLRepeatCommand.h"
#import "FLSequenceCommand.h"
#import "FLInterceptionCommand+Floc.h"
#import "FLMasterSlaveCommand+Floc.h"
#import "FLSequenceCommand+Floc.h"
#import "FLRetryCommand.h"

@interface BatmanTheme ()
@property(nonatomic, strong) FLCommand *theme;
@end

@implementation BatmanTheme

- (id)init {
    self = [super init];
    if (self) {
        [self withoutFluentAPI];
        [self withFluentAPI];
    }

    return self;
}

- (void)withoutFluentAPI {
    NSMutableArray *sequenceCommands = [[NSMutableArray alloc] initWithObjects:[[FLBlockCommand alloc] initWithBlock:^(FLBlockCommand *command) {
        NSLog(@"    Jocker: Ha! Batman, come here and fight me!");
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:1];
    }], [[FLBlockCommand alloc] initWithBlock:^(FLBlockCommand *command) {
        NSLog(@"    Batman: Ok!");
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:1];
    }], [[FLBlockCommand alloc] initWithBlock:^(FLBlockCommand *command) {
        NSLog(@"            ZOOM!");
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.2];
    }], [[FLBlockCommand alloc] initWithBlock:^(FLBlockCommand *command) {
        NSLog(@"     ZACK!");
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.2];
    }], [[FLBlockCommand alloc] initWithBlock:^(FLBlockCommand *command) {
        NSLog(@"                     POW!");
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.2];
    }], nil];

    FLBlockCommand *jockerHits = [[FLBlockCommand alloc] initWithBlock:^(FLBlockCommand *command) {
        NSLog(@"    ... (Jocker tries to hit batman)");
        NSError *error = [NSError errorWithDomain:@"Jocker missed..." code:0 userInfo:nil];
        [command performSelector:@selector(didExecuteWithError:) withObject:error afterDelay:1];
    }];

    [sequenceCommands addObject:[[FLRetryCommand alloc] initWithCommand:jockerHits retry:1]];
    FLSequenceCommand *sequenceCommand = [[FLSequenceCommand alloc] initWithCommands:sequenceCommands stopOnError:YES cancelOnCancel:NO];

    FLInterceptionCommand *interceptionCommand = [[FLInterceptionCommand alloc] initWithTarget:sequenceCommand success:[[FLBlockCommand alloc] initWithBlock:^(FLBlockCommand *command) {
        NSLog(@"    Batman: Ouch!");
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.2];
    }] error:[[FLBlockCommand alloc] initWithBlock:^(FLBlockCommand *command) {
        NSLog(@"    Batman: Ha! You missed");
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.2];
    }]];

    FLBlockCommand *na = [[FLBlockCommand alloc] initWithBlock:^(FLBlockCommand *command) {
        NSLog(@"na");
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.2];
    }];

    FLRepeatCommand *nanana = [[FLRepeatCommand alloc] initWithCommand:na repeat:16];

    FLBlockCommand *batman = [[FLBlockCommand alloc] initWithBlock:^(FLBlockCommand *command) {
        NSLog(@"Batman!");
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.2];
    }];

    FLSequenceCommand *theme = [[FLSequenceCommand alloc] initWithCommands:@[nanana, batman]];
    FLRepeatCommand *loopingTheme = [[FLRepeatCommand alloc] initWithCommand:theme repeat:-1];

    self.theme = [[FLMasterSlaveCommand alloc] initWithMaster:interceptionCommand slave:loopingTheme];
    [self.theme execute];
}

- (void)withFluentAPI {
    FLSQ(FLBC(^(FLBlockCommand *command) {
        NSLog(@"    Jocker: Ha! Batman, come here and fight me!");
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:1];
    }), FLBC(^(FLBlockCommand *command) {
        NSLog(@"    Batman: Ok!");
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:1];
    }), FLBC(^(FLBlockCommand *command) {
        NSLog(@"            ZOOM!");
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.2];
    }), FLBC(^(FLBlockCommand *command) {
        NSLog(@"     ZACK!");
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.2];
    }), FLBC(^(FLBlockCommand *command) {
        NSLog(@"                     POW!");
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.2];
    }), FLBC(^(FLBlockCommand *command) {
        NSLog(@"    ... (Jocker tries to hit batman)");
        NSError *error = [NSError errorWithDomain:@"Jocker missed..." code:0 userInfo:nil];
        [command performSelector:@selector(didExecuteWithError:) withObject:error afterDelay:1];
    }).retry(1)).stopsOnError(YES).intercept(FLBC(^(FLBlockCommand *command) {
        NSLog(@"    Batman: Ouch!");
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.2];
    }), FLBC(^(FLBlockCommand *command) {
        NSLog(@"    Batman: Ha! You missed");
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.2];
    })).slave(FLBC(^(FLBlockCommand *command) {
        NSLog(@"na");
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.2];
    }).repeat(16).flseq(FLBC(^(FLBlockCommand *command) {
        NSLog(@"Batman!");
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.2];
    })).repeat(-1)).keepAlive.execute;
}

@end