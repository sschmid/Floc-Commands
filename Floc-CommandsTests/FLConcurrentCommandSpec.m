//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "Kiwi.h"
#import "FLConcurrentCommand.h"
#import "ConcurrentCommand.h"
#import "AsyncCommandDelegate.h"
#import "Command.h"
#import "AsyncCommand.h"

SPEC_BEGIN(FLConcurrentCommandSpec)

        describe(@"FLConcurrentCommandSpec Tests", ^{

            context(@"when instantiated with no commands", ^{

                __block ConcurrentCommand *command;
                __block AsyncCommandDelegate *delegate;
                beforeEach(^{
                    command = [[ConcurrentCommand alloc] init];
                    delegate = [[AsyncCommandDelegate alloc] init];
                    command.delegate = delegate;
                });

                it(@"instantiates FLConcurrentCommand", ^{
                    [[command should] beKindOfClass:[FLCommand class]];
                    [[command should] beKindOfClass:[FLAsyncCommand class]];
                    [[command should] beKindOfClass:[FLConcurrentCommand class]];
                    [[command should] conformsToProtocol:@protocol(FLAsyncCommandDelegate)];
                });

                it(@"is in initial state", ^{
                    [[theValue(command.isInInitialState) should] beYes];
                    [[theValue(delegate.isInInitialState) should] beYes];
                    [[theValue(command.didCompleteExecutionCount) should] equal:theValue(0)];
                    [[theValue(command.didGetCancelledCount) should] equal:theValue(0)];
                });

                it(@"contains no commands", ^{
                    [command.commands shouldBeNil];
                });

                context(@"when executed", ^{

                    beforeEach(^{
                        [command execute];
                    });

                    it(@"executes immediately", ^{
                        [[theValue(command.isInDidExecuteWithoutErrorState) should] beYes];
                        [[theValue(delegate.isInDidExecuteWithoutErrorState) should] beYes];
                        [[theValue(command.didCompleteExecutionCount) should] equal:theValue(1)];
                        [[theValue(command.didGetCancelledCount) should] equal:theValue(0)];
                    });

                });

            });

            context(@"when instantiated with sync commands", ^{

                __block ConcurrentCommand *command;
                __block AsyncCommandDelegate *delegate;
                __block Command *command1;
                __block Command *command2;
                __block Command *command3;
                beforeEach(^{
                    command1 = [[Command alloc] init];
                    command2 = [[Command alloc] init];
                    command3 = [[Command alloc] init];

                    command = [[ConcurrentCommand alloc] initWithCommands:@[command1, command2, command3]];
                    delegate = [[AsyncCommandDelegate alloc] init];
                    command.delegate = delegate;
                });


                it(@"contains commands", ^{
                    [[[command.commands should] have:3] commands];
                });

                context(@"when executed", ^{

                    beforeEach(^{
                        [command execute];
                    });

                    it(@"executes immediately", ^{
                        [[theValue(command1.isInExecuteState) should] beYes];
                        [[theValue(command2.isInExecuteState) should] beYes];
                        [[theValue(command3.isInExecuteState) should] beYes];

                        [[theValue(command.isInDidExecuteWithoutErrorState) should] beYes];
                        [[theValue(delegate.isInDidExecuteWithoutErrorState) should] beYes];

                        [[theValue(command.didCompleteExecutionCount) should] equal:theValue(1)];
                        [[theValue(command.didGetCancelledCount) should] equal:theValue(0)];
                    });

                });

            });

            context(@"when instantiated with async commands", ^{

                __block ConcurrentCommand *command;
                __block AsyncCommandDelegate *delegate;
                __block AsyncCommand *command1;
                __block AsyncCommand *command2;
                __block AsyncCommand *command3;
                beforeEach(^{
                    command1 = [[AsyncCommand alloc] init];
                    command2 = [[AsyncCommand alloc] init];
                    command3 = [[AsyncCommand alloc] init];

                    command = [[ConcurrentCommand alloc] initWithCommands:@[command1, command2, command3]];
                    delegate = [[AsyncCommandDelegate alloc] init];
                    command.delegate = delegate;
                });

                context(@"when executed", ^{

                    beforeEach(^{
                        [command execute];
                    });

                    it(@"executes all commands", ^{
                        [[theValue(command1.isInExecuteState) should] beYes];
                        [[theValue(command2.isInExecuteState) should] beYes];
                        [[theValue(command3.isInExecuteState) should] beYes];
                        [[theValue(command.isInExecuteState) should] beYes];
                    });

                    it(@"completes execution", ^{
                        [[expectFutureValue(theValue(command1.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command2.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command3.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(delegate.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.didCompleteExecutionCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(command.didGetCancelledCount)) shouldEventually] equal:theValue(0)];
                    });

                    context(@"when cancelled", ^{

                        beforeEach(^{
                            [command cancel];
                        });

                        it(@"is in cancelled state", ^{
                            [[theValue(command1.isInCancelledState) should] beYes];
                            [[theValue(command2.isInCancelledState) should] beYes];
                            [[theValue(command3.isInCancelledState) should] beYes];
                            [[theValue(command.isInCancelledState) should] beYes];
                            [[theValue(delegate.isInCancelledState) should] beYes];
                            [[theValue(command.didCompleteExecutionCount) should] equal:theValue(0)];
                            [[theValue(command.didGetCancelledCount) should] equal:theValue(1)];
                        });

                        it(@"cancels execution", ^{
                            [[expectFutureValue(theValue(command1.isInCancelledState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(command2.isInCancelledState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(command3.isInCancelledState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(delegate.isInCancelledState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(command.didCompleteExecutionCount)) shouldEventually] equal:theValue(0)];
                            [[expectFutureValue(theValue(command.didGetCancelledCount)) shouldEventually] equal:theValue(1)];
                        });
                    });

                    context(@"when cancelled multiple times", ^{

                        beforeEach(^{
                            [command cancel];
                            [command cancel];
                        });

                        it(@"gets cancelled only once", ^{
                            [[theValue(command1.isInCancelledState) should] beYes];
                            [[theValue(command2.isInCancelledState) should] beYes];
                            [[theValue(command3.isInCancelledState) should] beYes];
                            [[theValue(command.isInCancelledState) should] beYes];
                            [[theValue(delegate.isInCancelledState) should] beYes];

                            [[theValue(command1.didGetCancelledCount) should] equal:theValue(1)];
                            [[theValue(command2.didGetCancelledCount) should] equal:theValue(1)];
                            [[theValue(command3.didGetCancelledCount) should] equal:theValue(1)];

                            [[theValue(command.didCompleteExecutionCount) should] equal:theValue(0)];
                            [[theValue(command.didGetCancelledCount) should] equal:theValue(2)];
                        });

                    });

                });

                context(@"when executed multiple times", ^{

                    it(@"executes all commands multiple times", ^{
                        [command execute];
                        [[theValue(command1.isInExecuteState) should] beYes];
                        [[theValue(command2.isInExecuteState) should] beYes];
                        [[theValue(command3.isInExecuteState) should] beYes];
                        [[theValue(command.isInExecuteState) should] beYes];

                        [[expectFutureValue(theValue(command1.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command2.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command3.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(delegate.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];

                        [[expectFutureValue(theValue(command1.didCompleteExecutionCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(command2.didCompleteExecutionCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(command3.didCompleteExecutionCount)) shouldEventually] equal:theValue(1)];

                        [command execute];
                        [[theValue(command1.isInExecuteState) should] beYes];
                        [[theValue(command2.isInExecuteState) should] beYes];
                        [[theValue(command3.isInExecuteState) should] beYes];
                        [[theValue(command.isInExecuteState) should] beYes];

                        [[expectFutureValue(theValue(command1.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command2.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command3.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(delegate.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];

                        [[expectFutureValue(theValue(command1.didCompleteExecutionCount)) shouldEventually] equal:theValue(2)];
                        [[expectFutureValue(theValue(command2.didCompleteExecutionCount)) shouldEventually] equal:theValue(2)];
                        [[expectFutureValue(theValue(command3.didCompleteExecutionCount)) shouldEventually] equal:theValue(2)];

                        [[expectFutureValue(theValue(command.didCompleteExecutionCount)) shouldEventually] equal:theValue(2)];
                        [[expectFutureValue(theValue(command.didGetCancelledCount)) shouldEventually] equal:theValue(0)];
                    });

                });

            });

            context(@"when instantiated with a failing command and stopOnError is set to NO", ^{

                __block ConcurrentCommand *command;
                __block AsyncCommandDelegate *delegate;
                __block AsyncCommand *command1;
                __block AsyncCommand *command2;
                __block AsyncCommand *command3;
                beforeEach(^{
                    command1 = [[AsyncCommand alloc] init];
                    command2 = [[AsyncCommand alloc] init];
                    command3 = [[AsyncCommand alloc] init];

                    command1.executeWithError = YES;

                    command1.delay = 0.1;
                    command2.delay = 0.2;
                    command3.delay = 0.3;

                    command = [[ConcurrentCommand alloc] initWithCommands:@[command1, command2, command3] stopOnError:NO cancelOnCancel:NO];
                    delegate = [[AsyncCommandDelegate alloc] init];
                    command.delegate = delegate;
                    [command execute];
                });

                it(@"executes all commands", ^{
                    [[theValue(command1.isInExecuteState) should] beYes];
                    [[theValue(command2.isInExecuteState) should] beYes];
                    [[theValue(command3.isInExecuteState) should] beYes];
                    [[theValue(command.isInExecuteState) should] beYes];
                });

                it(@"executes all commands", ^{
                    [[expectFutureValue(theValue(command1.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command2.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command3.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(delegate.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];

                    [[expectFutureValue(theValue(command.didCompleteExecutionCount)) shouldEventually] equal:theValue(1)];
                    [[expectFutureValue(theValue(command.didGetCancelledCount)) shouldEventually] equal:theValue(0)];
                });

            });
            context(@"when instantiated with a failing command and stopOnError is set to YES", ^{

                __block ConcurrentCommand *command;
                __block AsyncCommandDelegate *delegate;
                __block AsyncCommand *command1;
                __block AsyncCommand *command2;
                __block AsyncCommand *command3;
                beforeEach(^{
                    command1 = [[AsyncCommand alloc] init];
                    command2 = [[AsyncCommand alloc] init];
                    command3 = [[AsyncCommand alloc] init];

                    command1.executeWithError = YES;

                    command1.delay = 0.1;
                    command2.delay = 0.2;
                    command3.delay = 0.3;

                    command = [[ConcurrentCommand alloc] initWithCommands:@[command1, command2, command3] stopOnError:YES cancelOnCancel:NO];
                    delegate = [[AsyncCommandDelegate alloc] init];
                    command.delegate = delegate;
                    [command execute];
                });

                it(@"executes all commands", ^{
                    [[theValue(command1.isInExecuteState) should] beYes];
                    [[theValue(command2.isInExecuteState) should] beYes];
                    [[theValue(command3.isInExecuteState) should] beYes];
                    [[theValue(command.isInExecuteState) should] beYes];
                });

                it(@"executes all commands until one executes with error", ^{
                    [[expectFutureValue(theValue(command1.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command2.isInCancelledState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command3.isInCancelledState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(delegate.isInDidExecuteWithErrorState)) shouldEventually] beYes];

                    [[expectFutureValue(theValue(command.didCompleteExecutionCount)) shouldEventually] equal:theValue(1)];
                    [[expectFutureValue(theValue(command.didGetCancelledCount)) shouldEventually] equal:theValue(0)];
                });

            });

            context(@"when instantiated with a cancelling command and cancelOnCancel is set to NO", ^{

                __block ConcurrentCommand *command;
                __block AsyncCommandDelegate *delegate;
                __block AsyncCommand *command1;
                __block AsyncCommand *command2;
                __block AsyncCommand *command3;
                beforeEach(^{
                    command1 = [[AsyncCommand alloc] init];
                    command2 = [[AsyncCommand alloc] init];
                    command3 = [[AsyncCommand alloc] init];

                    command2.executeAndCancel = YES;

                    command = [[ConcurrentCommand alloc] initWithCommands:@[command1, command2, command3] stopOnError:NO cancelOnCancel:NO];
                    delegate = [[AsyncCommandDelegate alloc] init];
                    command.delegate = delegate;
                    [command execute];
                });

                it(@"executes all commands", ^{
                    [[theValue(command1.isInExecuteState) should] beYes];
                    [[theValue(command2.isInExecuteState) should] beYes];
                    [[theValue(command3.isInExecuteState) should] beYes];
                    [[theValue(command.isInExecuteState) should] beYes];
                });

                it(@"executes all commands", ^{
                    [[expectFutureValue(theValue(command1.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command2.isInCancelledState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command3.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(delegate.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];

                    [[expectFutureValue(theValue(command.didCompleteExecutionCount)) shouldEventually] equal:theValue(1)];
                    [[expectFutureValue(theValue(command.didGetCancelledCount)) shouldEventually] equal:theValue(0)];
                });

            });

            context(@"when instantiated with a cancelling command and cancelOnCancel is set to YES", ^{

                __block ConcurrentCommand *command;
                __block AsyncCommandDelegate *delegate;
                __block AsyncCommand *command1;
                __block AsyncCommand *command2;
                __block AsyncCommand *command3;
                beforeEach(^{
                    command1 = [[AsyncCommand alloc] init];
                    command2 = [[AsyncCommand alloc] init];
                    command3 = [[AsyncCommand alloc] init];

                    command2.executeAndCancel = YES;

                    command = [[ConcurrentCommand alloc] initWithCommands:@[command1, command2, command3] stopOnError:NO cancelOnCancel:YES];
                    delegate = [[AsyncCommandDelegate alloc] init];
                    command.delegate = delegate;
                    [command execute];
                });

                it(@"executes all commands", ^{
                    [[theValue(command1.isInExecuteState) should] beYes];
                    [[theValue(command2.isInExecuteState) should] beYes];
                    [[theValue(command3.isInExecuteState) should] beYes];
                    [[theValue(command.isInExecuteState) should] beYes];
                });

                it(@"executes all commands until one cancels", ^{
                    [[expectFutureValue(theValue(command1.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command2.isInCancelledState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command3.isInCancelledState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(delegate.isInCancelledState)) shouldEventually] beYes];

                    [[expectFutureValue(theValue(command.didCompleteExecutionCount)) shouldEventually] equal:theValue(0)];
                    [[expectFutureValue(theValue(command.didGetCancelledCount)) shouldEventually] equal:theValue(1)];
                });

            });

        });

SPEC_END