//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLCommand.h"

@interface FLParallelCommand : FLCommand <FLCommandDelegate>
@property(nonatomic, readonly) BOOL stopOnError;
@property(nonatomic, readonly) BOOL cancelOnCancel;
@property(nonatomic, strong, readonly) NSArray *commands;

- (id)initWithCommands:(NSArray *)commands;
- (id)initWithCommands:(NSArray *)commands stopOnError:(BOOL)stopOnError cancelOnCancel:(BOOL)cancelOnCancel;
@end