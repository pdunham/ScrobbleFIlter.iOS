//
//  PLDDetailViewController.m
//  ScrobbleFIlter
//
//  Created by Phillip Dunham on 5/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PLDDetailViewController.h"
#import "PLDDataSingleton.h"

@interface PLDDetailViewController ()

@end

@implementation PLDDetailViewController
@synthesize artsitLabel;
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
    artsitLabel.text = artistName;
    if ([singleton.filteredArtists containsObject:artistName]) {
        
        [filterButton setTitle:@"unfilter" forState:UIControlStateNormal ] ;
       
    } else {
        [filterButton setTitle:@"filter" forState:UIControlStateNormal ];
    }
    NSLog(@"current tab bar index: %d", [self.tabBarController selectedIndex]);

}

- (void)viewDidUnload
{
    [self setArtsitLabel:nil];
    [self setFilterButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)filterButtonPress:(id)sender {
    
    if ([singleton.filteredArtists containsObject:artistName]) {
        [singleton.filteredArtists removeObject:artistName];
        [filterButton setTitle:@"filter" forState:UIControlStateNormal ];    
    } else {
        [singleton.filteredArtists addObject:artistName];
        [filterButton setTitle:@"unfilter" forState:UIControlStateNormal ];
    }
    [singleton storeFilteredArtists];
    
}
@end
