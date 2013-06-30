//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLCommand.h"

@interface FLRepeatCommand : FLCommand <FLCommandDelegate>
- (id)initWithCommand:(FLCommand *)command repeat:(NSInteger)repeatCount;
@end