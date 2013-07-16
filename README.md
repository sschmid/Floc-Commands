# Floc Commands
![Floc Commands Logo](http://sschmid.com/Dev/iOS/Libs/Floc-Commands/Floc-Commands-128.png)
[![Build Status](https://travis-ci.org/sschmid/Floc-Commands.png?branch=master)](https://travis-ci.org/sschmid/Floc-Commands)

## Description
Floc Commands is a neat collection of easy-to-use commands for Objective-C.
A command usually contains a small part of synchronous or asynchronous logic and can be chained or nested
as much as you like. Floc Commands comes with a bunch of handy commands such as:

* Sequence Command (executes commands one after another)
* Parallel Command (executes commands all at once)
* Interception Command (executes commands depending on the target command's execution result)
* Block Command (executes a block)
* Master Slave Command (cancels the slave command as soon the master command did execute)
* Repeat Command (executes a command n times)
* Retry Command (retries to execute a command n times, if an error occoured)

All commands are sublcasses of `FLCommand`, which is designed to be used both synchronously or asynchronously.

## How to use Floc Commands
To get started, create a subclass of `FLCommand` and override `execute`. When a command finishes execution,
it must always call `didExecuteWithError:`. If it executed successfully without any errors, you pass `nil` as an argument
or you can use `didExecute` for convenience. Assign a delegate to respond to `commandWillExecute:`,
`command:didExecuteWithError:` or `commandCancelled:`.

## Fluent API and macros
Floc Commands comes with some nice categories and macros to enable cool stuff like:

```objective-c
FLSQ(dowloadImage, convertImage, applyFilter, upload).stopsOnError(YES).retry(3)
        .intercept(showSuccessAlert, showErrorAlert)
        .slave(playJeopardyTheme.repeat(-1)).keepAlive.execute;
```
In this example `FLSQ` (macro for `FLSequenceCommand`) executes all asynchronous commands one after another and will
retry to execute all commands if any errors occour. If the sequence fails, `showErrorAlert` will be executed,
else `showSuccessAlert`. `playJeopardyTheme` will repeat forever (`-1`) and will be executed along with the sequence and
gets cancelled, as soon as asynchronous operation is completed. Since we do not have a strong pointer to the command, we
call `keepAlive` to ensure the command will not be deallocated before it's completed. The lifecycle of the command will
be managed for you.

```objective-c
FLBC(^(FLBlockCommand *command) {
    NSLog(@"na");
    [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.2];
}).repeat(16).flseq(FLBC(^(FLBlockCommand *command) {
    NSLog(@"Batman!");
    [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.2];
})).repeat(-1).keepAlive.execute;
```
This example creates a `FLBlockCommand` which repeats 16x followed by another `FLBlockCommand`. The sequence will repeat forever (`-1`)

There are handy macros for each command type. Check them out!
See [FLCommand+Floc.h](https://github.com/sschmid/Floc-Commands/blob/master/Floc-Commands/Classes/Additions/FLCommand%2BFloc.h)

## Potential pitfalls
When working with asynchronous commands, you should keep a strong pointer to it, because otherwise it may be
deallocated before it finishes. Alternatively you can call `keepAlive`, so the lifecycle of the command will be
managed for you.

RequestDataCommand might take several seconds to complete, so it's a good idea to assign in to a property to keep
the command alive.

```objective-c
self.requestCommand = [[[RequesteDataCommand alloc] init] execute];

// or
[[RequesteDataCommand alloc] init].keepAlive.execute;
```

## Examples

#### Synchronous FLCommand

```objective-c
@implementation HelloWorldCommand

- (void)execute {
    [super execute];

    NSLog(@"Hello world!");

    [self didExecute];
}

@end
```

#### Asynchronous FLCommand

```objective-c
@implementation SendDataCommand

- (void)execute {
    [super execute];

      // This may take a few seconds...
      [self.service sendData:data onComplete:^(NSError *error) {
          [self didExecuteWithError:error];
      }];
}

- (void)cancel {
    [self.service closeConnection];
    [super cancel];
}

@end
```

#### FLSequenceCommand
Executes commands one at a time.
Available options:
* `stopOnError` will stop, when an error occoured
* `cancelOnCancel` will cancel, when a sub command got cancelled

```objective-c
[[FLSequenceCommand alloc] initWithCommands:@[c1, c2, c3, c4]];
```

#### FLParallelCommand
Executes commands all at once.
Available options:
* `stopOnError` will stop, when an error occoured
* `cancelOnCancel` will cancel, when a sub command got cancelled

```objective-c
[[FLPrallelCommand alloc] initWithCommands:@[c1, c2, c3, c4]];
```

#### FLInterceptionCommand
Executes target command. The success commands gets executed when no errors occoured,
else error command.
Available options:
* `cancelOnCancel` will cancel, when a sub command got cancelled
* `forwardTargetError` will forward the target error via `command:didExecuteWithError:`

```objective-c
self.postCommand = [[FLInterceptionCommand alloc] initWithTarget:sendDataCommand
                                                         success:hideSpinnerCommand
                                                           error:showErrorAlertCommand];
[self.postCommand execute];
```

#### Synchronous FLBlockCommand

```objective-c
[[FLBlockCommand alloc] initWithBlock:^(FLBlockCommand *command) {
    NSLog(@"Hello world!");
    [command didExecute];
}];
```

#### Asynchronous FLBlockCommand

```objective-c
FLBlockCommand *delayCommand = [[FLBlockCommand alloc] initWithBlock:^(FLBlockCommand *command) {
    [command performSelector:@selector(didExecute) withObject:nil afterDelay:1];
}];
```

#### FLMasterSlaveCommand
Executes both commands at the same time and will cancel slave, as soon as the master command did execute.
Available options:
* `forwardMasterError` will forward the matser error via `command:didExecuteWithError:`

```objective-c
[[FLMasterSlaveCommand alloc] initWithMaster:doHeavyTaskCommand slave:playJeopardyMusicCommand];
```

... and more (`FLRepeatCommand`, `FLRetryCommand`, `FLDelayCommand`)

## Install Floc Commands
You find the source files you need in Floc-Commands/Classes.

## CocoaPods
Install [CocoaPods] and add the Floc Commands reference to your Podfile

```
platform :ios, '5.0'
  pod 'Floc-Commands'
end
```

#### Install Floc Commands

```
$ cd path/to/project
$ pod install
```

Open the created Xcode Workspace file.

[CocoaPods]: http://cocoapods.org
