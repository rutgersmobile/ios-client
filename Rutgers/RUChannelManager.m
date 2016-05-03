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
        The Other Class register with this class
 
 
 */
#import "NSDictionary+Channel.h"
#import "RUDataLoadingManager_Private.h"
#import "RUNetworkManager.h"
#import "RUChannelManager.h"
#import "RUChannelProtocol.h"
#import "RUAnalyticsManager.h"
#import "NSURL+RUAdditions.h"
#import "RUFavoritesDynamicHandoffViewController.h"

NSString *const ChannelManagerJsonFileName = @"ordered_content";
NSString *const ChannelManagerDidUpdateChannelsKey = @"ChannelManagerDidUpdateChannelsKey";

#define CHANNEL_CACHE_TIME 60*60*24*1

@interface RUChannelManager ()
@property dispatch_group_t loadingGroup;

@property BOOL loading;
@property BOOL finishedLoading;
@property NSError *loadingError;
@end

@implementation RUChannelManager

/*
    
    Find : 
        What does the shared signify ?
 
 
 */
+(RUChannelManager *)sharedInstance{
    static RUChannelManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RUChannelManager alloc] init];
    });
    return manager;
}

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
/*
  Extracts files from path and takes tye latest files and creates Json Objects out of them 
  Thread safe : 
 
@result : array containing json objects
 
 
 */
@synthesize contentChannels = _contentChannels;
-(NSArray *)contentChannels{
    @synchronized(self) {
        if (!_contentChannels) {
            NSDate *latestDate;
            NSArray *paths = @[[self documentPath],[self bundlePath]];
            
            for (NSString *path in paths) {
                NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
                NSDate *date = [attributes fileModificationDate];
                
                if (!latestDate || [date compare:latestDate] == NSOrderedDescending) {
                    NSData *data = [NSData dataWithContentsOfFile:path];
                    if (data) {
                        NSArray *channels = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        if (channels.count) {
                            latestDate = date;
                            _contentChannels = channels;
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

-(BOOL)needsLoad{
    if (![super needsLoad]) return NO;
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self documentPath] error:nil];
    NSDate *date = [attributes fileModificationDate];
    if (!date) return YES;
    
    return ([date compare:[NSDate dateWithTimeIntervalSinceNow:-CHANNEL_CACHE_TIME]] == NSOrderedAscending);
}

-(void)load{
    [self willBeginLoad];
    [[RUNetworkManager sessionManager] GET:[ChannelManagerJsonFileName stringByAppendingPathExtension:@"json"] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            self.contentChannels = responseObject;
            [self didEndLoad:YES withError:nil];
        } else {
            [self didEndLoad:NO withError:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self didEndLoad:NO withError:error];
    }];
}


/*
    Usees the ViewTagstToClassNa..Map.. to find the string from the view controller and NSClassFromStr.. to obtain the actual Class / VIew Controller
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
    NSString *handle = [class performSelector:@selector(channelHandle)];  // call channelHandle to obtain the class name
    [self viewTagsToClassNameMapping][handle] = NSStringFromClass(class);  // use ios to convert class name into an acutal class instance
}

/*
    Creates the View Controller For the seperate channels ..
    Called by differnt channels to create the seperate view controllers ...
 */
-(UIViewController <RUChannelProtocol>*)viewControllerForChannel:(NSDictionary *)channel{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[RUAnalyticsManager sharedManager] queueEventForChannelOpen:channel];
    });
    
    // Obtains the Identifier for the Current VC from the channel and then uses it to create the view controller for the channel
    NSString *view = channel[@"view"];
    if (!view) view = [self defaultViewForChannel:channel];
    Class class = [self classForViewTag:view];
    
    if (![class conformsToProtocol:@protocol(RUChannelProtocol)]) [NSException raise:@"Invalid View" format:@"No way to handle view type %@",view];
    
    // Sets the required property for the particular View Controller. Since they are all initialized in a generic manner , this step adds additional configurations
    UIViewController <RUChannelProtocol>*vc = [class channelWithConfiguration:channel];
    vc.title = [channel channelTitle];  // VC obtains the title from the Generic channel
    return vc;
}

-(NSArray *)viewControllersForURL:(NSURL *)url destinationTitle:(NSString *)destinationTitle{
    NSMutableArray *components = [NSMutableArray array];
    NSString *urlString = [url.absoluteString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    for (NSString *component in urlString.pathComponents) {
        NSString *normalizedComponent = [component rutgersStringEscape];
        [components addObject:normalizedComponent];
    }
    [components removeObjectAtIndex:0];
   
    NSString *handle = components.firstObject;
    [components removeObjectAtIndex:0];
    
    NSString *viewTag = [[self channelWithHandle:handle] channelView];
    id class = [self classForViewTag:viewTag];
    
    if ([class respondsToSelector:@selector(viewControllersWithPathComponents:destinationTitle:)]) {
        return [class performSelector:@selector(viewControllersWithPathComponents:destinationTitle:) withObject:components withObject:destinationTitle];
    } else {
        return @[[[RUFavoritesDynamicHandoffViewController alloc] initWithHandle:handle pathComponents:components title:destinationTitle]];
    }
}

/*
 
    Descript:
 
    FIND
        Why is the channel NSDict ?
 
 */
-(NSString *)defaultViewForChannel:(NSDictionary *)channel{
    NSArray *children = channel[@"children"];
    for (NSDictionary *child in children) {
        if (child[@"answer"]) return @"faqview";
    }
    return @"dtable";
}


/*
    Keep track of the channel that has been last used :: For use by the root View Controller ????
 */
static NSString *const ChannelManagerLastChannelKey = @"ChannelManagerLastChannelKey";

-(NSDictionary *)lastChannel{
    
            // Obtain the last channel that was used by the user from the user defaulsts database and use it to start the app at a particular view
    NSDictionary *lastChannel = [[NSUserDefaults standardUserDefaults] dictionaryForKey:ChannelManagerLastChannelKey];
    if (![self.contentChannels containsObject:lastChannel]) lastChannel = nil;
    if (!lastChannel) lastChannel = @{@"view" : @"splash", @"title" : @"Welcome!"};
    return lastChannel;
}

-(void)setLastChannel:(NSDictionary *)lastChannel{
    if ([self.contentChannels containsObject:lastChannel]) {
        [[NSUserDefaults standardUserDefaults] setObject:lastChannel forKey:ChannelManagerLastChannelKey];
    }
}
@end
