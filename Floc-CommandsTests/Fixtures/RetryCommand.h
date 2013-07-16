//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLInterceptionCommand.h"
#import "FLRetryCommand.h"

@interface RetryCommand : FLRetryCommand
@property(nonatomic) int willExecuteCount;
@property(nonatomic) int didExecuteCount;
@property(nonatomic) int didCancelCount;
@property(nonatomic) float cancelDelay;

- (BOOL)isInInitialState;
- (BOOL)isInExecuteState;
- (BOOL)isInDidExecuteWithoutErrorState;
- (BOOL)isInDidExecuteWithErrorState;
- (BOOL)isInCancelledState;
@end
