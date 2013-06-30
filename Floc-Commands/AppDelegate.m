//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];

    [self showIcon];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)showIcon {
    UIImage *image = [UIImage imageNamed:@"Floc-Commands-144.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.center = self.window.center;
    [self.window addSubview:imageView];
}

@end
