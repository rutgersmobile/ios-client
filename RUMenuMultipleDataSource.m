//
//  RUMenuMultipleDataSource.m
//  Rutgers
//
//  Created by scm on 5/31/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import "RUMenuMultipleDataSource.h"
#import "RUFavoritesDataSource.h"
#import "ChannelsDataSource.h"
#import "RUMenuTableViewCell.h"
#import "AAPLPlaceholderView.h"
#import "RUUserInfoManager.h"
#import "RUChannelManager.h"

/*
 
    Holds the data from multiple data sources in a single data source
    ensures that kyles code can work and edit menu in options can be implemented on time

 
    This class has to be both persistent and singleton. If changes are made then it should be visible to everyone and multiple copies of this class is not required

 */

#warning TODO : Make Class Persistant : NSUserDefaults

@interface RUMenuMultipleDataSource ()
@property (strong , nonatomic) NSMutableArray * multipleArray ; // this will be the data source to which we add the items
    // Why inherit from Menu Baisc Data Sourc.. ? To ensure compatability with Kyles Menu Implementation
@end


/*
    here self.items is an ns array property within Basic Data Source which Menu Baisc Data source inherits from
    The methods we inherit from Menu Basic Data Source ensure that this class can be used as a data source for the Menu view in the slide bar
 */

/*
    Make this is a singleton class ??
    So that changes made to the array are not lost on init

    RUUserInfroMangaer manages the favourites and channel manager manages the favourites
 
 */

@implementation RUMenuMultipleDataSource

+(instancetype) sharedManager {
    static RUMenuMultipleDataSource * sharedDataSource = nil ;
    static dispatch_once_t onceToken ;
    dispatch_once(& onceToken , ^{
        sharedDataSource = [[self alloc] init];
    });
    return sharedDataSource;
}

-(instancetype) init
{
    self = [super init];
    if(self)
    {
        _multipleArray = [[NSMutableArray alloc] init] ;
        
        
        //[multipeArray addObjectsFromArray:[[RUFavoritesDataSource alloc] init].items];
        //[multipeArray addObjectsFromArray:[[ChannelsDataSource alloc] init].items];
       
       // add favourites to the array
        [_multipleArray addObjectsFromArray:[RUUserInfoManager favorites]];
        
        // Set up notification when new favourites have been created
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoritesDidChange) name:userInfoManagerDidChangeFavoritesKey object:nil];
        
        
        // add the channels to  the array
        [_multipleArray addObjectsFromArray:[RUChannelManager sharedInstance].contentChannels];
       
        // When new channels are added , they should be added to the top of the array
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelsDidChange) name:ChannelManagerDidUpdateChannelsKey object:nil];
        
        /*
                Base Class is given access to this array so that it can be displayed in the Menu slide bar :: Not Clean , but will work for now
          */
        self.items = [_multipleArray copy];
    }
    
    return self;
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#warning untested : Make changes in server and see if required behavior is seen

/**
    Called when new channels have been added : That is new channels have been added in the server side and we are displaying it at the top of the menu
 */
-(void) channelsDidChange
{
  /*
        Find the differences between the existing channels and the new channels. 
        Then add those channels to the top of the array
   */
NSMutableArray *newChannels = [NSMutableArray arrayWithArray:[RUChannelManager sharedInstance].contentChannels ];
    
    // obtain the newly added channels
    [newChannels removeObjectsInArray:_multipleArray];
   
    // add the new channels to the top of the array
    NSIndexSet * indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[newChannels count])];
   
    [_multipleArray insertObjects:newChannels atIndexes:indexes];

}

#warning untested
/**
    Called when favourties have changed
 
    Implemeted similar to channelsDidChange
 */
-(void)favoritesDidChange{
    self.items = [RUUserInfoManager favorites];
    
    NSMutableArray *newFavourite = [NSMutableArray arrayWithArray:[RUUserInfoManager favorites ]];

    [newFavourite removeObjectsInArray:_multipleArray];
    
    NSIndexSet * indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[newFavourite count])];
    
    [_multipleArray insertObjects:newFavourite atIndexes:indexes];
}


-(id) objectAtIndex:(NSUInteger)index
{
    return _multipleArray[index];
}

-(NSInteger) numberOfObjects
{
    return [_multipleArray count];
}



@end
