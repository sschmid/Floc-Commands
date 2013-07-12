//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "Kiwi.h"
#import "FLDelayCommand.h"
#import "DelayCommand.h"

SPEC_BEGIN(FLDelayCommandSpec)

        describe(@"FLDelayCommandSpec Tests", ^{

            it(@"instantiates FLDelayCommand", ^{
                DelayCommand *command = [[DelayCommand alloc] init];
                [[command should] beKindOfClass:[FLDelayCommand class]];
                [[command should] beKindOfClass:[FLCommand class]];
            });
            
            it(@"finishes execution after a delay", ^{
                DelayCommand *command = [[DelayCommand alloc] initWithDelay:0.5];
                [command execute];
                [[expectFutureValue(theValue(command.isInDidExecuteWithoutErrorState)) shouldEventually] beYes];
            });

        });

SPEC_END