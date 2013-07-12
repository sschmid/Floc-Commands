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
#import "FLInterceptionCommand.h"
#import "FLMasterSlaveCommand.h"
#import "MasterSlaveCommand.h"
#import "ParallelCommand.h"
#import "FLBlockCommand.h"
#import "FLSequenceCommand.h"

SPEC_BEGIN(FlocCommandsAdditions)

        describe(@"FlocCommandsAdditions Tests", ^{

            it(@"has a bunch of macros", ^{
                FLCommand *cmd = [[FLCommand alloc] init];
                NSArray *cmds = @[cmd];

                FLBC(^(FLBlockCommand *command) {});
                FLIC(cmd, cmd, cmd);
                FLICO(cmd, cmd, cmd, NO, NO);
                FLMSC(cmd, cmd);
                FLMSCO(cmd, cmd, NO);
                FLPL(cmds);
                FLPLO(cmds, NO, NO);
                FLRP(cmd, NO);
                FLRT(cmd, NO);
                FLSQ(cmds);
                FLSQO(cmds, NO, NO);
            });

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

                [[command.flpar(command2, command3) should] beKindOfClass:[FLParallelCommand class]];
                [command.flpar(command2, command3) execute];

                [[theValue(command.isInExecuteState) should] beYes];
                [[theValue(command2.isInExecuteState) should] beYes];
                [[theValue(command3.isInExecuteState) should] beYes];
                [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                [[expectFutureValue(theValue(command2.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                [[expectFutureValue(theValue(command3.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
            });

            it(@"executes parallel with options", ^{
                Command *command2 = [[Command alloc] init];
                Command *command3 = [[Command alloc] init];

                [[command.flpar(command2, command3) should] beKindOfClass:[FLParallelCommand class]];
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

                [[command.flseq(command2, command3) should] beKindOfClass:[FLSequenceCommand class]];
                [command.flseq(command2, command3) execute];

                [[theValue(command.isInExecuteState) should] beYes];
                [[theValue(command2.isInExecuteState) should] beNo];
                [[theValue(command3.isInExecuteState) should] beNo];
                [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                [[expectFutureValue(theValue(command2.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                [[expectFutureValue(theValue(command3.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
            });

            it(@"intercepts on success", ^{
                Command *success = [[Command alloc] init];
                Command *error = [[Command alloc] init];

                [[command.intercept(success, error) should] beKindOfClass:[FLInterceptionCommand class]];
                [command.intercept(success, error) execute];
                [[theValue(command.isInExecuteState) should] beYes];
                [[theValue(success.isInExecuteState) should] beNo];
                [[theValue(error.isInExecuteState) should] beNo];
                [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                [[expectFutureValue(theValue(success.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                [[expectFutureValue(theValue(error.isInDidExecuteWithoutErrorState)) shouldEventually] beNo];
            });

            it(@"intercepts on error", ^{
                Command *success = [[Command alloc] init];
                Command *error = [[Command alloc] init];
                command.executeWithError = YES;

                [[command.intercept(success, error) should] beKindOfClass:[FLInterceptionCommand class]];
                [command.intercept(success, error) execute];
                [[theValue(command.isInExecuteState) should] beYes];
                [[theValue(success.isInExecuteState) should] beNo];
                [[theValue(error.isInExecuteState) should] beNo];
                [[expectFutureValue(theValue(command.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                [[expectFutureValue(theValue(success.isInDidExecuteWithoutErrorState)) shouldEventually] beNo];
                [[expectFutureValue(theValue(error.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
            });

            it(@"master-slaves", ^{
                Command *slave = [[Command alloc] init];
                slave.didExecuteDelay = 1;

                [[command.slave(slave) should] beKindOfClass:[FLMasterSlaveCommand class]];
                [command.slave(slave) execute];

                [[theValue(command.isInExecuteState) should] beYes];
                [[theValue(slave.isInExecuteState) should] beYes];
                [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                [[expectFutureValue(theValue(slave.isInCancelledState)) shouldEventually] beYes];
            });

        });

        SPEC_END