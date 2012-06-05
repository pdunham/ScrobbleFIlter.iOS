//
//  PLDAppDelegate.m
//  ScrobbleFIlter
//
//  Created by Phillip Dunham on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// A fairly standard app delegate - most of the data is handled by a singleton object, so that object is loaded first thing, and methods to populate it are called

#import "PLDAppDelegate.h"
#import "PLDDataSingleton.h"

@implementation PLDAppDelegate

@synthesize window = _window;

PLDDataSingleton * singleton;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // when the app launches we wnat to try to load all the data we need,so we instantiate the singleton and call methods to populate data
    [self registerDefaultSettings];
    singleton = [PLDDataSingleton sharedInstance];
    if ([singleton loadlastfmname] != nil) {
        [singleton loadScrobbles];
    }
    [singleton loadFilteredArtists];
    return YES;
}

/*******************************************************************************
 * @method registerDefaultSettings  
 * @abstract ensures that the initial run setting is set   
 * @description  loads the default settings. Checkes to see if initial run is set. If not, sets it. 
 *******************************************************************************/
-(void) registerDefaultSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * initialrun = [defaults objectForKey:@"Initial Run"];
    NSLog(@"%@",initialrun);
    if (initialrun == nil) {
        NSLog(@"initial run was null");
        NSString *datestring = [NSString stringWithFormat:@"%@",[NSDate date]];
        [defaults setObject:datestring forKey:@"Initial Run"];
        [defaults synchronize];
        // Set your intial preferences in a .plist
    }
    NSLog(@"NSUserDefaults: %@", [[NSUserDefaults standardUserDefaults]
                                  dictionaryRepresentation]);
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
