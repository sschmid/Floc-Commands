//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLCommand.h"

@interface FLMasterSlaveCommand : FLCommand <FLCommandDelegate>
@property(nonatomic, strong, readonly) FLCommand *masterCommand;
@property(nonatomic, strong, readonly) FLCommand *slaveCommand;
@property(nonatomic, readonly) BOOL forwardMasterError;

- (id)initWithMaster:(FLCommand *)masterCommand slave:(FLCommand *)slaveCommand;
- (id)initWithMaster:(FLCommand *)masterCommand slave:(FLCommand *)slaveCommand forwardMasterError:(BOOL)forwardMasterError;
@end