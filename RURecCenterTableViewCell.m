//
//  RURecCenterTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURecCenterTableViewCell.h"

@implementation RURecCenterTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeGestureRecognizers];
    }
    return self;
}

-(void)initializeGestureRecognizers{
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goRight:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goLeft:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self addGestureRecognizer:leftSwipe];
    [self addGestureRecognizer:rightSwipe];
}

- (IBAction)goLeft:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RecCenterHeaderLeft" object:nil];
}

- (IBAction)goRight:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RecCenterHeaderRight" object:nil];
}


@end
