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

/*
 Descript : 
    Add the favouties item to the slide view controller
 
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
    return [UIImage imageNamed:@"athletics-filled"]; // <q> why is it specific to athletics filled ?
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
- (void)performActivity {
    NSLog(@"Fav : url %@ -> title %@", self.urlToFavorite.absoluteString , self.title);
    NSDictionary *favorite = @{
                               //@"isFavorite" : @true,
                               @"url" : self.urlToFavorite.absoluteString,
                               @"title" : self.title
                               };
    NSLog(@"Favoriting URL: %@",self.urlToFavorite);
    [RUUserInfoManager addFavorite:favorite]; // sets up the favourite
    [self activityDidFinish:YES]; // calls func of UIActivity
}

@end
