//
// Created by Simon Schmid
//
// contact@sschmid.com
//

#import "AppDelegate.h"
#import "BatmanTheme.h"

@interface AppDelegate ()
@property(nonatomic, strong) BatmanTheme *batmanTheme;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    [self showIcon];

    self.batmanTheme = [[BatmanTheme alloc] init];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)showIcon {
    UIImage *image = [UIImage imageNamed:@"Floc-Commands-Logo.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.center = self.window.center;
    [self.window addSubview:imageView];
}

@end
