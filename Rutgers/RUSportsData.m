//
//  RUSportsData.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/9/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSportsData.h"
#import "RUNetworkManager.h"

@implementation RUSportsData
+(NSDictionary *)allSports{
    static NSDictionary *allSpots = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allSpots = @{@"Baseball"                : @"19",
                     @"Basketball - Men"        : @"11",
                     @"Basketball - Women"      : @"12",
                     @"Crew - Women"            : @"24",
                     @"Cross Country"           : @"6",
                     @"Field Hockey"            : @"4",
                     @"Football"                : @"1",
                     @"Golf - Men"              : @"7",
                     @"Golf - Women"            : @"8",
                     @"Gymnastics"              : @"14",
                     @"Lacrosse - Men"          : @"21",
                     @"Lacrosse - Women"        : @"22",
                     @"Soccer - Men"            : @"2",
                     @"Soccer - Women"          : @"3",
                     @"Softball"                : @"20",
                     @"Swimming & Diving"       : @"15",
                     @"Tennis - Women"          : @"10",
                     @"Track & Field - Men"     : @"16",
                     @"Track & Field - Women"   : @"17",
                     @"Volleyball - Women"      : @"5",
                     @"Wrestling"               : @"18"};
    });
    return allSpots;
}
+(void)getRosterForSportID:(NSString *)sportID withSuccess:(void (^)(NSArray *))successBlock failure:(void (^)(void))failureBlock{
    [[RUNetworkManager xmlSessionManager] GET:@"http://scarletknights.com/rss/mobile/feed-roster.asp" parameters:@{@"sportid" : sportID} success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock(responseObject[@"row"]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failureBlock();
    }];
}
@end
