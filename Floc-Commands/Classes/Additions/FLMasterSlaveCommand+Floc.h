//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLMasterSlaveCommand.h"

typedef FLMasterSlaveCommand *(^FLMasterSlaveCommandOptionBlock)(BOOL);

@interface FLMasterSlaveCommand (Floc)
@property(nonatomic, copy, readonly) FLMasterSlaveCommandOptionBlock forwardsMasterError;
@end
