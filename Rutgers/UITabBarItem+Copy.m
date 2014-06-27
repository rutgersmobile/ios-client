//
//  UITabBarItem+Copy.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "UITabBarItem+Copy.h"

@implementation UITabBarItem (Copy)
-(instancetype)copy{
    UITabBarItem *copy = [[UITabBarItem alloc] init];
    copy.image = self.image;
    copy.selectedImage = self.selectedImage;
    copy.title = self.title;
    return copy;
}
@end
