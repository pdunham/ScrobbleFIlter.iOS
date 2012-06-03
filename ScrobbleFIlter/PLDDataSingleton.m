//
//  PLDDataSingleton.m
//  ScrobbleFIlter
//
//  Created by Phillip Dunham on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PLDDataSingleton.h"

@implementation PLDDataSingleton

@synthesize scrobbledArtists, filteredArtists;

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

-(NSString *) loadlastfmname {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *lastfmname = [settings objectForKey:@"lastfmname"];
    return lastfmname;
}

-(void)loadScrobbles {
    NSLog(@"loading scrobbles");
    NSString *lastFmName = [self loadlastfmname];
    NSString *urlString = @"http://ws.audioscrobbler.com/2.0/?method=user.gettopartists&period=7day&format=json&api_key=c0c210a13a2d568ed460f60479b79092&user=";
    urlString = [urlString stringByAppendingString: lastFmName];
    NSURL *url=[NSURL URLWithString:urlString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        dispatch_async(dispatch_get_main_queue(),^{
            NSError *error = nil;
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            //NSLog(@"Json as NSDictionary: %@",results);
            NSLog(@"done loading raw json file");
            //NSLog(@"%@", [[results objectForKey:@"topartists"] objectForKey:@"artist"]  );
            
            
            self.scrobbledArtists = [NSMutableArray arrayWithArray:[[results objectForKey:@"topartists"] objectForKey:@"artist"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"mobi.uchicago.scrobblefilter.download" object:scrobbledArtists];
            NSLog(@"posted download notification");

        });
    });
    
}


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

-(NSArray *) topThree   {
    
    NSArray *filteredList = [self filterScrobbles];
    NSMutableArray *topThree = [[NSMutableArray alloc] initWithCapacity:3];
    for (int i = 0 ; i < 3; i++) {
        [topThree addObject: [filteredList objectAtIndex:i]];
    }
    return topThree;
}


@end
