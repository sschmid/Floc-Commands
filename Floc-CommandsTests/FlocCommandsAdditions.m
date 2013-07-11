//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "Kiwi.h"
#import "FLCommand.h"
#import "FLCommand+Floc.h"
#import "FLRepeatCommand.h"
#import "FLRetryCommand.h"
#import "Command.h"

SPEC_BEGIN(FlocCommandsAdditions)

        describe(@"FlocCommandsAdditions Tests", ^{

            __block Command *command;
            beforeEach(^{
                command = [[Command alloc] init];
            });

            it(@"repeats command", ^{
                [[command.repeat(2) should] beKindOfClass:[FLRepeatCommand class]];
                [command.repeat(2) execute];
                [[theValue(command.willExecuteCount) should] equal:theValue(1)];
                [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(3)];
            });

            it(@"retries command", ^{
                command.executeWithError = YES;
                [[command.retry(2) should] beKindOfClass:[FLRetryCommand class]];
                [command.retry(2) execute];
                [[theValue(command.willExecuteCount) should] equal:theValue(1)];
                [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(3)];
            });

            it(@"executes parallel", ^{
                Command *command2 = [[Command alloc] init];
                Command *command3 = [[Command alloc] init];

                [command.flpar(command2, command3) execute];

                [[theValue(command.isInExecuteState) should] beYes];
                [[theValue(command2.isInExecuteState) should] beYes];
                [[theValue(command3.isInExecuteState) should] beYes];
                [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                [[expectFutureValue(theValue(command2.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                [[expectFutureValue(theValue(command3.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
            });

            it(@"executes sequential", ^{
                Command *command2 = [[Command alloc] init];
                Command *command3 = [[Command alloc] init];

                [command.flseq(command2, command3) execute];

                [[theValue(command.isInExecuteState) should] beYes];
                [[theValue(command2.isInExecuteState) should] beNo];
                [[theValue(command3.isInExecuteState) should] beNo];
                [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                [[expectFutureValue(theValue(command2.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                [[expectFutureValue(theValue(command3.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
            });

        });

        SPEC_END