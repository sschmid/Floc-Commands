//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "Kiwi.h"
#import "Command.h"
#import "MasterSlaveCommand.h"

SPEC_BEGIN(FLMasterSlaveCommandSpec)

        describe(@"FLMasterSlaveCommandSpec Tests", ^{

            context(@"when initialized without commands", ^{

                it(@"raises an exception", ^{
                    [[theBlock(^{
                        [[MasterSlaveCommand alloc] initWithMaster:nil slave:nil];
                    }) should] raise];
                });

            });

            context(@"when initialized with slave only", ^{

                it(@"raises an exception", ^{
                    [[theBlock(^{
                        [[MasterSlaveCommand alloc] initWithMaster:nil slave:[[FLCommand alloc] init]];
                    }) should] raise];
                });

            });

            context(@"when initialized with master only", ^{

                it(@"raises an exception", ^{
                    [[theBlock(^{
                        [[MasterSlaveCommand alloc] initWithMaster:[[FLCommand alloc] init] slave:nil];
                    }) should] raise];
                });

            });

            context(@"when initialized with successful master and slave", ^{

                __block Command *master;
                __block Command *slave;
                __block MasterSlaveCommand *command;
                beforeEach(^{
                    master = [[Command alloc] init];
                    slave = [[Command alloc] init];
                    command = [[MasterSlaveCommand alloc] initWithMaster:master slave:slave];
                });

                it(@"instantiates MasterSlaveCommand", ^{
                    [[command should] beKindOfClass:[MasterSlaveCommand class]];
                    [[command should] beKindOfClass:[FLMasterSlaveCommand class]];
                    [[command should] beKindOfClass:[FLCommand class]];
                    [[command should] conformToProtocol:@protocol(FLCommandDelegate)];
                });

                context(@"when master completes immediately", ^{

                    it(@"executes command and cancels slave", ^{
                        master.didExecuteDelay = 0;
                        [command execute];
                        [[theValue(master.isInDidExecuteWithoutErrorState) should] beYes];
                        [[theValue(slave.isInCancelledState) should] beYes];
                        [[theValue(command.isInDidExecuteWithoutErrorState) should] beYes];
                    });

                });

                context(@"when master completes before slave", ^{

                    it(@"executes command and cancels slave", ^{
                        master.didExecuteDelay = 0.1;
                        slave.didExecuteDelay = 0.2;
                        [command execute];
                        [[theValue(master.isInExecuteState) should] beYes];
                        [[theValue(slave.isInExecuteState) should] beYes];
                        [[theValue(command.isInExecuteState) should] beYes];
                        [[expectFutureValue(theValue(master.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(slave.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    });

                    context(@"when cancelling command before master or slave complete", ^{

                        it(@"cancels master and slave", ^{
                            command.cancelDelay = 0.1;
                            master.didExecuteDelay = 0.2;
                            slave.didExecuteDelay = 0.3;
                            [command execute];
                            [[theValue(master.isInExecuteState) should] beYes];
                            [[theValue(slave.isInExecuteState) should] beYes];
                            [[theValue(command.isInExecuteState) should] beYes];
                            [[expectFutureValue(theValue(master.isInCancelledState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(slave.isInCancelledState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(master.didCancelCount)) shouldEventually] equal:theValue(1)];
                            [[expectFutureValue(theValue(slave.didCancelCount)) shouldEventually] equal:theValue(1)];
                            [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(1)];
                        });

                    });

                });

                context(@"when master completes after slave", ^{

                    it(@"executes command and does not cancel slave", ^{
                        master.didExecuteDelay = 0.2;
                        slave.didExecuteDelay = 0.1;
                        [command execute];
                        [[theValue(master.isInExecuteState) should] beYes];
                        [[theValue(slave.isInExecuteState) should] beYes];
                        [[theValue(command.isInExecuteState) should] beYes];
                        [[expectFutureValue(theValue(master.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(slave.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    });

                    context(@"when cancelling command before master complete but after slave complete", ^{

                        it(@"cancels master and slave", ^{
                            command.cancelDelay = 0.2;
                            master.didExecuteDelay = 0.3;
                            slave.didExecuteDelay = 0.1;
                            [command execute];
                            [[theValue(master.isInExecuteState) should] beYes];
                            [[theValue(slave.isInExecuteState) should] beYes];
                            [[theValue(command.isInExecuteState) should] beYes];
                            [[expectFutureValue(theValue(master.isInCancelledState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(slave.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                            [[expectFutureValue(theValue(master.didCancelCount)) shouldEventually] equal:theValue(1)];
                            [[expectFutureValue(theValue(slave.didCancelCount)) shouldEventually] equal:theValue(0)];
                            [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(1)];
                        });

                    });

                });

            });

            context(@"when initialized with failing master", ^{

                __block Command *master;
                __block Command *slave;
                __block MasterSlaveCommand *command;
                beforeEach(^{
                    master = [[Command alloc] init];
                    master.executeWithError = YES;
                    slave = [[Command alloc] init];
                });

                context(@"when forwardMasterError is set to NO", ^{

                    beforeEach(^{
                        command = [[MasterSlaveCommand alloc] initWithMaster:master slave:slave forwardMasterError:NO];
                    });

                    it(@"does not forward master error", ^{
                        [command execute];
                        [[theValue(master.isInExecuteState) should] beYes];
                        [[theValue(slave.isInExecuteState) should] beYes];
                        [[theValue(command.isInExecuteState) should] beYes];
                        [[expectFutureValue(theValue(master.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(slave.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                    });

                });

                context(@"when forwardMasterError is set to YES", ^{

                    beforeEach(^{
                        command = [[MasterSlaveCommand alloc] initWithMaster:master slave:slave forwardMasterError:YES];
                    });

                    it(@"forwards master error", ^{
                        [command execute];
                        [[theValue(master.isInExecuteState) should] beYes];
                        [[theValue(slave.isInExecuteState) should] beYes];
                        [[theValue(command.isInExecuteState) should] beYes];
                        [[expectFutureValue(theValue(master.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(slave.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.isInDidExecuteWithErrorState)) shouldEventually] beYes];
                    });

                });

            });

            context(@"when initialized with cancelling master", ^{

                __block Command *master;
                __block Command *slave;
                __block MasterSlaveCommand *command;
                beforeEach(^{
                    master = [[Command alloc] init];
                    master.executeAndCancel = YES;
                    slave = [[Command alloc] init];
                    command = [[MasterSlaveCommand alloc] initWithMaster:master slave:slave forwardMasterError:YES];
                });

                context(@"when master cancels before slave completed", ^{

                    it(@"cancels slave and command", ^{
                        slave.didExecuteDelay = 0.3;
                        [command execute];
                        [[theValue(master.isInExecuteState) should] beYes];
                        [[theValue(slave.isInExecuteState) should] beYes];
                        [[theValue(command.isInExecuteState) should] beYes];
                        [[expectFutureValue(theValue(master.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(slave.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(master.didCancelCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(slave.didCancelCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(1)];
                    });

                });

                context(@"when master cancels after slave completed", ^{

                    it(@"does not cancels slave but command", ^{
                        master.didExecuteDelay = 0.2;
                        slave.didExecuteDelay = 0.1;
                        [command execute];
                        [[theValue(master.isInExecuteState) should] beYes];
                        [[theValue(slave.isInExecuteState) should] beYes];
                        [[theValue(command.isInExecuteState) should] beYes];
                        [[expectFutureValue(theValue(master.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(slave.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(master.didCancelCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(slave.didCancelCount)) shouldEventually] equal:theValue(0)];
                        [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(1)];
                    });

                });

            });

            context(@"when initialized with cancelling slave", ^{

                __block Command *master;
                __block Command *slave;
                __block MasterSlaveCommand *command;
                beforeEach(^{
                    master = [[Command alloc] init];
                    slave = [[Command alloc] init];
                    slave.executeAndCancel = YES;
                    command = [[MasterSlaveCommand alloc] initWithMaster:master slave:slave forwardMasterError:YES];
                });

                context(@"when slave cancels before master completed", ^{

                    it(@"cancels slave and command", ^{
                        master.didExecuteDelay = 0.3;
                        [command execute];
                        [[theValue(master.isInExecuteState) should] beYes];
                        [[theValue(slave.isInExecuteState) should] beYes];
                        [[theValue(command.isInExecuteState) should] beYes];
                        [[expectFutureValue(theValue(master.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(slave.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(master.didCancelCount)) shouldEventually] equal:theValue(0)];
                        [[expectFutureValue(theValue(slave.didCancelCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(0)];
                    });

                });

                context(@"when slave cancels after master completed", ^{

                    it(@"does not cancels slave but command", ^{
                        master.didExecuteDelay = 0.1;
                        slave.didExecuteDelay = 0.2;
                        [command execute];
                        [[theValue(master.isInExecuteState) should] beYes];
                        [[theValue(slave.isInExecuteState) should] beYes];
                        [[theValue(command.isInExecuteState) should] beYes];
                        [[expectFutureValue(theValue(master.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(slave.isInCancelledState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
                        [[expectFutureValue(theValue(master.didCancelCount)) shouldEventually] equal:theValue(0)];
                        [[expectFutureValue(theValue(slave.didCancelCount)) shouldEventually] equal:theValue(1)];
                        [[expectFutureValue(theValue(command.didCancelCount)) shouldEventually] equal:theValue(0)];
                    });

                });

            });

            context(@"when master and slave commands execute immediately", ^{

                __block Command *master;
                __block Command *slave;
                __block MasterSlaveCommand *command;
                beforeEach(^{
                    master = [[Command alloc] init];
                    slave = [[Command alloc] init];

                    master.didExecuteDelay = 0;
                    slave.didExecuteDelay = 0;

                    command = [[MasterSlaveCommand alloc] initWithMaster:master slave:slave forwardMasterError:YES];
                });

                it(@"won't crash", ^{
                    [command execute];
                });

            });

            context(@"when master and slave commands cancel immediately", ^{

                __block Command *master;
                __block Command *slave;
                __block MasterSlaveCommand *command;
                beforeEach(^{
                    master = [[Command alloc] init];
                    slave = [[Command alloc] init];

                    master.didExecuteDelay = 0;
                    slave.didExecuteDelay = 0;

                    command = [[MasterSlaveCommand alloc] initWithMaster:master slave:slave forwardMasterError:YES];
                });

                it(@"won't crash", ^{
                    [command cancel];
                });

            });

        });

SPEC_END