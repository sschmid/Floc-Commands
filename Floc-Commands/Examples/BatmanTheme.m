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

@interface BatmanTheme ()
@property(nonatomic, strong) FLCommand *theme;
@end

@implementation BatmanTheme

- (id)init {
    self = [super init];
    if (self) {

        //[self theLongWay];
        [self theFLWay];

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
    FLBC(^(FLBlockCommand *command) {
        NSLog(@"    Jocker: Ha! Batman, come here and fight me!");
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:1];
    }).flseq(FLBC(^(FLBlockCommand *command) {
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
    })).then(FLBC(^(FLBlockCommand *command) {
        NSLog(@"    ... (Jocker tries to hit batman)");
        NSError *error = [NSError errorWithDomain:@"Jocker missed..." code:0 userInfo:nil];
        [command performSelector:@selector(didExecuteWithError:) withObject:error afterDelay:2];
    }).retry(1)).intercept(FLBC(^(FLBlockCommand *command) {
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