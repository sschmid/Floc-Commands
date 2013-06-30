//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "Kiwi.h"
#import "RepeatCommand.h"
#import "Command.h"

SPEC_BEGIN(FLRepeatCommandSpec)

        describe(@"FLRepeatCommandSpec Tests", ^{

            context(@"when initialized without a command", ^{

                it(@"raises exception", ^{
                    [[theBlock(^{
                        [[RepeatCommand alloc] init];
                    }) should] raise];
                });

            });

            __block RepeatCommand *command;
            __block Command *targetCommand;
            beforeEach(^{
                targetCommand = [[Command alloc] init];
            });

            it(@"instantiates FLRepeatCommand", ^{
                command = [[RepeatCommand alloc] initWithCommand:targetCommand repeat:0];
                [[command should] beKindOfClass:[FLRepeatCommand class]];
                [[command should] beKindOfClass:[FLCommand class]];
                [[command should] conformToProtocol:@protocol(FLCommandDelegate)];
            });

            context(@"when initialized with a successful target command", ^{

                context(@"when repeat count is set to 0", ^{

                    it(@"executes command only once", ^{
                        command = [[RepeatCommand alloc] initWithCommand:targetCommand repeat:0];
                        [command execute];

                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(targetCommand.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(targetCommand.didExecuteCount)) shouldEventually] equal:theValue(1)];
                    });

                });

                context(@"when repeat count is set", ^{

                    it(@"repeats target command specified times", ^{
                        NSInteger repeatCount = 3;
                        command = [[RepeatCommand alloc] initWithCommand:targetCommand repeat:repeatCount];
                        [command execute];

                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(targetCommand.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(targetCommand.didExecuteCount)) shouldEventually] equal:theValue(repeatCount + 1)];
                    });

                    it(@"repeats target command specified times when executed multiple times", ^{
                        NSInteger repeatCount = 3;
                        command = [[RepeatCommand alloc] initWithCommand:targetCommand repeat:repeatCount];
                        [command execute];

                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(targetCommand.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(targetCommand.didExecuteCount)) shouldEventually] equal:theValue(repeatCount + 1)];

                        [command execute];

                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(2)];
                        [[expectFutureValue(theValue(targetCommand.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(targetCommand.didExecuteCount)) shouldEventually] equal:theValue(2*(repeatCount + 1))];
                    });

                });

            });

            context(@"when initialized with a failing target command", ^{

                context(@"when repeat count is set", ^{

                    it(@"repeats target command specified times", ^{
                        NSInteger repeatCount = 3;
                        targetCommand.executeWithError = YES;
                        command = [[RepeatCommand alloc] initWithCommand:targetCommand repeat:repeatCount];
                        [command execute];

                        [[expectFutureValue(theValue(command.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(targetCommand.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(targetCommand.didExecuteCount)) shouldEventually] equal:theValue(1)];
                    });

                });

            });

            context(@"when initialized with cancelling command", ^{

                context(@"when repeat count is set", ^{

                    beforeEach(^{
                        targetCommand.executeAndCancel = YES;
                        NSUInteger repeatCount = 3;
                        command = [[RepeatCommand alloc] initWithCommand:targetCommand repeat:repeatCount];
                        [command execute];
                    });

                    it(@"cancels command", ^{
                        [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(targetCommand.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(targetCommand.didCancelCount)) shouldEventually] equal:theValue(1)];
                    });

                });

            });

            context(@"when cancelled", ^{

                context(@"when repeat count is set", ^{

                    beforeEach(^{
                        NSUInteger repeatCount = 3;
                        command = [[RepeatCommand alloc] initWithCommand:targetCommand repeat:repeatCount];
                        [command execute];
                        [command cancel];
                    });

                    it(@"cancels command", ^{
                        [[theValue(command.isInCancelledState) shouldEventually] beYes];
                        [[theValue(command.didCancelCount) shouldEventually] equal:theValue(1)];
                        [[theValue(targetCommand.isInCancelledState) shouldEventually] beYes];
                        [[theValue(targetCommand.didCancelCount) shouldEventually] equal:theValue(1)];

                        [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(targetCommand.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(targetCommand.didCancelCount)) shouldEventually] equal:theValue(1)];
                    });

                });

            });

            context(@"when cancelled multiple times", ^{

                context(@"when repeat count is set", ^{

                    beforeEach(^{
                        NSUInteger repeatCount = 3;
                        command = [[RepeatCommand alloc] initWithCommand:targetCommand repeat:repeatCount];
                        [command execute];
                        [command cancel];
                        [command cancel];
                    });

                    it(@"cancels target command only once", ^{
                        [[theValue(command.isInCancelledState) shouldEventually] beYes];
                        [[theValue(command.didCancelCount) shouldEventually] equal:theValue(2)];
                        [[theValue(targetCommand.isInCancelledState) shouldEventually] beYes];
                        [[theValue(targetCommand.didCancelCount) shouldEventually] equal:theValue(1)];

                        [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(2)];
                        [[expectFutureValue(theValue(targetCommand.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(targetCommand.didCancelCount)) shouldEventually] equal:theValue(1)];
                    });

                    it(@"cancels target command when executed and cancelled again", ^{
                        [[theValue(command.isInCancelledState) shouldEventually] beYes];
                        [[theValue(command.didCancelCount) shouldEventually] equal:theValue(2)];
                        [[theValue(targetCommand.isInCancelledState) shouldEventually] beYes];
                        [[theValue(targetCommand.didCancelCount) shouldEventually] equal:theValue(1)];

                        [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(2)];
                        [[expectFutureValue(theValue(targetCommand.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(targetCommand.didCancelCount)) shouldEventually] equal:theValue(1)];

                        [command execute];
                        [command cancel];

                        [[theValue(command.isInCancelledState) shouldEventually] beYes];
                        [[theValue(command.didCancelCount) shouldEventually] equal:theValue(3)];
                        [[theValue(targetCommand.isInCancelledState) shouldEventually] beYes];
                        [[theValue(targetCommand.didCancelCount) shouldEventually] equal:theValue(2)];

                        [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(3)];
                        [[expectFutureValue(theValue(targetCommand.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(targetCommand.didCancelCount)) shouldEventually] equal:theValue(2)];
                    });

                });

            });

        });

SPEC_END