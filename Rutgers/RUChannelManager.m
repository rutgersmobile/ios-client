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

NSString *const ChannelManagerJsonFileName = @"ordered_content"; // Json file used in the creation of the different channels
NSString *const ChannelManagerDidUpdateChannelsKey = @"ChannelManagerDidUpdateChannelsKey";

/*
    Update the number of channels and colletevery day ?
 
 */
#define CHANNEL_CACHE_TIME 60*60*24*1

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
+(RUChannelManager *)sharedInstance{
    static RUChannelManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
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
                
                if (!latestDate || [date compare:latestDate] == NSOrderedDescending)
                {  // If the latest date has not been set or if the date
                    NSData *data = [NSData dataWithContentsOfFile:path];
                    if (data)
                    {
                        NSArray *channels = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        if (channels.count)
                        {
                            latestDate = date;
                            _contentChannels = channels;  // So we create channel from files converted into JSonn Objects ?
                        }
                    }
                }
            }
        
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            if ([self needsLoad]) {
                [self load];
            }
        });
        return _contentChannels;
    }
}

/*
  Find a paritcular data in either the content channels or the other channels
 
 @return NSDict : of Data ?
 */
-(NSDictionary *)channelWithHandle:(NSString *)handle{
    for (NSDictionary *channel in self.contentChannels) {
        if ([[channel channelHandle] isEqualToString:handle]) {
            return channel;
        }
    }
    for (NSDictionary *channel in self.otherChannels) {
        if ([[channel channelHandle] isEqualToString:handle]) {
            return channel;
        }
    }
    return nil;
}



-(void)setContentChannels:(NSArray *)allChannels{
    if (!allChannels.count) return;
    
    @synchronized(self) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:allChannels options:0 error:nil];
        if (data) [data writeToFile:[self documentPath] atomically:YES];
        
        if ([_contentChannels isEqual:allChannels]) return;
        
        _contentChannels = allChannels;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ChannelManagerDidUpdateChannelsKey object:self];
        });
    }
}

#pragma mark Channel manager loading
-(NSString *)documentPath{
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return [documentsDir stringByAppendingPathComponent:[ChannelManagerJsonFileName stringByAppendingPathExtension:@"json"]];
}

-(NSString *)bundlePath{
    return [[NSBundle mainBundle] pathForResource:ChannelManagerJsonFileName ofType:@"json"];
}


/**
    Determines if new information is avaliable , if it is then returns TRUE
    Reads the files , Looks @ their dates and if data is older than a CHANNEL_CHACHE_TIME invertal , then a needsLoad occurs.
 */
-(BOOL)needsLoad{
    if (![super needsLoad]) return NO;
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self documentPath] error:nil];
    NSDate *date = [attributes fileModificationDate];
    if (!date) return YES;
    
    return ([date compare:[NSDate dateWithTimeIntervalSinceNow:-CHANNEL_CACHE_TIME]] == NSOrderedAscending);  // The data is updated within a certain time interval .
}

/*
    Loads the data when it needsLoad calls True
    Used in the creation of contentChannels
 */
-(void)load{
    [self willBeginLoad];
    [[RUNetworkManager sessionManager] GET:[ChannelManagerJsonFileName stringByAppendingPathExtension:@"json"] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {   // ????? How is the usl determined ?
        if ([responseObject isKindOfClass:[NSArray class]]) {
            self.contentChannels = responseObject;  // Sets the contentChannel to the be response array.
            [self didEndLoad:YES withError:nil];
        } else {
            [self didEndLoad:NO withError:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self didEndLoad:NO withError:error];
    }];
}


/*
    Uses the ViewTagstToClassNa..Map.. to find the string from the view controller and NSClassFromStr.. to obtain the actual Class / VIew Controller
    Handled by iOS. The ViewContr.. has to be loaded before use..
 
 */
-(Class)classForViewTag:(NSString *)viewTag{
    NSString *className = [self viewTagsToClassNameMapping][viewTag];
    return NSClassFromString(className);
}


/*
    Descript  : 
 
    Each View Controller Has a tag and this tag is used and  filled in the viewTags... dictionary.
    
    The Tagging is done between a keyword and the name of the view controller :: 
    eg : tag : bus
        className : RUBusViewController
 
    Find :
        How is this populated
 */
-(NSMutableDictionary *)viewTagsToClassNameMapping{
    static NSMutableDictionary *viewTagsToClassNameMapping = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        viewTagsToClassNameMapping = [NSMutableDictionary dictionary];
    });
    return viewTagsToClassNameMapping;
}


