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

    [self showIcon:@"Floc-Commands-144.png"];

    self.batmanTheme = [[BatmanTheme alloc] init];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)showIcon:(NSString *)filePath {
    UIImage *image = [UIImage imageNamed:filePath];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.center = self.window.center;
    [self.window addSubview:imageView];
}

@end
