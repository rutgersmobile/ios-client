//
//  RUFavoriteActivity.m
//  Rutgers
//
//  Created by Open Systems Solutions on 1/14/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import "RUFavoriteActivity.h"
#import "RUUserInfoManager.h"
#import "RUChannelManager.h"
#import "Rutgers-Swift.h"
/*
 Descript : 
 
 */

@interface RUFavoriteActivity ()
@property (nonatomic) NSString *title;
@property (nonatomic) NSURL *urlToFavorite;
@end

@implementation RUFavoriteActivity
-(instancetype)initWithTitle:(NSString *)title{
    self = [super init];
    if (self) {
        self.title = title;
    }
    return self;
}

- (nullable NSString *)activityTitle {
    return @"Favorite";
}

- (nullable UIImage *)activityImage {
    return [UIImage imageNamed:@"athletics-filled"]; //  The icons for the favourites is the 
}

/*
    Decides whether to perform the activity of not
    
    Override of UIActivity class function
 */
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    if (activityItems.count != 1) return NO;
    if (![activityItems.firstObject isKindOfClass:[NSURL class]]) return NO;
    return YES;
}

/*
 prepares to add favourtie item
 */
- (void)prepareWithActivityItems:(NSArray *)activityItems {
    self.urlToFavorite = activityItems.firstObject; // <q>
}


/*
    Add the favourite to RUUserInfoMan...

 
 
 */
- (void)performActivity
{
    
    RUFavorite *favorite = [[RUFavorite alloc] initWithTitle:self.title url:[self.urlToFavorite asRutgersURL]]; // we convert between the url used for https sending and the internal url used for storing the favourties.. 
    [[RUMenuItemManager sharedManager] addFavorite:favorite]; 

    [self activityDidFinish:YES];
}

@end
