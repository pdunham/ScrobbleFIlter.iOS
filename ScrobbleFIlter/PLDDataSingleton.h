//
//  PLDDataSingleton.h
//  ScrobbleFIlter
//
//  Created by Phillip Dunham on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLDDataSingleton : NSObject

@property (strong, nonatomic) NSMutableArray *scrobbledArtists;
@property (strong, nonatomic) NSMutableSet *filteredArtists;
@property bool isLastFmNameValid;
@property bool downloadFailed;

// Methods
+ (id)sharedInstance;
-(NSString *) loadlastfmname;
-(void)loadScrobbles;
-(void) loadFilteredArtists;
-(void) storeFilteredArtists;
-(NSArray *) filterScrobbles;
-(NSArray *) topThree;
@end
