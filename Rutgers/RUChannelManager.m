//
//  RUComponentManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//


/*
    Descript : 
        Called When the App Loads   
        The Other Class register with this class , basically similar to keeping a pointer for access .
 
        This class is used when the app transitions from one UIViewTable to the next ... 
 
 
 */
#import "NSDictionary+Channel.h"
#import "RUDataLoadingManager_Private.h"
#import "RUNetworkManager.h"
#import "RUChannelManager.h"
#import "RUChannelProtocol.h"
#import "RUAnalyticsManager.h"
#import "NSURL+RUAdditions.h"
#import "RUFavoritesDynamicHandoffViewController.h"
#import "RUSplashViewController.h"



NSString *const ChannelManagerJsonFileName = @"ordered_content"; // Json file used in the creation of the different channels
NSString *const ChannelManagerDidUpdateChannelsKey = @"ChannelManagerDidUpdateChannelsKey";

/*
    Update the number of channels and colletevery day ?
 
 */
//#define CHANNEL_CACHE_TIME 60*60*24*1
#define CHANNEL_CACHE_TIME 60

@interface RUChannelManager ()
@property dispatch_group_t loadingGroup;

@property BOOL loading;
@property BOOL finishedLoading;
@property NSError *loadingError;
@end

@implementation RUChannelManager

/*
    Creates a singleton class to mangage the different channels
 
 */
+(RUChannelManager *)sharedInstance
{
    static RUChannelManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        manager = [[RUChannelManager alloc] init];
    });
    return manager;
}


/*
    Other channel is the Options Channel at the end
 
 */
#pragma mark - Channel Information Methods
@synthesize otherChannels = _otherChannels;
-(NSArray *)otherChannels{
    if (!_otherChannels) {
        _otherChannels = @[
                           @{@"handle" : @"options",
                             @"title" : @"Options",
                             @"view" : @"options",
                             @"icon" : @"gear"}
                           ];
    }
    return _otherChannels;
}


/**
    Loads the contentChannels from a file ::
    Is the getter of the contentChannels property the most important step of loading the different channels from the file is done. .
    After the end of this getter , the contentChannels will be an nsArray containing dictionary elements , such that each dictionary in the array will be a
    channel 
 
    The input file is ordered_content file :: It is in the json format hence serialization is done by a JSONSerilaizer
                    the orederd_content file is under common , channel

    The ordered content is tested from in multiple locations : which is why there is the documentPath and bundlePath
 
    ordered_content is stored in its setter in the documentPath :
    So we also look at the ordered_content that we might have added to obtain the channels

    :: Some additional test are done to ensure ???
 
    This is one of the blocks called just after initialization
 
 */
@synthesize contentChannels = _contentChannels;
-(NSArray *)contentChannels
{
    @synchronized(self)
    {
        if (!_contentChannels)
        { // If the content channel has not been created , create it .
            NSDate *latestDate;
            
            NSArray *paths = @[[self documentPath],[self bundlePath]];
            
            for (NSString *path in paths)
            {
                NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
                NSDate *date = [attributes fileModificationDate];
                
                if (!latestDate || [date compare:latestDate] == NSOrderedDescending) // serach for the latest copy ?
                {
                    NSData *data = [NSData dataWithContentsOfFile:path];
                    if (data)
                    {
                        NSArray *channels = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        if (channels.count) // if there are multiple items in the channel
                        {
                            NSLog(@" # CHANNELS : %i " , (int)channels.count);
                            latestDate = date;
                            _contentChannels = channels;  // So we create channel from files converted into JSonn Objects ?
                        }
                    }
                }
            }
        
        }
       
        // After the copy stored in the device is read , do a network request to get the
        // latest ordered content in the server
        
        // This is done as a background process , with out causing delay of the curretn
        // thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            if ([self needsLoad]) {
                [self load];
            }
        });
        return _contentChannels;
    }
}

/*
    The input handle is compared with handle present in the orderend content channel :: Each channel in the ordered content file has a channel feild
    
    If they match then the whole channel containing the handle is returend
 */
