//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import <Foundation/Foundation.h>
#import "FLCommand.h"

#define FLBC(__block__) [[FLBlockCommand alloc] initWithBlock:__block__]
#define FLIC(__targetCommand__, __successCommand__, __errorCommand__) [[FLInterceptionCommand alloc] initWithTarget:__targetCommand__ success:__successCommand__ error:__errorCommand__]
#define FLICO(__targetCommand__, __successCommand__, __errorCommand__, __cancel__, forward) [[FLInterceptionCommand alloc] initWithTarget:__targetCommand__ success:__successCommand__ error:__errorCommand__ cancelOnCancel:__cancel__ forwardTargetError:forward]
#define FLMSC(__masterCommand__, __slaveCommand__) [[MasterSlaveCommand alloc] initWithMaster:__masterCommand__ slave:__slaveCommand__]
#define FLMSCO(__masterCommand__, __slaveCommand__, __forward__) [[MasterSlaveCommand alloc] initWithMaster:__masterCommand__ slave:__slaveCommand__ forwardMasterError:__forward__]
#define FLPL(__commands__) [[ParallelCommand alloc] initWithCommands:__commands__]
#define FLPLO(__commands__, __stop__, __cancel__) [[ParallelCommand alloc] initWithCommands:__commands__ stopOnError:__stop__ cancelOnCancel:__cancel__]
#define FLRP(__command__, __repeat__) [[FLRepeatCommand alloc] initWithCommand:__command__ repeat:__repeat__]
#define FLRT(__command__, __retry__) [[FLRetryCommand alloc] initWithCommand:__command__ retry:__retry__]
#define FLSQ(__commands__) [[FLSequenceCommand alloc] initWithCommands:__commands__]
#define FLSQO(__commands__, __stop__, __cancel__) [[FLSequenceCommand alloc] initWithCommands:__commands__ stopOnError:__stop__ cancelOnCancel:__cancel__]

#define flpar(...) parallel(__VA_ARGS__, nil)
#define flseq(...) sequence(__VA_ARGS__, nil)

@interface FLCommand (Floc)

typedef FLCommand *(^FLCFCommandBlock)(FLCommand *);
typedef FLCommand *(^FLCFCommandsBlock)(FLCommand *, ...); //NS_REQUIRES_NIL_TERMINATION
typedef FLCommand *(^FLCFCountBlock)(NSUInteger);
typedef FLCommand *(^FLCFChoiceBlock)(FLCommand *, FLCommand *);

@property(nonatomic, copy, readonly) FLCFCommandsBlock parallel; // Hint: use macro par
@property(nonatomic, copy, readonly) FLCFCommandsBlock sequence; // Hint: use macro seq
@property(nonatomic, copy, readonly) FLCFCountBlock repeat;
@property(nonatomic, copy, readonly) FLCFCountBlock retry;
@property(nonatomic, copy, readonly) FLCFChoiceBlock intercept;
@property(nonatomic, copy, readonly) FLCFCommandBlock slave;

@end