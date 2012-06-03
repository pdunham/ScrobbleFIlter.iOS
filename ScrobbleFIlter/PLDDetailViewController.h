//
//  PLDDetailViewController.h
//  ScrobbleFIlter
//
//  Created by Phillip Dunham on 5/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLDDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextView *artistTextView;
@property (strong, nonatomic) IBOutlet UIButton *filterButton;
@property (weak, nonatomic) NSString *artistName;

- (IBAction)filterButtonPress:(id)sender;

@end