-(NSDictionary *)channelWithHandle:(NSString *)handle{
    
    // looks in the data obtained from the ordered_content file , either on the device or from the internet :

    for (NSDictionary *channel in self.contentChannels)
    {
        if ([[channel channelHandle] isEqualToString:handle])
        {
            return channel;
        }
    }
    
    for (NSDictionary *channel in self.otherChannels) // the others channel for now have a singel channel , but in the future other channels migh be added programatically
    {
        if ([[channel channelHandle] isEqualToString:handle])
        {
            return channel;
        }
    }
    return nil;
}

/*
    This is the setter for the contentChannels:: 
        The new content is stored to the disk
        If the new items and old items are same , the fucntion just returns
 
 
 */
-(void)setContentChannels:(NSArray *)allChannels
{
    
    if (!allChannels.count) return; // if the input array has no element return :: no element or is nill
    
    @synchronized(self)
    {
        NSData *data = [NSJSONSerialization dataWithJSONObject:allChannels options:0 error:nil]; // obtain the channel from the array
        
        if (data) [data writeToFile:[self documentPath] atomically:YES]; // WRITE THE NEW ORDERED CONTENT INTO THE DOCUMENTS FILE
        
        if ([_contentChannels isEqual:allChannels]) return;
        
        _contentChannels = allChannels;
        
        dispatch_async(
        dispatch_get_main_queue(),
            ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:ChannelManagerDidUpdateChannelsKey object:self];
                // send notification to everyone who listens that the contents of the file has been changed
             }
        );
    }
}

#pragma mark Channel manager loading
-(NSString *)documentPath // THIS IS THE LOCATION THAT THE NEW ORDERED CONTENT FROM THE INTERNET IS STORED
{
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return [documentsDir stringByAppendingPathComponent:[ChannelManagerJsonFileName stringByAppendingPathExtension:@"json"]];
}

-(NSString *)bundlePath // LOCATION OF THE OREDERED CONTENT THAT IS SHIPPED WITH THE APP
{
    return [[NSBundle mainBundle] pathForResource:ChannelManagerJsonFileName ofType:@"json"];
}


/**
    Determines if new information is avaliable , if it is then returns TRUE
    Reads the files , Looks @ their dates and if data is older than a CHANNEL_CHACHE_TIME invertal , then it returns true
 */
-(BOOL)needsLoad
{
    if (![super needsLoad]) return NO;
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self documentPath] error:nil];
    NSDate *date = [attributes fileModificationDate];
    if (!date) return YES;
    
    return ([date compare:[NSDate dateWithTimeIntervalSinceNow:-CHANNEL_CACHE_TIME]] == NSOrderedAscending);  // The data is updated within a certain time interval .
}

/*
    Loads the data from the interet servers : 
    The data is the ordered content :: 
        This data is also written to the disk in the setter of the content channels
    Used in the creation of contentChannels
 */
-(void)load
{
    [self willBeginLoad];
    [
         [RUNetworkManager sessionManager] GET:[ChannelManagerJsonFileName stringByAppendingPathExtension:@"json"] parameters:nil
     
        success:
         ^(NSURLSessionDataTask *task, id responseObject) // pass in a block for success
        {
            if ([responseObject isKindOfClass:[NSArray class]])
            {
                
                self.contentChannels = responseObject; // change the content channel with new information from the internet ::
                /*
                        What happenns if there are some changes , are they immediately applied , will the app crash because of this ?
                 
                      */
                
                [self didEndLoad:YES withError:nil];
            }
            else
            {
                [self didEndLoad:NO withError:nil];
            }
        }
         
        failure:
         ^(NSURLSessionDataTask *task, NSError *error)
        {
            NSLog(@"ERROR: %@:",error);
            [self didEndLoad:NO withError:error];
        }
   ];
}


/*
    Uses the ViewTagstToClassNa..Map.. to find the string from the view controller and NSClassFromStr.. to obtain the actual Class / VIew Controller
 
    This functiuon is very important as is it used to mapp from the view tag in the channel , to the view controller that is used to display the data pertaining to the channel
 
 */
