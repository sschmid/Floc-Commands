//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "BatmanTheme.h"
#import "FLBlockCommand.h"
#import "FLRepeatCommand.h"
#import "FLSequenceCommand.h"
#import "FLCommand+Floc.h"
#import "FLInterceptionCommand.h"
#import "FLMasterSlaveCommand.h"
#import "MasterSlaveCommand.h"
#import "ParallelCommand.h"
#import "FLRetryCommand.h"

@interface BatmanTheme ()
@property(nonatomic, strong) FLCommand *theme;
@end

@implementation BatmanTheme

- (id)init {
    self = [super init];
    if (self) {

        //[self theLongWay];
        //[self theFLWay];

    }

    return self;
}

- (void)theLongWay {
    FLBlockCommand *na = [[FLBlockCommand alloc] initWithBlock:^(FLBlockCommand *command) {
        NSLog(@"na");
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.2];
    }];

    FLBlockCommand *batman = [[FLBlockCommand alloc] initWithBlock:^(FLBlockCommand *command) {
        NSLog(@"Batman!");
        [command didExecute];
    }];

    FLRepeatCommand *nanana = [[FLRepeatCommand alloc] initWithCommand:na repeat:16];

    self.theme = [[FLSequenceCommand alloc] initWithCommands:@[nanana, batman]];
    [self.theme execute];
}

- (void)theFLWay {
    self.theme = FLBC(^(FLBlockCommand *command) {
        NSLog(@"na");
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.2];
    }).repeat(16).flseq(FLBC(^(FLBlockCommand *command) {
        NSLog(@"Batman!");
        [command didExecute];
    })).repeat(2);

    [self.theme execute];
}

@end