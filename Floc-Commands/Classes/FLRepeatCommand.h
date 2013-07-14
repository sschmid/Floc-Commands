//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLCommand.h"

@interface FLRepeatCommand : FLCommand <FLCommandDelegate>
@property(nonatomic, strong, readonly) FLCommand *command;
@property(nonatomic, readonly) NSInteger repeatCount;
- (id)initWithCommand:(FLCommand *)command repeat:(NSInteger)repeatCount;
@end