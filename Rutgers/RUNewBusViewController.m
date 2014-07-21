//
//  RUNewBusViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUNewBusViewController.h"

@interface RUNewBusViewController ()
@property (weak, nonatomic) IBOutlet UIView *rightContainerView;

@end

@implementation RUNewBusViewController

+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[UIStoryboard storyboardWithName:@"BusStoryboard" bundle:nil] instantiateInitialViewController];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CALayer *layer = self.rightContainerView.layer;
    layer.shadowRadius = 10;
    layer.shadowOpacity = 0.3;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"leftContainer"]) {
        
    } else if ([segue.identifier isEqualToString:@"rightContainer"]) {
        
    }
    
    
    
}


@end
