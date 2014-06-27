//
//  RUTabBarController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/26/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUTabBarController.h"

@interface RUTabBarController () <UIGestureRecognizerDelegate>
@property (nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) CGFloat currentTabBarOffset;
@end

@implementation RUTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    self.panGestureRecognizer.delegate = self;
   // [self.view addGestureRecognizer:self.panGestureRecognizer];
}

-(void)setTabBarOffset:(CGFloat)offset{
    [self incrementTabBarOffset:(offset - self.currentTabBarOffset)];
}
-(void)incrementTabBarOffset:(CGFloat)offset{
    CGRect frame = self.tabBar.frame;
    frame.origin.y += offset;
    self.currentTabBarOffset += offset;
    self.tabBar.frame = frame;
}

-(void)pan:(UIPanGestureRecognizer *)panGestureRecognizer{
    [self incrementTabBarOffset:-[panGestureRecognizer translationInView:self.view].y];
    [panGestureRecognizer setTranslation:CGPointZero inView:self.view];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
   return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
