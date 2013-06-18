//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "Kiwi.h"
#import "Command.h"
#import "CommandDelegate.h"

SPEC_BEGIN(FLCommandSpec)

        describe(@"FLCommandSpec Tests", ^{

            context(@"when instantiated", ^{

                __block Command *command;
                __block CommandDelegate *delegate;
                beforeEach(^{
                    command = [[Command alloc] init];
                    delegate = [[CommandDelegate alloc] init];
                    command.delegate = delegate;
                });

                it(@"instantiates FLCommand", ^{
                    [[command should] beKindOfClass:[Command class]];
                    [[command should] beKindOfClass:[FLCommand class]];
                });

                it(@"is in initial state", ^{
                    [[theValue(command.isInInitialState) should] beYes];
                    [[theValue(delegate.isInInitialState) should] beYes];
                    [[theValue(command.willExecuteCount) should] equal:theValue(0)];
                    [[theValue(command.didExecuteCount) should] equal:theValue(0)];
                    [[theValue(command.didCancelCount) should] equal:theValue(0)];
                });

                context(@"when executed without an error", ^{

                    beforeEach(^{
                        command.executeWithError = NO;
                        [command execute];
                    });

                    it(@"is in execute state", ^{
                        [[theValue(command.isInExecuteState) should] beYes];
                        [[theValue(command.willExecuteCount) should] equal:theValue(1)];
                        [[theValue(delegate.isInExecuteState) should] beYes];
                    });

                    it(@"is in did execute without error state", ^{
                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(delegate.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(0)];
                    });

                });

                context(@"when executed with an error", ^{

                    beforeEach(^{
                        command.executeWithError = YES;
                        [command execute];
                    });

                    it(@"is in execute state", ^{
                        [[theValue(command.isInExecuteState) should] beYes];
                        [[theValue(command.willExecuteCount) should] equal:theValue(1)];
                        [[theValue(delegate.isInExecuteState) should] beYes];
                    });

                    it(@"is in did execute with error state", ^{
                        [[expectFutureValue(theValue(command.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(delegate.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(0)];
                    });

                });

                context(@"when cancelled", ^{

                    beforeEach(^{
                        command.executeWithError = NO;
                        [command execute];
                        [command cancel];
                    });

                    it(@"is in cancelled state", ^{
                        [[theValue(command.isInCancelledState) should] beYes];
                        [[theValue(delegate.isInCancelledState) should] beYes];
                        [[theValue(command.didExecuteCount) should] equal:theValue(0)];
                        [[theValue(command.didCancelCount) should] equal:theValue(1)];
                    });

                    it(@"cancels execution", ^{
                        [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(delegate.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.didExecuteCount)) shouldEventually] equal:theValue(0)];
                        [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(1)];
                    });

                });

            });

        });

SPEC_END
