//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "BatmanTheme.h"
#import "FLBlockCommand.h"
#import "FLRepeatCommand.h"
#import "FLSequenceCommand.h"

@interface BatmanTheme ()
@property(nonatomic, strong) FLSequenceCommand *theme;
@end

@implementation BatmanTheme

- (id)init {
    self = [super init];
    if (self) {

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

    return self;
}


@end