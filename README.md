# Floc Commands
![Floc Commands Logo](http://sschmid.com/Dev/iOS/Libs/Floc-Commands/Floc-Commands-128.png)

## Description
Floc Commands is a neat collection of easy-to-use commands for Objective-C.
A command usually contains a small part of synchronous or asynchronous logic and can be chained or nested
as much as you like. Floc Commands comes with a bunch of handy commands such as:

* Sequence Command (executes commands one after another)
* Concurrent Command (executes commands all at once)
* Interception Command (executes commands depending on the target command's execution result)
* Block Command (executes a block)
* Master Slave Command (cancels the slave command as soon the master command did execute)
* Repeat Command (executes a command n times)
* Retry Command (retries to execute a command n times, if an error occoured)

All commands are sublcasses of `FLCommand`, which is designed to be used both synchronously or asynchronously.

## How to use Floc Commands
To get started, create a subclass of `FLCommand` and override `execute`. When a command finishes execution,
it must always call `didExecuteWithError:`. If it executed successfully without any errors, you pass nil as an argument
or you can use `didExecute` for convenience. Assign a delegate to respond to `commandWillExecute:`,
`command:didExecuteWithError:` or `commandCancelled:`.

## Examples
Synchronous FLCommand

```objective-c
@implementation HelloWorldCommand

- (void)execute {
    [super execute];

    NSLog(@"Hello world!");

    [self didExecute];
}

@end
```

Asynchronous FLCommand

```objective-c
@implementation SendDataCommand

- (void)execute {
    [super execute];

      // This may take a few seconds...
      [self.server sendData:data onComplete:^(NSError *error) {
          [self didExecuteWithError:error];
      }];
}

@end
```

FLSequenceCommand will execute commands one at a time.
Available options:
* `stopOnError` will stop, when an error occoured
* `cancelOnCancel` will cancel, when a sub command got cancelled

```objective-c
[[FLSequenceCommand alloc] initWithCommands:@[c1, c2, c3, c4]];
```

FLConcurrentCommand.
Available options:
* `stopOnError` will stop, when an error occoured
* `cancelOnCancel` will cancel, when a sub command got cancelled

```objective-c
[[FLConcurrentCommand alloc] initWithCommands:@[c1, c2, c3, c4]];
```

FLInterceptionCommand.
Available options:
* `cancelOnCancel` will cancel, when a sub command got cancelled
* `forwardTargetError` will forward the target error via `command:didExecuteWithError:`

```objective-c
self.postCommand = [[FLInterceptionCommand alloc] initWithTarget:sendDataCommand
                                                         success:hideSpinnerCommand
                                                           error:showErrorAlertCommand];
[self.postCommand execute];
```

Synchronous FLBlockCommand

```objective-c
[[FLBlockCommand alloc] initWithBlock:^(FLBlockCommand *command) {
    NSLog(@"Hello world!");
    [command didExecute];
}];
```

Asynchronous FLBlockCommand

```objective-c
FLBlockCommand *delayCommand = [[FLBlockCommand alloc] initWithBlock:^(FLBlockCommand *command) {
    [command performSelector:@selector(didExecute) withObject:nil afterDelay:1];
}];
```

FLMasterSlaveCommand. Executes both commands at the same time and will cancel slave, as soon as the master command did execute.
Available options:
* `forwardMasterError` will forward the matser error via `command:didExecuteWithError:`

```objective-c
[[FLMasterSlaveCommand alloc] initWithMaster:doHeavyTaskCommand slave:playJeopardyMusicCommand];
```

## Install Floc Commands
You find the source files you need in Floc-Commands/Classes.

## CocoaPods
Install [CocoaPods] and add the Floc Commands reference to your Podfile

```
platform :ios, '5.0'
  pod 'Floc-Commands'
end
```

#### Add this remote

```
$ pod repo add sschmid-cocoapods-specs https://github.com/sschmid/cocoapods-specs
```

#### Install Floc Commands

```
$ cd path/to/project
$ pod install
```

Open the created Xcode Workspace file.

[CocoaPods]: http://cocoapods.org
