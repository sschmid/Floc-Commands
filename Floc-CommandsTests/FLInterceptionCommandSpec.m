//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "Kiwi.h"
#import "InterceptionCommand.h"
#import "Command.h"

SPEC_BEGIN(FLInterceptionCommandSpec)

        describe(@"FLInterceptionCommandSpec Tests", ^{

            context(@"when initialized without commands", ^{

                it(@"raises an exception", ^{
                    [[theBlock(^{
                        [[InterceptionCommand alloc] initWithTarget:nil success:nil error:nil];
                    }) should] raise];
                });

            });

            context(@"when initialized with target only", ^{

                it(@"raises an exception", ^{
                    [[theBlock(^{
                        [[InterceptionCommand alloc] initWithTarget:[[Command alloc] init] success:nil error:nil];
                    }) should] raise];
                });

            });

            context(@"when initialized with successful target and no success command", ^{

                __block InterceptionCommand *command;
                __block Command *target;
                __block Command *error;
                beforeEach(^{
                    target = [[Command alloc] init];
                    error = [[Command alloc] init];
                    command = [[InterceptionCommand alloc] initWithTarget:target success:nil error:error];
                });

                it(@"instantiates FLInterceptionCommand", ^{
                    [[command should] beKindOfClass:[InterceptionCommand class]];
                    [[command should] beKindOfClass:[FLInterceptionCommand class]];
                    [[command should] beKindOfClass:[FLCommand class]];
                    [[command should] conformToProtocol:@protocol(FLCommandDelegate)];
                });

                it(@"executes command", ^{
                    [command execute];
                    [[theValue(target.isInExecuteState) should] beYes];
                    [[theValue(error.isInInitialState) should] beYes];
                    [[theValue(command.isInExecuteState) should] beYes];
                    [[expectFutureValue(theValue(target.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(error.isInInitialState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                });

            });

            context(@"when initialized with successful target and success command", ^{

                __block InterceptionCommand *command;
                __block Command *target;
                __block Command *success;
                beforeEach(^{
                    target = [[Command alloc] init];
                    success = [[Command alloc] init];
                    command = [[InterceptionCommand alloc] initWithTarget:target success:success error:nil];
                });

                it(@"executes command", ^{
                    [command execute];
                    [[theValue(target.isInExecuteState) should] beYes];
                    [[theValue(success.isInInitialState) should] beYes];
                    [[theValue(command.isInExecuteState) should] beYes];
                    [[expectFutureValue(theValue(target.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(success.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                });

                context(@"when cancelling before target completes", ^{

                    it(@"cancels target", ^{
                        [command execute];
                        [command cancel];

                        [[theValue(target.isInCancelledState) should] beYes];
                        [[theValue(success.isInInitialState) should] beYes];
                        [[theValue(command.isInCancelledState) should] beYes];
                        [[expectFutureValue(theValue(target.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(success.isInInitialState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(1)];
                    });

                });

                context(@"when cancelling after target completed", ^{

                    it(@"cancels target", ^{
                        command.cancelDelay = 1.0/50;
                        [command execute];

                        [[theValue(target.isInExecuteState) should] beYes];
                        [[theValue(success.isInInitialState) should] beYes];
                        [[theValue(command.isInExecuteState) should] beYes];
                        [[expectFutureValue(theValue(target.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(success.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(1)];
                    });

                });

            });

            context(@"when initialized with successful target and failing success", ^{

                __block InterceptionCommand *command;
                __block Command *target;
                __block Command *success;
                beforeEach(^{
                    target = [[Command alloc] init];
                    success = [[Command alloc] init];
                    success.executeWithError = YES;
                });

                it(@"executes command", ^{
                    command = [[InterceptionCommand alloc] initWithTarget:target success:success error:nil];
                    [command execute];
                    [[theValue(target.isInExecuteState) should] beYes];
                    [[theValue(success.isInInitialState) should] beYes];
                    [[theValue(command.isInExecuteState) should] beYes];
                    [[expectFutureValue(theValue(target.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(success.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                });

                it(@"forwards target error", ^{
                    command = [[InterceptionCommand alloc] initWithTarget:target success:success error:nil cancelOnCancel:NO forwardTargetError:YES];
                    [command execute];
                    [[expectFutureValue(theValue(target.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(success.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                });

            });

            context(@"when initialized with failing target and no error command", ^{

                __block InterceptionCommand *command;
                __block Command *target;
                __block Command *success;
                beforeEach(^{
                    target = [[Command alloc] init];
                    target.executeWithError = YES;
                    success = [[Command alloc] init];
                });

                context(@"when forwardTargetError is set to NO", ^{

                    beforeEach(^{
                        command = [[InterceptionCommand alloc] initWithTarget:target success:success error:nil cancelOnCancel:NO forwardTargetError:NO];
                    });

                    it(@"executes command", ^{
                        [command execute];
                        [[theValue(target.isInExecuteState) should] beYes];
                        [[theValue(success.isInInitialState) should] beYes];
                        [[theValue(command.isInExecuteState) should] beYes];
                        [[expectFutureValue(theValue(target.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(success.isInInitialState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    });

                });

            });

            context(@"when initialized with failing target and no error command", ^{

                __block InterceptionCommand *command;
                __block Command *target;
                __block Command *success;
                beforeEach(^{
                    target = [[Command alloc] init];
                    target.executeWithError = YES;
                    success = [[Command alloc] init];
                });

                context(@"when forwardTargetError is set to YES", ^{

                    beforeEach(^{
                        command = [[InterceptionCommand alloc] initWithTarget:target success:success error:nil cancelOnCancel:NO forwardTargetError:YES];
                    });

                    it(@"executes command", ^{
                        [command execute];
                        [[theValue(target.isInExecuteState) should] beYes];
                        [[theValue(success.isInInitialState) should] beYes];
                        [[theValue(command.isInExecuteState) should] beYes];
                        [[expectFutureValue(theValue(target.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(success.isInInitialState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                    });

                });

            });

            context(@"when initialized with failing target and error command", ^{

                __block InterceptionCommand *command;
                __block Command *target;
                __block Command *error;
                beforeEach(^{
                    target = [[Command alloc] init];
                    target.executeWithError = YES;
                    error = [[Command alloc] init];
                });

                it(@"executes command", ^{
                    command = [[InterceptionCommand alloc] initWithTarget:target success:nil error:error];
                    [command execute];
                    [[theValue(target.isInExecuteState) should] beYes];
                    [[theValue(error.isInInitialState) should] beYes];
                    [[theValue(command.isInExecuteState) should] beYes];
                    [[expectFutureValue(theValue(target.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(error.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                });

                context(@"when forwarding target error", ^{

                    it(@"forwards target error", ^{
                        command = [[InterceptionCommand alloc] initWithTarget:target success:nil error:error cancelOnCancel:NO forwardTargetError:YES];
                        [command execute];
                        [[theValue(target.isInExecuteState) should] beYes];
                        [[theValue(error.isInInitialState) should] beYes];
                        [[theValue(command.isInExecuteState) should] beYes];
                        [[expectFutureValue(theValue(target.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(error.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                    });

                });

            });

            context(@"when initialized with failing target and failing error command", ^{

                __block InterceptionCommand *command;
                __block Command *target;
                __block Command *error;
                beforeEach(^{
                    target = [[Command alloc] init];
                    target.executeWithError = YES;
                    error = [[Command alloc] init];
                    error.executeWithError = YES;
                    command = [[InterceptionCommand alloc] initWithTarget:target success:nil error:error];
                });

                it(@"executes command", ^{
                    [command execute];
                    [[theValue(target.isInExecuteState) should] beYes];
                    [[theValue(error.isInInitialState) should] beYes];
                    [[theValue(command.isInExecuteState) should] beYes];
                    [[expectFutureValue(theValue(target.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(error.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                });

            });

            context(@"when initialized with successful target and success command and error command", ^{

                __block InterceptionCommand *command;
                __block Command *target;
                __block Command *success;
                __block Command *error;
                beforeEach(^{
                    target = [[Command alloc] init];
                    success = [[Command alloc] init];
                    error = [[Command alloc] init];
                    command = [[InterceptionCommand alloc] initWithTarget:target success:success error:error];
                });

                it(@"executes success command", ^{
                    [command execute];
                    [[theValue(target.isInExecuteState) should] beYes];
                    [[theValue(success.isInInitialState) should] beYes];
                    [[theValue(error.isInInitialState) should] beYes];
                    [[theValue(command.isInExecuteState) should] beYes];
                    [[expectFutureValue(theValue(target.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(success.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(error.isInInitialState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                });

                context(@"when cancelled after execution", ^{

                    it(@"", ^{
                        [command execute];
                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [command cancel];

                        [[theValue(success.isInDidExecuteWithoutErrorState) should] beYes];
                        [[theValue(success.didCancelCount) should] equal:theValue(0)];
                    });

                });

            });


            context(@"when initialized with failing target and success command and error command", ^{

                __block InterceptionCommand *command;
                __block Command *target;
                __block Command *success;
                __block Command *error;
                beforeEach(^{
                    target = [[Command alloc] init];
                    target.executeWithError = YES;
                    success = [[Command alloc] init];
                    error = [[Command alloc] init];
                    command = [[InterceptionCommand alloc] initWithTarget:target success:success error:error];
                });

                it(@"executes error command", ^{
                    [command execute];
                    [[theValue(target.isInExecuteState) should] beYes];
                    [[theValue(success.isInInitialState) should] beYes];
                    [[theValue(error.isInInitialState) should] beYes];
                    [[theValue(command.isInExecuteState) should] beYes];
                    [[expectFutureValue(theValue(target.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(success.isInInitialState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(error.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                });

            });

            context(@"when initialized with cancelling target and cancelOnCancel set to NO", ^{

                __block InterceptionCommand *command;
                __block Command *target;
                __block Command *success;
                __block Command *error;
                beforeEach(^{
                    target = [[Command alloc] init];
                    target.executeAndCancel = YES;
                    success = [[Command alloc] init];
                    error = [[Command alloc] init];
                    command = [[InterceptionCommand alloc] initWithTarget:target success:success error:error cancelOnCancel:NO forwardTargetError:NO];
                });

                it(@"cancels command", ^{
                    [command execute];
                    [[theValue(target.isInExecuteState) should] beYes];
                    [[theValue(command.isInExecuteState) should] beYes];
                    [[expectFutureValue(theValue(target.isInCancelledState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(success.isInInitialState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(error.isInInitialState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                });

            });

            context(@"when initialized with cancelling target and cancelOnCancel set to YES", ^{

                __block InterceptionCommand *command;
                __block Command *target;
                __block Command *success;
                __block Command *error;
                beforeEach(^{
                    target = [[Command alloc] init];
                    target.executeAndCancel = YES;
                    success = [[Command alloc] init];
                    error = [[Command alloc] init];
                    command = [[InterceptionCommand alloc] initWithTarget:target success:success error:error cancelOnCancel:YES forwardTargetError:NO];
                });

                it(@"cancels command", ^{
                    [command execute];
                    [[theValue(target.isInExecuteState) should] beYes];
                    [[theValue(command.isInExecuteState) should] beYes];
                    [[expectFutureValue(theValue(target.isInCancelledState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(success.isInInitialState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(error.isInInitialState)) shouldEventually] beYes];
                    [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                });

            });

        });

        SPEC_END