/*
    Descript : 
            Different Views / CLasses like "options , ruifo " loads and registers with this class
 
 */
-(void)registerClass:(Class)class{
    if (![class conformsToProtocol:@protocol(RUChannelProtocol)]) {
        NSLog(@"Trying to register class with channel manager that does not conform to RUChannelProtocol");
        return;
    }
    NSString *handle = [class performSelector:@selector(channelHandle)];  // call channelHandle to obtain the handle name
    self.viewTagsToClassNameMapping[handle] = NSStringFromClass(class);  // use ios to convert actual class into a class name
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
-(UIViewController <RUChannelProtocol>*)viewControllerForChannel:(NSDictionary *)channel{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[RUAnalyticsManager sharedManager] queueEventForChannelOpen:channel];   // Stores each event , Why ?
    });
    
    // Obtains the Identifier for the next VC from the channel and then uses it to create / bind the VC for the channel
    NSString *view = channel[@"view"];
    if (!view) view = [self defaultViewForChannel:channel]; // Different Classes create different kinds of channel
    Class class = [self classForViewTag:view];  // apple funcs which enable us to obtain a VC from the name used to represent it.
    
    if (![class conformsToProtocol:@protocol(RUChannelProtocol)]) [NSException raise:@"Invalid View" format:@"No way to handle view type %@",view];
    
    // Sets the required property for the particular View Controller. Since they are all initialized in a generic manner , this step adds additional configurations
    // Like Coolors, the # sections in the table view etc.
    UIViewController <RUChannelProtocol>*vc = [class channelWithConfiguration:channel];
    vc.title = [channel channelTitle];  // VC obtains the title from the Generic channel
    return vc;
}

/*
 
trollersForURL
 
 */
-(NSArray *)viewControllersForURL:(NSURL *)url destinationTitle:(NSString *)destinationTitle{
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
    [components removeObjectAtIndex:0]; // remove the rutgers part
   
    NSString *handle = components.firstObject;
    [components removeObjectAtIndex:0];
    
    NSString *viewTag = [[self channelWithHandle:handle] channelView];
    id class = [self classForViewTag:viewTag];
   
    // Check if the channel handles opening favorites itself, or defers to the channnel manager
    if ([class respondsToSelector:@selector(viewControllersWithPathComponents:destinationTitle:)]) {
            // If this part of the code is called , then things work
        
        return [class performSelector:@selector(viewControllersWithPathComponents:destinationTitle:) withObject:components withObject:destinationTitle];
    }
    else {
        
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
-(NSString *)defaultViewForChannel:(NSDictionary *)channel{
    NSArray *children = channel[@"children"];
    for (NSDictionary *child in children) {
        if (child[@"answer"]) return @"faqview";  // Why this specific case ? Why is faqview different ?
    }
    return @"dtable"; // This is the reply , the name of the view in the channel while a view contrller move to the next section in the table UITableView
    // dtable seems to be used for any generic movement from a TVC (Table Vie. Con. ) to one of the sections in it.
}


/*
    Keep track of the channel that has been last used :: For use by the root View Controller ????
 */
static NSString *const ChannelManagerLastChannelKey = @"ChannelManagerLastChannelKey";

-(NSDictionary *)lastChannel{
    
            // Obtain the last channel that was used by the user from the user defaulsts database and use it to start the app at a particular view
    NSDictionary *lastChannel = [[NSUserDefaults standardUserDefaults] dictionaryForKey:ChannelManagerLastChannelKey];
    if (![self.contentChannels containsObject:lastChannel]) lastChannel = nil;
    if (!lastChannel) lastChannel = @{@"view" : @"splash", @"title" : @"Welcome!"};  // What is splash and Welcome ?
    return lastChannel;
}

// Set the last channel that has been opened.
-(void)setLastChannel:(NSDictionary *)lastChannel{
    if ([self.contentChannels containsObject:lastChannel]) {
        [[NSUserDefaults standardUserDefaults] setObject:lastChannel forKey:ChannelManagerLastChannelKey];
    }
}
@end
