//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLCommand.h"

@interface FLInterceptionCommand : FLCommand <FLCommandDelegate>
@property(nonatomic, readonly) BOOL cancelOnCancel;
@property(nonatomic, readonly) BOOL forwardTargetError;

- (id)initWithTarget:(FLCommand *)targetCommand success:(FLCommand *)successCommand error:(FLCommand *)errorCommand;
- (id)initWithTarget:(FLCommand *)targetCommand success:(FLCommand *)successCommand error:(FLCommand *)errorCommand
      cancelOnCancel:(BOOL)cancelOnCancel forwardTargetError:(BOOL)forwardTargetError;
@end
