//
//  RUSidePanelController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSidePanelController.h"

@interface RUSidePanelController ()

@end

@implementation RUSidePanelController
-(UIBarButtonItem *)leftButtonForCenterPanel{
    return [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(toggleLeftPanel:)];
}
- (void)styleContainer:(UIView *)container animate:(BOOL)animate duration:(NSTimeInterval)duration {
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:container.bounds cornerRadius:0.0f];
    if (animate) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        animation.fromValue = (id)container.layer.shadowPath;
        animation.toValue = (id)shadowPath.CGPath;
        animation.duration = duration;
        [container.layer addAnimation:animation forKey:@"shadowPath"];
    }
    container.layer.shadowPath = shadowPath.CGPath;
    container.layer.shadowColor = [UIColor blackColor].CGColor;
    container.layer.shadowRadius = 8.0f;
    container.layer.shadowOpacity = 0.75f;
    container.clipsToBounds = NO;
}

- (void)stylePanel:(UIView *)panel {
    panel.layer.cornerRadius = 0;
    panel.clipsToBounds = YES;
}

@end
