//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLCommand.h"

@interface Command : FLCommand
- (BOOL)isInInitialState;
- (BOOL)isInExecuteState;
@end