//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLAsyncCommand.h"

@interface AsyncCommand : FLAsyncCommand
@property (nonatomic) float delay;
@property (nonatomic) BOOL executeWithError;
@property (nonatomic) BOOL executeAndCancel;
@property(nonatomic) int didCompleteExecutionCount;
@property(nonatomic) int didGetCancelledCount;

- (BOOL)isInInitialState;
- (BOOL)isInExecuteState;
- (BOOL)isInDidExecuteWithoutErrorState;
- (BOOL)isInDidExecuteWithErrorState;
- (BOOL)isInCancelledState;
@end