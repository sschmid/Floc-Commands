//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "Kiwi.h"
#import "FLAsyncCommand.h"
#import "AsyncCommand.h"
#import "AsyncCommandDelegate.h"

SPEC_BEGIN(FLAsyncCommandSpec)

        describe(@"FLAsyncCommandSpec Tests", ^{

            context(@"when instantiated", ^{

                __block AsyncCommand *command;
                beforeEach(^{
                    command = [[AsyncCommand alloc] init];
                });

                it(@"instantiates FLAsyncCommand", ^{
                    [[command should] beKindOfClass:[FLCommand class]];
                    [[command should] beKindOfClass:[FLAsyncCommand class]];
                });

                it(@"is in initial state", ^{
                    [[theValue(command.isInInitialState) should] beYes];
                });

                context(@"when executed without an error", ^{

                    beforeEach(^{
                        command.asyncResult = [[NSObject alloc] init];
                        [command execute];
                    });

                    it(@"is in execute state", ^{
                        [[theValue(command.isInExecuteState) should] beYes];
                    });

                    it(@"is in did execute without error state", ^{
                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    });

                });

                context(@"when executed with an error", ^{

                    beforeEach(^{
                        command.asyncResult = nil;
                        [command execute];
                    });

                    it(@"is in execute state", ^{
                        [[theValue(command.isInExecuteState) should] beYes];
                    });

                    it(@"is in did execute with error state", ^{
                        [[expectFutureValue(theValue(command.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                    });

                });

                context(@"when cancelled", ^{

                    beforeEach(^{
                        command.asyncResult = nil;
                        [command execute];
                        [command cancel];
                    });

                    it(@"is in cancelled state", ^{
                        [[theValue(command.isInCancelledState) should] beYes];
                    });

                    it(@"cancels execution", ^{
                        [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                    });

                });

                context(@"when delegate assigned", ^{

                    __block AsyncCommandDelegate *delegate;
                    beforeEach(^{
                        delegate = [[AsyncCommandDelegate alloc] init];
                        command.delegate = delegate;
                    });

                    it(@"is in initial state", ^{
                        [[theValue(delegate.isInInitialState) should] beYes];
                    });

                    context(@"when executed without an error", ^{

                        beforeEach(^{
                            command.asyncResult = [[NSObject alloc] init];
                            [command execute];
                        });

                        it(@"delegates completion without an error", ^{
                            [[expectFutureValue(theValue(delegate.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        });

                    });

                    context(@"when executed with an error", ^{

                        beforeEach(^{
                            command.asyncResult = nil;
                            [command execute];
                        });

                        it(@"delegates completion with an error", ^{
                            [[expectFutureValue(theValue(delegate.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                        });

                    });

                    context(@"when cancelled", ^{

                        beforeEach(^{
                            command.asyncResult = nil;
                            [command execute];
                            [command cancel];
                        });

                        it(@"delegates cancel", ^{
                            [[theValue(delegate.isInCancelState) should] beYes];
                        });

                        it(@"cancels execution", ^{
                            [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                        });

                    });

                });

            });

        });

SPEC_END
