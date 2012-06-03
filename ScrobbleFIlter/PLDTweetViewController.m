//
//  PLDTweetViewController.m
//  ScrobbleFIlter
//
//  Created by Phillip Dunham on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PLDTweetViewController.h"
#import "PLDDataSingleton.h"

@interface PLDTweetViewController ()

@end

@implementation PLDTweetViewController
@synthesize tweetButton;
@synthesize tweetText;
@synthesize splashImage;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotNotification:) name:@"mobi.uchicago.scrobblefilter.download" object:nil];
    NSLog(@"registered for notification");
    NSLog(@"current tab bar index: %d", [self.tabBarController selectedIndex]);

}

- (void)gotNotification:(NSNotification *)notif {
    
    NSLog(@">>>> Notification Center Recieved:");
    
    // Update UI; needs be on main thread
//    [self performSelectorOnMainThread:@selector(composeTweet:) withObject:nil waitUntilDone:YES];
    [self composeTweet];
    [self.splashImage setHidden:YES];
}

- (void)viewDidUnload
{
    [self setTweetButton:nil];
    [self setTweetText:nil];
    [self setSplashImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated {
    if (singleton.scrobbledArtists != nil) 
        [self composeTweet];
}

-(void) composeTweet {
    NSLog(@"composing tweet");
    singleton = [PLDDataSingleton sharedInstance];
    NSArray *topThree = [singleton topThree];
    NSDictionary *scrobbleOne = (NSDictionary*)[topThree objectAtIndex:0];
    NSDictionary *scrobbleTwo = (NSDictionary*)[topThree objectAtIndex:1];
    NSDictionary *scrobbleThree = (NSDictionary*)[topThree objectAtIndex:2];
    id artistOne = [scrobbleOne valueForKey:@"name"];
    id artistTwo = [scrobbleTwo valueForKey:@"name"];
    id artistThree = [scrobbleThree valueForKey:@"name"];
    
    tweet =  [NSString stringWithFormat:@"I've been listening to %@, %@, and %@.",artistOne, artistTwo, artistThree]; 
    self.tweetText.text = tweet;

}

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
                    NSLog(@"%@", [urlResponse allHeaderFields]);
					[self performSelectorOnMainThread:@selector(displayText:) withObject:output waitUntilDone:NO];
				}];
			} else {
                [self launchAlert];
            }
        }
	}];
}

-(void) launchAlert {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Twitter Account required!" 
                                                 message:@"You need a Twitter account set up on your phone to use this feature." 
                                                delegate:self
                                       cancelButtonTitle:@"OK" 
                                       otherButtonTitles:nil];
    [av show];
    
}


- (void)displayText:(NSString *)text {
	self.tweetText.text = text;
}

@end
