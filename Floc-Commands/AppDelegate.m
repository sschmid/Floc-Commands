//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [self addIcon];

    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)addIcon {
    UIImage *image = [UIImage imageNamed:@"Floc-Commands-144.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    CGRect centerFrame = CGRectMake(self.window.center.x - imageView.frame.size.width / 2,
            self.window.center.y - imageView.frame.size.height / 2,
            imageView.frame.size.width,
            imageView.frame.size.height);

    imageView.frame = centerFrame;
    [self.window addSubview:imageView];
}

@end
