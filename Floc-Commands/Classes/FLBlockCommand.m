//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "FLBlockCommand.h"

@interface FLBlockCommand ()
@property(nonatomic, copy) FLBlockCommandBlock block;
@end

@implementation FLBlockCommand

- (id)init {
    self = [self initWithBlock:nil];
    return self;
}

- (id)initWithBlock:(FLBlockCommandBlock)block {
    self = [super init];
    if (self) {
        if (!block)
            [[NSException exceptionWithName:[NSString stringWithFormat:@"%@Exception", [self class]]
                                     reason:@"Block must not be nil!"
                                   userInfo:nil] raise];

        self.block = block;
    }

    return self;
}

- (void)execute {
    [super execute];
    self.block(self);
}

@end