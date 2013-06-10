//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLConcurrentCommand.h"

@interface ConcurrentCommand : FLConcurrentCommand
@property(nonatomic) int didCompleteExecutionCount;
@property(nonatomic) int didGetCancelledCount;
- (BOOL)isInInitialState;
- (BOOL)isInExecuteState;
- (BOOL)isInDidExecuteWithoutErrorState;
- (BOOL)isInDidExecuteWithErrorState;
- (BOOL)isInCancelledState;
@end