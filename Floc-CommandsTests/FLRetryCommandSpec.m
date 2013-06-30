//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "Kiwi.h"
#import "Command.h"
#import "RetryCommand.h"

SPEC_BEGIN(FLRetryCommandSpec)

        describe(@"FLRetryCommandSpec Tests", ^{

            context(@"when initialized without a command", ^{

                it(@"raises exception", ^{
                    [[theBlock(^{
                        [[FLRetryCommand alloc] init];
                    }) should] raise];
                });

            });

            __block RetryCommand *command;
            __block Command *targetCommand;
            beforeEach(^{
                targetCommand = [[Command alloc] init];
            });


            context(@"when initialized with failing command", ^{

                beforeEach(^{
                    targetCommand.executeWithError = YES;
                });

                it(@"instantiates FLRetryCommand", ^{
                    command = [[RetryCommand alloc] initWithCommand:targetCommand retry:0];
                    [[command should] beKindOfClass:[FLRetryCommand class]];
                    [[command should] beKindOfClass:[FLCommand class]];
                    [[command should] conformToProtocol:@protocol(FLCommandDelegate)];
                });

                context(@"when retry count is set to 0", ^{

                    it(@"does not retry", ^{
                        command = [[RetryCommand alloc] initWithCommand:targetCommand retry:0];
                        [command execute];

                        [[expectFutureValue(theValue(command.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(targetCommand.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(targetCommand.didExecuteCount)) shouldEventually] equal:theValue(1)];
                    });

                });

                context(@"when retry count is set", ^{

                    it(@"does retry specified count", ^{
                        NSUInteger retryCount = 3;
                        command = [[RetryCommand alloc] initWithCommand:targetCommand retry:retryCount];
                        [command execute];

                        [[expectFutureValue(theValue(command.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(targetCommand.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(targetCommand.didExecuteCount)) shouldEventually] equal:theValue(retryCount + 1)];
                    });

                    context(@"when running successful after some time", ^{

                        it(@"does not retry anymore", ^{
                            NSUInteger retryCount = 3;
                            targetCommand.resetExecuteWithErrorAfterDidExecute = YES;
                            command = [[RetryCommand alloc] initWithCommand:targetCommand retry:retryCount];
                            [command execute];

                            [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(1)];
                            [[expectFutureValue(theValue(targetCommand.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(targetCommand.didExecuteCount)) shouldEventually] equal:theValue(2)];
                        });

                    });

                    context(@"when executed multiple times", ^{

                        it(@"does retry specified count", ^{
                            NSUInteger retryCount = 3;
                            command = [[RetryCommand alloc] initWithCommand:targetCommand retry:retryCount];
                            [command execute];

                            [[expectFutureValue(theValue(command.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(1)];
                            [[expectFutureValue(theValue(targetCommand.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(targetCommand.didExecuteCount)) shouldEventually] equal:theValue(retryCount + 1)];

                            [command execute];

                            [[expectFutureValue(theValue(command.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(2)];
                            [[expectFutureValue(theValue(targetCommand.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(targetCommand.didExecuteCount)) shouldEventually] equal:theValue(2 * (retryCount + 1))];
                        });

                    });

                });

            });

            context(@"when initialized with successful command", ^{

                context(@"when retry count is set", ^{

                    beforeEach(^{
                        NSUInteger retryCount = 3;
                        command = [[RetryCommand alloc] initWithCommand:targetCommand retry:retryCount];
                        [command execute];
                    });

                    it(@"does not retry", ^{
                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(targetCommand.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(targetCommand.didExecuteCount)) shouldEventually] equal:theValue(1)];
                    });

                    context(@"when executed multiple times", ^{

                        it(@"does retry specified count", ^{
                            [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(1)];
                            [[expectFutureValue(theValue(targetCommand.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(targetCommand.didExecuteCount)) shouldEventually] equal:theValue(1)];

                            [command execute];

                            [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(2)];
                            [[expectFutureValue(theValue(targetCommand.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(targetCommand.didExecuteCount)) shouldEventually] equal:theValue(2)];
                        });

                    });

                });

            });

            context(@"when initialized with cancelling command", ^{

                beforeEach(^{
                    targetCommand.executeAndCancel = YES;
                });

                context(@"when retry count is set", ^{

                    beforeEach(^{
                        NSUInteger retryCount = 3;
                        command = [[RetryCommand alloc] initWithCommand:targetCommand retry:retryCount];
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

                context(@"when retry count is set", ^{

                    beforeEach(^{
                        NSUInteger retryCount = 3;
                        command = [[RetryCommand alloc] initWithCommand:targetCommand retry:retryCount];
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

                context(@"when retry count is set", ^{

                    beforeEach(^{
                        NSUInteger retryCount = 3;
                        command = [[RetryCommand alloc] initWithCommand:targetCommand retry:retryCount];
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