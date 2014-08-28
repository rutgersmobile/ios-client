//
//  EZCollectionViewCell.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TileCollectionViewCell : UICollectionViewCell
@property (nonatomic) UILabel *textLabel;
@property (nonatomic) BOOL showsEllipses;
-(void)updateFonts;
@end
