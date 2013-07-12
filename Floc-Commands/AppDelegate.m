//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "AppDelegate.h"
#import "BatmanTheme.h"
#import "FLCommand+Floc.h"
#import "FLBlockCommand.h"
#import "FLCommand+KeepAlive.h"
#import "FLDelayCommand.h"

@interface AppDelegate ()
@property(nonatomic, strong) BatmanTheme *batmanTheme;
@property(nonatomic) BOOL commandDidExecute;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    [self showIcon];

    self.batmanTheme = [[BatmanTheme alloc] init];

    __weak AppDelegate *weak_self = self;
    FLDLY(0.1).then(FLBC(^(FLBlockCommand *command) {
        weak_self.commandDidExecute = YES;
        [command performSelector:@selector(didExecute) withObject:nil afterDelay:0.1];
    })).keepAlive.execute;
//

    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(checkIfCommandDidExecuteTillEnd)
                                   userInfo:nil
                                    repeats:NO];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)checkIfCommandDidExecuteTillEnd {
    NSAssert(self.commandDidExecute, @"Manual test failed");
}

- (void)showIcon {
    UIImage *image = [UIImage imageNamed:@"Floc-Commands-Logo.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.center = self.window.center;
    [self.window addSubview:imageView];
}

@end