-(Class)classForViewTag:(NSString *)viewTag
{
    NSString *className = [self viewTagsToClassNameMapping][viewTag];
   
    if(className) // if the a class does not exist for the view tag , we turn nil and an error alert will the shown
    {
        return NSClassFromString(className);
    }
    else
    {
        return nil;
    }
    
}

/*
    The Tagging is done between a keyword and the name of the view controller ::
    eg : tag : bus
        className : RUBusViewController
 
    the keyword is obtained from the view feild in the channel obtained from the ordered content file :: 
    We predefine which view controller is used to  display a particular data  in this view tag ::
 
    Find :
        How is this populated ? 
            >> This is populated when each class calls the register class function just below
 */
-(NSMutableDictionary *)viewTagsToClassNameMapping
{
    static NSMutableDictionary *viewTagsToClassNameMapping = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once( // just done once
    &onceToken,
        ^{
            viewTagsToClassNameMapping = [NSMutableDictionary dictionary];
        }
    );
    return viewTagsToClassNameMapping;
}


/*
 
    This function allows the mapping between the view feild in the channel from ordered content and its view controller :: 
 
    There are two parts to this working properly : 
    Each view controller has a channelHandle function which maps a view to the view controller ::  A class having  channelHandle function is one of the conditions of conforming to a protocol
    This view and view controller mapping is added to the viewTagsToClassNameMapping Dictionary : where the the view tag is the key and the object is the string name of the class

    Now the handle from the ordered content is used as a key to the dict and the correponsing view controller is obatained
 
 */
-(void)registerClass:(Class)class // This FUNCTION IS CALLED BY ALL VIEW CONTROLLERS FOR MAPPIGN BETWEEN A VIEW AND THE VIEW CONTGROLE R
{
    if (![class conformsToProtocol:@protocol(RUChannelProtocol)])
    {
        NSLog(@"Trying to register class with channel manager that does not conform to RUChannelProtocol");
        return;
    }
    
    NSString *handle = [class performSelector:@selector(channelHandle)];  //
    self.viewTagsToClassNameMapping[handle] = NSStringFromClass(class);  // use ios to convert actual class into a class name stirng
}


/*
    Creates the View Controller For the seperate channels ..
    Called by differnt channels to create the seperate view controllers ...
 
    This is called both in the intiall call while moving from the side bar to the seperate view controllers
    and also within a specific view controller , while moving to the next view controller eg : Scart.. Kni.. to Athel... Schedu... 
 
    What is the information stored in the channel ? 
    Eg : Specific Movement from ScaletKnight to Athele. Schedu. 
 
        What is being done is pretty Cool :     
            Rutgers does not seem to have a specific shedule , so Kyle is obtaining data from mulitple websites and combining them somehow ? 
 
    <q> Channel : 
            How is the channel created and set up ?
                > It seems to be created when a user touches an item on the table view ,  by the concrete class supporting the
                   Data Source class.
 */
-(UIViewController <RUChannelProtocol>*)viewControllerForChannel:(NSDictionary *)channel
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
        ^{
            [[RUAnalyticsManager sharedManager] queueEventForChannelOpen:channel];   // used for sending usage reports to the rutgers server
         }
    );
    
    // Obtains the Identifier for the next VC from the channel and then uses it to create / bind the VC for the channel
    NSString *view = channel[@"view"];
    // based on the view feild in the channel dict we decide which view controller to show for the data
    
    
    if (!view) view = [self defaultViewForChannel:channel]; // the default for each channel is the dynamic table view contorller or called a dtable
                                                            // If the channel is for faq , then a differnt view is used.
    

    Class class = [self classForViewTag:view]; // uses the class view mapping stored in the viewTagsToClassNameMapping dict to obtain the class used for displaying the view
    
    NSLog(@"%@",class);
    
    if (![class conformsToProtocol:@protocol(RUChannelProtocol)]) [NSException raise:@"Invalid View" format:@"No way to handle view type %@",view]; // all the view controller used to display the channel conforsm to RUChannelProtocol
    
       /*
                channelWithConfig is implemented by the view controller conforming to the protocol
        */
    UIViewController <RUChannelProtocol>*vc = [class channelWithConfiguration:channel];
    
    vc.title = [channel channelTitle];  // channelTitile is implemnted as a category on the channel (NSDictionary)
    NSLog(@"class : %@", vc);
    return vc;
}

