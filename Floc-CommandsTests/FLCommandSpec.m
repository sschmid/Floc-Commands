//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "Kiwi.h"
#import "Command.h"

SPEC_BEGIN(FLCommandSpec)

        describe(@"FLCommandSpec Tests", ^{

            context(@"when instantiated", ^{

                __block Command *command;
                beforeEach(^{
                    command = [[Command alloc] init];
                });

                it(@"instantiates Command", ^{
                    [[command should] beKindOfClass:[FLCommand class]];
                });

                it(@"is in initial state", ^{
                    [[theValue(command.isInInitialState) should] beYes];
                });

                context(@"when executed", ^{

                    beforeEach(^{
                        [command execute];
                    });

                    it(@"is in execute state", ^{
                        [[theValue(command.isInExecuteState) should] beYes];
                    });

                });

            });

        });

SPEC_END