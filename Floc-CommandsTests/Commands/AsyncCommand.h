//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLAsyncCommand.h"

@interface AsyncCommand : FLAsyncCommand
@property (nonatomic) BOOL executeWithError;
@property (nonatomic) BOOL executeAndCancel;
- (BOOL)isInInitialState;
- (BOOL)isInExecuteState;
- (BOOL)isInDidExecuteWithoutErrorState;
- (BOOL)isInDidExecuteWithErrorState;
- (BOOL)isInCancelledState;
@end