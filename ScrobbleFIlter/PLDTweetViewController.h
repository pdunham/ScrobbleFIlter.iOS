//
//  PLDTweetViewController.h
//  ScrobbleFIlter
//
//  Created by Phillip Dunham on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>


@interface PLDTweetViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *tweetButton;
@property (strong, nonatomic) IBOutlet UITextView *tweetText;
- (IBAction)tweet:(id)sender;

@end
