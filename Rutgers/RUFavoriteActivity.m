//
//  RUFavoriteActivity.m
//  Rutgers
//
//  Created by Open Systems Solutions on 1/14/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import "RUFavoriteActivity.h"
#import "RUUserInfoManager.h"
#import "RUFavorite.h"

@interface RUFavoriteActivity ()
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *handle;
@property (nonatomic) NSURL *urlToFavorite;
@end

@implementation RUFavoriteActivity
-(instancetype)initWithTitle:(NSString *)title handle:(NSString *)handle{
    self = [super init];
    if (self) {
        self.title = title;
        self.handle = handle;
    }
    return self;
}

- (nullable NSString *)activityTitle {
    return @"Favorite";
}

- (nullable UIImage *)activityImage {
    return [UIImage imageNamed:@"athletics-filled"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    if (activityItems.count != 1) return NO;
    if (![activityItems.firstObject isKindOfClass:[NSURL class]]) return NO;
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    self.urlToFavorite = activityItems.firstObject;
}

- (void)performActivity {
    RUFavorite *favorite = [[RUFavorite alloc] initWithTitle:self.title handle:self.handle url:self.urlToFavorite];
    [RUUserInfoManager addFavorite:favorite];
    [self activityDidFinish:YES];
}

@end
