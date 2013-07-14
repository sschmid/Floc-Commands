//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLParallelCommand.h"

typedef FLParallelCommand *(^FLParallelCommandOptionBlock)(BOOL);

@interface FLParallelCommand (Floc)
@property(nonatomic, copy, readonly) FLParallelCommandOptionBlock stopsOnError;
@property(nonatomic, copy, readonly) FLParallelCommandOptionBlock cancelsOnCancel;
@end
