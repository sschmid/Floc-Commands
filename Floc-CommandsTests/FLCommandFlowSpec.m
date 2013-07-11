//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "Kiwi.h"
#import "FLCommandFlow.h"
#import "CommandDelegate.h"

SPEC_BEGIN(FLCommandFlowSpec)

        describe(@"FLCommandFlowSpec Tests", ^{

            __block FLCommandFlow *flow;
            __block CommandDelegate *delegate;
            beforeEach(^{
                flow = FLCFlow;
                delegate = [[CommandDelegate alloc] init];
                flow.delegate = delegate;
            });

            it(@"instantiates FLCommandFlow", ^{
                [[flow should] beKindOfClass:[FLCommandFlow class]];
                [[flow should] beKindOfClass:[FLCommand class]];
                [[flow should] conformToProtocol:@protocol(FLCommandDelegate)];
            });

            it(@"executes sync block command", ^{
                __block BOOL didExecute = NO;

                [flow.flcmd(^(FLBlockCommand *command) {
                    didExecute = YES;
                    [command didExecute];
                }) execute];

                [[theValue(didExecute) should] beYes];
                [[theValue(delegate.isInDidExecuteWithoutErrorState) should] beYes];
            });

            it(@"executes async block command", ^{
                __block BOOL didExecute = NO;

                [flow.flcmd(^(FLBlockCommand *command) {
                    didExecute = YES;
                    [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.1];
                }) execute];

                [[theValue(didExecute) should] beYes];
                [[theValue(delegate.isInDidExecuteWithoutErrorState) should] beNo];
                [[expectFutureValue(theValue(delegate.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
            });

            it(@"executes multiple sync block commands concurrently", ^{
                __block BOOL didExecute1 = NO;
                __block BOOL didExecute2 = NO;

                [flow.flcmd(^(FLBlockCommand *command) {
                    didExecute1 = YES;
                    [command didExecute];
                }, ^(FLBlockCommand *command) {
                    didExecute2 = YES;
                    [command didExecute];
                }) execute];

                [[theValue(didExecute1) should] beYes];
                [[theValue(didExecute2) should] beYes];
                [[theValue(delegate.isInDidExecuteWithoutErrorState) should] beYes];
            });

            it(@"executes multiple async block commands concurrently", ^{
                __block BOOL didExecute1 = NO;
                __block BOOL didExecute2 = NO;

                [flow.flcmd(^(FLBlockCommand *command) {
                    didExecute1 = YES;
                    [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.1];
                }, ^(FLBlockCommand *command) {
                    didExecute2 = YES;
                    [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.1];
                }) execute];

                [[theValue(didExecute1) should] beYes];
                [[theValue(didExecute2) should] beYes];
                [[theValue(delegate.isInDidExecuteWithoutErrorState) should] beNo];
                [[expectFutureValue(theValue(delegate.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
            });

            it(@"executes commands in sequence", ^{
                __block BOOL didExecute1 = NO;
                __block BOOL didExecute2 = NO;

                [flow.flcmd(^(FLBlockCommand *command) {
                    didExecute1 = YES;
                    [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.1];
                }).flcmd(^(FLBlockCommand *command) {
                    didExecute2 = YES;
                    [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.1];
                }) execute];

                [[theValue(didExecute1) should] beYes];
                [[theValue(didExecute2) should] beNo];
                [[theValue(delegate.isInDidExecuteWithoutErrorState) should] beNo];
                [[expectFutureValue(theValue(didExecute2)) shouldEventually] beYes];
                [[expectFutureValue(theValue(delegate.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
            });

            it(@"works fine with a mix", ^{
                __block BOOL cmd1Started = NO;
                __block BOOL cmd2Started = NO;
                __block BOOL cmd3Started = NO;
                __block BOOL cmd4Started = NO;

                [flow.flcmd(^(FLBlockCommand *command) {
                    cmd1Started = YES;
                    [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.1];
                }, ^(FLBlockCommand *command) {
                    cmd2Started = YES;
                    [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.1];
                }).flcmd(^(FLBlockCommand *command) {
                    cmd3Started = YES;
                    [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.1];
                }).flcmd(^(FLBlockCommand *command) {
                    cmd4Started = YES;
                    [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.1];
                }) execute];

                [[theValue(cmd1Started) should] beYes];
                [[theValue(cmd2Started) should] beYes];
                [[theValue(cmd3Started) should] beNo];
                [[theValue(cmd4Started) should] beNo];
                [[theValue(delegate.isInDidExecuteWithoutErrorState) should] beNo];
                [[expectFutureValue(theValue(cmd3Started)) shouldEventually] beYes];
                [[expectFutureValue(theValue(cmd4Started)) shouldEventually] beYes];
                [[expectFutureValue(theValue(delegate.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
            });

            it(@"retries commands when they fail", ^{
                __block int executeCount = 0;

                [flow.flcmd(^(FLBlockCommand *command) {
                    executeCount++;
                    [command performSelector:@selector(didExecuteWithError) withObject:nil afterDelay:0.1];
                }).retry(3) execute];

                [[theValue(executeCount) should] equal:theValue(1)];
                [[expectFutureValue(theValue(executeCount)) shouldEventually] equal:theValue(3)];
            });

            it(@"does not retry commands when they do not fail", ^{
                __block int executeCount = 0;

                [flow.flcmd(^(FLBlockCommand *command) {
                    executeCount++;
                    [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.1];
                }).retry(3) execute];

                [[theValue(executeCount) should] equal:theValue(1)];
                [[expectFutureValue(theValue(executeCount)) shouldEventually] equal:theValue(1)];
            });

            it(@"does not retry when no commands", ^{
                [flow.retry(3) execute];
            });

            it(@"repeats commands", ^{
                __block int executeCount = 0;

                [flow.flcmd(^(FLBlockCommand *command) {
                    executeCount++;
                    [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.1];
                }).repeat(3) execute];

                [[theValue(executeCount) should] equal:theValue(1)];
                [[expectFutureValue(theValue(executeCount)) shouldEventually] equal:theValue(3)];
            });

            it(@"does not repeat when no commands", ^{
                [flow.repeat(3) execute];
            });

        });

SPEC_END