//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLCommand.h"

@class FLAsyncCommand;

@protocol FLAsyncCommandDelegate
- (void)command:(FLAsyncCommand *)command didExecuteWithError:(NSError *)error;
- (void)commandCancelled:(FLAsyncCommand *)command;
@end

@interface FLAsyncCommand : FLCommand
@property(nonatomic, weak) id <FLAsyncCommandDelegate> delegate;
- (void)cancel;

// Call in subclasses when execution completed
- (void)didExecuteWithError:(NSError *)error;
- (void)didExecuteWithError;
- (void)didExecute;
@end