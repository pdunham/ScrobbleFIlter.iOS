//
//  PLDSecondViewController.m
//  ScrobbleFIlter
//
//  Created by Phillip Dunham on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PLDRecentScrobblesViewController.h"
#import "PLDDataSingleton.h"
#import "PLDDetailViewController.h"

@interface PLDRecentScrobblesViewController ()

@end

@implementation PLDRecentScrobblesViewController

@synthesize scrobbleArtists;

PLDDataSingleton * singleton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    singleton = [PLDDataSingleton sharedInstance];
    scrobbleArtists = [singleton filterScrobbles] ;  
    NSLog(@"recent artists view loaded");
    NSLog(@"scrobbled artists has %d items", [scrobbleArtists count] );
    NSLog(@"current tab bar index: %d", [self.tabBarController selectedIndex]);

}

- (void)viewDidUnload
{
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
    if (singleton.downloadFailed) {
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //if (cell == nil) [cell initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    // Configure the cell...
    NSLog(@"Working on cell:%d",indexPath.row);
    NSDictionary *artist = [self.scrobbleArtists objectAtIndex:indexPath.row];
    cell.textLabel.text = [artist objectForKey:@"name"];
    cell.editingAccessoryType = UITableViewCellAccessoryCheckmark;
  //  cell.textLabel.text  = [NSString stringWithFormat:@"%@: %@",  [tweet objectForKey:@"from_user"],[tweet objectForKey:@"created_at"]];
//    NSString *imageURL = [tweet objectForKey:@"profile_image_url"];
 //   NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:imageURL]];
   // cell.imageView.image = [UIImage imageWithData: imageData];
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


@end
