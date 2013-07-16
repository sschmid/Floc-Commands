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
#import "DelayCommand.h"
#import "FLSequenceCommand+Floc.h"
#import "FLInterceptionCommand+Floc.h"
#import "FLMasterSlaveCommand+Floc.h"

SPEC_BEGIN(FlocCommandsAdditionsSpec)

        describe(@"FlocCommandsAdditionsSpec Tests", ^{

            it(@"has a bunch of macros", ^{
                FLCommand *cmd1 = [[FLCommand alloc] init];
                FLCommand *cmd2 = [[FLCommand alloc] init];
                FLCommand *cmd3 = [[FLCommand alloc] init];

                FLBC(^(FLBlockCommand *command) {});
                FLDLY(0.5);
                FLIC(cmd1, cmd2, cmd3);
                FLICO(NO, NO, cmd1, cmd2, cmd3);
                FLMS(cmd1, cmd2);
                FLMSO(NO, cmd1, cmd2);
                FLPL(cmd1, cmd2, cmd3);
                FLPLO(NO, NO, cmd1, cmd2, cmd3);
                FLRP(cmd1, NO);
                FLRT(cmd1, NO);
                FLSQ(cmd1, cmd2, cmd3);
                FLSQO(NO, NO, cmd1, cmd2, cmd3);
            });

            __block Command *command;
            beforeEach(^{
                command = [[Command alloc] init];
            });

            it(@"repeats command", ^{
                FLRepeatCommand *repeatCommand = command.repeat(2);
                [[repeatCommand should] beKindOfClass:[FLRepeatCommand class]];
                [[repeatCommand.command should] equal:command];
                [[theValue(repeatCommand.repeatCount) should] equal:theValue(2)];
            });

            it(@"retries command", ^{
                FLRetryCommand *retryCommand = command.retry(2);
                [[retryCommand should] beKindOfClass:[FLRetryCommand class]];
                [[retryCommand.command should] equal:command];
                [[theValue(retryCommand.retryCount) should] equal:theValue(2)];
            });

            it(@"executes parallel", ^{
                Command *command2 = [[Command alloc] init];
                Command *command3 = [[Command alloc] init];

                FLSequenceCommand *sequenceCommand = command.flpar(command2, command3);

                [[sequenceCommand should] beKindOfClass:[FLSequenceCommand class]];
                [[[sequenceCommand.commands should] have:2] commands];

                [[sequenceCommand.commands[0] should] equal:command];

                FLParallelCommand *parallelCommand = sequenceCommand.commands[1];
                [[parallelCommand should] beKindOfClass:[FLParallelCommand class]];
                [[parallelCommand.commands should] equal:@[command2, command3]];
            });

            it(@"executes parallel with options", ^{
                FLSequenceCommand *parallelCommand = command.flpar(nil).stopsOnError(YES).cancelsOnCancel(YES);
                [[parallelCommand should] beKindOfClass:[FLSequenceCommand class]];
                [[theValue(parallelCommand.stopOnError) should] beYes];
                [[theValue(parallelCommand.cancelOnCancel) should] beYes];
            });

            it(@"executes sequential", ^{
                Command *command2 = [[Command alloc] init];
                Command *command3 = [[Command alloc] init];

                FLSequenceCommand *sequenceCommand = command.flseq(command2, command3);

                [[sequenceCommand should] beKindOfClass:[FLSequenceCommand class]];
                [[[sequenceCommand.commands should] have:2] commands];

                [[sequenceCommand.commands[0] should] equal:command];

                FLSequenceCommand *seqCmd = sequenceCommand.commands[1];
                [[seqCmd should] beKindOfClass:[FLSequenceCommand class]];
                [[seqCmd.commands should] equal:@[command2, command3]];
            });

            it(@"executes sequential with options", ^{
                FLSequenceCommand *sequenceCommand = command.flseq(nil).stopsOnError(YES).cancelsOnCancel(YES);
                [[sequenceCommand should] beKindOfClass:[FLSequenceCommand class]];
                [[theValue(sequenceCommand.stopOnError) should] beYes];
                [[theValue(sequenceCommand.cancelOnCancel) should] beYes];
            });

            it(@"intercepts on success", ^{
                Command *success = [[Command alloc] init];
                Command *error = [[Command alloc] init];

                FLInterceptionCommand *interceptionCommand = command.intercept(success, error);
                [[interceptionCommand should] beKindOfClass:[FLInterceptionCommand class]];
                [[interceptionCommand.targetCommand should] equal:command];
                [[interceptionCommand.successCommand should] equal:success];
                [[interceptionCommand.errorCommand should] equal:error];
            });

            it(@"intercepts with options", ^{
                Command *success = [[Command alloc] init];
                Command *error = [[Command alloc] init];

                FLInterceptionCommand *interceptionCommand = command.intercept(success, error).cancelsOnCancel(YES).forwardsTargetError(YES);
                [[interceptionCommand should] beKindOfClass:[FLInterceptionCommand class]];
                [[theValue(interceptionCommand.cancelOnCancel) should] beYes];
                [[theValue(interceptionCommand.forwardTargetError) should] beYes];
            });

            it(@"master-slaves", ^{
                Command *slave = [[Command alloc] init];
                FLMasterSlaveCommand *masterSlaveCommand = command.slave(slave);
                [[masterSlaveCommand should] beKindOfClass:[FLMasterSlaveCommand class]];
                [[masterSlaveCommand.masterCommand should] equal:command];
                [[masterSlaveCommand.slaveCommand should] equal:slave];
            });

            it(@"master-slaves with options", ^{
                Command *slave = [[Command alloc] init];

                FLMasterSlaveCommand *masterSlaveCommand = command.slave(slave).forwardsMasterError(YES);
                [[masterSlaveCommand should] beKindOfClass:[FLMasterSlaveCommand class]];
                [[theValue(masterSlaveCommand.forwardMasterError) should] beYes];
            });

            it(@"manual AppDelegate tests", ^{
                __block BOOL manualAppDelegateTestsDidPass = NO;
                FLDLY(0.3).flseq(FLBC(^(FLBlockCommand *command) {
                    manualAppDelegateTestsDidPass = YES;
                    [command didExecute];
                })).execute;

                [[expectFutureValue(theValue(manualAppDelegateTestsDidPass)) shouldEventually] beYes];
            });

        });

        SPEC_END