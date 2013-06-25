//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLCommand.h"

@class FLBlockCommand;

typedef void (^FLBlockCommandBlock)(FLBlockCommand *);

@interface FLBlockCommand : FLCommand
- (id)initWithBlock:(FLBlockCommandBlock)block;
@end
