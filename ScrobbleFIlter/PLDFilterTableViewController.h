//
//  PLDFilterTableViewController.h
//  ScrobbleFIlter
//
//  Created by Phillip Dunham on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLDFilterTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *infoButton;
- (IBAction)showInfo:(id)sender;
@end
