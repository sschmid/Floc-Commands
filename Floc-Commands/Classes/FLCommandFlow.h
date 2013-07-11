//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLBlockCommand.h"

#define FLCFlow [[FLCommandFlow alloc] init]
#define flcmd(...) addConcurrentCommands(__VA_ARGS__, nil)

@class FLCommandFlow;
@class FLSequenceCommand;

typedef FLCommandFlow *(^FLCommandFlowConcurrentCommandBlock)(FLBlockCommandBlock, ...); //NS_REQUIRES_NIL_TERMINATION
typedef FLCommandFlow *(^FLCommandFlowRepeatBlock)(NSUInteger);
typedef FLCommandFlow *(^FLCommandFlowRetryBlock)(NSUInteger);

@interface FLCommandFlow : FLCommand <FLCommandDelegate>
@property(nonatomic, copy, readonly) FLCommandFlowConcurrentCommandBlock addConcurrentCommands; // Hint: use flcmd
@property(nonatomic, copy, readonly) FLCommandFlowRepeatBlock repeat;
@property(nonatomic, copy, readonly) FLCommandFlowRetryBlock retry;
@end
