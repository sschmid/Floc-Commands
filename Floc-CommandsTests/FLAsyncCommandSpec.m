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
                __block AsyncCommandDelegate *delegate;
                beforeEach(^{
                    command = [[AsyncCommand alloc] init];
                    delegate = [[AsyncCommandDelegate alloc] init];
                    command.delegate = delegate;
                });

                it(@"instantiates FLAsyncCommand", ^{
                    [[command should] beKindOfClass:[FLCommand class]];
                    [[command should] beKindOfClass:[FLAsyncCommand class]];
                });

                it(@"is in initial state", ^{
                    [[theValue(command.isInInitialState) should] beYes];
                    [[theValue(delegate.isInInitialState) should] beYes];
                });

                context(@"when executed without an error", ^{

                    beforeEach(^{
                        command.executeWithError = NO;
                        [command execute];
                    });

                    it(@"is in execute state", ^{
                        [[theValue(command.isInExecuteState) should] beYes];
                    });

                    it(@"is in did execute without error state", ^{
                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(delegate.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    });

                });

                context(@"when executed with an error", ^{

                    beforeEach(^{
                        command.executeWithError = YES;
                        [command execute];
                    });

                    it(@"is in execute state", ^{
                        [[theValue(command.isInExecuteState) should] beYes];
                    });

                    it(@"is in did execute with error state", ^{
                        [[expectFutureValue(theValue(command.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(delegate.isInDidExecuteWithErrorState)) shouldEventually] beYes];
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
                    });

                    it(@"cancels execution", ^{
                        [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(delegate.isInCancelledState)) shouldEventually] beYes];
                    });

                });

            });

        });

SPEC_END
