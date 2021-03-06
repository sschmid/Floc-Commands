//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLCommand.h"

@class FLInterceptionCommand;
@class FLMasterSlaveCommand;
@class FLParallelCommand;
@class FLRepeatCommand;
@class FLRetryCommand;
@class FLSequenceCommand;

#define FLBC(__block__) [[FLBlockCommand alloc] initWithBlock:__block__]
#define FLDLY(__delay__) [[FLDelayCommand alloc] initWithDelay:__delay__]
#define FLIC(__targetCommand__, __successCommand__, __errorCommand__) [[FLInterceptionCommand alloc] initWithTarget:__targetCommand__ success:__successCommand__ error:__errorCommand__]
#define FLICO(__cancel__, __forward__, __targetCommand__, __successCommand__, __errorCommand__) [[FLInterceptionCommand alloc] initWithTarget:__targetCommand__ success:__successCommand__ error:__errorCommand__ cancelOnCancel:__cancel__ forwardTargetError:__forward__]
#define FLMS(__masterCommand__, __slaveCommand__) [[MasterSlaveCommand alloc] initWithMaster:__masterCommand__ slave:__slaveCommand__]
#define FLMSO(__forward__, __masterCommand__, __slaveCommand__) [[MasterSlaveCommand alloc] initWithMaster:__masterCommand__ slave:__slaveCommand__ forwardMasterError:__forward__]
#define FLPL(...) [[ParallelCommand alloc] initWithCommands:@[__VA_ARGS__]]
#define FLPLO(__stop__, __cancel__, ...) [[ParallelCommand alloc] initWithCommands:@[__VA_ARGS__] stopOnError:__stop__ cancelOnCancel:__cancel__]
#define FLRP(__command__, __repeat__) [[FLRepeatCommand alloc] initWithCommand:__command__ repeat:__repeat__]
#define FLRT(__command__, __retry__) [[FLRetryCommand alloc] initWithCommand:__command__ retry:__retry__]
#define FLSQ(...) [[FLSequenceCommand alloc] initWithCommands:@[__VA_ARGS__]]
#define FLSQO(__stop__, __cancel__, ...) [[FLSequenceCommand alloc] initWithCommands:@[__VA_ARGS__] stopOnError:__stop__ cancelOnCancel:__cancel__]

#define flpar(...) parallel(__VA_ARGS__, nil)
#define flseq(...) sequence(__VA_ARGS__, nil)

// FL Command Flow
typedef FLInterceptionCommand *(^FLCFInterceptionCommandBlock)(FLCommand *, FLCommand *);
typedef FLMasterSlaveCommand *(^FLCFMasterSlaveCommandBlock)(FLCommand *);
typedef FLSequenceCommand *(^FLCFParallelCommandBlock)(FLCommand *, ...); //NS_REQUIRES_NIL_TERMINATION
typedef FLRepeatCommand *(^FLCFRepeatBlock)(NSInteger);
typedef FLRetryCommand *(^FLCFRetryBlock)(NSInteger);
typedef FLSequenceCommand *(^FLCFSequenceCommandBlock)(FLCommand *, ...); //NS_REQUIRES_NIL_TERMINATION

@interface FLCommand (Floc)
@property(nonatomic, copy, readonly) FLCFInterceptionCommandBlock intercept;
@property(nonatomic, copy, readonly) FLCFMasterSlaveCommandBlock slave;
@property(nonatomic, copy, readonly) FLCFParallelCommandBlock parallel; // Hint: use macro flpar, to avoid nil termination
@property(nonatomic, copy, readonly) FLCFRepeatBlock repeat;
@property(nonatomic, copy, readonly) FLCFRetryBlock retry;
@property(nonatomic, copy, readonly) FLCFSequenceCommandBlock sequence; // Hint: use macro flseq, to avoid nil termination
@end
