//
//  NSDictionary+Channel.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUUserInfoManager.h"

@implementation NSDictionary (Channel)

-(NSString *)channelTitle{
    id title = self[@"title"];
    if ([title isKindOfClass:[NSString class]]) {
        return title = title;
    } else if ([title isKindOfClass:[NSDictionary class]]) {
        NSString *campus = title[@"homeCampus"];
        if ([campus isEqualToString:[RUUserInfoManager sharedInstance].campus[@"title"]]) {
            return title[@"homeTitle"];
        } else {
            return title[@"foreignTitle"];
        }
    }
    return nil;
}

-(UIImage *)channelIcon{
    NSString *iconName = self[@"icon"];
    UIImage *image = [[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return image;
}

-(NSString *)channelHandle{
    return self[@"handle"];
}

-(NSString *)channelURL{
    return self[@"url"];
}

-(NSString *)channelView{
    return self[@"view"];
}
@end
