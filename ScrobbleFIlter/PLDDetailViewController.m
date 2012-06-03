//
//  PLDDetailViewController.m
//  ScrobbleFIlter
//
//  Created by Phillip Dunham on 5/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  This is the view controller that handles the display of individual artists. 
//  The user gets here iether from the list of recent scrobbles, or the list of filtered artists.
// from here the user can add or remove artists from the filtered artists list
//  all the actual data is handled using calls tot he singleton class
//


#import "PLDDetailViewController.h"
#import "PLDDataSingleton.h"

@interface PLDDetailViewController ()

@end

@implementation PLDDetailViewController
@synthesize artistTextView;
@synthesize filterButton;
@synthesize artistName;

PLDDataSingleton * singleton;

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
	// Do any additional setup after loading the view.
    singleton = [PLDDataSingleton sharedInstance];
    artistTextView.text = artistName;
    if ([singleton.filteredArtists containsObject:artistName]) {
        [filterButton setTitle:@"unfilter" forState:UIControlStateNormal ] ;
        [artistTextView setTextColor: [UIColor redColor]]; 
    } else {
        [filterButton setTitle:@"filter" forState:UIControlStateNormal ];
        [artistTextView setTextColor: [UIColor blueColor]]; 
    }
    NSLog(@"current tab bar index: %d", [self.tabBarController selectedIndex]);

}

- (void)viewDidUnload
{
    [self setFilterButton:nil];
    [self setArtistTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*******************************************************************************
 * @method filterButtonPress  
 * @abstract adds/removes artists from list of filtered artists   
 * @description  when the filter button is clicked, if the artist is in the filtered artist lists, it is removed
 *          otherwise, it is added. Method also handles corresponding chages to button text and text area color
 *******************************************************************************/
- (IBAction)filterButtonPress:(id)sender {
    
    if ([singleton.filteredArtists containsObject:artistName]) {
        [singleton.filteredArtists removeObject:artistName];
        [filterButton setTitle:@"filter" forState:UIControlStateNormal ];
        [artistTextView setTextColor: [UIColor blueColor]]; 

    } else {
        [singleton.filteredArtists addObject:artistName];
        [filterButton setTitle:@"unfilter" forState:UIControlStateNormal ];
        [artistTextView setTextColor: [UIColor redColor]]; 

    }
    [singleton storeFilteredArtists];
    
}
@end
