//
//  PLDSettingsViewController.h
//  ScrobbleFIlter
//
//  Created by Phillip Dunham on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PLDSettingsViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *lastFmTextField;
@property (strong, nonatomic) NSMutableArray *scrobbledArtists;
@property (strong, nonatomic) IBOutlet UIPickerView *accountPicker;

@end
