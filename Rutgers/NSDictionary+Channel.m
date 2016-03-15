//
//  NSDictionary+Channel.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUUserInfoManager.h"
#import "NSDictionary+Channel.h"

@implementation NSDictionary (Channel)

-(NSString *)channelTitle{
    id title = self[@"title"];
    if ([title isKindOfClass:[NSString class]]) {
        return title = title;
    } else if ([title isKindOfClass:[NSDictionary class]]) {
        NSString *campus = title[@"homeCampus"];
        if ([campus isEqualToString:[RUUserInfoManager currentCampus][@"title"]]) {
            return title[@"homeTitle"];
        } else {
            return title[@"foreignTitle"];
        }
    }
    return nil;
}

-(NSCache *)channelIconCache{
    static NSCache *channelIconCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        channelIconCache = [[NSCache alloc] init];
    });
    return channelIconCache;
}

-(UIImage *)cachedImageWithName:(NSString *)name{
    UIImage *image = [[self channelIconCache] objectForKey:name];
    if (!image) {
        image = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [[self channelIconCache] setObject:image forKey:name];
    }
    return image;
}

-(UIImage *)channelIcon{
    NSString *iconName = self[@"icon"];
    if (!iconName) return nil;
    
    return [self cachedImageWithName:iconName];
}

-(UIImage *)filledChannelIcon{
    NSString *iconName = [self[@"icon"] stringByAppendingString:@"-filled"];
    if (!iconName) return nil;
    
    UIImage *image = [self cachedImageWithName:iconName];
    if (image) return image;
    return [self channelIcon];
}

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
