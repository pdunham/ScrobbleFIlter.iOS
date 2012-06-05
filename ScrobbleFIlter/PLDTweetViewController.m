//
//  PLDTweetViewController.m
//  ScrobbleFIlter
//
//  Created by Phillip Dunham on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  This view controller displays the actual tweet that will be posted to the user's Twitter account.
// data is collected from the singleton class, but the communication with Twitter is handled here
// various error conditions are handled with appropriate messages

#import "PLDTweetViewController.h"
#import "PLDDataSingleton.h"

@interface PLDTweetViewController ()

@end

@implementation PLDTweetViewController
@synthesize tweetButton;
@synthesize tweetText;
@synthesize splashImage;
@synthesize statusLabel;
@synthesize infoButton;

PLDDataSingleton *singleton;
NSString * tweet;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    singleton = [PLDDataSingleton sharedInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotNotification:) name:@"mobi.uchicago.scrobblefilter.download" object:nil];
    NSLog(@"registered for notification");
    NSLog(@"current tab bar index: %d", [self.tabBarController selectedIndex]);
    if (singleton.downloadFailed) [self gotErrorNotification:nil];
    if ([singleton loadlastfmname] == nil) {
        [self missingLastFmName];
    }
}

-(void) missingLastFmName {
    tweetText.text = @"Go to the Settings tab to input your last.fm user name."; 
    [tweetButton setEnabled:NO];
    [splashImage setHidden:YES];
}

/*******************************************************************************
 * @method gotErrorNotification  
 * @abstract handles case when there are no scrobbles    
 * @description  if the singleton failed when trying to download scrobbles, this method is called
 *  instead of compising a tweet from recent scrobbles, the tweet text area is set to an error message and the tweet button is disabled.
 *******************************************************************************/
-(void)gotErrorNotification:(NSNotification *)notif {
    NSLog(@">>>> Error Notification Recieved:");
    self.tweetText.text = @"Could not communicate with Last.fm to get scrobbles.\nCheck your network connectivity.";
    [self.tweetButton setEnabled:NO];
    [self.splashImage setHidden:YES];
}

/*******************************************************************************
 * @method gotNotification  
 * @abstract handler method for when scrobbles have been downloaded    
 * @description  once the scrobbles have been downloaded, this method is called to compose the tweet and remove the splash image 
 *              This viewcontroller is the first one displayed when the application launches, but if we try to compose a tweet 
 *              before the scrobbles are done being downloaded, we will get an error. So, the splash image is displayed until then
 *******************************************************************************/
- (void)gotNotification:(NSNotification *)notif {
    
    NSLog(@">>>> Notification Center Recieved:");
    [self composeTweet];
    [self.splashImage setHidden:YES];
}

