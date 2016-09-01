//
//  NSDictionary+Channel.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUUserInfoManager.h"
#import "NSDictionary+Channel.h"

/*
    This class add aditional functions to channels
    <q> Where is channel defined and created ?
 */


@implementation NSDictionary (Channel)

-(NSString *)channelTitle
{
    id title = self[@"title"];
    if ([title isKindOfClass:[NSString class]])
    {
        return title = title;
    }
    else if ([title isKindOfClass:[NSDictionary class]])
    {
        NSString *campus = title[@"homeCampus"];
        /*
            Based on the campus title , the schools will be different and the campus will be foreign or home based on the 
            campus choosen
         */
        if ([campus isEqualToString:[RUUserInfoManager currentCampus][@"title"]])
        {
            return title[@"homeTitle"];
        }
        else
        {
            return title[@"foreignTitle"];
        }
    }
    return nil;
}

/*
    Create a cache to store the items in
 
 */
-(NSCache *)channelIconCache{
    static NSCache *channelIconCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        channelIconCache = [[NSCache alloc] init];  // create the cache
    });
    return channelIconCache;
}

/*
    store the images in the chache so that they do not have to be loaded again
 
 */
-(UIImage *)cachedImageWithName:(NSString *)name
{
    UIImage *image = [[self channelIconCache] objectForKey:name];
    if (!image)
    {
        image = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        if(!image) // If the proper image is not found, then fall back on a default image
        {
            image = [[UIImage imageNamed:@"no-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        
        [[self channelIconCache] setObject:image forKey:name];
    }
    return image;
}

/*
    obtain the icon for the channel
 */
-(UIImage *)channelIcon{
    NSString *iconName = self[@"icon"];
    if (!iconName) return nil;
    
    return [self cachedImageWithName:iconName];
}

/*
    different types of icon  "filled" they are loaded . 
    May be used by the favourites
 */
-(UIImage *)filledChannelIcon{
    NSString *iconName = [self[@"icon"] stringByAppendingString:@"-filled"];
    if (!iconName) return nil;
    
    UIImage *image = [self cachedImageWithName:iconName];
    if (image) return image;
    return [self channelIcon];
}

/* 
 Obtain the various components of the channel
 */

-(NSString *)channelHandle{
    return self[@"handle"];
}

-(NSString *)channelURL{
    return self[@"api"] ? self[@"api"] : self[@"url"];
}

-(NSString *)channelView{
    return self[@"view"];
}

-(BOOL)channelIsWebLink{
    return self[@"url"] ? YES : NO;
}

@end
