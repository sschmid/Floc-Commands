//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "Kiwi.h"
#import "SequenceCommand.h"
#import "CommandDelegate.h"

SPEC_BEGIN(FLSequenceCommandSpec)

        describe(@"FLSequenceCommandSpec Tests", ^{

            context(@"when instantiated with no commands", ^{

                __block SequenceCommand *command;
                __block CommandDelegate *delegate;
                beforeEach(^{
                    command = [[SequenceCommand alloc] init];
                    delegate = [[CommandDelegate alloc] init];
                    command.delegate = delegate;
                });

                it(@"instantiates SequenceCommand", ^{
                    [[command should] beKindOfClass:[SequenceCommand class]];
                    [[command should] beKindOfClass:[FLSequenceCommand class]];
                    [[command should] beKindOfClass:[FLCommand class]];
                    [[command should] conformToProtocol:@protocol(FLCommandDelegate)];
                });

                it(@"is in initial state", ^{
                    [[theValue(command.isInInitialState) should] beYes];
                    [[theValue(delegate.isInInitialState) should] beYes];
                    [[theValue(command.willExecuteCount) should] equal:theValue(0)];
                    [[theValue(command.didExecuteCount) should] equal:theValue(0)];
                    [[theValue(command.didCancelCount) should] equal:theValue(0)];
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
                        [[theValue(command.willExecuteCount) should] equal:theValue(1)];
                        [[theValue(command.didExecuteCount) should] equal:theValue(1)];
                        [[theValue(command.didCancelCount) should] equal:theValue(0)];
                    });

                });

            });

            context(@"when instantiated with commands", ^{

                __block SequenceCommand *command;
                __block CommandDelegate *delegate;
                __block Command *command1;
                __block Command *command2;
                __block Command *command3;
                beforeEach(^{
                    command1 = [[Command alloc] init];
                    command2 = [[Command alloc] init];
                    command3 = [[Command alloc] init];

                    command = [[SequenceCommand alloc] initWithCommands:@[command1, command2, command3]];
                    delegate = [[CommandDelegate alloc] init];
                    command.delegate = delegate;
                });

                context(@"when executed", ^{

                    beforeEach(^{
                        [command execute];
                    });

                    it(@"executes", ^{
                        [[theValue(command1.isInExecuteState) should] beYes];
                        [[theValue(command2.isInInitialState) should] beYes];
                        [[theValue(command3.isInInitialState) should] beYes];
                        [[theValue(command.isInExecuteState) should] beYes];

                        [[theValue(command1.willExecuteCount) should] equal:theValue(1)];
                        [[theValue(command.willExecuteCount) should] equal:theValue(1)];
                    });

                    it(@"completes execution", ^{
                        [[expectFutureValue(theValue(command1.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command2.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command3.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(delegate.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];

                        [[expectFutureValue(theValue(command.willExecuteCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(0)];
                    });

                    context(@"when cancelled", ^{

                        beforeEach(^{
                            [command cancel];
                        });

                        it(@"is in cancelled state", ^{
                            [[theValue(command1.isInCancelledState) should] beYes];
                            [[theValue(command2.isInInitialState) should] beYes];
                            [[theValue(command3.isInInitialState) should] beYes];
                            [[theValue(command.isInCancelledState) should] beYes];
                            [[theValue(delegate.isInCancelledState) should] beYes];
                            [[theValue(command.didCancelCount) should] equal:theValue(1)];

                        });

                        it(@"cancels execution", ^{
                            [[expectFutureValue(theValue(command1.isInCancelledState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(command2.isInInitialState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(command3.isInInitialState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(delegate.isInCancelledState)) shouldEventually] beYes];

                            [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(0)];
                            [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(1)];
                            [[expectFutureValue(theValue(command1.didCancelCount)) shouldEventually] equal:theValue(1)];
                        });
                    });

                });

                context(@"when executed multiple times", ^{

                    it(@"executes all commands multiple times", ^{
                        [command execute];

                        [[expectFutureValue(theValue(command1.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command2.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command3.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(delegate.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];

                        [[expectFutureValue(theValue(command.willExecuteCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(command1.didExecuteCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(command2.didExecuteCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(command3.didExecuteCount)) shouldEventually] equal:theValue(1)];

                        [command execute];
                        [[theValue(command1.isInExecuteState) should] beYes];
                        [[theValue(command2.isInDidExecuteWithoutErrorState) should] beYes];
                        [[theValue(command3.isInDidExecuteWithoutErrorState) should] beYes];
                        [[theValue(command.isInExecuteState) should] beYes];

                        [[expectFutureValue(theValue(command1.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command2.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command3.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(delegate.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];

                        [[expectFutureValue(theValue(command1.didExecuteCount)) shouldEventually] equal:theValue(2)];
                        [[expectFutureValue(theValue(command2.didExecuteCount)) shouldEventually] equal:theValue(2)];
                        [[expectFutureValue(theValue(command3.didExecuteCount)) shouldEventually] equal:theValue(2)];

                        [[expectFutureValue(theValue(command.willExecuteCount)) shouldEventually] equal:theValue(2)];
                        [[expectFutureValue(theValue(command1.willExecuteCount)) shouldEventually] equal:theValue(2)];
                        [[expectFutureValue(theValue(command2.willExecuteCount)) shouldEventually] equal:theValue(2)];
                        [[expectFutureValue(theValue(command3.willExecuteCount)) shouldEventually] equal:theValue(2)];

                        [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(2)];
                        [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(0)];
                    });

                });

            });

            context(@"when instantiated with a failing command and stopOnError is set to NO", ^{

                __block SequenceCommand *command;
                __block CommandDelegate *delegate;
                __block Command *command1;
                __block Command *command2;
                __block Command *command3;
                beforeEach(^{
                    command1 = [[Command alloc] init];
                    command2 = [[Command alloc] init];
                    command3 = [[Command alloc] init];

                    command1.executeWithError = YES;

                    command = [[SequenceCommand alloc] initWithCommands:@[command1, command2, command3] stopOnError:NO cancelOnCancel:NO];
                    delegate = [[CommandDelegate alloc] init];
                    command.delegate = delegate;
                    [command execute];
                });

                it(@"executes all commands", ^{
                    [[expectFutureValue(theValue(command1.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command2.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command3.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(delegate.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];

                    [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(1)];
                    [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(0)];
                });

            });

            context(@"when instantiated with a failing command and stopOnError is set to YES", ^{

                __block SequenceCommand *command;
                __block CommandDelegate *delegate;
                __block Command *command1;
                __block Command *command2;
                __block Command *command3;
                beforeEach(^{
                    command1 = [[Command alloc] init];
                    command2 = [[Command alloc] init];
                    command3 = [[Command alloc] init];

                    command1.executeWithError = YES;

                    command = [[SequenceCommand alloc] initWithCommands:@[command1, command2, command3] stopOnError:YES cancelOnCancel:NO];
                    delegate = [[CommandDelegate alloc] init];
                    command.delegate = delegate;
                    [command execute];
                });

                it(@"executes all commands until one executes with error", ^{
                    [[expectFutureValue(theValue(command1.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command2.isInInitialState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command3.isInInitialState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(delegate.isInDidExecuteWithErrorState)) shouldEventually] beYes];

                    [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(1)];
                    [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(0)];
                });

            });

            context(@"when instantiated with a cancelling command and cancelOnCancel is set to NO", ^{

                __block SequenceCommand *command;
                __block CommandDelegate *delegate;
                __block Command *command1;
                __block Command *command2;
                __block Command *command3;
                beforeEach(^{
                    command1 = [[Command alloc] init];
                    command2 = [[Command alloc] init];
                    command3 = [[Command alloc] init];

                    command2.executeAndCancel = YES;

                    command = [[SequenceCommand alloc] initWithCommands:@[command1, command2, command3] stopOnError:NO cancelOnCancel:NO];
                    delegate = [[CommandDelegate alloc] init];
                    command.delegate = delegate;
                    [command execute];
                });

                it(@"executes all commands", ^{
                    [[expectFutureValue(theValue(command1.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command2.isInCancelledState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command3.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(delegate.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];

                    [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(1)];
                    [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(0)];
                });

            });

            context(@"when instantiated with a cancelling command and cancelOnCancel is set to YES", ^{

                __block SequenceCommand *command;
                __block CommandDelegate *delegate;
                __block Command *command1;
                __block Command *command2;
                __block Command *command3;
                beforeEach(^{
                    command1 = [[Command alloc] init];
                    command2 = [[Command alloc] init];
                    command3 = [[Command alloc] init];

                    command2.executeAndCancel = YES;

                    command = [[SequenceCommand alloc] initWithCommands:@[command1, command2, command3] stopOnError:NO cancelOnCancel:YES];
                    delegate = [[CommandDelegate alloc] init];
                    command.delegate = delegate;
                    [command execute];
                });

                it(@"executes all commands until one cancels", ^{
                    [[expectFutureValue(theValue(command1.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command2.isInCancelledState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command3.isInInitialState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(delegate.isInCancelledState)) shouldEventually] beYes];

                    [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(0)];
                    [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(1)];
                    [[expectFutureValue(theValue(command2.didCancelCount)) shouldEventually] equal:theValue(1)];
                });

            });

        });

SPEC_END