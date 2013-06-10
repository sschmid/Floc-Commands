//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLAsyncCommand.h"

@interface FLConcurrentCommand : FLAsyncCommand <FLAsyncCommandDelegate>
@property(nonatomic) BOOL stopOnError;
@property(nonatomic) BOOL cancelOnCancel;
@property(nonatomic, strong, readonly) NSArray *commands;
- (id)initWithCommands:(NSArray *)commands;
@end