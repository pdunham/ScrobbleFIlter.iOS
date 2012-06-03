//
//  PLDDataSingleton.m
//  ScrobbleFIlter
//
//  Created by Phillip Dunham on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  This class handles all most of the data for the application.
//  As you can probably tell, the idea for the class came when the original intent was to store the data in CoreData.
//  However, all the data that needs to be stored for the app so far can be stored in plists if not directly in user defaults
//  This class also handled downloading and holding the list of recent scrobbles from last.fm.  Since more than one ViewController is interested in using that list,
//  namely the PLDTweetViewController and the PLDRecentScrobblesViewCOntroller, and it is important for them to be working off of the same list,
//  it makes sense to centralize that in this singleton class so that they are in agreement.
//

#import "PLDDataSingleton.h"

@implementation PLDDataSingleton


@synthesize scrobbledArtists, filteredArtists, isLastFmNameValid, downloadFailed;

/*******************************************************************************
 * @method          sharedInstance
 * @abstract        Create the singleton
 * @description     Not sure about the block stuff, but it words
 ******************************************************************************/
+ (id)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

/*******************************************************************************
 * @method loadlastfmname  
 * @abstract loads the user's last.fm name from user defaults   
 * @description  Also sets boolen flag if the name is nil 
 *******************************************************************************/
-(NSString *) loadlastfmname {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *lastfmname = [settings objectForKey:@"lastfmname"];
    isLastFmNameValid = ( lastfmname != nil );
    return lastfmname;
}

/*******************************************************************************
 * @method loadScrobbles  
 * @abstract downloads list of recent scrobbles from last.fm   
 * @description  uses last.fm's RESTful API to download top artists from the last 7 days. WIll post notifications when successful or if an error occured 
 *      once loaded the list is kept in a property that is accessible to other classes
 *******************************************************************************/
-(void)loadScrobbles {
    NSLog(@"loading scrobbles");
    NSString *lastFmName = [self loadlastfmname];
    NSString *urlString = @"http://ws.audioscrobbler.com/2.0/?method=user.gettopartists&period=7day&format=json&api_key=c0c210a13a2d568ed460f60479b79092&user=";
    urlString = [urlString stringByAppendingString: lastFmName];
    NSURL *url=[NSURL URLWithString:urlString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
        if (data==nil) {
            NSLog(@"%@", error);
            downloadFailed = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"mobi.uchicago.scrobblefilter.fail" object:error];
            NSLog(@"sent failure notification");
        } else
        dispatch_async(dispatch_get_main_queue(),^{
            NSError *error2 = nil;
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error2];
            //NSLog(@"Json as NSDictionary: %@",results);
            NSLog(@"done loading raw json file");
            //NSLog(@"%@", [[results objectForKey:@"topartists"] objectForKey:@"artist"]  );
            
            
            self.scrobbledArtists = [NSMutableArray arrayWithArray:[[results objectForKey:@"topartists"] objectForKey:@"artist"]];
            downloadFailed = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"mobi.uchicago.scrobblefilter.download" object:scrobbledArtists];
            NSLog(@"posted download notification");

        });
    });
    
}

/*******************************************************************************
 * @method loadFilteredArtists  
 * @abstract loads list of fiiltered artists from file   
 * @description  The list of filtered artists is kept in a plist in the same directory as user default. 
 *      once loaded the list is kept in a property that is accessible to other classes
 *******************************************************************************/
-(void) loadFilteredArtists {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"filteredartists.plist"];
    NSMutableArray *filteredArtistsArray = [NSMutableArray arrayWithContentsOfFile:finalPath ];
    NSLog(@"reading from file");
    // dump the contents of the dictionary to the console
    NSLog(@"logging filtered artists");
    for (id artist in filteredArtists) {
        NSLog(@"artist: %@", artist);
    }
    filteredArtists = [NSMutableSet setWithArray:filteredArtistsArray];
}

/*******************************************************************************
 * @method soterFilteredArtists  
 * @abstract writes list of filtered artists to file   
 * @description  The list of filtered artists, which can be set as a [property on this singleton, 
 *          is written tot a plist file in the same directory as user defaults
 *******************************************************************************/
-(void) storeFilteredArtists {
    BOOL success;
    NSError *error;

    //make suer we have the correct path to write the file
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"filteredartists.plist"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *filePath = [path stringByAppendingPathComponent:@"mySettings.plist"];
	
    //make sure the file exists
	success = [fileManager fileExistsAtPath:filePath];
	if (!success) {		
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mySettings" ofType:@"plist"];
        success = [fileManager fileExistsAtPath:filePath];
	}	
	NSLog(@"success: %@, error: %@",success,error);
    
    // write the file
    NSLog(@"writing to path %@",finalPath);
    if (![[filteredArtists allObjects] writeToFile:finalPath atomically:NO]) {
        NSLog(@"could not write file");
    }
    
}

/*******************************************************************************
 * @method filterScrobbles  
 * @abstract returns a list of recent scrobbles minus any artists in the filteredArtists list   
 * @description  The singleton keeps two arrays - the list of recent scrobbled artists (which is unfiltered) and the list of artists to filter
 *      When the RecentScrobblesVIewController wants a list to display, it calls this method  
 *******************************************************************************/
-(NSArray *) filterScrobbles {
    
    NSMutableArray * filteredList =  [[NSMutableArray alloc] initWithArray:scrobbledArtists copyItems:YES]; 
    
    for (int i = 0; i < [scrobbledArtists count]; i++ ) {
        NSDictionary * scrobble = (NSDictionary *) [scrobbledArtists objectAtIndex:i];
        id artistName = [scrobble objectForKey:@"name"];
        if ([filteredArtists containsObject:artistName]) {
            [filteredList removeObject:scrobble];
        }
    }
    return filteredList;
}

/*******************************************************************************
 * @method topThree  
 * @abstract returns an array with the top three recent scrobbles   
 * @description  This method returns the top three elements from the filtered list (from the filterScrobbles method)
 *      This is used y the TweetViewController
 *******************************************************************************/
-(NSArray *) topThree   {
    
    NSArray *filteredList = [self filterScrobbles];
    NSMutableArray *topThree = [[NSMutableArray alloc] initWithCapacity:3];
    for (int i = 0 ; [filteredList count] > (i+1) &&  i < 3; i++) {
        [topThree addObject: [filteredList objectAtIndex:i]];
    }
    return topThree;
}


@end
