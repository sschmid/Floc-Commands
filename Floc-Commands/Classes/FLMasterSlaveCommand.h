//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLCommand.h"

@interface FLMasterSlaveCommand : FLCommand <FLCommandDelegate>
@property(nonatomic, readonly) BOOL forwardMasterError;

- (id)initWithMaster:(FLCommand *)masterCommand slave:(FLCommand *)slaveCommand;
- (id)initWithMaster:(FLCommand *)masterCommand slave:(FLCommand *)slaveCommand forwardMasterError:(BOOL)forwardMasterError;
@end