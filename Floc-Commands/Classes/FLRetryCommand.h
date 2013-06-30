//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLCommand.h"

@interface FLRetryCommand : FLCommand <FLCommandDelegate>
@property(nonatomic, readonly) NSUInteger retryCount;

- (id)initWithCommand:(FLCommand *)command retry:(NSUInteger)retryCount;
@end