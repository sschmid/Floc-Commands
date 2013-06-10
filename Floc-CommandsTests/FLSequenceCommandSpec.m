//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "Kiwi.h"
#import "SequenceCommand.h"
#import "AsyncCommandDelegate.h"
#import "Command.h"

SPEC_BEGIN(FLSequenceCommandSpec)

        describe(@"FLSequenceCommandSpec Tests", ^{

            context(@"when instantiated with no commands", ^{

                __block SequenceCommand *command;
                __block AsyncCommandDelegate *delegate;
                beforeEach(^{
                    command = [[SequenceCommand alloc] init];
                    delegate = [[AsyncCommandDelegate alloc] init];
                    command.delegate = delegate;
                });

                it(@"instantiates SequenceCommand", ^{
                    [[command should] beKindOfClass:[FLCommand class]];
                    [[command should] beKindOfClass:[FLAsyncCommand class]];
                    [[command should] beKindOfClass:[FLSequenceCommand class]];
                    [[command should] conformsToProtocol:@protocol(FLAsyncCommandDelegate)];
                });

                it(@"is in initial state", ^{
                    [[theValue(command.isInInitialState) should] beYes];
                    [[theValue(delegate.isInInitialState) should] beYes];
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
                    });

                });

            });

            context(@"when instantiated with sync commands", ^{

                __block SequenceCommand *command;
                __block AsyncCommandDelegate *delegate;
                __block Command *command1;
                __block Command *command2;
                __block Command *command3;
                beforeEach(^{
                    command1 = [[Command alloc] init];
                    command2 = [[Command alloc] init];
                    command3 = [[Command alloc] init];

                    command = [[SequenceCommand alloc] initWithCommands:@[command1, command2, command3]];
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
                    });

                });

            });

            context(@"when instantiated with async commands", ^{

                __block SequenceCommand *command;
                __block AsyncCommandDelegate *delegate;
                __block AsyncCommand *command1;
                __block AsyncCommand *command2;
                __block AsyncCommand *command3;
                beforeEach(^{
                    command1 = [[AsyncCommand alloc] init];
                    command2 = [[AsyncCommand alloc] init];
                    command3 = [[AsyncCommand alloc] init];

                    command = [[SequenceCommand alloc] initWithCommands:@[command1, command2, command3]];
                    delegate = [[AsyncCommandDelegate alloc] init];
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
                    });

                    it(@"completes execution", ^{
                        [[expectFutureValue(theValue(command1.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command2.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command3.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(delegate.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
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
                        });

                        it(@"cancels execution", ^{
                            [[expectFutureValue(theValue(command1.isInCancelledState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(command2.isInInitialState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(command3.isInInitialState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(delegate.isInCancelledState)) shouldEventually] beYes];
                        });
                    });

                });

            });

            context(@"when instantiated with a failing command and stopOnError is set to NO", ^{

                __block SequenceCommand *command;
                __block AsyncCommandDelegate *delegate;
                __block AsyncCommand *command1;
                __block AsyncCommand *command2;
                __block AsyncCommand *command3;
                beforeEach(^{
                    command1 = [[AsyncCommand alloc] init];
                    command2 = [[AsyncCommand alloc] init];
                    command3 = [[AsyncCommand alloc] init];

                    command1.executeWithError = YES;

                    command = [[SequenceCommand alloc] initWithCommands:@[command1, command2, command3] stopOnError:NO cancelOnCancel:NO];
                    delegate = [[AsyncCommandDelegate alloc] init];
                    command.delegate = delegate;
                    [command execute];
                });

                it(@"executes all commands", ^{
                    [[expectFutureValue(theValue(command1.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command2.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command3.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(delegate.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                });

            });

            context(@"when instantiated with a failing command and stopOnError is set to YES", ^{

                __block SequenceCommand *command;
                __block AsyncCommandDelegate *delegate;
                __block AsyncCommand *command1;
                __block AsyncCommand *command2;
                __block AsyncCommand *command3;
                beforeEach(^{
                    command1 = [[AsyncCommand alloc] init];
                    command2 = [[AsyncCommand alloc] init];
                    command3 = [[AsyncCommand alloc] init];

                    command1.executeWithError = YES;

                    command = [[SequenceCommand alloc] initWithCommands:@[command1, command2, command3] stopOnError:YES cancelOnCancel:NO];
                    delegate = [[AsyncCommandDelegate alloc] init];
                    command.delegate = delegate;
                    [command execute];
                });

                it(@"executes all commands until one executes with error", ^{
                    [[expectFutureValue(theValue(command1.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command2.isInInitialState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command3.isInInitialState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(delegate.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                });

            });

            context(@"when instantiated with a cancelling command and cancelOnCancel is set to NO", ^{

                __block SequenceCommand *command;
                __block AsyncCommandDelegate *delegate;
                __block AsyncCommand *command1;
                __block AsyncCommand *command2;
                __block AsyncCommand *command3;
                beforeEach(^{
                    command1 = [[AsyncCommand alloc] init];
                    command2 = [[AsyncCommand alloc] init];
                    command3 = [[AsyncCommand alloc] init];

                    command2.executeAndCancel = YES;

                    command = [[SequenceCommand alloc] initWithCommands:@[command1, command2, command3] stopOnError:NO cancelOnCancel:NO];
                    delegate = [[AsyncCommandDelegate alloc] init];
                    command.delegate = delegate;
                    [command execute];
                });

                it(@"executes all commands", ^{
                    [[expectFutureValue(theValue(command1.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command2.isInCancelledState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command3.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(delegate.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                });

            });

            context(@"when instantiated with a cancelling command and cancelOnCancel is set to YES", ^{

                __block SequenceCommand *command;
                __block AsyncCommandDelegate *delegate;
                __block AsyncCommand *command1;
                __block AsyncCommand *command2;
                __block AsyncCommand *command3;
                beforeEach(^{
                    command1 = [[AsyncCommand alloc] init];
                    command2 = [[AsyncCommand alloc] init];
                    command3 = [[AsyncCommand alloc] init];

                    command2.executeAndCancel = YES;

                    command = [[SequenceCommand alloc] initWithCommands:@[command1, command2, command3] stopOnError:NO cancelOnCancel:YES];
                    delegate = [[AsyncCommandDelegate alloc] init];
                    command.delegate = delegate;
                    [command execute];
                });

                it(@"executes all commands until one cancels", ^{
                    [[expectFutureValue(theValue(command1.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command2.isInCancelledState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command3.isInInitialState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(delegate.isInCancelledState)) shouldEventually] beYes];
                });

            });

        });

SPEC_END