- (void)viewDidUnload
{
    [self setTweetButton:nil];
    [self setTweetText:nil];
    [self setSplashImage:nil];
    [self setStatusLabel:nil];
    [self setInfoButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated {
    // scrobbles may have been updated since the view last appeared, so we will attempt to compose an updated tweet if scrobbles are available
    if (singleton.scrobbledArtists != nil) 
        [self composeTweet];
}

/*******************************************************************************
 * @method composeTweet  
 * @abstract puts together text for tweet based on top 3 scrobbles   
 * @description  gets the top 3 scrobbles from the data singleton instance, and constrcuts a tweet. Handles error conditions if scrobble download failed, or 
 *      number of top tweets is less than 3
 *******************************************************************************/
-(void) composeTweet {
    NSLog(@"composing tweet");
    singleton = [PLDDataSingleton sharedInstance];
    if (singleton.downloadFailed) [self gotErrorNotification:nil];
    else {
        NSArray *topThree = [singleton topThree];
        id artistOne, artistTwo, artistThree;
        if ([topThree count] > 0) { 
            NSDictionary *scrobbleOne = (NSDictionary*)[topThree objectAtIndex:0];
            artistOne = [scrobbleOne valueForKey:@"name"];
        }
        if ([topThree count] > 1) { 
            NSDictionary *scrobbleTwo = (NSDictionary*)[topThree objectAtIndex:1];
            artistTwo = [scrobbleTwo valueForKey:@"name"];
        }    
        if ([topThree count] > 2) { 
            NSDictionary *scrobbleThree = (NSDictionary*)[topThree objectAtIndex:2];
            artistThree = [scrobbleThree valueForKey:@"name"];
        }
        switch ([topThree count]) {
            case 3:
                tweet =  [NSString stringWithFormat:@"I've been listening to %@, %@, and %@.",artistOne, artistTwo, artistThree]; 
                break;
            case 2:
                tweet =  [NSString stringWithFormat:@"I've been listening to %@, and %@.",artistOne, artistTwo]; 
                break; 
            case 1:
                tweet =  [NSString stringWithFormat:@"I've been listening to %@.",artistOne];        
                break;
            default:
                tweet = @"I haven't listened to anything recently.";
                break;
        }
        self.tweetText.text = tweet;
        [self.tweetButton setEnabled:YES];
    }

}

/*******************************************************************************
 * @method showInfo  
 * @abstract displays information to the user   
 * @description  If the user clicks the info icon, instructional information is displayed in an action sheet. 
 *******************************************************************************/
- (IBAction)displayInfo:(id)sender {
        NSLog(@"info button clicked");
        UIActionSheet *msg = [[UIActionSheet alloc] 
                              initWithTitle:@"To change the artists in this tweet, go to the recent scrobbles tab and pick artists to filter.\n"
                              delegate:nil 
                              cancelButtonTitle:nil  destructiveButtonTitle:nil 
                              otherButtonTitles:@"Okay", nil];
        [msg showInView:self.view];

}

/*******************************************************************************
 * @method tweet  
 * @abstract Posts a message to Twitter    
 * @description  takes example code from the apple documentation on the iOS5 Twitter integration
 *              If there are multiple Twitter accounts, it just uses the first one
 *              If there are no twitter accounts set up, it launches an alert 
 *******************************************************************************/
- (IBAction)tweet:(id)sender {

    //////////////////////////////////////////////////////////////////////////////////////
    //This code was lifted from Apple's sample Twitter app code at:
    // http://developer.apple.com/library/ios/#samplecode/Tweeting/Introduction/Intro.html
    //////////////////////////////////////////////////////////////////////////////////////
    
    // Create an account store object.
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	
	// Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	// Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
			// Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
			
			// For the sake of brevity, we'll assume there is only one Twitter account present.
			// You would ideally ask the user which account they want to tweet from, if there is more than one Twitter account present.
			if ([accountsArray count] > 0) {
				// Grab the initial Twitter account to tweet from.
				ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                NSLog(@"using account %@", [twitterAccount username] );
				
				// Create a request, which in this example, posts a tweet to the user's timeline.
				// This example uses version 1 of the Twitter API.
				// This may need to be changed to whichever version is currently appropriate.
				TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"] parameters:[NSDictionary dictionaryWithObject:tweet forKey:@"status"] requestMethod:TWRequestMethodPOST];
				
				// Set the account used to post the tweet.
				[postRequest setAccount:twitterAccount];
				
				// Perform the request created above and create a handler block to handle the response.
				[postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
					NSString *output = [NSString stringWithFormat:@"HTTP response status: %i", [urlResponse statusCode]];
                    NSLog(@"%@",output);
                    NSLog(@"%@", [urlResponse allHeaderFields]);
					[self performSelectorOnMainThread:@selector(displayStatus:) withObject:urlResponse waitUntilDone:NO];
				}];
			} else {
                [self launchAlert];
            }
        }
	}];
}

/*******************************************************************************
 * @method launchLaert  
 * @abstract launches alert about the lack of a Twitter account   
 * @description  If the tweet method finds no Twitter accounts configured on the device, it calls this method to launch an alert 
 *******************************************************************************/
-(void) launchAlert {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Twitter Account required!" 
                                                 message:@"You need a Twitter account set up on your phone to use this feature." 
                                                delegate:self
                                       cancelButtonTitle:@"OK" 
                                       otherButtonTitles:nil];
    [av show];
    
}

/*******************************************************************************
 * @method displayStatus  
 * @abstract displays status result of post to twitter   
 * @description  the tweet method, if it successfully communicated with twitter, wil receive back an http status
 *      based on this status, the app will display success or failure, so the user knows if the tweet has gone through.
 *******************************************************************************/
- (void)displayStatus:(NSHTTPURLResponse *)httpResponse {
    if ([httpResponse statusCode] == 200) {
        self.statusLabel.text = @"tweeted successfully";
        [self.statusLabel setTextColor:[UIColor blueColor]];
    } else {
        self.statusLabel.text = @"tweet failed";
        [self.statusLabel setTextColor:[UIColor redColor]];
    }
}

@end
