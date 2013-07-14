//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLSequenceCommand.h"

typedef FLSequenceCommand *(^FLSequenceCommandOptionBlock)(BOOL);

@interface FLSequenceCommand (Floc)
@property(nonatomic, copy, readonly) FLSequenceCommandOptionBlock stopsOnError;
@property(nonatomic, copy, readonly) FLSequenceCommandOptionBlock cancelsOnCancel;
@end