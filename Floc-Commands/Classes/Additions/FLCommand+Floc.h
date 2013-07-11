//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLCommand.h"

#define flpar(...) parallel(__VA_ARGS__, nil)
#define flseq(...) sequence(__VA_ARGS__, nil)
#define FLBC(block) [[FLBlockCommand alloc] initWithBlock:block]

@interface FLCommand (Floc)

typedef FLCommand *(^FLCFCommandsBlock)(FLCommand *, ...); //NS_REQUIRES_NIL_TERMINATION
typedef FLCommand *(^FLCFCountBlock)(NSUInteger);

@property(nonatomic, copy, readonly) FLCFCommandsBlock parallel; // Hint: use macro par
@property(nonatomic, copy, readonly) FLCFCommandsBlock sequence; // Hint: use macro seq
@property(nonatomic, copy, readonly) FLCFCountBlock repeat;
@property(nonatomic, copy, readonly) FLCFCountBlock retry;

@end