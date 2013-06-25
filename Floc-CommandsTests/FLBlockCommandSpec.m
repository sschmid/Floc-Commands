//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "Kiwi.h"
#import "FLBlockCommand.h"

SPEC_BEGIN(FLBlockCommandSpec)

        describe(@"FLBlockCommandSpec Tests", ^{

            __block FLBlockCommand *command;

            context(@"when initialized without a block", ^{

                it(@"raises an exception", ^{
                    [[theBlock(^{
                        [[FLBlockCommand alloc] init];
                    }) should] raise];
                });

            });

            context(@"when initialized with block", ^{

                __block BOOL blockDidExecute = NO;
                beforeEach(^{
                    command = [[FLBlockCommand alloc] initWithBlock:^(FLBlockCommand *blockCommand) {
                        blockDidExecute = YES;
                        [command didExecute];
                    }];
                });

                it(@"instantiates FLBlockCommand", ^{
                    [[command should] beKindOfClass:[FLBlockCommand class]];
                    [[command should] beKindOfClass:[FLCommand class]];
                    [[theValue(blockDidExecute) should] beNo];
                });

                context(@"when executed", ^{

                   it(@"executes block", ^{
                       [command execute];
                       [[theValue(blockDidExecute) should] beYes];
                   });

                });

            });

        });

SPEC_END