/*
    Converts the URL into a view controller 
 
 */
-(NSArray *)viewControllersForURL:(NSURL *)url destinationTitle:(NSString *)destinationTitle
{
    NSMutableArray *components = [NSMutableArray array];
    NSString *urlString = [url.absoluteString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    /*
      eg :
     converts rutgers://knights/news/baseball/
     into rutgers knighits news baseball
     */
    for (NSString *component in urlString.pathComponents) {
        NSString *normalizedComponent = [component rutgersStringEscape];
        [components addObject:normalizedComponent];
    }
  //  [components removeObjectAtIndex:0]; // remove the http part
   // [components removeObjectAtIndex:0]; // remove the rumobile.rutgers.edu link
    [components removeObjectAtIndex:0]; // remove the link part
    
    NSString *handle = components.firstObject;
    [components removeObjectAtIndex:0];
    
    NSString *viewTag = [[self channelWithHandle:handle] channelView];
    id class = [self classForViewTag:viewTag];
   
   
    // if a wrong url comes along , we show the splash screen
    if(class == nil)
    {
        return @[[[RUSplashViewController alloc] initWithWrongUrl]];
    }
    
    // Check if the channel handles opening favorites itself, or defers to the channnel manager
    if ([class respondsToSelector:@selector(viewControllersWithPathComponents:destinationTitle:)]) {
            // If this part of the code is called , then things work
        
        return [class performSelector:@selector(viewControllersWithPathComponents:destinationTitle:) withObject:components withObject:destinationTitle];
    }
    else
    {
        
        NSLog(@"error in VCForUrl");
            // If this part of the code is called , then it ends in error
        return @[[[RUFavoritesDynamicHandoffViewController alloc] initWithHandle:handle pathComponents:components title:destinationTitle]];
    }
    

}

/*
 
    Descript:
        Used when moving from a VC to the next section within the VC. Eg : While moving from Scarl... Kni.. to Athe.. Sche..
 
    FIND
        Why is the channel NSDict ? -> A Dict is used to store the values describing the channel.
            Different keys like handle : ??
                                view : Name of VC
 icon : icon ??
 title : Name fo title
 
 
 */
-(NSString *)defaultViewForChannel:(NSDictionary *)channel
{
    NSArray *children = channel[@"children"];
    for (NSDictionary *child in children)
    {
        if (child[@"answer"]) return @"faqview";  // Why this specific case ? Why is faqview different ?
    }
    return @"dtable"; // This is the reply , the name of the view in the channel while a view contrller move to the next section in the table UITableView
    // dtable seems to be used for any generic movement from a TVC (Table Vie. Con. ) to one of the sections in it.
}


/*
    Keep track of the channel that has been last used :: For use by the root View Controller ????
 */
static NSString *const ChannelManagerLastChannelKey = @"ChannelManagerLastChannelKey";



/*
    Returns the splash screen ( rutgers logo ) when the app is being started for the first time , else gives the last opened view
    The view is stored in the NSUSER DEFAULTS
 */
-(NSDictionary *)lastChannel
{
            // Obtain the last channel that was used by the user from the user defaulsts database and use it to start the app at a particular view
    NSDictionary *lastChannel = [[NSUserDefaults standardUserDefaults] dictionaryForKey:ChannelManagerLastChannelKey];
    if (![self.contentChannels containsObject:lastChannel]) lastChannel = nil;
    if (!lastChannel) lastChannel = @{@"view" : @"splash", @"title" : @"Welcome!"};
    return lastChannel;
}

// Set the last channel that has been opened.
-(void)setLastChannel:(NSDictionary *)lastChannel
{
    if ([self.contentChannels containsObject:lastChannel])
    {
        [[NSUserDefaults standardUserDefaults] setObject:lastChannel forKey:ChannelManagerLastChannelKey];
    }
}

@end
