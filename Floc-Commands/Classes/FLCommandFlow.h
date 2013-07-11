//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLBlockCommand.h"

#define flcmd(...) addConcurrentCommands(__VA_ARGS__, nil)

@class FLCommandFlow;
@class FLSequenceCommand;

typedef FLCommandFlow *(^FLFlowConcurrentCommandBlock)(FLBlockCommandBlock, ...); //NS_REQUIRES_NIL_TERMINATION

@interface FLCommandFlow : FLCommand <FLCommandDelegate>
@property(nonatomic, copy, readonly) FLFlowConcurrentCommandBlock addConcurrentCommands; // Hint: use flcmd
@end
