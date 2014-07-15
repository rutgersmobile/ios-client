//
//  NSDictionary+Channel.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NSDictionary+Channel.h"
#import "RUUserInfoManager.h"

@implementation NSDictionary (Channel)
-(NSString *)identifierForChannel{
    return self[@"handle"];
}
-(NSString *)titleForChannel{
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

-(UIImage *)iconForChannel{
    NSString *iconName = self[@"icon"];
    UIImage *image = [[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return image;
}

-(NSString *)handle{
    return self[@"handle"];
}
@end
