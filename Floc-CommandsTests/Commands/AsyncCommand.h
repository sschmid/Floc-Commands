//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLAsyncCommand.h"

@interface AsyncCommand : FLAsyncCommand
@property(nonatomic, strong) id asyncResult;

- (BOOL)isInInitialState;
- (BOOL)isInExecuteState;
- (BOOL)isInDidExecuteWithoutErrorState;
- (BOOL)isInDidExecuteWithErrorState;
- (BOOL)isInCancelledState;
@end