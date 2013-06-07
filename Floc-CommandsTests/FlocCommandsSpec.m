//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "Kiwi.h"

SPEC_BEGIN(FlocCommandsSpec)

        describe(@"FlocCommandsSpec Tests", ^{

            it(@"fails", ^{
                id object = nil;
                [object shouldNotBeNil];
            });

            __block NSObject *object;
            beforeEach(^{
                object = [[NSObject alloc] init];
            });

            it(@"instantiates NSObject", ^{
                [[object should] beKindOfClass:[NSObject class]];
            });
            
        });

SPEC_END