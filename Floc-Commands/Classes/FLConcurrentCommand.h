//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLAsyncCommand.h"

@interface FLConcurrentCommand : FLAsyncCommand <FLAsyncCommandDelegate>
@property(nonatomic, readonly) BOOL stopOnError;
@property(nonatomic, readonly) BOOL cancelOnCancel;
@property(nonatomic, strong, readonly) NSArray *commands;
- (id)initWithCommands:(NSArray *)commands;
- (id)initWithCommands:(NSArray *)commands stopOnError:(BOOL)stopOnError cancelOnCancel:(BOOL)cancelOnCancel;
@end