//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLDelayCommand.h"

@interface DelayCommand : FLDelayCommand
@property(nonatomic) int willExecuteCount;
@property(nonatomic) int didExecuteCount;
@property(nonatomic) int didCancelCount;

- (BOOL)isInInitialState;
- (BOOL)isInExecuteState;
- (BOOL)isInDidExecuteWithoutErrorState;
- (BOOL)isInDidExecuteWithErrorState;
- (BOOL)isInCancelledState;
@end