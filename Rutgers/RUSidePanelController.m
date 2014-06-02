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
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.leftFixedWidth = 280;
        self.shouldResizeLeftPanel = YES;
        self.allowLeftOverpan = NO;
        self.allowRightOverpan = NO;
    }
    return self;
}

-(UIBarButtonItem *)leftButtonForCenterPanel{
    return [[UIBarButtonItem alloc] initWithTitle:@"Channels" style:UIBarButtonItemStylePlain target:self action:@selector(toggleLeftPanel:)];
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
    container.layer.shadowRadius = 5.0f;
    container.layer.shadowOpacity = 0.65f;
    container.clipsToBounds = NO;
}

- (void)stylePanel:(UIView *)panel {
    panel.layer.cornerRadius = 0;
    panel.clipsToBounds = YES;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    BOOL shouldBegin = [super gestureRecognizerShouldBegin:gestureRecognizer];
    if (shouldBegin && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    }
    return shouldBegin;
}
@end
