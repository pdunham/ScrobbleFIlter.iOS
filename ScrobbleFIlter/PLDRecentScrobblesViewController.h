//
//  PLDRecentScrobblesViewController.h
//  ScrobbleFIlter
//
//  Created by Phillip Dunham on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLDRecentScrobblesViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *scrobbleArtists;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;

- (IBAction)showInfo:(id)sender;
@end
