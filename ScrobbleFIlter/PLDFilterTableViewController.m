//
//  PLDFilterTableViewController.m
//  ScrobbleFIlter
//
//  Created by Phillip Dunham on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  A Table View controller used to display a list of artists that the user does NOT want to be displayed/tweeted in their scrobble feed 
//  most data operations are handled by the dingleton class PLDDataSingleton 
//

#import "PLDFilterTableViewController.h"
#import "PLDDetailViewController.h"
#import "PLDDataSingleton.h"

@interface PLDFilterTableViewController ()

@end

@implementation PLDFilterTableViewController
@synthesize infoButton;

NSMutableArray *filteredArtists;
PLDDataSingleton * singleton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    singleton = [PLDDataSingleton sharedInstance];
    filteredArtists =  [[NSMutableArray alloc] initWithArray:[singleton.filteredArtists allObjects]];
    NSLog(@"current tab bar index: %d", [self.tabBarController selectedIndex]);

}

- (void)viewDidUnload
{
    [self setInfoButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated {
    //list may have changed since the viwe was last displayed, especially since they may have gone to the detailedViewController to update list
    [super viewWillAppear:animated];
    filteredArtists =  [[NSMutableArray alloc] initWithArray:[singleton.filteredArtists allObjects]];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [filteredArtists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"filteredArtist";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSLog(@"%@",[filteredArtists objectAtIndex:indexPath.row]);
    cell.textLabel.text = [filteredArtists objectAtIndex:indexPath.row];
    // we color the text red to indicate that this is a list of *filtered* artists
    cell.textLabel.textColor = [UIColor redColor];
    return cell;
}



#pragma mark - Table view delegate


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Pass the data to the detail view controller
    NSString *senderDescription = [sender description];
    NSLog(@"%@",senderDescription);
    NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
    
    NSString *artist = [filteredArtists objectAtIndex:selectedRowIndex.row];
    
    PLDDetailViewController *detailViewController = [segue destinationViewController];
    detailViewController.artistName = artist;
    
}

/*******************************************************************************
 * @method showInfo  
 * @abstract displays information to the user   
 * @description  If the user clicks the info icon, instructional information is displayed in an action sheet. 
 *******************************************************************************/
- (IBAction)showInfo:(id)sender {
    NSLog(@"info button clicked");
    UIActionSheet *msg = [[UIActionSheet alloc] 
                          initWithTitle:@"These artists will not appear in your recent scrobbles.\n"
                          "Click the artist name to go to another screen to remove them from your filter.\n"
                          delegate:nil 
                          cancelButtonTitle:nil  destructiveButtonTitle:nil 
                          otherButtonTitles:@"Okay", nil];
    [msg showInView:self.tableView];

}
@end
