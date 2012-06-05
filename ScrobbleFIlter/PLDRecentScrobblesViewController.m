//
//  PLDRecentScrobblesViewController.m
//  ScrobbleFIlter
//
//  Created by Phillip Dunham on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  A Table View controller used to display a list of artists recently scrobbled by the user. 
//  The list is filtered to remove any artists from the user's list of filtered artists  
//  most data operations are handled by the dingleton class PLDDataSingleton 

#import "PLDRecentScrobblesViewController.h"
#import "PLDDataSingleton.h"
#import "PLDDetailViewController.h"

@interface PLDRecentScrobblesViewController ()

@end

@implementation PLDRecentScrobblesViewController

@synthesize scrobbleArtists;
@synthesize infoButton;

PLDDataSingleton * singleton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// get the singleton, and the list of scrobbles 
    singleton = [PLDDataSingleton sharedInstance];
    scrobbleArtists = [singleton filterScrobbles] ;  
    NSLog(@"recent artists view loaded");
    NSLog(@"scrobbled artists has %d items", [scrobbleArtists count] );
    NSLog(@"current tab bar index: %d", [self.tabBarController selectedIndex]);

}

- (void)viewDidUnload
{
    [self setInfoButton:nil];
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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // the list of scrobbles may have changed since the last time the table was viewed, so we will try to update whenever the view is re-displayed
    if (singleton.downloadFailed) {
        // download would have failed due to network not being available.
        // maybe it's back now?  this is the point where we try again.
        // scrobbles may not load here (due to threading issues), but will appear next time the view is redisplayed
        [singleton loadScrobbles];
    }
    scrobbleArtists = [singleton filterScrobbles];
    [self.tableView reloadData];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"there will be %d rows in the table", [self.scrobbleArtists count] );
    return [self.scrobbleArtists count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //straightforward table cell population based on scrobbledArtist array
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    NSLog(@"Working on cell:%d",indexPath.row);
    NSDictionary *artist = [self.scrobbleArtists objectAtIndex:indexPath.row];
    cell.textLabel.text = [artist objectForKey:@"name"];
    cell.editingAccessoryType = UITableViewCellAccessoryCheckmark;
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Pass the data to the detail view controller
    NSString *senderDescription = [sender description];
    NSLog(@"%@",senderDescription);
    NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
    
    NSDictionary *scrobble = [self.scrobbleArtists objectAtIndex:selectedRowIndex.row];
    
    PLDDetailViewController *detailViewController = [segue destinationViewController];
    detailViewController.artistName = [scrobble objectForKey:@"name"];
    
}

/*******************************************************************************
 * @method showInfo  
 * @abstract displays information to the user   
 * @description  If the user clicks the info icon, instructional information is displayed in an action sheet. 
 *******************************************************************************/
- (IBAction)showInfo:(id)sender {
    NSLog(@"info button clicked");
    UIActionSheet *msg = [[UIActionSheet alloc] 
                          initWithTitle:@"These are the artists you've scrobbled in the past 7 days, (not including the ones you've filtered). They are arranged in order of most scrobbled. Click the artist name to go to another screen to add them to your filter.\n"
                          delegate:nil 
                          cancelButtonTitle:nil  destructiveButtonTitle:nil 
                          otherButtonTitles:@"Okay", nil];
    [msg showInView:self.tableView];

}
@end
