//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>

@interface AsyncCommandDelegate : NSObject <FLAsyncCommandDelegate>
- (BOOL)isInInitialState;
- (BOOL)isInDidExecuteWithoutErrorState;
- (BOOL)isInDidExecuteWithErrorState;
- (BOOL)isInCancelState;
@end