//
//  PLDFilterTableViewController.m
//  ScrobbleFIlter
//
//  Created by Phillip Dunham on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
    cell.textLabel.textColor = [UIColor redColor];
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


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
