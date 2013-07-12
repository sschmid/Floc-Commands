//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLCommand.h"

@interface FLCommand (KeepAlive)
@property (nonatomic, readonly) FLCommand *keepAlive;
@end