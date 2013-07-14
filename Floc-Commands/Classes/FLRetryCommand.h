//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLCommand.h"

@interface FLRetryCommand : FLCommand <FLCommandDelegate>
@property(nonatomic, strong, readonly) FLCommand *command;
@property(nonatomic, readonly) NSInteger retryCount;
- (id)initWithCommand:(FLCommand *)command retry:(NSInteger)retryCount;
@end