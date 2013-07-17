//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>

@class FLCommand;

@protocol FLCommandDelegate <NSObject>
@optional
- (void)commandWillExecute:(FLCommand *)command;
- (void)command:(FLCommand *)command didExecuteWithError:(NSError *)error;
- (void)commandCancelled:(FLCommand *)command;
@end

@interface FLCommand : NSObject
@property(nonatomic, weak) id <FLCommandDelegate> delegate;
@property(nonatomic, readonly) BOOL isRunning;

- (void)execute;
- (void)cancel;

- (void)didExecute;
- (void)didExecuteWithError;
- (void)didExecuteWithError:(NSError *)error;
@end