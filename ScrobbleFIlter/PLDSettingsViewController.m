//
//  PLDSettingsViewController.m
//  ScrobbleFIlter
//
//  Created by Phillip Dunham on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// THis is the view controller where the user handles settings - at first just the user's last.fm account name
// THis class is a UITextFieldDelegate in order to handle the text input field for the last fm user name

#import "PLDSettingsViewController.h"
#import "PLDDataSingleton.h"

@interface PLDSettingsViewController ()

@end

@implementation PLDSettingsViewController
@synthesize lastFmTextField;
@synthesize scrobbledArtists;
@synthesize accountPicker;

PLDDataSingleton *singleton;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    singleton = [PLDDataSingleton sharedInstance];
    lastFmTextField.text = [singleton loadlastfmname];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotNotification:) name:@"mobi.uchicago.scrobblefilter.usercheck" object:nil];

}

- (void)viewDidUnload
{
    [self setLastFmTextField:nil];
    [self setAccountPicker:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender
{
    [sender resignFirstResponder];
    NSLog(@"return pressed");
    [self validateLastFmName:lastFmTextField.text];
    return YES;
}

/*******************************************************************************
 * @method storelastfmname  
 * @abstract Store the user's Last.fm user name   
 * @description  stores the new name in the default settings
 *******************************************************************************/
-(void) storelastfmname {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults]; 
    [settings setObject:lastFmTextField.text forKey:@"lastfmname"];
    [settings synchronize];
    NSLog(@"stored lastfm user name");
}

/*******************************************************************************
 * @method gotNotification  
 * @abstract handles notification last.fm suer validation check   
 * @description  When the application makes a RESTful call to Last.fm to validate a 
 *      user name, this notification is fired when the call to last.fm completes
 *      if valid, the name is stored, and a new set of scrobbles are loaded.
 *      if not valid, an alert is displayed
 *******************************************************************************/
-(void) gotNotification:(NSNotification *)notif {
    if (singleton.isLastFmNameValid) {
        [self storelastfmname];
        [singleton loadScrobbles];
    } else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Invalid Last.fm user!" 
                                                     message:@"Please choose a valid Last.fm user name." 
                                                    delegate:self
                                           cancelButtonTitle:@"OK" 
                                           otherButtonTitles:nil];
        [av show];
    }
        
}

/*******************************************************************************
 * @method gotErrorNotification  
 * @abstract Handles errors from the user validation call to last.fm     
 * @description  If the call to lastfm fails, this method gets called, and alerts the user that communication failed.
 *      originally designed to be called via notifications, but is just called directly wen the error is detected
 *******************************************************************************/
-(void) gotErrorNotification:(NSNotification *)notif {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Could not communicate with Last.fm!" 
                                                     message:@"New user name was not stored. Was not able to contact Last.fm to confirm this user name.\nCheck your connectivity.\n" 
                                                    delegate:self
                                           cancelButtonTitle:@"OK" 
                                           otherButtonTitles:nil];
    [av show];
    
}

/*******************************************************************************
 * @method loadlastfmname  
 * @abstract loads the last fm name to the view   
 * @description  gets the last fm user name from the singleton and sets it on the text field 
 *******************************************************************************/
-(void) loadlastfmname {
    lastFmTextField.text = [singleton loadlastfmname];
    NSLog(@"loaded lastfm username");
}
    
/*******************************************************************************
 * @method validateLastFmName  
 * @abstract validates that the user input exists as a valid user on last.fm   
 * @description  utilizes RESTful last.fm api to validate that the user name exists.
 *      If so, fires notification that is intercepted by this class
 *      If communication with lastfm fails, an error handlin method is called directly
 *******************************************************************************/
-(void) validateLastFmName:(NSString *)lastfmname {
    NSString *urlString = @"http://ws.audioscrobbler.com/2.0/?method=user.getinfo&format=json&api_key=c0c210a13a2d568ed460f60479b79092&user=";
    urlString = [urlString stringByAppendingString: lastfmname];
    NSURL *url=[NSURL URLWithString:urlString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        NSError *error1;
        NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error1];
        if (data==nil) {
            NSLog(@"%@", error1);
            [self gotErrorNotification:nil];
        } else
        dispatch_async(dispatch_get_main_queue(),^{
            NSError *error = nil;
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSLog(@"done loading user info json response");
            //NSLog(@"%@", [[results objectForKey:@"topartists"] objectForKey:@"artist"]  );
            NSString * errorString = (NSString *)[results objectForKey:@"message"];
            if (errorString != nil) {
                singleton.isLastFmNameValid = NO;
                NSLog(@"user is invalid");
            } else {
                NSLog(@"user is valid");
                singleton.isLastFmNameValid = YES;
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"mobi.uchicago.scrobblefilter.usercheck" object:scrobbledArtists];
            NSLog(@"posted usercheck notification");
            
        });
    });

}


@end
