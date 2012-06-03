//
//  PLDFirstViewController.m
//  ScrobbleFIlter
//
//  Created by Phillip Dunham on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
    [self storelastfmname];
    [singleton loadScrobbles];
    return YES;
}

-(void) storelastfmname {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults]; 
    [settings setObject:lastFmTextField.text forKey:@"lastfmname"];
    [settings synchronize];
    NSLog(@"stored lastfm user name");
}

-(void) loadlastfmname {
    lastFmTextField.text = [singleton loadlastfmname];
    NSLog(@"loaded lastfm username");
}



@end
