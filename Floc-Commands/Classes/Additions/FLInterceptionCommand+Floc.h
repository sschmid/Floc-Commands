//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLInterceptionCommand.h"

typedef FLInterceptionCommand *(^FLInterceptionCommandOptionBlock)(BOOL);

@interface FLInterceptionCommand (Floc)
@property(nonatomic, copy, readonly) FLInterceptionCommandOptionBlock cancelsOnCancel;
@property(nonatomic, copy, readonly) FLInterceptionCommandOptionBlock forwardsTargetError;
@end